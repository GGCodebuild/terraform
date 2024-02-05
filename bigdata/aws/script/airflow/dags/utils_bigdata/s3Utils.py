import pytz
import re
import os
import boto3

from airflow.contrib.operators.s3_copy_object_operator import S3CopyObjectOperator
from airflow.contrib.operators.s3_list_operator import S3ListOperator
from airflow.hooks.S3_hook import S3Hook
from airflow.models import BaseOperator
from airflow.operators.python import PythonOperator
from io import StringIO

from utils import secretManagerUtils as secret


class S3DeleteObjectsCustomOperator(BaseOperator):

    template_fields = ["bucket"]

    def __init__(self, *, bucket: str, task_old_keys: str = None, keys: str = None, aws_conn_id: str, **kwargs) -> bool:

        super().__init__(**kwargs)
        self.bucket = bucket
        self.task_old_keys = task_old_keys
        self.keys = keys
        self.aws_conn_id = aws_conn_id
        self.kwargs = kwargs

    def execute(self, context) -> str:

        self.log.info(f'Context: {context}')
        keys = None

        if self.keys:
            keys = self.keys
        else:
            keys = context['ti'].xcom_pull(task_ids=self.task_old_keys)

        self.log.info(f'Context: {keys}')

        s3_hook = S3Hook(aws_conn_id=self.aws_conn_id)
        s3_hook.delete_objects(bucket=self.bucket, keys=keys)

        return True


class S3CountLinesCustomOperator(BaseOperator):

    template_fields = ["bucket_name"]

    def __init__(self, *, bucket_name: str, key: str, aws_conn_id: str, **kwargs):

        super().__init__(**kwargs)
        self.bucket_name = bucket_name
        self.key = key
        self.aws_conn_id = aws_conn_id
        self.kwargs = kwargs

    def execute(self, context):

        self.log.info(f'Context: {context}')

        s3_hook = S3Hook(aws_conn_id=self.aws_conn_id)
        select = s3_hook.select_key(bucket_name=self.bucket_name,
            key=self.key,
            expression="SELECT count(*) FROM S3Object s WHERE s._1 NOT LIKE '%cpf%'",
            expression_type='SQL')

        return ''.join(re.findall('\d+', select))


class S3GetLastModificationCustomOperator(BaseOperator):

    template_fields = ["bucket_name"]

    def __init__(self, *, bucket_name: str, key: str, aws_conn_id: str, **kwargs):

        super().__init__(**kwargs)
        self.bucket_name = bucket_name
        self.key = key
        self.aws_conn_id = aws_conn_id
        self.kwargs = kwargs

    def execute(self, context):

        self.log.info(f'Context: {context}')

        s3_hook = S3Hook(aws_conn_id=self.aws_conn_id)
        key_object = s3_hook.get_key(bucket_name=self.bucket_name, key=self.key)

        last_modification_datetime = key_object.last_modified
        sao_paulo_time = pytz.timezone('America/Sao_Paulo')
        last_modification_datetime = last_modification_datetime.astimezone(sao_paulo_time)

        return last_modification_datetime.strftime('%d/%m/%Y %H:%M')


def get_bucket_name(task_id, bucket):
    get_bucket_name = PythonOperator(
        task_id=task_id,
        python_callable=secret.get_secret_python_operator,
        op_kwargs={'SECRET_KEY': f'bucket/{bucket}'}
    )

    return get_bucket_name


def filter_objects(**context):
    objects = context['ti'].xcom_pull(task_ids='s3_move_file_output.s3_list_files_output')
    for i in range(1, len(objects)):
        if objects[i][len(objects[0]):] != '_SUCCESS':
            return objects[i]


def s3_list_files(task_id, bucket, source_bucket_key):
    s3_file = S3ListOperator(
        task_id=task_id,
        bucket=bucket,
        prefix=source_bucket_key,
        delimiter='/',
        aws_conn_id='aws_default'
    )

    return s3_file


def s3_copy_file(task_id, source_bucket_name, dest_bucket_name, source_bucket_key, dest_bucket_key, new_file_name):
    s3_copy_file = S3CopyObjectOperator(
        task_id=task_id,
        source_bucket_name=source_bucket_name,
        source_bucket_key=source_bucket_key,
        dest_bucket_name=dest_bucket_name,
        dest_bucket_key=f'{dest_bucket_key}{new_file_name}',
        aws_conn_id='aws_default'
    )

    return s3_copy_file


def s3_filter_file(task_id):
    s3_filter_file = PythonOperator(
        task_id=task_id,
        python_callable=filter_objects,
        provide_context=True
    )

    return s3_filter_file


def s3_remove_file(task_id, bucket, task_old_keys, keys_path):
    s3_remove_file = S3DeleteObjectsCustomOperator(
        task_id=task_id,
        bucket=bucket,
        task_old_keys=task_old_keys,
        keys=keys_path,
        aws_conn_id='aws_default'
    )

    return s3_remove_file


def s3_count_file_lines(task_id, bucket_name, key):
    s3_count_file_lines = S3CountLinesCustomOperator(
        task_id=task_id,
        bucket_name=bucket_name,
        key=key,
        aws_conn_id='aws_default'
    )

    return s3_count_file_lines


def s3_get_last_modification(task_id, bucket_name, key):
    s3_get_last_modification = S3GetLastModificationCustomOperator(
        task_id=task_id,
        bucket_name=bucket_name,
        key=key,
        aws_conn_id='aws_default'
    )

    return s3_get_last_modification


def s3_save_dag_status_direct(**kwargs):
    """
    autor: Marcelo Senaga
    Comentário: Salva mensagem de erro da DAG no S3, para posterior recuperacao pelo Lambda
    """
    try:
        env = os.environ["AIRFLOW__CUSTOM__ENVIRONMENT"]

        s3_bucket = "lakehouse-logs-spc-{}".format(env)
        s3_key = "AIRFLOW/dags/{}.txt".format(kwargs['dag_name'])

        s3_client = boto3.client('s3')
        output = StringIO(kwargs['message'])

        s3_client.put_object(Bucket=s3_bucket, Key=s3_key, Body=output.getvalue())
    except Exception as e:
        print(e)


def s3_save_dag_status_in_bucket(task_id, message, dag_name, trigger_rule='all_success'):
    """
    autor: Marcelo Senaga
    Comentário: Salva mensagem de erro da DAG no S3, para posterior recuperacao pelo Lambda
    """
    return PythonOperator(
        task_id=task_id,
        python_callable=s3_save_dag_status_direct,
        op_kwargs={'dag_name': dag_name, 'message': message},
        trigger_rule=trigger_rule
    )
