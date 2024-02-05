resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  name          = var.name
  database_name = var.database

  table_type = "DELTA"

  parameters = {
    EXTERNAL = "TRUE"
  }

  storage_descriptor {
    location      = var.location
  }
}