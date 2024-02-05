import os
from pyspark.sql import SparkSession

class ConfigLocalUbuntu:
    """
    Classe de configuração para execução do ETL em ambiente local
    """

    def init_spark(self, params_etl):
        """
        Inicia o Spark configurando as credenciais das variáveis de ambiente para acessar as API's da AWS de forma local, no Ubuntu
        
        :param params_etl: parâmetros do arquivo de configuração do ETL
        :return: instância do Spark
        """
        app_name = f"{params_etl.get('process_name')}_{params_etl.get('layer_process')}"

        spark_builder = SparkSession.builder \
            .appName(app_name) \
            .config('spark.hadoop.fs.s3a.access.key', os.getenv('AWS_ACCESS_KEY_ID')) \
            .config('spark.hadoop.fs.s3a.secret.key', os.getenv('AWS_SECRET_ACCESS_KEY')) \
            .config('spark.hadoop.fs.s3a.session.token', os.getenv('AWS_SESSION_TOKEN')) \
            .config('spark.sql.inMemoryColumnarStorage.compressed', 'true') \
            .config('spark.sql.legacy.parquet.datetimeRebaseModeInRead', 'LEGACY') \
            .config('spark.sql.legacy.parquet.datetimeRebaseModeInWrite', 'LEGACY') \
            .config('spark.sql.legacy.avro.datetimeRebaseModeInRead', 'LEGACY') \
            .config('spark.sql.legacy.avro.datetimeRebaseModeInWrite', 'LEGACY') \
            .config('spark.sql.parquet.int96RebaseModeInRead', 'LEGACY') \
            .config('spark.sql.parquet.int96RebaseModeInWrite', 'LEGACY')
        
        if params_etl.get('target_file_format') == 'delta':

            spark_builder.config("spark.jars.packages", "io.delta:delta-core_2.12:2.2.0") \
            .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
            .config("spark.sql.catalog.spark_catalog","org.apache.spark.sql.delta.catalog.DeltaCatalog") \
            .config("spark.databricks.delta.retentionDurationCheck.enabled", "false")
            
            # spark.sparkContext.addPyFile(f"s3://{self.get_parameters().get('bucket_artifactory')}/glue/lib/delta-core_2.12-1.1.0.jar")

        return spark_builder.getOrCreate()
    
    
    @staticmethod
    def get_parameters():
        """
        Retorna um dicionário de parâmetros necessários para a execução do processo
        
        :return: dicionário contendo parâmetros necessários para a execução do processo
        """
        return {'url_config': 'https://31kkygzqxh-vpce-0f3946a58ebd76078.execute-api.sa-east-1.amazonaws.com/management-process/operator?fileName=',
                'url_processes_history': 'https://z37298kq97-vpce-0f3946a58ebd76078.execute-api.sa-east-1.amazonaws.com/management-process/operator',
                'process_name': 'consulta_realizada',
                'layer_process': 'raw',
                'bucket_artifactory': 'lakehouse-artifactory-spc-dev'}