from com.spc.repository.impl.aws_s3_repository import AwsS3Repository
from enum import Enum

class RepositoryEnum(Enum):
    """
    Enumerator instanciador de classes de repositório
    """
    AWS_S3 = AwsS3Repository()