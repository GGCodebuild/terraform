from datetime import datetime, timedelta, timezone
from airflow.models import DagRun, SkipMixin
from airflow.models.baseoperator import BaseOperator

class AirflowVerifyLastExecutionOperator(BaseOperator, SkipMixin):

    def __init__(self, *, dag_id_to_be_verified: str, days_from_the_last_execution: int, task_success: str, task_failed: str, **kwargs):
        """
        Inicia uma nova instância do Operator AirflowVerifyLastExecutionOperator

        :param dag_id_to_be_verified: ID da DAG que será verificada a data da última execução
        :param days_from_the_last_execution: O número de dias necessários desde a última execução da DAG verificada para que seja dado continuidade ao processo
        :param task_success: ID da task que será executada caso a última execução da DAG verificada seja menor que o parâmetro "days_from_the_last_execution"
        :param task_failed: ID da task que será executada caso a última execução da DAG verificada seja maior que o parâmetro "days_from_the_last_execution"
        :return: ID da task que deve ser executada após a verificação
        """
        super().__init__(**kwargs)
        self.dag_id_to_be_verified = dag_id_to_be_verified
        self.days_from_the_last_execution = days_from_the_last_execution
        self.task_success = task_success
        self.task_failed = task_failed
        self.kwargs = kwargs

    def execute(self, context):

        self.log.info(f'Context: {context}')

        dag_runs = DagRun.find(dag_id=self.dag_id_to_be_verified)
        dag_runs.sort(key=lambda x: x.execution_date, reverse=True)
        branch = None

        if dag_runs:

            self.log.info(f'Data de execução do ultimo processamento da DAG Positiva "{ dag_runs[0].execution_date }".')

            if dag_runs[0].execution_date > datetime.now(timezone.utc) - timedelta(self.days_from_the_last_execution) \
                    and dag_runs[0].get_state() == 'success':
                self.log.info(f'Fazem menos de 7 dias desde a última execução da DAG "{ self.dag_id_to_be_verified }", continuando o processo.')
                branch = self.task_success
            else:
                self.log.info(f'Fazem mais de 7 dias desde a última execução da DAG "{ self.dag_id_to_be_verified }" ou sua última execução falhou, abortando o processo.')
                branch = self.task_failed
        else:
            self.log.info(f'A DAG "{ self.dag_id_to_be_verified }" nunca foi executada, abortando o processo.')
            branch = self.task_failed

        self.skip_all_except(context['ti'], branch)
        return branch