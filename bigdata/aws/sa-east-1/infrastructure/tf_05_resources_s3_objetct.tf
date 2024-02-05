module "object_bucket_dag_airflow" {
  source      = "../../modules/S3_Object"
  bucket_id   = "${var.bucket_dags}-${local.environment}"
  local_path  = "../../script/airflow/dags"
  remote_path = "airflow/dags/"
}

module "object_bucket_dag_utils" {
  source      = "../../modules/S3_Object"
  bucket_id   = "${var.bucket_dags}-${local.environment}"
  local_path  = "../../script/airflow/dags/utils_bigdata"
  remote_path = "airflow/dags/utils_bigdata"
}

module "object_bucket_dag_config_submit" {
  source      = "../../modules/S3_Object"
  bucket_id   = "${var.bucket_dags}-${local.environment}"
  local_path  = "../../script/airflow/config/${local.environment}/cluster"
  remote_path = "airflow/config/${local.environment}/cluster"
}

module "object_bucket_dag_config_step" {
  source      = "../../modules/S3_Object"
  bucket_id   = "${var.bucket_dags}-${local.environment}"
  local_path  = "../../script/airflow/config/${local.environment}/step"
  remote_path = "airflow/config/${local.environment}/step"
}


module "object_bucket_artifactory_scala" {
  source      = "../../modules/S3_Object"
  bucket_id   = "${var.bucket_artifactory}-${local.environment}"
  local_path  = "../../deploy"
  remote_path = "emr/scala_source"
}

