import requests

class ConfigETL:
    """
    Classe de configuração para execução do ETL
    """

    @staticmethod
    def get_request_params(params):
        """
        Faz uma requisição a um endpoint que contêm os parâmetros necessários para o processo

        :return: dicionário contendo parâmetros necessários para o processo
        """
        uri = f"{params.get('url_config')}{params.get('process_name')}_{params.get('layer_process')}"
        response = requests.get(uri)
        return response.json()[0]


    @staticmethod
    def get_buckets_and_paths(params):
        """
        Pega o nome dos buckets e os caminhos que serão utilizados
        
        :return: dicionário contendo dicionários com nomes e caminhos dos buckets source e target
        """
        source = params.get('source_path')
        target = params.get('target_path')
        delta = params.get('delta_path')
        buckets_path = []
        buckets = []
        paths = []

        buckets_path.append(source)
        buckets_path.append(target)
        buckets_path.append(delta)

        for i in range(len(buckets_path)):
            prefix = 's3://'
            beg = buckets_path[i].find(prefix) + len(prefix)
            end = buckets_path[i][beg:].find('/') + len(prefix)
            buckets.append(buckets_path[i][beg:end])
            paths.append(buckets_path[i][end + 1:])

        return {'source_bucket_name': buckets[0], 'source_bucket_path': paths[0],
                'target_bucket_name': buckets[1], 'target_bucket_path': paths[1],
                'delta_bucket_name': buckets[2], 'delta_bucket_path': paths[2]}