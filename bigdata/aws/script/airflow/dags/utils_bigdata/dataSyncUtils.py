import time

from airflow.providers.amazon.aws.hooks.base_aws import AwsBaseHook
from airflow.exceptions import AirflowException, AirflowTaskTimeout
from airflow.models import BaseOperator


class DataSyncStartTask(BaseOperator):

    def __init__(self, *, task_arn: str, aws_conn_id: str, **kwargs) -> str:

        if not task_arn:
            raise AirflowException("Exactly one task_exec_arn must be specified.")

        super().__init__(**kwargs)
        self.task_arn = task_arn
        self.aws_conn_id = aws_conn_id
        self.kwargs = kwargs

    def execute(self, context) -> str:

        hook = AwsBaseHook(aws_conn_id=self.aws_conn_id, client_type='datasync')
        client_sync = hook.get_client_type('datasync')
        response = client_sync.start_task_execution(TaskArn=self.task_arn)

        print(response)

        if not response["ResponseMetadata"]["HTTPStatusCode"] == 200:
            raise AirflowException(f"Steps creation failed: {response}")
        else:
            task = response['TaskExecutionArn']
            self.log.info("Task execution with id %s created", task)
            return str(task)


class DataSyncWaitTask(BaseOperator):

    template_fields = ["task_exec_arn"]

    def __init__(self, *, task_exec_arn: str, aws_conn_id: str, **kwargs):

        if not task_exec_arn:
            raise AirflowException("Exactly one task_exec_arn must be specified.")

        super().__init__(**kwargs)
        self.task_exec_arn = task_exec_arn
        self.aws_conn_id = aws_conn_id
        self.kwargs = kwargs

    def execute(self, context) -> bool:

        EXECUTION_FAILURE_STATES = ("ERROR",)
        EXECUTION_SUCCESS_STATES = ("SUCCESS",)
        EXECUTION_INTERMEDIATE_STATES = ("INITIALIZING", "QUEUED", "LAUNCHING", "PREPARING","TRANSFERRING", "VERIFYING",)

        task_exec_arn = self.task_exec_arn
        status = None
        wait_interval_seconds: int = 60

        hook = AwsBaseHook(aws_conn_id=self.aws_conn_id, client_type='datasync')
        client_sync = hook.get_client_type('datasync')

        while status is None or status in EXECUTION_INTERMEDIATE_STATES:
            task_execution = client_sync.describe_task_execution(TaskExecutionArn=task_exec_arn)
            status = task_execution["Status"]
            self.log.info("status=%s", status)
            if status in EXECUTION_FAILURE_STATES:
                break
            if status in EXECUTION_SUCCESS_STATES:
                break

            time.sleep(wait_interval_seconds)

        if status in EXECUTION_SUCCESS_STATES:
            return True

        raise AirflowException(f"Unknown status: {status}")