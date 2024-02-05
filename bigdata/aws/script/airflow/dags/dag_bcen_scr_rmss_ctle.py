import os

import pendulum
from airflow import AirflowException
from airflow import DAG
from airflow.hooks.S3_hook import S3Hook
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import BranchPythonOperator
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.providers.amazon.aws.operators.athena import AWSAthenaOperator
from airflow.utils.dates import days_ago

from utils_bigdata.dagRunningOperator import DagRunningOperator

env = os.environ['AIRFLOW__CUSTOM__ENVIRONMENT']
bucket_logs = 'lakehouse-logs-spc-' + env
prefix_athena = 'ATHENA_TEMP/bcen_scr_rmss/'

athena_query = """
    SELECT CASE
		WHEN count(1) > 0 THEN 'true' ELSE 'false'
        END AS has_rmss
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
                        AND NOT exists (
                            SELECT 1
                            FROM db_refined.ctle_crga_bcen
                            WHERE id_pln_exe = 45
                                AND id_etp = 4
                                AND(
                                    DATE(dat_fim_prt) = DATE '1970-01-01' OR dat_fim_prt IS NULL
                                )
                            LIMIT 1
                        )
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
        ) rmss
    WHERE qtd = qtd_arq_esp;
"""


def fnzr_erro():
    raise AirflowException("Error")


def check_has_rmss():
    s3_hook = S3Hook(aws_conn_id="aws_default")
    files = s3_hook.list_keys(bucket_name=bucket_logs, prefix=prefix_athena)

    for file in files:
        if file.endswith(".csv"):
            obj = s3_hook.get_key(key=file, bucket_name=bucket_logs)
            if "true" in str(obj.get()['Body'].read()):
                print("Há remessas para processar.")
                s3_hook.delete_objects(bucket=bucket_logs, keys=files)
                return 'rmss_abto'
            else:
                print("Não há remessas para processar.")
                s3_hook.delete_objects(bucket=bucket_logs, keys=files)
                return 'nao_rmss_abto'


LOCAL_TZ = pendulum.timezone("America/Sao_Paulo")

default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
    'depends_on_past': False,
    'retries': 0
}

with DAG(
        dag_id='bcen_scr_rmss_ctle',
        default_args=default_args,
        schedule_interval=None,
        max_active_runs=1
        # schedule_interval='5 */6 * * *',
        # catchup=False,
        # start_date=days_ago(1),

) as dag:
    bscr_ctle_crga = AWSAthenaOperator(
        task_id='bscr_ctle_crga',
        query=athena_query,
        output_location=f"s3://{bucket_logs}/{prefix_athena}",
        database='db_refined',
        aws_conn_id="aws_default",
        dag=dag
    )

    vrfc_dag_exec = DagRunningOperator(
        task_id='vrfc_dag_exec',
        target_dag_id='bcen_scr_rmss_ctle',
        task_true='exec',
        task_false='nao_exec'
    )

    vrfc_rmss_abto = BranchPythonOperator(
        task_id='vrfc_rmss_abto',
        python_callable=check_has_rmss,
        provide_context=True
    )

    nao_exec = DummyOperator(
        task_id='nao_exec'
    )

    exec = DummyOperator(
        task_id='exec'
    )

    nao_rmss_abto = DummyOperator(
        task_id='nao_rmss_abto'
    )

    rmss_abto = DummyOperator(
        task_id='rmss_abto'
    )

    exec_dag_emr = TriggerDagRunOperator(
        task_id='exec_dag_emr',
        trigger_dag_id="bcen_scr_rmss_emr",
        wait_for_completion=True
    )

    exec_dag_glue = TriggerDagRunOperator(
        task_id='exec_dag_glue',
        trigger_dag_id="bcen_scr_rmss_glue",
        wait_for_completion=True
    )

    # fnzr = DummyOperator(
    #     task_id='fnzr'
    # )

    fnzr_erro = PythonOperator(
        task_id='fnzr_erro',
        python_callable=fnzr_erro,
        trigger_rule='one_failed'
    )

vrfc_dag_exec >> nao_exec >> bscr_ctle_crga >> vrfc_rmss_abto
vrfc_dag_exec >> exec >> fnzr_erro

vrfc_rmss_abto >> nao_rmss_abto >> fnzr_erro
vrfc_rmss_abto >> rmss_abto >> exec_dag_emr >> exec_dag_glue >> fnzr_erro