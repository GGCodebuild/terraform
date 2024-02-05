import sys

sys.path.insert(0, 'package/')

import requests
import boto3
import Enum_Airflow
import json
import os
import base64
from datetime import datetime


class AirflowUtils:

    def __init__(self, mwaa_env_name):
        self.mwaa_env_name = mwaa_env_name

    def read_s3_log(self, dag_name):
        """
        Le o log da DAG no S3, em caso de erro
        :param dag_name: Nome da dag do airflow
        :return retorna a mensagem salva no arquivo texto no S3
        """
        try:
            s3_client = boto3.client("s3")
            s3_key = "AIRFLOW/dags/{}.txt".format(dag_name)
            env_name = "prd" if "-prd" in self.mwaa_env_name else "dev"

            s3_bucket = "lakehouse-logs-spc-{}".format(env_name)
            print("Lendo: {}/{}".format(s3_bucket, s3_key))

            file_content = s3_client.get_object(
                Bucket=s3_bucket, Key=s3_key)["Body"].read().decode("utf-8").strip()
            return file_content
        except Exception as ex:
            print("Exception:", str(ex))
            return ''

    def request_airflow(self, raw_data: str):
        """
        Realiza a chamadas a api do airflow
        :param raw_data: comando à ser executado no endpoint do airflow
        :returns retorna o status code da requisição, messagem de retorno e a mensagem de erro
        """
        client = boto3.client('mwaa')
        mwaa_cli_token = client.create_cli_token(Name=self.mwaa_env_name)
        mwaa_webserver_hostname = 'https://{0}/aws_mwaa/cli'.format(mwaa_cli_token['WebServerHostname'])
        mwaa_auth_token = 'Bearer ' + mwaa_cli_token['CliToken']

        mwaa_response = requests.post(
            mwaa_webserver_hostname,
            headers={
                'Authorization': mwaa_auth_token,
                'Content-Type': 'text/plain'
            },
            data=raw_data
        )

        status_code = mwaa_response.status_code
        mwaa_std_err_message = base64.b64decode(mwaa_response.json()['stderr']).decode('utf8')
        mwaa_std_out_message = base64.b64decode(mwaa_response.json()['stdout']).decode('utf8')

        return status_code, mwaa_std_out_message, mwaa_std_err_message

    def start_dag(self, dag_name: str):
        """
        Realiza a inicialização de um DAG do airflow, através do endpoint da ferramenta
        :param dag_name: Nome da dag do airflow
        :return retorna o payload com o resultado do processo
        """
        raw_data: str = '{0} {1}'.format('dags trigger', dag_name)
        status_code, mwaa_std_out_message, mwaa_std_err_message = self.request_airflow(raw_data)

        if status_code == 200 and mwaa_std_out_message.__contains__('triggered: True'):
            return {'state': 'success', 'timestamp': self.generate_timestamp(), 'error_description': ''}

        return {'state': 'error', 'timestamp': self.generate_timestamp(), 'error_description': mwaa_std_err_message}

    def health_check_dag(self, dag_name: str):
        """
        Realiza o health chega da dag
        :param dag_name: Nome da dag do airflow
        :return retorna o payload com o resultado do processo
        """
        raw_data = '{0} -d {1} -o json --state running'.format('dags list-runs', dag_name)
        status_code, mwaa_std_out_message, mwaa_std_err_message = self.request_airflow(raw_data)

        if status_code != 200:
            return {'state': 'error', 'timestamp': self.generate_timestamp(), 'error_description': mwaa_std_err_message}

        #print("mwaa_std_out_message = ", mwaa_std_out_message)
        mwaa_std_out_message = mwaa_std_out_message.replace('[', '').replace(']\n', '')

        if mwaa_std_out_message:
            mwaa_std_out_message = json.loads(mwaa_std_out_message)
            return {'state': mwaa_std_out_message['state'], 'timestamp': self.generate_timestamp(),
                    'error_description': ''}

        return None

    @staticmethod
    def generate_timestamp():
        """
        Gera o timestamp no momento do processo
        :return retorna o timestamp
        """
        return datetime.now().strftime("%Y%m%d%H%M%S")

    @staticmethod
    def get_dag_name(value: str) -> str:
        """
        Gera o timestamp no momento do processo
        :param value string a chave da DAG
        :return retorna o nome da DAG
        """
        try:
            dag = Enum_Airflow.DAG(value)
            return dag.name
        except Exception:
            raise ValueError("DAG Invalida!")

    @staticmethod
    def get_event_name(value: str) -> str:
        """
        Gera o timestamp no momento do processo
        :param value string a chave da DAG
        :return retorna o nome da DAG
        """
        try:
            event = Enum_Airflow.EVENT(value)
            return event.name
        except Exception:
            raise ValueError("Event Invalido!")

    @staticmethod
    def json_return(status_code: str, result_body: dict):
        """
         Gera o json de retorno
         :param status_code código referente ao status code da requisição realizada ao airflow
         :param result_body recebe o dicionário para adicionar no body da retorno
         :return retorna o dicionário do request
         """
        return {
            "statusCode": status_code,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps(result_body)
        }

    def json_return_error(self, error_description: str):
        """
         Gera o json de erro
         :param error_description código referente ao status code da requisição realizada ao airflow
         :return retorna o dicionário do request
         """
        result_body = {'state': 'error', 'timestamp': self.generate_timestamp(), 'error_description': error_description}
        return self.json_return(500, result_body)

    def json_return_success(self, result_body):
        """
         Gera o json de sucesso
         :param result_body recebe o dicionário para adicionar no body da retorno
         :return retorna o dicionário do request
         """
        return self.json_return(200, result_body)


def lambda_handler(event, context):
    """
    Metodo responsável que realiza integração com o endpoint do airflow, através deste código é possível iniciar a dag
    e verificar o status da execução da DAG:
    :param event: parametros de entrada Exemplo do paylod {'body': {'dag_name': 'negativo', event: 'check' }}
    :param context: contexto do lambda
    """
    mwaa_env_name: str = os.environ['MWAA_NAME']
    airflow_utils = AirflowUtils(mwaa_env_name)

    try:
        print(f'Airflow envioroment: {mwaa_env_name}')

        payload = json.loads(event['body'])
        dag_name = airflow_utils.get_dag_name(payload['dag_name'])
        event_lambda = airflow_utils.get_event_name(payload['event_name'])
        request = airflow_utils.health_check_dag(dag_name)

        print(f'Retorno Health Check: {request}')

        if event_lambda == 'start' and not request:
            request = airflow_utils.start_dag(dag_name)
            print(f'Retorno Started Dag: {request}')
            return airflow_utils.json_return_success(request)

        if event_lambda == 'start':
            request['error_description'] = 'A Dag esta em execucao no momento, nao e possível iniciar um novo processo!'
            print(f'Retorno Exceção Start: {request}')

        if event_lambda == 'check' and not request:
            error_description = airflow_utils.read_s3_log(dag_name)
            if error_description != '':
                return airflow_utils.json_return_error(error_description)
            else:
                request = {'state': 'finished', 'timestamp': airflow_utils.generate_timestamp(),
                           'error_description': ''}

        return airflow_utils.json_return_success(request)

    except ValueError as e:
        print('Ocorreu um erro!')
        print(f'Payload de entrada: {event}')
        print(f'Erro: {e}')
        return airflow_utils.json_return_error(str(e))

    except Exception as e:
        print('Ocorreu um erro!')
        print(f'Payload de entrada: {event}')
        print(f'Erro: {e}')
        return airflow_utils.json_return_error('Erro desconhecido!')
