import os
from datetime import datetime

import pendulum
from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow import AirflowException
from airflow.operators.python import PythonOperator
from airflow.contrib.operators.sns_publish_operator import SnsPublishOperator

import utils_bigdata.s3Utils as s3Utils

env = os.environ['AIRFLOW__CUSTOM__ENVIRONMENT']
LOCAL_TZ = pendulum.timezone("America/Sao_Paulo")
START_DATE = datetime(2023, 3, 9).astimezone(LOCAL_TZ)


def fnzr_erro():
    raise AirflowException("Error")


def rgtr_log_erro(context):
    task_id = context.get('task_instance').task_id
    print("Task Id: {}".format(task_id))

    if task_id == 'fnzr_erro':
        return

    msgs = {
        'exec_dag_rmss': 'Bacen SCR - Ocorreu uma falha no processo de remessa',
        'exec_dag_base': 'Bacen SCR - Ocorreu uma falha no processo de base',
        'exec_dag_orcl': 'Bacen SCR - Insercao dos dados no oracle',
    }

    msg_erro = msgs.get(task_id, 'Bacen SCR - Ocorreu uma falha desconhecida')
    print("Msg Erro: {}".format(msg_erro))

    s3Utils.s3_save_dag_status_direct(dag_name="bcen_scr_pcpl", message=msg_erro)


default_args = {
    'owner': 'airflow',
    'start_date': START_DATE,
    'depends_on_past': False,
    'retries': 0,
    "on_failure_callback": rgtr_log_erro
}

with DAG(
        dag_id='bcen_scr_pcpl',
        default_args=default_args,
        schedule_interval=None
        # schedule_interval='0 */2 * * *',
        # catchup=False,
        # start_date=days_ago(1),

) as dag:
    incr_log = s3Utils.s3_save_dag_status_in_bucket(
        'incr_log',
        '',
        'bcen_scr_pcpl'
    )

    exec_dag_rmss = TriggerDagRunOperator(
        task_id='exec_dag_rmss',
        trigger_dag_id="bcen_scr_rmss_ctle",
        wait_for_completion=True
    )

    exec_dag_base = TriggerDagRunOperator(
        task_id='exec_dag_base',
        trigger_dag_id="bcen_scr_base_ctle",
        wait_for_completion=True
    )

    exec_dag_orcl = TriggerDagRunOperator(
        task_id='exec_dag_orcl',
        trigger_dag_id="bcen_scr_orcl_ctle",
        wait_for_completion=True
    )

    envr_emil_erro = SnsPublishOperator(
        task_id="envr_emil_erro",
        target_arn=os.environ["AIRFLOW__CUSTOM__ENGINEERING_ARN_SNS"],
        subject='AWS :: Bacen SCR :: Erro',
        message='O ocorreu uma falha na DAG de processamento arquivos SCR.',
        aws_conn_id='aws_default',
        trigger_rule="one_failed"
    )

    fnzr = DummyOperator(
        task_id='fnzr'
    )

    fnzr_erro = PythonOperator(
        task_id='fnzr_erro',
        python_callable=fnzr_erro
    )

incr_log >> exec_dag_rmss >> exec_dag_base >> exec_dag_orcl >> fnzr

exec_dag_rmss >> envr_emil_erro >> fnzr_erro
exec_dag_base >> envr_emil_erro >> fnzr_erro
exec_dag_orcl >> envr_emil_erro >> fnzr_erro
