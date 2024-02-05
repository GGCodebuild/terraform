import datetime
import boto3
import yaml
from typing import List, Dict
from pathlib import Path


class EmrUtilsDev:

    def __init__(self, bucket_artifactory_name, path_config):
        self.bucket_artifactory_name = bucket_artifactory_name
        self.path_config = path_config

    def get_config(self, local_file_name):
        """
        Busca os parametros de configuração que está no arquivo yaml no s3

        :param local_file_name: Nome do arquivo que contem as configurações parametrizadas
        :return: Dicionário com as configurações
        """
        path_config = f'{self.path_config}/{local_file_name}'
        conf = yaml.safe_load(Path(path_config).read_text())
        return conf


    def get_job_flow_overrides(self, s3_file_name: str) -> str:
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
            master_instance_type =  config['emr']['config']['primaryNode']['instanceType']
            master_instance_count =  config['emr']['config']['primaryNode']['instanceCount']
            slave_instance_type =  config['emr']['config']['slaveNodes']['instanceType']
            slave_instance_count =  config['emr']['config']['slaveNodes']['instanceCount']

            job_flow_overrides = {
                'Name': f'{name}',
                'LogUri': f'{self.log_path}',
                'ReleaseLabel': emr_version,
                'Applications': [{'Name': 'Spark'}],
                'Instances': {
                    'InstanceGroups': [
                        {
                            'Name': 'Primary node',
                            'Market': 'ON_DEMAND',
                            'InstanceRole': 'MASTER',
                            'InstanceType': f'{master_instance_type}',
                            'InstanceCount': master_instance_count
                        },
                        {
                            'Name': "Slave nodes",
                            'Market': 'ON_DEMAND',
                            'InstanceRole': 'CORE',
                            'InstanceType': f'{slave_instance_type}',
                            'InstanceCount': slave_instance_count
                        }
                    ],
                    'KeepJobFlowAliveWhenNoSteps': True,
                    'TerminationProtected': False,
                    'Ec2SubnetId': f'{self.sub_net}',
                    'Ec2KeyName': f'{self.pem_key}',
                    'EmrManagedMasterSecurityGroup': f'{self.master_security_group}',
                    'EmrManagedSlaveSecurityGroup': f'{self.slave_security_group}',
                    'ServiceAccessSecurityGroup': f'{self.service_access_security_group}'
                },
                'JobFlowRole': f'{self.job_flow_role}',
                'ServiceRole': f'{self.service_role}',
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

        return str(job_flow_overrides)

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
            print(f'## {key_step}: {value}')
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
                item = datetime.datetime.now().strftime("%Y-%m-%d")
            args.append(item)

        return args

    def generate_spark_steps(self, s3_file_name: str) -> List[str]:
        """
        Gera o json com as configurações necessárias realizar o submit no cluster EMR

        :param s3_file_name: Nome do arquivo que contem as configurações parametrizadas
        :return: Json com as configurações para inicializar o processo no cluster EMR
        """

        spark_steps = None
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
                    'ActionOnFailure': 'CONTINUE', #'CONTINUE',  No caso de erro precisamos encerrar o processo
                    'HadoopJarStep': {
                        'Jar': 'command-runner.jar',
                        'Args': args
                    }
                }
            ]

        return spark_steps


if __name__ == "__main__":

    #TODO: Alterar o parametros abaixo
    region_aws = 'sa-east-1'
    id_cluster = 'j-GXLQHLYR937K'
    path_config = f'/home/rodrigo/Documents/source-repository/repositorio-git-spc/lakehouse/aws/script/airflow/config/prd/step'
    emr_utils = EmrUtilsDev('lakehouse-artifactory-spc-dev', path_config)

    # TODO: Execução cálculo variáveis negativo
    #step_spark = emr_utils.generate_spark_steps('negative_lending.yaml')

    # TODO: Execução cálculo variáveis positivo
    #step_spark = emr_utils.generate_spark_steps('positive_lending.yaml')

    # TODO: Execução geração modelo de score
    step_spark = emr_utils.generate_spark_steps('model_execution_lending.yaml')

    print(step_spark)
    #connection = boto3.client('emr', region_name=region_aws)
    #connection.add_job_flow_steps(JobFlowId=id_cluster, Steps=step_spark)

    #padrão nomenclatura do arquivos gerado: nubank_score_output_ano_mes.csv