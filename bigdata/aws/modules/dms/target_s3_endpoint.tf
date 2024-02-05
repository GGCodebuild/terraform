resource "aws_dms_endpoint" "target" {
  endpoint_id   = var.endpoint_id_target
  endpoint_type = "target"
  engine_name   = "s3"

  s3_settings {
    add_column_name                   = false
    bucket_folder                     = ""
    bucket_name                       = var.bucket_name_target
    canned_acl_for_objects            = "NONE"
    cdc_inserts_and_updates           = false
    cdc_inserts_only                  = false
    #cdc_max_batch_interval            = 300
    #cdc_min_file_size                 = 320
    cdc_path                          = var.cdc_path_s3
    compression_type                  = "NONE"
    csv_delimiter                     = ","
    csv_no_sup_value                  = "NONE"
    csv_null_value                    = "NONE"
    csv_row_delimiter                 = "\\n"
    #data_page_size                    = 10
    #dict_page_size_limit              = 10
    data_format                       = var.data_format_target
    date_partition_delimiter          = "NONE"
    date_partition_enabled            = var.date_partition_enabled_target
    date_partition_sequence           = "YYYYMMDD"
    enable_statistics                 = false
    encoding_type                     = "rle-dictionary" #plain plain-dictionary rle-dictionary
    encryption_mode                   = "SSE_S3"
    external_table_definition         = "NONE"
    ignore_headers_row                = 1
    include_op_for_full_load          = false
    #max_file_size                     = 1048576
    parquet_timestamp_in_millisecond  = false
    parquet_version                   = var.parquet_version_target
    preserve_transactions             = false
    rfc_4180                          = false
    #row_group_length                  = 10000
    service_access_role_arn           = var.service_access_role_arn_target
    server_side_encryption_kms_key_id = "NONE"
    timestamp_column_name             = var.timestamp_column_name_target
    use_csv_no_sup_value              = false

  }

  extra_connection_attributes = ""

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.endpoint_id_target
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = "DMS-Endpoint-target"
  }
}