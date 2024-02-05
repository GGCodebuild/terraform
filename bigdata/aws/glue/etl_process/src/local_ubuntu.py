from com.spc.process.impl.etl_process import ETLProcess
from com.spc.spark.config.config_enum import ConfigEnum

def local():
    """
    Realiza as configurações para a execução do processo na máquina local
    """
    ETLProcess(ConfigEnum.LOCAL_UBUNTU.value).main_process()


local()