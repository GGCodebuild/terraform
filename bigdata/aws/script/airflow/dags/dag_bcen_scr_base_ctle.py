import os
from datetime import datetime

import pendulum
from airflow import DAG
from airflow.hooks.S3_hook import S3Hook
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import BranchPythonOperator
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow import AirflowException
from airflow.providers.amazon.aws.operators.athena import AWSAthenaOperator
from airflow.utils.dates import days_ago

env = os.environ['AIRFLOW__CUSTOM__ENVIRONMENT']
bucket_logs = 'lakehouse-logs-spc-' + env
prefix_athena = 'ATHENA_TEMP/bcen_scr_base/'

athena_query = """
    SELECT CASE
            WHEN count(1) > 0 THEN 'true' ELSE 'false'
        END AS has_rmss
    FROM db_refined.ctle_crga_bcen
    WHERE id_pln_exe = 45
        AND id_etp = 4
        AND(
            DATE(dat_fim_prt) = DATE '1970-01-01' OR dat_fim_prt IS NULL
        )
        AND NOT exists (
            SELECT 1
            FROM db_refined.ctle_crga_bcen
            WHERE id_pln_exe = 45
                AND id_etp = 46
                AND(
                    DATE(dat_fim_prt) = DATE '1970-01-01' OR dat_fim_prt IS NULL
                )
            LIMIT 1
        )
    LIMIT 1;
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
START_DATE = datetime(2023, 3, 9).astimezone(LOCAL_TZ)

default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
    'depends_on_past': False,
    'retries': 0
}

with DAG(
        dag_id='bcen_scr_base_ctle',
        default_args=default_args,
        schedule_interval=None,
        max_active_runs=1
        # schedule_interval='0 */2 * * *',
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

    vrfc_rmss_abto = BranchPythonOperator(
        task_id='vrfc_rmss_abto',
        python_callable=check_has_rmss,
        provide_context=True
    )


    nao_rmss_abto = DummyOperator(
        task_id='nao_rmss_abto'
    )

    rmss_abto = DummyOperator(
        task_id='rmss_abto'
    )

    exec_dag_emr = TriggerDagRunOperator(
        task_id='exec_dag_emr',
        trigger_dag_id="bcen_scr_base_emr",
        wait_for_completion=True
    )

    exec_dag_glue = TriggerDagRunOperator(
        task_id='exec_dag_glue',
        trigger_dag_id="bcen_scr_base_glue",
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

bscr_ctle_crga >> vrfc_rmss_abto

vrfc_rmss_abto >> nao_rmss_abto >> fnzr_erro
vrfc_rmss_abto >> rmss_abto >> exec_dag_emr >> exec_dag_glue >> fnzr_erro
