import os
import json
import logging
import functions_framework
from google.cloud import storage, bigquery

# Configuração de Logs Estruturados
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("event-driven-pipeline")

# Inicialização dos Clientes GCP
storage_client = storage.Client()
bq_client = bigquery.Client()

DATASET_ID = os.getenv("DATASET_ID", "pipeline_data")
TABLE_ID = os.getenv("TABLE_ID", "processed_records")
PROCESSED_BUCKET = os.getenv("PROCESSED_BUCKET", "gcp-event-driven-pipeline-processed")

@functions_framework.cloud_event
def process_file(cloud_event):
    """
    Função Serverless disparada por evento de upload no Cloud Storage.
    Lê o arquivo JSON, insere os registros no BigQuery e move o arquivo para o bucket de processados.
    """
    data = cloud_event.data
    bucket_name = data.get("bucket")
    file_name = data.get("name")

    logger.info(f"Evento recebido. Arquivo: {file_name} no Bucket: {bucket_name}")

    if not bucket_name or not file_name:
        logger.error("Dados de evento inválidos.")
        return

    try:
        # 1. Leitura do arquivo do Cloud Storage
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        content = blob.download_as_text()
        
        records = json.loads(content)
        if isinstance(records, dict):
            records = [records]

        logger.info(f"Total de registros a processar: {len(records)}")

        # 2. Inserção dos dados no BigQuery
        table_ref = f"{bq_client.project}.{DATASET_ID}.{TABLE_ID}"
        errors = bq_client.insert_rows_json(table_ref, records)
        
        if errors:
            logger.error(f"Erro ao inserir no BigQuery: {errors}")
            raise RuntimeError(f"BigQuery Insert Errors: {errors}")

        logger.info("Dados inseridos com sucesso no BigQuery.")

        # 3. Mover arquivo para o Bucket de Processados
        processed_bucket = storage_client.bucket(PROCESSED_BUCKET)
        bucket.copy_blob(blob, processed_bucket, file_name)
        blob.delete()
        logger.info(f"Arquivo movido com sucesso para o bucket: {PROCESSED_BUCKET}")

    except Exception as e:
        logger.error(f"Falha ao processar o arquivo {file_name}: {str(e)}")
        raise e