from airflow.models import DagRun, SkipMixin
from airflow.models.baseoperator import BaseOperator


class DagRunningOperator(BaseOperator, SkipMixin):

    def __init__(self, *, target_dag_id: str, task_true: str, task_false: str, **kwargs):
        """
        Inicia uma nova instância do Operator DagRunningOperaor

        :param target_dag_id: ID da DAG que será verificada
        :param task_true: ID da task que será executada caso a DAG já esteja em execução"
        :param task_false: ID da task que será executada caso a DAG não esteja em execução"
        :return: ID da task que deve ser executada após a verificação
        """
        super().__init__(**kwargs)
        self.target_dag_id = target_dag_id
        self.task_true = task_true
        self.task_false = task_false
        self.kwargs = kwargs

    def execute(self, context):

        self.log.info(f'Context: {context}')

        dag_runs = DagRun.find(dag_id=self.target_dag_id)
        task_running = 0

        for dag in dag_runs:
            if dag.get_state() == 'running':
                task_running = task_running + 1

            if task_running == 2:
                self.skip_all_except(context['ti'], self.task_true)
                return self.task_true

        self.skip_all_except(context['ti'], self.task_false)
        return self.task_false
