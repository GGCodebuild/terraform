module lambda_layer_deltalake_smart_open {
  source = "../../modules/Lambda_Layer"
  layer_name = "lambda_layer_deltalake_smart_open_py390"
  bucket_name_artifactory = "${var.bucket_artifactory}-${local.environment}"
  key_lambda_to_s3 = "lambda_layer/deltalake_smart_open_python390.zip"
  source_package = "../../script/lambda_layer/DeltaLake_SmartOpen_Layer.zip"
}

