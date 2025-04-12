variable "cloud_id" {
  description = "Ваш Cloud ID в Yandex.Cloud"
}

variable "folder_id" {
  description = "Ваш Folder ID в Yandex.Cloud"
}

variable "access_key" {
  description = "Access key для S3"
}

variable "secret_key" {
  description = "Secret key для S3"
}


variable "ssh_user" {
  default = "ubuntu"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}