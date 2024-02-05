from awsglue.utils import getResolvedOptions
from pyspark.sql import SparkSession
import sys

class ConfigAWSGlue:
    """
    Classe de configuração para execução do ETL em ambiente AWS Glue
    """

    def init_spark(self, params_etl):
        """
        Inicia o Spark

        :param params_etl: parâmetros do arquivo de configuração do ETL
        :return: instância do Spark
        """
        app_name = f"{params_etl.get('process_name')}_{params_etl.get('layer_process')}"

        spark_builder = SparkSession.builder \
            .appName(app_name) \
            .config('spark.sql.inMemoryColumnarStorage.compressed', 'true') \
            .config('spark.sql.legacy.parquet.datetimeRebaseModeInRead', 'LEGACY') \
            .config('spark.sql.legacy.parquet.datetimeRebaseModeInWrite', 'LEGACY') \
            .config('spark.sql.legacy.avro.datetimeRebaseModeInRead', 'LEGACY') \
            .config('spark.sql.legacy.avro.datetimeRebaseModeInWrite', 'LEGACY') \
            .config('spark.sql.parquet.int96RebaseModeInRead', 'LEGACY') \
            .config('spark.sql.parquet.int96RebaseModeInWrite', 'LEGACY')
        
        if params_etl.get('target_file_format') == 'delta':

            spark_builder.config('spark.sql.extensions', 'io.delta.sql.DeltaSparkSessionExtension') \
                .config('spark.sql.catalog.spark_catalog','org.apache.spark.sql.delta.catalog.DeltaCatalog')

        return spark_builder.getOrCreate()


    @staticmethod
    def get_parameters():
        """
        Retorna um dicionário de parâmetros necessários para a execução do processo
        
        :return: dicionário contendo parâmetros necessários para a execução do processo
        """
        args = getResolvedOptions(sys.argv, ['url_config',
                                             'url_processes_history',
                                             'process_name',
                                             'layer_process',
                                             'bucket_artifactory'])

        return {'url_config': args['url_config'],
                'url_processes_history': args['url_processes_history'],
                'process_name': args['process_name'],
                'layer_process': args['layer_process'],
                'bucket_artifactory': args['bucket_artifactory']}