import datetime
import os
import yaml
from airflow.exceptions import AirflowException
from airflow.models import BaseOperator
from airflow.providers.amazon.aws.hooks.base_aws import AwsBaseHook
from airflow.providers.amazon.aws.hooks.emr import EmrHook
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.providers.amazon.aws.operators.emr_terminate_job_flow import EmrTerminateJobFlowOperator
from airflow.providers.amazon.aws.sensors.emr_step import EmrStepSensor
from typing import List, Dict


class EmrUtils:

    def __init__(self):

        self.environment = os.environ['AIRFLOW__CUSTOM__ENVIRONMENT']
        self.bucket_artifactory_name = os.environ['AIRFLOW__CUSTOM__ARTIFACTORY_AWS_BUCKET']
        self.bucket_airflow_name = os.environ['AIRFLOW__CUSTOM__AIRFLOW_AWS_BUCKET']
        self.path_artifactory = os.environ['AIRFLOW__CUSTOM__PATH_ARTIFACTORY']
        self.log_path = os.environ['AIRFLOW__CUSTOM__LOG_PATH']
        self.sub_net = os.environ['AIRFLOW__CUSTOM__SUB_NET']
        self.pem_key = os.environ['AIRFLOW__CUSTOM__PEM_KEY']
        self.master_security_group = os.environ['AIRFLOW__CUSTOM__MASTER_SECURITY_GROUP']
        self.slave_security_group = os.environ['AIRFLOW__CUSTOM__SLAVE_SECURITY_GROUP']
        self.service_access_security_group = os.environ['AIRFLOW__CUSTOM__SERVICE_ACCESS_SECURITY_GROUP']
        self.job_flow_role = os.environ['AIRFLOW__CUSTOM__JOB_FLOW_ROLE']
        self.service_role = os.environ['AIRFLOW__CUSTOM__SERVICE_ROLE']

    def get_config(self, s3_file_name):
        """
        Busca os parametros de configuração que está no arquivo yaml no s3

        :param s3_file_name: Nome do arquivo que contem as configurações parametrizadas
        :return: Dicionário com as configurações
        """
        key_path = f'airflow/config/{self.environment}/{s3_file_name}'
        hook = S3Hook(aws_conn_id='aws_default')
        file_content = hook.read_key(key=key_path, bucket_name=self.bucket_airflow_name)

        conf = yaml.safe_load(file_content)
        return conf

    def get_tags(self, key_config: str, config_values: Dict):
        """
        Recupera as tags existentes no arquivo de configuração

        :param key_config: chave da configuração do spark existente no dicionário
        :param config_values: dicionário que contem todas as configurações
        :return: retorna as tags existentes no dicionário do arquivo de configuração
        """
        tags_config = None
        list_tag: list = []

        if key_config in config_values.keys():
            tags_config = config_values[key_config]

        if not tags_config is None:
            for key, value in tags_config.items():
                list_tag.append({'Key': key, 'Value': value})

        print(list_tag)
        return list_tag

    def get_job_flow_overrides(self, s3_file_name: str):
        """
        Gera o json com as configurações necessárias para criar o cluster EMR

        :param s3_file_name: Nome do arquivo que contem as configurações parametrizadas
        :return: Json com as configurações para inicializar o cluster EMR on EC2
        """
        job_flow_overrides = None
        config = self.get_config(s3_file_name)

        if not config is None:
            name = config['emr']['config']['name']
            emr_version = config['emr']['config']['version']
            master_instance_type = config['emr']['config']['primaryNode']['instanceType']
            master_instance_count = config['emr']['config']['primaryNode']['instanceCount']
            master_disk_type = config['emr']['config']['primaryNode']['disk_type']
            master_disk_size = config['emr']['config']['primaryNode']['disk_size']
            slave_instance_type = config['emr']['config']['slaveNodes']['instanceType']
            slave_instance_count = config['emr']['config']['slaveNodes']['instanceCount']
            slave_disk_type = config['emr']['config']['slaveNodes']['disk_type']
            slave_disk_size = config['emr']['config']['slaveNodes']['disk_size']
            tags = self.get_tags('tags', config['emr']['config'])

            # Parametriza os apps
            apps = [{'Name': 'Spark'}]
            hadoop_configurations = []

            if 'apps' in config['emr']['config']:
                apps = []
                for i in config['emr']['config']['apps']:
                    apps.append({'Name': i})

                    if i == 'Hadoop':
                        hadoop_configurations = [{
                            "Classification": "hdfs-site",
                            "Properties": {
                                "dfs.replication": "2"
                            }
                        }]

            job_flow_overrides = {
                'Name': f'{name}',
                'LogUri': f'{self.log_path}',
                'ReleaseLabel': emr_version,
                'Applications': apps,
                'Configurations': hadoop_configurations,
                'Instances': {
                    'InstanceGroups': [
                        {
                            'Name': 'Primary node',
                            'Market': 'ON_DEMAND',
                            'InstanceRole': 'MASTER',
                            'InstanceType': f'{master_instance_type}',
                            'InstanceCount': master_instance_count,
                            'EbsConfiguration': {
                                'EbsBlockDeviceConfigs': [
                                    {
                                        'VolumeSpecification': {
                                            'VolumeType': master_disk_type,
                                            'SizeInGB': master_disk_size
                                        }
                                    }
                                ]
                            }
                        },
                        {
                            'Name': "Slave nodes",
                            'Market': 'ON_DEMAND',  # 'ON_DEMAND'|'SPOT',
                            'InstanceRole': 'CORE',  # 'MASTER'|'CORE'|'TASK',
                            'InstanceType': f'{slave_instance_type}',
                            'InstanceCount': slave_instance_count,
                            'EbsConfiguration': {
                                'EbsBlockDeviceConfigs': [
                                    {
                                        'VolumeSpecification': {
                                            'VolumeType': slave_disk_type,
                                            'SizeInGB': slave_disk_size
                                        }
                                    }
                                ]
                            }

                        }
                    ],
                    'KeepJobFlowAliveWhenNoSteps': True,
                    'TerminationProtected': False,
                    'Ec2SubnetId': f'{self.sub_net}',
                    'Ec2KeyName': f'{self.pem_key}', #'EngDadosDev'
                    'EmrManagedMasterSecurityGroup': f'{self.master_security_group}',
                    'EmrManagedSlaveSecurityGroup': f'{self.slave_security_group}',
                    'ServiceAccessSecurityGroup': f'{self.service_access_security_group}'
                },
                'JobFlowRole': f'{self.job_flow_role}',
                'ServiceRole': f'{self.service_role}',
                'Tags': tags,
                'VisibleToAllUsers': True,
                'BootstrapActions': [
                    {
                        'Name': 'Implementacao de Libs necessarias',
                        'ScriptBootstrapAction': {
                            'Path': f'{self.path_artifactory}emr/bootstrap_install_dependencies.sh',
                            'Args': [f'{self.bucket_artifactory_name}']
                        }
                    }
                ]
            }

        return job_flow_overrides

    def add_item_args(self, args: List[str], key_step: str, key_config: str, config_values: Dict) -> List[str]:
        """
        Atualiza a lista de configuração do spark submit

        :param args: lista que será atualizada
        :param key_step: chave da configuração do spark
        :param key_config: valor atribuido a chave
        :param config_values: dicionário que contem todas as configurações
        :return: Json com as configurações para inicializar o cluster EMR on EC2
        """
        value = None

        if key_config in config_values.keys():
            value = config_values[key_config]

            if key_config in ['archives', 'py_files', 'files']:
                value = f's3://{self.bucket_artifactory_name}{value}'

        if not value is None:
            args.append(key_step)
            args.append(str(value))

        return args

    @staticmethod
    def add_item_args_conf(args: List[str], config_values: Dict) -> List[str]:
        """
        Atualiza a lista de configuração do spark submit

        :param args: lista que será atualizada
        :param config_values: dicionário que contem todas as configurações
        :return: Json com as configurações para inicializar o cluster EMR on EC2
        """
        key_conf = 'conf'

        if key_conf in config_values.keys():
            for value in config_values[key_conf]:
                args.append('--conf')
                args.append(value)

        return args

    @staticmethod
    def add_parameters(args: List[str], parameters: List[str]) -> List[str]:
        """
        Atualiza a lista de parametros existentes no arquivo yaml

        :param args: lista que será atualizada
        :param parameters: dicionário que contem todas as configurações
        :return: Json com as configurações para inicializar o cluster EMR on EC2
        """
        for item in parameters:
            if item in 'DATE_PROCESS':
                date_generate = datetime.date.today().replace(day=1) - datetime.timedelta(1)
                item = date_generate.strftime("%Y-%m-%d")
            args.append(item)

        return args

    def add_item_args_extra_jars(self, args: List[str], config_values: Dict) -> str:
        """
        Gera a string com todas as dependências de pacotes do processo

        :param args: lista que será atualizada
        :param config_values: dicionário que contem todas as configurações
        :return: String com todas as dependências de pacotes do processo
        """
        key_conf = 'jars'
        result_jar_dependencies = ""

        if key_conf in config_values.keys():
            for value in config_values[key_conf]:
                path_jar = f's3://{self.bucket_artifactory_name}/emr/lib/maven-repository/{value},'
                result_jar_dependencies = result_jar_dependencies + path_jar
            result_jar_dependencies = result_jar_dependencies[:-1]
            args.append('--jars')
            args.append(result_jar_dependencies)

        return args

    def generate_dist_cp_step(self, name: str, src: str, dest: str, srcPattern: str) -> List[str]:
        """
        Gera o json com as configurações necessárias realizar o submit no S3DistCP

        :param name: Nome do step
        :param src: Origem dos dados
        :param dest: Destino dos dados
        :param srcPattern: Regex do padrão de nomenclatura dos arquivos
        :return: Json com as configurações para inicializar o processo no cluster EMR
        """

        args = ['s3-dist-cp', '--src=' + src, '--dest=' + dest, '--srcPattern=' + srcPattern]

        steps = [
            {
                'Name': f'{name}',
                'ActionOnFailure': 'TERMINATE_JOB_FLOW',
                'HadoopJarStep': {
                    'Jar': 'command-runner.jar',
                    'Args': args,
                }
            }
        ]

        return steps

    def generate_spark_steps(self, s3_file_name: str) -> List[str]:
        """
        Gera o json com as configurações necessárias realizar o submit no cluster EMR

        :param s3_file_name: Nome do arquivo que contem as configurações parametrizadas
        :return: Json com as configurações para inicializar o processo no cluster EMR
        """

        args = ['spark-submit']
        config = self.get_config(s3_file_name)

        if not config is None:
            name = config['spark']['submit']['name']
            main_file_name = config['spark']['submit']['main_file_name']
            submit_config = config['spark']['submit']

            args = self.add_item_args(args, '--packages', 'packages', submit_config)
            args = self.add_item_args(args, '--master', 'master', submit_config)
            args = self.add_item_args(args, '--deploy-mode', 'mode', submit_config['deploy'])
            args = self.add_item_args(args, '--class', 'class', submit_config)

            args = self.add_item_args_conf(args, submit_config)
            args = self.add_item_args_extra_jars(args, submit_config)

            args = self.add_item_args(args, '--archives', 'archives', submit_config)
            args = self.add_item_args(args, '--py-files', 'py_files', submit_config)
            args = self.add_item_args(args, '--files', 'files', submit_config)

            args.append(f's3://{self.bucket_artifactory_name}{main_file_name}')

            args = self.add_parameters(args, submit_config['parameters'])

            spark_steps = [
                {
                    'Name': f'{name}',
                    'ActionOnFailure': 'TERMINATE_JOB_FLOW',
                    # 'CONTINUE',  No caso de erro precisamos encerrar o processo
                    'HadoopJarStep': {
                        'Jar': 'command-runner.jar',
                        'Args': args
                    }
                }
            ]

            return spark_steps


class EmrCreateCustomJobFlowOperator(BaseOperator):
    def __init__(self, *, aws_conn_id: str, emr_conn_id: str, job_path_config: str, **kwargs):
        """
        Inicia uma nova instância do Operator EmrCreateCustomJobFlowOperator

        :param aws_conn_id: Conexão do Airflow usada para o acesso a AWS
        :param emr_conn_id: ID necessário para o uso do método "create_job_flow"
        :param job_path_config: Caminho/Nome do arquivo de configuração utilizado para criar o cluster EMR
        :return: ID do cluster EMR criado
        """
        super().__init__(**kwargs)
        self.aws_conn_id = aws_conn_id
        self.emr_conn_id = emr_conn_id
        self.job_path_config = job_path_config

    def execute(self, context) -> str:

        self.log.info(f'Context: {context}')

        emr = EmrHook(aws_conn_id=self.aws_conn_id, emr_conn_id=self.emr_conn_id)
        self.log.info("Creating JobFlow using aws-conn-id: %s, emr-conn-id: %s", self.aws_conn_id, self.emr_conn_id)
        self.log.info("Path config: %s", self.job_path_config)

        job_flow_overrides = EmrUtils().get_job_flow_overrides(self.job_path_config)
        response = emr.create_job_flow(job_flow_overrides)

        if not response["ResponseMetadata"]["HTTPStatusCode"] == 200:
            raise AirflowException(f"JobFlow creation failed: {response}")
        else:
            job_flow_id = response["JobFlowId"]
            self.log.info("JobFlow with id %s created", job_flow_id)
            return job_flow_id


class EmrAddStepsCustomOperator(BaseOperator):
    template_fields = ["job_flow_id"]

    def __init__(self, *, job_flow_id: str, aws_conn_id: str, steps_path_config: str, **kwargs):
        """
        Inicia uma nova instância do Operator EmrAddStepsCustomOperator

        :param job_flow_id: ID do cluster EMR
        :param aws_conn_id: Conexão do Airflow usada para o acesso a AWS
        :param steps_path_config: Caminho/Nome do arquivo de configuração utilizado para realizar o spark submit
        :return: ID do job spark
        """
        if not job_flow_id:
            raise AirflowException("Exactly one of job_flow_id or job_flow_name must be specified.")

        super().__init__(**kwargs)
        self.aws_conn_id = aws_conn_id
        self.job_flow_id = job_flow_id
        self.steps_path_config = steps_path_config

    def execute(self, context) -> str:

        self.log.info(f'Context: {context}')

        hook = AwsBaseHook(aws_conn_id=self.aws_conn_id, client_type='emr')
        client_emr = hook.get_client_type('emr')

        if not self.job_flow_id:
            raise AirflowException(f"No cluster found for id: {self.job_flow_id}")

        job_flow_id = self.job_flow_id
        self.log.info("Cluster ID: %s", job_flow_id)

        self.log.info("Adding steps to %s", job_flow_id)
        steps = EmrUtils().generate_spark_steps(self.steps_path_config)
        self.log.info("steps: %s", steps)

        response = client_emr.add_job_flow_steps(JobFlowId=job_flow_id, Steps=steps)

        if not response["ResponseMetadata"]["HTTPStatusCode"] == 200:
            raise AirflowException(f"Steps creation failed: {response}")
        else:
            step_id = response['StepIds'][0]
            self.log.info("Step with id %s created", step_id)
            return str(step_id)


class EmrAddStepsDistCpOperator(BaseOperator):
    template_fields = ["job_flow_id", "path_src"]

    def __init__(self, *, job_flow_id: str, aws_conn_id: str, step_name: str, path_src: str, path_dest: str,
                 src_pattern: str, **kwargs):
        """
        Inicia uma nova instância do Operator EmrAddStepsDistCpOperator

        :param job_flow_id: ID do cluster EMR
        :param aws_conn_id: Conexão do Airflow usada para o acesso a AWS
        :param path_src: Caminho de origem
        :param path_dest: Caminho de destino
        :return: ID do job spark
        """
        if not job_flow_id:
            raise AirflowException("Exactly one of job_flow_id or job_flow_name must be specified.")

        super().__init__(**kwargs)
        self.aws_conn_id = aws_conn_id
        self.job_flow_id = job_flow_id
        self.path_src = path_src
        self.path_dest = path_dest
        self.src_pattern = src_pattern
        self.step_name = step_name

    def execute(self, context) -> str:

        self.log.info(f'Context: {context}')

        hook = AwsBaseHook(aws_conn_id=self.aws_conn_id, client_type='emr')
        client_emr = hook.get_client_type('emr')

        if not self.job_flow_id:
            raise AirflowException(f"No cluster found for id: {self.job_flow_id}")

        job_flow_id = self.job_flow_id
        self.log.info("Cluster ID: %s", job_flow_id)

        self.log.info("Adding steps to %s", job_flow_id)
        steps = EmrUtils().generate_dist_cp_step(self.step_name, self.path_src, self.path_dest, self.src_pattern)
        self.log.info("steps: %s", steps)

        response = client_emr.add_job_flow_steps(JobFlowId=job_flow_id, Steps=steps)

        if not response["ResponseMetadata"]["HTTPStatusCode"] == 200:
            raise AirflowException(f"Steps creation failed: {response}")
        else:
            step_id = response['StepIds'][0]
            self.log.info("Step with id %s created", step_id)
            return str(step_id)


def create_emr(s3_file_name: str) -> EmrCreateCustomJobFlowOperator:
    """
    Cria o cluster EMR Efemero

    :param s3_file_name: Nome do arquivo que contem as configurações parametrizadas
    :return: retorna o objeto EmrCreateJobFlowOperator
    """
    return EmrCreateCustomJobFlowOperator(
        task_id='create_cluster_emr',
        job_path_config=s3_file_name,
        aws_conn_id='aws_default',
        emr_conn_id='emr_default')


def terminate_cluster() -> EmrTerminateJobFlowOperator:
    """
    Cria o cluster EMR Efemero
    :return: retorna o objeto EmrTerminateJobFlowOperator
    """
    return EmrTerminateJobFlowOperator(
        task_id='remove_cluster',
        job_flow_id="{{ task_instance.xcom_pull('create_cluster_emr', key='return_value') }}",
        aws_conn_id='aws_default')


def create_steps_emr(dict_execute_step: Dict) -> List:
    """
    Gera os steps do processos da DAG do airflow de acordo com a lista de parametros enviados

    :param dict_execute_step: Dicionario que contem chave[string] e valor[string]
    :return: Retorna os steps da dag EmrAddStepsOperator e EmrStepSensor
    """
    task_list = []
    for key, value in dict_execute_step.items():
        task_id_running_process = f'{key}_running_process'
        task_id_waiting_run_process = f'waiting_run_process_{key}'
        file_config = value

        running_process = EmrAddStepsCustomOperator(
            task_id=task_id_running_process,
            job_flow_id="{{ task_instance.xcom_pull('create_cluster_emr', key='return_value') }}",
            aws_conn_id='aws_default',
            steps_path_config=file_config
        )

        waiting_run_process = EmrStepSensor(
            task_id=task_id_waiting_run_process,
            job_flow_id="{{ task_instance.xcom_pull('create_cluster_emr', key='return_value') }}",
            step_id="{{ task_instance.xcom_pull(task_ids='" + task_id_running_process + "', key='return_value') }}",
            aws_conn_id='aws_default'
        )

        task_list.append(running_process)
        task_list.append(waiting_run_process)

    return task_list
