from airflow.operators.python import PythonOperator
from airflow import AirflowException


def generate_exception(task_id):

    """
    autor: Marcelo Senaga
    Comentário: Gera uma Task Com Falha (para indicar que a DAG Falhou)
    """

    def throw_exception():
        raise AirflowException("Error")

    return PythonOperator(
        task_id=task_id,
        python_callable=throw_exception,
        trigger_rule='one_success'
    )
