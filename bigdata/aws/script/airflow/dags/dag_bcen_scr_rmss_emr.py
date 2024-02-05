import os
import re

from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.hooks.S3_hook import S3Hook
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import BranchPythonOperator, PythonOperator
from airflow.providers.amazon.aws.operators.athena import AWSAthenaOperator
from airflow.providers.amazon.aws.sensors.emr_step import EmrStepSensor

import utils_bigdata.emrUtils as emrUtils

dict_execute_step = {
    'spark_remessa': 'step/step_bcen_scr_rmss.yaml',
}

default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
    'depends_on_past': False
}

env = os.environ['AIRFLOW__CUSTOM__ENVIRONMENT']
bucket_logs = 'lakehouse-logs-spc-' + env
bucket_landing = 'lakehouse-landing-zone-spc-' + env
file_prefix = 'xml/cadpos/bcen/scr/rcmt/'
hdfs_path = '/storage/xml/cadpos/bcen/scr'
prefix_athena = 'ATHENA_TEMP/bcen_scr_rmss_emr/'

athena_query = """
    SELECT files.des_cga
    FROM (
    		SELECT rmss_abto.num_rss,
    			rmss_abto.dat_rss,
    			qtd_arq_esp,
    			qtd
    		FROM (
    				SELECT num_rss,
    					dat_rss
    				FROM db_refined.ctle_crga_bcen
    				WHERE id_pln_exe = 45
    					AND id_etp = 52
    					AND(
    						DATE(dat_fim_prt) = DATE '1970-01-01'
    						OR dat_fim_prt IS NULL
    					)
    				ORDER BY num_rss ASC
    			) rmss_abto
    			LEFT JOIN (
    				SELECT num_rss,
    					dat_rss,
    					cast(substring(des_cga, -6, 2) as INT) as qtd_arq_esp
    				FROM db_refined.ctle_crga_bcen
    				WHERE id_pln_exe = 45
    					AND id_etp = 1
    					AND id_tip_cga = 10
    			) arq_final ON arq_final.num_rss = rmss_abto.num_rss
    			AND arq_final.dat_rss = rmss_abto.dat_rss
    			LEFT JOIN (
    				SELECT num_rss,
    					dat_rss,
    					count(1) as qtd
    				FROM db_refined.ctle_crga_bcen
    				WHERE id_pln_exe = 45
    					AND id_etp = 1
    				group BY num_rss,
    					dat_rss
    			) arq_qtds ON arq_final.num_rss = arq_qtds.num_rss
    			AND arq_final.dat_rss = arq_qtds.dat_rss
    		WHERE qtd = qtd_arq_esp
    	) rmss
    	LEFT JOIN (
    		SELECT *
    		FROM db_refined.ctle_crga_bcen
    		WHERE id_pln_exe = 45
    			AND id_etp = 1
    	) files ON files.num_rss = rmss.num_rss
    	AND files.dat_rss = rmss.dat_rss
    LIMIT 1;
"""


def check_has_file(**context):
    s3_hook = S3Hook(aws_conn_id="aws_default")
    files = s3_hook.list_keys(bucket_name=bucket_logs, prefix=prefix_athena)

    for file in files:
        if file.endswith(".csv"):
            obj = s3_hook.get_key(key=file, bucket_name=bucket_logs)
            value = str(obj.get()['Body'].read())
            pattern = r'(\d{4}-\d{2}-\d{2}/\d+/)'
            result = re.search(pattern, value)

            if result:
                print("Há arquivos para processar.")
                s3_hook.delete_objects(bucket=bucket_logs, keys=files)
                path = f"s3://{bucket_landing}/{file_prefix}{result.group(1)}"
                context['ti'].xcom_push(key='s3_key', value=path)
                return 'yes_has_file'
            else:
                print("Não há arquivos para processar.")
                s3_hook.delete_objects(bucket=bucket_logs, keys=files)
                return 'not_has_file'


with DAG(
        dag_id='bcen_scr_rmss_emr',
        default_args=default_args,
        start_date=days_ago(1),
        schedule_interval=None
) as dag:
    run_athena_query = AWSAthenaOperator(
        task_id='read_ctle_crga',
        query=athena_query,
        output_location=f"s3://{bucket_logs}/{prefix_athena}",
        database='db_refined',
        aws_conn_id="aws_default",
        dag=dag
    )

    check_has_file = BranchPythonOperator(
        task_id='check_has_file',
        python_callable=check_has_file,
        provide_context=True
    )

    not_has_file = DummyOperator(
        task_id='not_has_file'
    )

    yes_has_file = DummyOperator(
        task_id='yes_has_file'
    )

    dist_cp_running_process = emrUtils.EmrAddStepsDistCpOperator(
        task_id="dist_scp_running_process",
        job_flow_id="{{ task_instance.xcom_pull('create_cluster_emr', key='return_value') }}",
        aws_conn_id='aws_default',
        step_name="MoveXMLtoHDFS",
        path_src="{{ task_instance.xcom_pull('check_has_file', key='s3_key') }}",
        path_dest=f"hdfs://{hdfs_path}",
        src_pattern=r".*\.xml$"
    )

    waiting_run_dist_cp = EmrStepSensor(
        task_id="waiting_run_dist_cp",
        job_flow_id="{{ task_instance.xcom_pull('create_cluster_emr', key='return_value') }}",
        step_id="{{ task_instance.xcom_pull(task_ids='dist_scp_running_process', key='return_value') }}",
        aws_conn_id='aws_default'
    )

    create_cluster_emr = emrUtils.create_emr('cluster/cluster_bcen_scr_rmss.yaml')
    task_list = emrUtils.create_steps_emr(dict_execute_step)
    terminate_cluster = emrUtils.terminate_cluster()

run_athena_query >> check_has_file

check_has_file >> yes_has_file >> create_cluster_emr
check_has_file >> not_has_file

create_cluster_emr >> dist_cp_running_process >> waiting_run_dist_cp >> terminate_cluster
dist_cp_running_process >> waiting_run_dist_cp >> task_list[0] >> task_list[1] >> terminate_cluster
