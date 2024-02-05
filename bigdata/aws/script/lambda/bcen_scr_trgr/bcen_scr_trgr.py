import sys

sys.path.insert(0, 'package/')

import os
import boto3
from smart_open import open
import re
from deltalake import DeltaTable
from deltalake.writer import write_deltalake
import pandas as pd
import json

s3_client = boto3.client('s3')
env = os.environ['LAMBDA_ENV'].lower()
bucket_landing = f"lakehouse-landing-zone-spc-{env}"
path_landing = 'xml/cadpos/bcen/scr/rcmt/'

bucket_delta = f"lakehouse-refined-spc-{env}"
path_delta = 'delta_lake/ctle_crga_bcen/'

# Controle de carga
ctl_cnpj_fnt = 38166000954
ctl_id_pln_exe = 45
ctl_id_etp_arquivos = 1
ctl_id_etp_controle = 52
ctl_id_tip_cga_parquet = 25
ctl_id_tip_cga_arquivo = 0
ctl_id_tip_cga_bastao = 10
ctl_qtd = 0
ctl_num_particao = 0


def lambda_handler(event, context):
    pd.set_option('display.max_columns', None)

    print("Lendo dataframe de controle...")
    df_base = read_delta_table(ctl_id_etp_arquivos)

    print("DataFrame de controle: ")
    print(df_base)

    #start_date = get_start_date(df_base)
    start_date = "0"
    print("Data de recorte: " + start_date)

    folders = list_folders_on_s3(start_date)
    print("Lista de diretorios encontrados: ")
    print(folders)

    files = list_files_on_s3(folders)
    print("Lista de arquivos encontrados: ")
    print(files)

    print("Gerando Dataframe com novos arquivos...")
    df_list = generate_dataframe(files)
    # print(df_list)

    print("Removendo arquivos já registrados...")
    df_write = merge_dataframe(df_list, df_base)
    # print(df_write)

    print("Escrevendo lista arquivos...")
    write_delta_table(df_write)

    df_write['id_etp'] = ctl_id_etp_controle
    df_write['id_tip_cga'] = ctl_id_tip_cga_parquet
    df_write['des_cga'] = "PROCESSAMENTO REMESSA"
    df_write['dat_fim_prt'] = pd.Timestamp('1970-01-01')

    df_ctl = generate_dataframe_ctl(df_write)

    print("Escrevendo controle...")
    write_delta_table(df_ctl)

    execute_crawler()

    return {
        'statusCode': 200,
        'body': json.dumps(f"Estimulo inicial rodou com sucesso!")
    }


def execute_crawler():
    try:
        glue = boto3.client('glue')
        crawler_name = 'ctle_crga_bcen_refined_delta'
        response = glue.start_crawler(Name=crawler_name)

        return response
    except:
        print("Crawler não existe ou já está em execução.")


def merge_dataframe(df_insert, df_base):
    if df_base.empty:
        return df_insert

    df_merge = df_insert.merge(df_base, on='des_cga', how='left', indicator=True)
    df = df_merge.loc[df_merge['_merge'] == 'left_only', 'des_cga']

    return df_insert[df_insert['des_cga'].isin(df)]


def get_start_date(df_base):
    if df_base.empty:
        return "0"

    df_base['str_dat'] = df_base['des_cga'].str.split("/").str[0]
    df_base['start_date_format'] = df_base['str_dat'].str.split("-").str[2] \
                                   + df_base['str_dat'].str.split("-").str[1] \
                                   + df_base['str_dat'].str.split("-").str[0]

    df_ordenado = df_base.sort_values(by='start_date_format', ascending=False)

    return df_ordenado['start_date_format'].iloc[0]


def generate_dataframe(files):
    data = []

    for item in files:
        lines = read_file(item, 3)
        ctl_num_part, ctl_num_rss, clt_id_tip_cga_arq = extract_attr(lines)
        ctl_des_cga, ctl_dat_rss = slice_path(item)

        # Linha do arquivo
        data.append([ctl_cnpj_fnt, ctl_id_pln_exe, ctl_id_etp_arquivos, ctl_num_rss, ctl_dat_rss, ctl_des_cga,
                     clt_id_tip_cga_arq, pd.Timestamp.now(), ctl_qtd, pd.Timestamp.now(), ctl_num_part])

    df = pd.DataFrame(data, columns=['cnpj_fnt', 'id_pln_exe', 'id_etp', 'num_rss', 'dat_rss', 'des_cga', 'id_tip_cga',
                                     'dat_ini_prt', 'qtd', 'dat_fim_prt', 'num_particao'])

    return df


def generate_dataframe_ctl(df):
    if df.empty:
        return df

    df_unique = df.drop_duplicates(subset=['num_rss', 'dat_rss'])
    df_rmss = read_delta_table(ctl_id_etp_controle)

    if df_rmss.empty:
            return df_unique

    df_merge = df_unique.merge(df_rmss, on='num_rss', how='left', indicator=True)
    df_final = df_merge.loc[df_merge['_merge'] == 'left_only', 'num_rss']

    return df_unique[df_unique['num_rss'].isin(df_final)]


def read_delta_table(id_etp):
    if not folder_exist_on_s3(bucket_delta, path_delta):
        return pd.DataFrame()

    dt = DeltaTable("s3://" + bucket_delta + "/" + path_delta)
    df = dt.to_pandas()

    return df[(df['id_pln_exe'] == ctl_id_pln_exe) & (df['id_etp'] == id_etp)]


def write_delta_table(df):
    if df.empty:
        print("Nenhum novo registro foi inserido!")
        return

    storage_options = {
        "AWS_S3_ALLOW_UNSAFE_RENAME": "true",
    }

    path = "s3://" + bucket_delta + "/" + path_delta
    write_deltalake(path, df.reset_index(drop=True), mode='append', storage_options=storage_options)


def slice_path(path):
    des_cga = path[path.index('rcmt/') + 5:]
    dat_rss = des_cga.split("/")[2][15:23]
    return des_cga, dat_rss


def folder_exist_on_s3(bucket_name, folder_path):
    response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=folder_path, MaxKeys=5)

    count = 0
    if 'Contents' in response:
        count = len(response['Contents'])

    return count > 1


def list_folders_on_s3(start_date):
    target = []

    response = s3_client.list_objects_v2(
        Bucket=bucket_landing,
        Prefix=path_landing,
        Delimiter='/'
    )

    if 'CommonPrefixes' in response:
        for directory in response['CommonPrefixes']:
            item = directory['Prefix']
            handle_date = item[item.index('rcmt/') + 5:item.index('rcmt/') + 15].replace("-", "")
            if int(handle_date) >= int(start_date):
                target.append(item)

    return target


def list_files_on_s3(folders):
    target = []
    for path in folders:
        response = s3_client.list_objects_v2(
            Bucket=bucket_landing,
            Prefix=path
        )

        if 'Contents' in response:
            for obj in response['Contents']:
                if obj['Key'].find(".xml") != -1:
                    target.append(obj['Key'])

    return target


def read_file(path, lines):
    full_path = f's3://{bucket_landing}/{path}'
    head = ""

    with open(full_path, 'r') as file:
        for _ in range(lines):
            line = file.readline()
            if line:
                head = head + line

    return head


def extract_attr(text):
    pattern = r'DtBase="(.*?)" DtAtualBase="(.*?)" NrRemessa="(.*?)"'
    matches = re.search(pattern, text)

    typeFile = ctl_id_tip_cga_bastao if re.search(r'TpArq="F"', text) else ctl_id_tip_cga_arquivo

    if matches:
        return int(matches.group(1).replace("-", "")), int(matches.group(3)), typeFile
