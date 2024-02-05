variable "bucket_arn" {
  type        = string
  description = "ID do bucket"
}

variable "expiration_days" {
  type = number
}

variable "filter_path" {
  type = string
}