import boto3

from delta.tables import DeltaTable
from pyspark.sql.functions import lit

class AwsS3Repository:
    """
    Classe de utilitários para manipulação de arquivos no bucket S3
    """

    @staticmethod
    def verify_path(bucket_name, bucket_path):
        """
        Verifica se o caminho existe no bucket
        :param bucket_name: nome do bucket
        :param bucket_path: caminho do bucket
        :return: True caso o caminho exista e False caso contrário
        """
        s3 = boto3.client('s3')
        result = s3.list_objects(Bucket=bucket_name, Prefix=bucket_path)
        if 'Contents' in result:
            return True
        return False

    def generate_dataframe(self, spark, path, params):
        """
        Transforma um arquivo em um Dataframe

        :param spark: instância do Spark
        :param path: caminho do bucket onde se encontra o arquivo que será convertido em um Dataframe
        :param params: dicionário contendo diversos parâmetros referentes ao arquivo de configuração
        :return: dataframe
        """
        if params.get('source_file_format').lower() == 'csv':
            return self.generate_from_csv_to_dataframe(spark, params, path)
        elif params.get('source_file_format').lower() == 'parquet':
            return self.generate_from_parquet_to_dataframe(spark, path)

    @staticmethod
    def generate_dataframe_delta_to_parquet(spark, path):
        return spark.read.format('delta').load(path)

    @staticmethod
    def generate_from_csv_to_dataframe(spark, params, path):
        """
        Transforma um arquivo CSV em um Dataframe

        :param spark: instância do Spark
        :param params: dicionário contendo diversos parâmetros referentes ao arquivo de configuração
        :param path: caminho do bucket onde se encontra o arquivo CSV que será convertido em um Dataframe
        :return: dataframe
        """
        return spark.read.format('csv') \
            .option("header", "true").option("delimiter", params.get('source_file_delimiter')).load(path)


    @staticmethod
    def generate_from_parquet_to_dataframe(spark, path):
        """
        Transforma um arquivo Parquet em um Dataframe

        :param spark: instância do Spark
        :param path: caminho do bucket onde se encontra o arquivo Parquet que será convertido em um Dataframe
        :return: dataframe
        """
        return spark.read.parquet(path)
    

    def persist(self, data_frame, path, params):
        """
        Transforma um Dataframe no formato desejado e insere em um caminho no bucket

        :param data_frame: dataframe
        :param path: caminho do bucket onde será inserido o arquivo
        :param params: dicionário contendo diversos parâmetros referentes ao arquivo de configuração
        """
        if params.get('target_file_format').lower() == 'parquet':
            self.persist_parquet(data_frame, params, path)
        elif params.get('target_file_format').lower() == 'delta':
            self.persist_delta(data_frame, params, path)


    @staticmethod
    def persist_parquet(data_frame, params, path):
        """
        Transforma um Dataframe em Parquet e insere em um caminho no bucket

        :param data_frame: dataframe
        :param params: dicionário contendo diversos parâmetros referentes ao arquivo de configuração
        :param path: caminho do bucket onde será inserido o arquivo
        """

        #Esta regra foi necessária pora forçar o persistencia do tipo merge seja processada como overwrite
        persistence_mode = params.get('persistence_mode')
        if params.get('persistence_mode') == 'merge':
            persistence_mode = 'overwrite'

        if params.get('fields_to_partition') == '':
            data_frame.write.mode(persistence_mode).parquet(path)
        else:
            if params.get('fields_to_partition').find(', ') != -1:
                fields_to_partition = params.get('fields_to_partition').split(', ')
            else:
                fields_to_partition = params.get('fields_to_partition').split(',')

            data_frame.write.partitionBy(*fields_to_partition).mode(persistence_mode).parquet(path)


    @staticmethod
    def persist_delta(data_frame, params, path):
        """
        Transforma um Dataframe em Delta e insere em um caminho no bucket

        :param data_frame: dataframe
        :param params: dicionário contendo diversos parâmetros referentes ao arquivo de configuração
        :param path: caminho do bucket onde será inserido o arquivo
        """
        if params.get('fields_to_partition') == '':
            data_frame.write.format('delta').mode(params.get('persistence_mode'))\
                .option("mergeSchema", "true").save(path)
        else:
            if params.get('fields_to_partition').find(', ') != -1:
                fields_to_partition = params.get('fields_to_partition').split(', ')
            else:
                fields_to_partition = params.get('fields_to_partition').split(',')

            data_frame.write.partitionBy(*fields_to_partition) \
                .format('delta').mode(params.get('persistence_mode')).option("mergeSchema", "true") \
                .save(path)

    @staticmethod
    def upsert_delta(spark, data_frame, path_delta, str_join):
        """
        Realiza o upsert dos registros no bucket S3, utilizando delta lake
        :param spark instancia do spark
        :param data_frame: dataframe
        :param path_delta: path do bucket s3 onde estão os arquivos delta
        :param str_join: instrução do join entre os dataframes
        """

        print(f'Criando o data frame source: {path_delta}')
        delta_table = DeltaTable.forPath(spark, path_delta)

        delta_table.alias("oldData").merge(data_frame.alias("newData"), str_join) \
            .whenMatchedUpdateAll() \
            .whenNotMatchedInsertAll() \
            .execute()


    @staticmethod
    def move_object(source_bucket_name, source_bucket_path, target_bucket_name, target_bucket_path):
        """
        Move um único objeto de um caminho em um bucket para outro caminho em um bucket

        :param source_bucket_name: nome do bucket onde o arquivo se encontra
        :param source_bucket_path: caminho do bucket onde o arquivo se encontra
        :param target_bucket_name: nome do bucket para qual o arquivo será movido
        :param target_bucket_path: caminho do bucket para qual o arquivo será movido
        """
        s3 = boto3.client('s3')
        s3.copy_object(CopySource=f'{source_bucket_name}/{source_bucket_path}', Bucket=target_bucket_name,
                       Key=target_bucket_path)

        s3.delete_object(Bucket=source_bucket_name, Key=source_bucket_path)


    @staticmethod
    def move_objects(source_bucket_name, source_bucket_path, target_bucket_name, target_bucket_path):
        """
        Move todos os objetos de um caminho em um bucket para outro caminho em um bucket

        :param source_bucket_name: nome do bucket onde os arquivos se encontram
        :param source_bucket_path: caminho do bucket onde os arquivos se encontram
        :param target_bucket_name: nome do bucket para qual os arquivos serão movidos
        :param target_bucket_path: caminho do bucket para qual os arquivos serão movidos
        """
        s3 = boto3.client('s3')
        result = s3.list_objects(Bucket=source_bucket_name, Prefix=source_bucket_path)

        for object in result['Contents']:

            if object['Key'] in [source_bucket_path]:
                continue
            
            if str(object['Key']).__contains__(f'{source_bucket_path}processed') or \
                str(object['Key']).__contains__(f'{source_bucket_path}work-in-progress'):
                continue

            filename = object['Key'][object['Key'].rfind('/') + 1:]
            print(f'Source: {source_bucket_name}/{source_bucket_path}{filename}')
            print(f'Bucket Target: {target_bucket_name}')
            print(f'Key Target: {target_bucket_path}{filename}')
            s3.copy_object(CopySource=f'{source_bucket_name}/{source_bucket_path}{filename}', Bucket=target_bucket_name,
                           Key=f'{target_bucket_path}{filename}')

            s3.delete_object(Bucket=source_bucket_name, Key=object['Key'])