terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "mkuliaev-terraform-state"
    region                      = "ru-central1"
    key                         = "global/s3/terraform.tfstate"
    access_key                  = var.access_key
    secret_key                  = var.secret_key
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
