variable "source_package" {
  type = string
}

variable "bucket_name_artifactory" {
  type = string
}

variable "key_lambda_to_s3" {
  type = string
}

variable "layer_name" {
  type = string
}


variable "compatible_runtimes" {
  type = list(string)
  default = ["python3.9"]
}