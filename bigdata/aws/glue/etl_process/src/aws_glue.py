from com.spc.process.impl.etl_process import ETLProcess
from com.spc.spark.config.config_enum import ConfigEnum

def glue():
    """
    Realiza as configurações para a execução do processo no AWS Glue
    """
    ETLProcess(ConfigEnum.AWS_GLUE.value).main_process()


glue()