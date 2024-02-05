import sys

sys.path.insert(0, 'package/')

import os
import boto3
from smart_open import open
from deltalake import DeltaTable
import pandas as pd
from datetime import datetime

s3_client = boto3.client('s3')
env = os.environ['LAMBDA_ENV'].lower()
bucket_delta = f"lakehouse-refined-spc-{env}"
path_delta = 'delta_lake/ctle_crga_bcen/'

bucket_output = f"lakehouse-output-spc-{env}"
output_key = "bcen-scr-reports/"


def lambda_handler(event, context):
    pd.set_option('display.max_columns', None)

    df = read_delta_table()
    df_distinct_rss = df.loc[(df['id_etp'] == 52)][['num_rss', 'dat_rss', 'num_particao']].drop_duplicates()

    for idx, i in df_distinct_rss.iterrows():
        generate_html(df, int(i['num_rss']), int(i['dat_rss']), str(int(i['num_particao'])))
        print("[" + str(int(i['num_rss'])) + "] Relatorio gerado com sucesso!")


def generate_html(df, num_rss, dat_rss, dat_bas):
    # INFO RSS
    dat_rss = datetime.strptime(str(dat_rss), '%Y%m%d').strftime('%d-%m-%Y')
    dat_bas = datetime.strptime(str(dat_bas), '%Y%m').strftime('%m-%Y')
    qtd = df.loc[(df['id_etp'] == 1) & (df['num_rss'] == num_rss)].shape[0]
    data_info_rss = {"num-rss": int(num_rss), "dat-rss": dat_rss, "dat-bas": dat_bas, "qtd": qtd}

    # ARQ REG
    df_files = df.loc[(df['id_etp'] == 1) & (df['num_rss'] == num_rss)][['des_cga', 'id_tip_cga']]

    data_arq_reg_files = []

    for idx, file in df_files.iterrows():
        filename = file['des_cga'].split("/")[2]
        tipo = "Arquivo" if file['id_tip_cga'] == 0 else "Arquivo Bastao"
        data_arq_reg_files.append({"filename": filename, "type": tipo})

    data_arq_reg = {"files": data_arq_reg_files}

    # ETP RSS
    df_files = df.loc[(df['id_etp'] == 47) & (df['num_rss'] == num_rss)][["des_cga"]].drop_duplicates()

    tipos = {1: "cli", 3: "opr", 96: "gar"}

    files = []

    counts_tot = {"cli": 0, "opr": 0, "gar": 0}

    for idx, file in df_files.iterrows():
        filename = file['des_cga'].split("/")[2]
        df_counts = df.loc[(df['id_etp'] == 47) & (df['num_rss'] == num_rss) & (df['des_cga'] == file['des_cga']) & (
            df['id_tip_cga'].isin([1, 3, 96]))][["id_tip_cga", "qtd"]]

        counts = {}

        for i, row in df_counts.iterrows():
            tipo_carga = tipos[row['id_tip_cga']]
            qtd = row['qtd']
            counts[tipo_carga] = int(qtd)
            counts_tot[tipo_carga] = int(counts_tot[tipo_carga] + qtd)

        files.append({
            "filename": filename,
            "counts": counts
        })

    files.append({
        "filename": "Todos",
        "counts": counts_tot
    })

    data_etp_rss = {
        "files": files
    }

    # ETP BAS
    df_etp_bas = df.loc[(df['id_etp'] == 8) & (df['num_rss'] == num_rss)][["des_cga", "id_tip_cga", "qtd"]]
    etp_bas_tips = {1: 0, 58: 0, 3: 0, 59: 0, 96: 0, 98: 0, 54: 0}

    for key in etp_bas_tips:
        df_handle = df_etp_bas.loc[(df['id_tip_cga'] == key)]
        if df_handle.shape[0] > 0:
            etp_bas_tips[key] = int(df_handle.iloc[0]['qtd'])

    data_etp_bas = {
        "trusted": {
            "cli": etp_bas_tips[1],
            "opr": etp_bas_tips[3],
            "gar": etp_bas_tips[96]
        },
        "garbage": {
            "cli": etp_bas_tips[58],
            "opr": etp_bas_tips[59],
            "gar": etp_bas_tips[98]
        },
        "erros": etp_bas_tips[54]
    }

    # STA-ETP

    count_tot_etps = 0
    count_ok_etps = 0

    # ETP - RSS - VALIDACAO XSD
    etp_rss_vld_xsd_status = "OK" if df.loc[(df['id_tip_cga'] == 97) & (df['num_rss'] == num_rss)].shape[
                                         0] > 0 else "PENDENTE"
    etp_rss_vld_xsd = {
        "status": etp_rss_vld_xsd_status,
        "title": "Validação XSD",
        "child": []
    }

    # ETP - RSS - PROCESSAMENTO ARQUIVOS
    df_files = df.loc[(df['id_etp'] == 47) & (df['num_rss'] == num_rss)][["des_cga"]].drop_duplicates()

    list_tip_cga = [9, 1, 3, 96]
    list_tip_cga_desc = ["Historico", "Cliente", "Operacao", "Garantia"]
    child_geral = []
    status_global = "OK" if df_files.shape[0] > 0 else "PENDENTE"

    for idx, file in df_files.iterrows():
        filename = file['des_cga'].split("/")[2]
        child = []
        status_geral = "OK"

        for i, id_tip_cga in enumerate(list_tip_cga):
            status = "OK" if df.loc[(df['id_tip_cga'] == id_tip_cga) & (df['num_rss'] == num_rss)].shape[
                                 0] > 0 else "PENDENTE"
            child.append({
                "status": status,
                "title": list_tip_cga_desc[i],
                "child": []
            })

            count_tot_etps += 1
            if status == "OK":
                count_ok_etps += 1

            if status_geral == "OK" and status == "PENDENTE":
                status_geral = "PENDENTE"

        child_geral.append({
            "status": status_geral,
            "title": filename,
            "child": child
        })

        if status_global == "OK" and status_geral == "PENDENTE":
            status_global = "PENDENTE"

    etp_rss_proc = {
        "status": status_global,
        "title": "Processamento arquivos",
        "child": child_geral
    }

    etp_rss_status = "OK" if etp_rss_vld_xsd_status == "OK" and status_global == "OK" else "PENDENTE"
    etp_rss = {
        "status": etp_rss_status,
        "title": "Etapa Remessa",
        "child": [etp_rss_vld_xsd, etp_rss_proc]
    }

    # ETP - BAS
    order = {1: 0, 58: 0, 3: 0, 59: 0, 96: 0, 98: 0, 54: 0}
    order_desc = [
        "Clientes Validos", "Clientes Invalidas", "Operacoes Validas", "Operacoes Invalidas", "Garantias Validas",
        "Garantias Invalidas", "Ocorrencias de erros"
    ]

    for key in order:
        df_handle = df.loc[(df['id_etp'] == 8) & (df['num_rss'] == num_rss) & (df['id_tip_cga'] == key)]
        if df_handle.shape[0] > 0:
            order[key] = df_handle.iloc[0]['num_particao']

    etp_bas_child = []
    etp_bas_status = "OK"

    for idx in range(1, 6):
        child_partition = []
        partition_status = "OK"
        for i, key in enumerate(order):
            status = "OK" if idx <= order[key] else "PENDENTE"
            child_partition.append({
                "status": status,
                "title": order_desc[i],
                "child": []
            })

            count_tot_etps += 1
            if (status == "OK"):
                count_ok_etps += 1

            if (partition_status == "OK" and status == "PENDENTE"):
                partition_status = "PENDENTE"

        etp_bas_child.append({
            "status": partition_status,
            "title": "Bloco " + str(idx),
            "child": child_partition
        })

        if (etp_bas_status == "OK" and partition_status == "PENDENTE"):
            etp_bas_status = "PENDENTE"

    etp_bas = {
        "status": etp_bas_status,
        "title": "Etapa Base",
        "child": etp_bas_child
    }

    data_sta_etp = [etp_rss, etp_bas]

    # STA GERAL
    percent = (count_ok_etps / count_tot_etps) * 100
    title = "Finalizado" if percent == 100 else "Em andamento..."
    data_sta_geral = {"title": title, "percent": percent}

    data = {
        "sta-geral": data_sta_geral,
        "info-rss": data_info_rss,
        "arq-reg": data_arq_reg,
        "etp-rss": data_etp_rss,
        "etp-bas": data_etp_bas,
        "sta-etp": data_sta_etp
    }

    template = get_template()
    html = template.replace("{{json_origem}}", str(data))

    now = datetime.now().strftime('%Y%m%d%H%M%S')
    output_filename = "scr-report-" + str(num_rss) + "-" + now + ".html"
    s3_client.put_object(Body=html, Bucket=bucket_output, Key=output_key + output_filename)


def get_template():
    with open('./template.html', 'r', encoding="utf-8") as f:
        template = f.read()

    return template


def read_delta_table():
    dt = DeltaTable("s3://" + bucket_delta + "/" + path_delta)
    df = dt.to_pandas()

    return df
