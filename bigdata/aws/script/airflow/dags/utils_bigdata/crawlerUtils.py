from typing import List
from airflow.providers.amazon.aws.operators.glue_crawler import AwsGlueCrawlerOperator

def create_steps(lista_crawler: List[str]) -> List:
    """
    Gera os steps para atualizar os tabelas existentes no processo

    :param lista_crawler: Dicionario que contem chave[string] e valor[string]
    :return: Retorna os steps dag AwsGlueCrawlerOperator
     """

    task_list = []
    for value in lista_crawler:

        task_id_running_process = f'{value}_run_crawler'

        crawlers_run = AwsGlueCrawlerOperator(
            task_id=task_id_running_process,
            config={"Name": value},
            aws_conn_id="aws_default"
        )

        task_list.append(crawlers_run)

    return task_list