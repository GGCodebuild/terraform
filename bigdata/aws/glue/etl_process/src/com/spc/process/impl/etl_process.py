import requests

from typing import List

from datetime import datetime
from pyspark.sql.functions import when, col, lit

from com.spc.repository.repository_enum import RepositoryEnum
from com.spc.spark.config.impl.config_etl import ConfigETL


class ETLProcess:
    """
    Classe principal do processo de ETL, contêm lógicas de negócio
    """

    def __init__(self, config_environ):
        self.params = config_environ.get_parameters()

        config_etl = ConfigETL()
        self.params_etl = config_etl.get_request_params(self.params)
        self.buckets = config_etl.get_buckets_and_paths(self.params_etl.copy())

        self.spark = config_environ.init_spark(self.params_etl)

        self.bucket_source = self.buckets.get('source_bucket_name')
        self.bucket_target = self.buckets.get('target_bucket_name')
        self.bucket_delta_merge = self.buckets.get('delta_bucket_name')

        self.path_bucket_source_to_process = self.buckets.get('source_bucket_path')
        self.path_bucket_source_processing = f'{self.path_bucket_source_to_process}work-in-progress/'
        self.path_bucket_source_processed = f'{self.path_bucket_source_to_process}processed/'
        self.path_source = f's3a://{self.bucket_source}/{self.path_bucket_source_to_process}'
        self.path_source_work_in_progress = f's3a://{self.bucket_source}/{self.path_bucket_source_processing}'

        self.path_bucket_target = self.buckets.get('target_bucket_path')
        self.path_target = f's3a://{self.bucket_target}/{self.path_bucket_target}'

        self.path_bucket_delta_merge = self.buckets.get('delta_bucket_path')
        self.path_delta_merge = f's3a://{self.bucket_delta_merge}/{self.path_bucket_delta_merge}'

        self.TEMP_NAME_COLUMN = '_NEW_VALUE_TEMP_#'

    def main_process(self):
        """
        Executa a lógica principal do processo
        """
        start_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        process_count = 0
        status = ''
        error = None
        error_description = ''

        try:

            if self.params_etl.get('persistence_mode') == 'merge':
                print('Inicializando o processo de merge')
                process_count = self.merge_process()

            elif self.params_etl.get('persistence_mode') == 'upsert':
                print('Inicializando o processo de upsert')
                process_count = self.upsert_process()

            else:
                if self.params_etl.get('source') == 'landing':
                    process_count = self.landing_source_process()
                else:
                    process_count = self.raw_or_trusted_or_refined_source_process()

            print(f'Processo executado com sucesso')
            status = 'success'

        except BaseException as e:
            print(f'Erro no processo: {str(e)}')
            status = 'error'
            error_description = str(e)
            error = e

        end_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        self.post_request_processes_history(process_count, start_time, end_time, status, error_description)

        self.spark.stop()

        if status == 'error':
            raise error

    def landing_source_process(self):
        """
        Contêm a lógica de interação entre a camada landing e camada target (raw, trusted ou refined)

        :return: count do dataframe
        """
        print('Inicializando o repositório')
        repository = RepositoryEnum.AWS_S3.value

        print(f'Verificando se existem arquivos no caminho {self.path_bucket_source_to_process} do bucket {self.bucket_source}')
        if repository.verify_path(self.bucket_source, self.path_bucket_source_to_process):

            print(f'Movendo os arquivos para o caminho: {self.path_bucket_source_processing}')
            repository.move_objects(self.bucket_source, self.path_bucket_source_to_process, self.bucket_source,
                                    self.path_bucket_source_processing)

            df = self.process_persist(repository, self.path_source_work_in_progress)
            process_count = self.count_dataframe(df)

            print(f'Movendo arquivos para o caminho: {self.path_bucket_source_processed}')
            repository.move_objects(self.bucket_source, self.path_bucket_source_processing, self.bucket_source,
                                    self.path_bucket_source_processed)
            
            return process_count
        else:
            print(f"Não existe o caminho {self.path_bucket_source_to_process} no bucket {self.bucket_source}")
            return 0

    def raw_or_trusted_or_refined_source_process(self):
        """
        Contêm a lógica de interação entre as camadas raw, trusted ou refined

        :return: count do dataframe
        """
        print('Inicializando o repositório')
        repository = RepositoryEnum.AWS_S3.value

        print(f'Verificando se existem arquivos no caminho {self.path_bucket_source_to_process} do bucket {self.bucket_source}')
        if repository.verify_path(self.bucket_source, self.path_bucket_source_to_process):

            df = self.process_persist(repository, self.path_source)
            process_count = self.count_dataframe(df)

            return process_count
        else:
            print(f"Não existe o caminho {self.path_bucket_source_to_process} no bucket {self.bucket_source}")
            return 0

    def process_persist(self, repository, source_path):
        """
        Contêm a lógica para persistência de arquivos da camada landing para a raw

        :param repository: instância da classe de repositório
        :return: dataframe
        """
        print(f'Lendo os arquivos, existentes no caminho: {source_path}')
        df = repository.generate_dataframe(self.spark, source_path, self.params_etl)
        
        df = self.query_transformation(df)

        print(f'Persistindo no bucket: {self.bucket_target} no caminho: {self.path_bucket_target}')
        repository.persist(df, self.path_target, self.params_etl)

        return df

    def query_transformation(self, data_frame):
        """
        Aplica query de transformação do dataframe

        :param data_frame: dataframe
        :return: dataframe pós aplicação da query de transformação
        """
        if self.params_etl.get('transformation_query') != '':
            transformation_query = self.params_etl.get('transformation_query').replace('.', '_')
            transformation_query = self.set_op_column_in_query(transformation_query, data_frame)
            table_name = self.get_table_name(transformation_query)
            data_frame.createOrReplaceTempView(table_name)
            data_frame = self.spark.sql(transformation_query)
        else:

            #Verificando se é carga full, se for criar a coluna Op
            if 'Op' not in data_frame.columns:
                print(f'Não existe a coluna OP: {str(data_frame.columns)}')
                data_frame = data_frame.withColumn('Op', lit('F'))
            
        return data_frame

    @staticmethod
    def set_op_column_in_query(transformation_query, data_frame):
        """
        Adiciona a coluna op na query, caso o campo não exista
        :param transformation_query
        :param data_frame: dataframe
        :return: dataframe pós aplicação da query de transformação
        """
        print(f'Ajustando a query adicionando a coluna OP: {str(data_frame.columns)}')
        if 'Op' in data_frame.columns:
            transformation_query = "SELECT Op," + transformation_query[6:]
        else:
            transformation_query = "SELECT 'F' as Op," + transformation_query[6:]

        print(f'Query ajustada: {transformation_query}')
        return transformation_query

    @staticmethod
    def get_table_name(transformation_query):
        """
        Manipula uma query de transformação de modo a identificar e retornar o nome da tabela

        :param transformation_query: query de transformação
        :return: nome da tabela
        """
        prefix = 'FROM '
        beg = transformation_query.find(prefix) + len(prefix)
        end = transformation_query[beg:].find(' ')
        if end == -1:
            return transformation_query[beg:]
        else:
            end += len(transformation_query[:beg])
        return transformation_query[beg:end]

    def post_request_processes_history(self, process_count, start_time, end_time, status, error_description):
        """
        Realiza uma requisição POST para o endpoint de armazenamento de histórico de processos

        :param process_count: quantidade de registros da tabela
        :param start_time: horário de início da execução do processo
        :param end_time: horário de término da execução do processo
        :param status: status do processo
        :param error_description: descrição de erro do processo
        """
        params_etl = self.params_etl
        params_etl['process_count'] = process_count
        params_etl['start_time'] = start_time
        params_etl['end_time'] = end_time
        params_etl['status'] = status
        params_etl['error_description'] = error_description or ''
        requests.post(self.params.get('url_processes_history'), json = params_etl)


    @staticmethod
    def count_dataframe(df):
        """
        Faz um count no dataframe

        :return: valor inteiro que representa a quantidade de registros do dataframe
        """
        return df.count()

    def merge_process(self):
        """
        Contêm a lógica de merge entre data frames, este processo para que ocorra correto é necessário
        de tres camada de dados a camada de origem (recomendamos a camada raw),
        a camada de merge (recomendamos a camada confiável) e a camada delta (recomendamos a camada refined ou trusted,
        caso optem por trusted não utilizar). Um ponto importante é que os path não sejam o mesmo, e recomendamos este
        tipo de processo sempre utilizar o metodo de persistencia overwrite
        :return: count do dataframe
        """
        print('Inicializando o repositório')
        repository = RepositoryEnum.AWS_S3.value

        print(f'Verificando se existem arquivos no caminho {self.path_bucket_source_to_process} do bucket {self.bucket_source}')
        if repository.verify_path(self.bucket_source, self.path_bucket_source_to_process):

            print(f'Criando o dataframe source: {self.path_bucket_source_processing}')
            df_source = repository.generate_dataframe(self.spark, self.path_source, self.params_etl)

            print(f'Separando registro de operações de delete e update: {self.path_bucket_source_processing}')
            df_source_merge = df_source.where(col('Op').isin(['U', 'D']))
            df_source_merge = df_source_merge.dropDuplicates(['id', 'Op'])

            print(f'Renomeando colunas do dataframe source: {self.path_bucket_source_processing}')
            df_source_merge = self.rename_temp_columns(df_source_merge)

            print(f'Criando o dataframe source: {self.path_bucket_source_processing}')
            df_delta = repository.generate_dataframe_delta_to_parquet(self.spark, self.path_delta_merge)
            df_delta = df_delta.drop('Op')

            print(f'Aplicando merge')
            merge_data_frame = self.merge_dataframes(df_source_merge, df_delta)
            merge_data_frame = self.remove_temp_columns(merge_data_frame)

            print('Adicionando registros')
            data_frame_persist = df_source.where(col('Op') == lit('I'))
            data_frame_persist = self.union_data_frame(data_frame_persist, merge_data_frame)

            print(f'Aplicando query transformation')
            merge_data_frame = self.query_transformation(data_frame_persist)

            print(f'Persistindo no bucket: {self.bucket_target} no caminho: {self.path_bucket_target}')
            repository.persist(merge_data_frame, self.path_target, self.params_etl)
            process_count = self.count_dataframe(data_frame_persist)

            return process_count
        else:
            print(f"Não existe o caminho {self.path_bucket_source_to_process} no bucket {self.bucket_source}")
            return 0

    def upsert_process(self):
        """
        Contêm a lógica de upsert entre data frames, utilizando o delta lake
        :return: count do dataframe
        """
        print('Inicializando o repositório')
        repository = RepositoryEnum.AWS_S3.value

        print(f'Verificando se existem arquivos no caminho {self.path_bucket_source_to_process} do bucket {self.bucket_source}')
        if repository.verify_path(self.bucket_source, self.path_bucket_source_to_process):

            print('Montando join dinamicamente')
            str_join = ""

            if self.params_etl.get('key_fields').find(', ') != -1:
                key_fields = self.params_etl.get('key_fields').split(', ')
            else:
                key_fields = self.params_etl.get('key_fields').split(',')

            for key_field in key_fields:
                if str_join:
                    str_join = f" and oldData.{key_field}  = newData.{key_field}"
                else:
                    str_join = f"oldData.{key_field}  = newData.{key_field}"

            print(f'Criando o data frame source: {self.path_bucket_source_processing}')
            df_source = repository.generate_dataframe(self.spark, self.path_source, self.params_etl)

            print(f'Persistindo op de inserts no bucket: {self.bucket_target} no path: {self.path_target}')
            print(f'Campos utilizados no join: {self.path_bucket_source_processing}')
            data_frame_persist = df_source.where(col('Op') == lit('I'))
            repository.upsert_delta(self.spark, data_frame_persist, self.path_target, str_join)

            print(f'Tratando duplicidade nas operações de update e delete')
            df_source_up_del = df_source.where(col('Op').isin(['U', 'D']))
            df_source_up_del = df_source_up_del.dropDuplicates(['id', 'Op'])

            print(f'Persistindo op de updates e deletes no bucket: {self.bucket_target} no path: {self.path_target}')
            print(f'Campos utilizados no join: {self.path_bucket_source_processing}')
            repository.upsert_delta(self.spark, df_source_up_del, self.path_target, str_join)

            print('Executando count no processo')
            process_count = self.count_dataframe(df_source)

            return process_count
        else:
            print(f"Não existe o caminho {self.path_bucket_source_to_process} no bucket {self.bucket_source}")
            return 0

    def rename_temp_columns(self, data_frame):
        """
        Renomeia as colunas do dataframe
        :param data_frame recebe o dataframe que sofrerá alteração do nome das colunas
        :return: count do dataframe
        """
        columns: List[str] = data_frame.columns
        for column_name in columns:
            if column_name == 'id' or column_name == 'Op':
                continue
            data_frame = data_frame.withColumnRenamed(column_name, f'{column_name}{self.TEMP_NAME_COLUMN}')

        return data_frame

    def remove_temp_columns(self, data_frame):
        """
        Remove as colunas temporárias do dataframe
        :param data_frame recebe o dataframe que sofrerá alteração do nome das colunas
        :return: count do dataframe
        """
        columns: List[str] = data_frame.columns
        for column_name in columns:

            if column_name == 'id' or column_name == 'Op':
                continue

            if column_name.__contains__(self.TEMP_NAME_COLUMN):
                data_frame = data_frame.drop(column_name)

        return data_frame

    def merge_dataframes(self, data_frame_source, data_frame_delta):
        """
        Contêm a lógica de merge entre dois dataframes
        :param data_frame_source dataframe com os dados de origem
        :param data_frame_delta dataframe delta para realizar a comparração
        :return: count do dataframe
        """
        if self.params_etl.get('key_fields').find(', ') != -1:
            key_fields = self.params_etl.get('key_fields').split(', ')
        else:
            key_fields = self.params_etl.get('key_fields').split(',')

        df_join = data_frame_source.join(data_frame_delta, *key_fields, "inner")
        columns: List[str] = df_join.columns

        print(f"Colunas existentes no DF de MERGE: {str(columns)}")

        for column_name in columns:

            if column_name in key_fields or column_name == 'Op':
                continue

            if column_name.__contains__(self.TEMP_NAME_COLUMN ):
                continue

            column_temp = f"{column_name}{self.TEMP_NAME_COLUMN }"
            df_join = df_join.withColumn(column_name, when(col(column_temp).isNull(), col(column_name)).otherwise(col(column_temp)))

        return df_join

    @staticmethod
    def union_data_frame(df_main, df_union):
        """
        Realiza o union entre dois dataframes
        :param df_main dataframe spark
        :param df_union dataframe spark
        :return: dataframe
        """
        columns: List[str] = df_main.columns
        df_main = df_main.select(*columns)
        df_union = df_union.select(*columns)
        return df_main.union(df_union)
