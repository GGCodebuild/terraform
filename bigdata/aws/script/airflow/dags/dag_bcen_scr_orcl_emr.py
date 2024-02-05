from airflow import DAG
from airflow.utils.dates import days_ago

from utils_bigdata import emrUtils

dict_execute_step = {
    'spark_orcl': 'step/step_bcen_scr_orcl.yaml',
}

default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
    'depends_on_past': False
}

with DAG(
        dag_id='bcen_scr_orcl_emr',
        default_args=default_args,
        start_date=days_ago(1),
        schedule_interval=None
) as dag:
    create_cluster_emr = emrUtils.create_emr('cluster/cluster_bcen_scr_orcl.yaml')
    task_list = emrUtils.create_steps_emr(dict_execute_step)
    terminate_cluster = emrUtils.terminate_cluster()

create_cluster_emr >> task_list[0] >> task_list[1] >> terminate_cluster
terminate_cluster
