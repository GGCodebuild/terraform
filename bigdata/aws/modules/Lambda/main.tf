resource "null_resource" "pip" {
  triggers = {
    always_run   = "${timestamp()}"
    main         = base64sha256(file(var.path_filename))
    requirements = base64sha256(file(var.path_file_requirements))
  }

  provisioner "local-exec" {
    command = "pip install -r ${var.path_file_requirements} -t ${var.path_file_package}"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_dir_lambda_zip
  output_path = var.output_path_lambda_zip

  depends_on = [null_resource.pip]
}

resource "aws_lambda_function" "lambda_function" {
  filename      = var.output_path_lambda_zip
  function_name = var.function_name
  role          = var.arn_role
  handler       = "${var.function_name}.lambda_handler"
  timeout       = var.timeout
  layers        = var.layers

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = var.runtime

  vpc_config {
    subnet_ids         = var.subnets_id
    security_group_ids = var.security_groups_id
  }

  environment {
    variables = var.environment_variables
  }

  tags = {
    "SPC:BILLING:VN"           = var.tag_vn
    "SPC:BILLING:CENTROCUSTO"  = var.tag_cost_center
    "SPC:BILLING:PROJETO"      = var.tag_project
    "SPC:AMBIENTE:DATACRIACAO" = var.tag_create_date
    "SPC:AMBIENTE:NOME"        = var.function_name
    "SPC:AMBIENTE:TIPO"        = var.environment
    "SPC:AMBIENTE:SERVICO"     = var.tag_service
  }
}

resource "aws_s3_object" "lambda_to_s3" {
  bucket = var.bucket_name_artifactory
  source = data.archive_file.lambda_zip.output_path
  etag   = md5(data.archive_file.lambda_zip.output_path)
  key    = var.key_lambda_to_s3
}