import sys

sys.path.insert(0, 'package/')

import os
import boto3
from deltalake import DeltaTable
from deltalake.writer import write_deltalake
import pandas as pd
import json

s3_client = boto3.client('s3')
env = os.environ['LAMBDA_ENV'].lower()

ctl_cnpj_fnt = 38166000954

bucket_delta = f"lakehouse-refined-spc-{env}"
path_delta = 'delta_lake/ctle_crga_bcen/'


def lambda_handler(event, context):
    pd.set_option('display.max_columns', None)

    for row in event['rows']:
        typeAction = row['type']

        if typeAction == "DELETE":
            delete(row['filters'])
        elif typeAction == "INSERT":
            insert(row['values'])

    return {
        'statusCode': 200,
        'body': json.dumps(f"Ação executada com sucesso!")
    }


def insert(row):
    print(row)

    dat_ini = (pd.Timestamp.now()) if row['dat_ini_prt'] == "NOW" else pd.Timestamp('1970-01-01')
    dat_fim = (pd.Timestamp.now()) if row['dat_fim_prt'] == "NOW" else pd.Timestamp('1970-01-01')

    data = [[ctl_cnpj_fnt, row['id_pln_exe'], row['id_etp'], row['num_rss'], row['dat_rss'], row['des_cga'],
             row['id_tip_cga'], dat_ini, row['qtd'], dat_fim, int(row['num_particao'])]]

    df = pd.DataFrame(data, columns=['cnpj_fnt', 'id_pln_exe', 'id_etp', 'num_rss', 'dat_rss', 'des_cga', 'id_tip_cga',
                                     'dat_ini_prt', 'qtd', 'dat_fim_prt', 'num_particao'])

    write_delta_table(df)


def delete(row):
    path = "s3://" + bucket_delta + "/" + path_delta
    dt = DeltaTable(path)
    df = dt.to_pandas()
    df['num_particao'] = df['num_particao'].round().fillna(0).astype('int64')

    df = df[~((df['id_pln_exe'] == row['id_pln_exe']) & (df['id_etp'] == row['id_etp']) & (
                df['num_rss'] == row['num_rss']) & (df['dat_rss'] == row['dat_rss']) & (
                          df['des_cga'] == row['des_cga']) & (df['id_tip_cga'] == row['id_tip_cga']))]

    storage_options = {
        "AWS_S3_ALLOW_UNSAFE_RENAME": "true",
    }

    write_deltalake(path, df.reset_index(drop=True), mode='overwrite', storage_options=storage_options)


def write_delta_table(df):
    if df.empty:
        print("Nenhum novo registro foi inserido!")
        return

    storage_options = {
        "AWS_S3_ALLOW_UNSAFE_RENAME": "true",
    }

    path = "s3://" + bucket_delta + "/" + path_delta
    write_deltalake(path, df.reset_index(drop=True), mode='append', storage_options=storage_options)
