from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.utils.task_group import TaskGroup

from utils_bigdata import crawlerUtils

list_crawler = ['bcen_scr_htrc_raw', 'bcen_scr_cltn_raw',
                'bcen_scr_oprc_raw', 'bcen_scr_grnt_raw',
                'ctle_crga_bcen_refined_delta']

default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
    'depends_on_past': False
}

with DAG(
        dag_id='bcen_scr_rmss_glue',
        default_args=default_args,
        start_date=days_ago(1),
        schedule_interval=None
) as dag:
    with TaskGroup(group_id="crawlers") as crawlers:
        list_crawler_dag = crawlerUtils.create_steps(list_crawler)

crawlers
