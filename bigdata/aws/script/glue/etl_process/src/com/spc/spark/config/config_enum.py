from com.spc.spark.config.impl.config_aws_glue import ConfigAWSGlue
from com.spc.spark.config.impl.config_local_ubuntu import ConfigLocalUbuntu
from enum import Enum

class ConfigEnum(Enum):
    """
    Enumerator instanciador de classes de configuração
    """
    AWS_GLUE = ConfigAWSGlue()
    LOCAL_UBUNTU = ConfigLocalUbuntu()