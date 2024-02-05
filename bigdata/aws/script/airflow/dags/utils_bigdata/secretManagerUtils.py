from airflow.providers.amazon.aws.hooks.base_aws import AwsBaseHook

KEY_BUCKET_RAW: str = 'raw'
KEY_BUCKET_TRUSTED: str = 'trusted'
KEY_BUCKET_REFINED: str = 'refined'

def get_buckets_name_secret_manager():
    return {KEY_BUCKET_RAW: get_secret('bucket/raw'),
            KEY_BUCKET_TRUSTED: get_secret('bucket/trusted'),
            KEY_BUCKET_REFINED: get_secret('bucket/refined')}

def get_secret_python_operator(**kwargs):
    secret_id = kwargs['SECRET_KEY']
    return get_secret(secret_id)

def get_secret(secret_id: str) -> str:
    hook = AwsBaseHook(client_type='secretsmanager')
    client = hook.get_client_type('secretsmanager')
    response = client.get_secret_value(SecretId=secret_id)
    secretString = response["SecretString"]

    print(f'### value of credentials: {secretString}')

    return secretString