variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  sensitive   = true
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
  sensitive   = true
}

variable "yc_zone" {
  description = "Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "public_cidr" {
  description = "CIDR for public subnet"
  type        = string
  default     = "192.168.10.0/24"
}

variable "private_cidr" {
  description = "CIDR for private subnet"
  type        = string
  default     = "192.168.20.0/24"
}

variable "nat_ip" {
  description = "NAT instance internal IP"
  type        = string
  default     = "192.168.10.254"
}

variable "nat_image_id" {
  description = "NAT instance image id"
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1"
}

variable "ubuntu_image_id" {
  description = "Ubuntu 24 image id"
  type        = string
  default     = "fd8ou6hurlbfqmi57ofd"
}