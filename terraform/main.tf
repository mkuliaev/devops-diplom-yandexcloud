# Провайдера Yandex.Cloud
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.87.0"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone

}

# Определение ресурса виртуальной машины
# 1. Создаем пустую VPC
resource "yandex_vpc_network" "vpc_network" {
  name = "kuliaev-vpc"
}

# 2. Публичная подсеть
resource "yandex_vpc_subnet" "public_subnet" {
  name           = "public"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.vpc_network.id
  v4_cidr_blocks = [var.public_cidr]
}

# 3. NAT-инстанс в публичной подсети
resource "yandex_compute_instance" "nat_instance" {
  name        = "nat-instance"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.nat_image_id # Образ с NAT
      size     = 10
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public_subnet.id
    nat        = true       # Публичный IP для NAT-инстанса
    ip_address = var.nat_ip # Фиксированный внутренний IP
  }

  metadata = {
    ssh-keys = "kuliaev:${file("~/.ssh/id_rsa.pub")}"

  }
}

# 4. Виртуалка в публичной подсети
resource "yandex_compute_instance" "public_instance" {
  name        = "public-instance"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id # Ubuntu 24
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public_subnet.id
    nat       = true # включен!
  }

  metadata = {
    ssh-keys = "kuliaev:${file("~/.ssh/id_rsa.pub")}"

  }
}

# 5. Приватная подсеть
resource "yandex_vpc_subnet" "private_subnet" {
  name           = "private"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.vpc_network.id
  v4_cidr_blocks = [var.private_cidr]
  route_table_id = yandex_vpc_route_table.nat_route.id # Привязываем таблицу маршрутизации
}

# 6. Таблица маршрутизации
resource "yandex_vpc_route_table" "nat_route" {
  name       = "nat-route"
  network_id = yandex_vpc_network.vpc_network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.nat_ip # NAT-инстанс
  }
}

# 7. Виртуалка в приватной подсети
resource "yandex_compute_instance" "private_instance" {
  name        = "private-instance"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id # Ubuntu 24
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_subnet.id
    nat       = false # выключен! остаётся только внутренний IP
  }

  metadata = {
    ssh-keys  = "kuliaev:${file("~/.ssh/id_rsa.pub")}"
    user-data = <<-EOF
                #cloud-config

                package_update: true
                packages:
                  - traceroute
                  - sudo
                runcmd:
                  - [systemctl, restart, sshd]
                EOF
  }
}

# Вывод IP-адресов
output "public_instance_ip_PUBLIK" {
  value = yandex_compute_instance.public_instance.network_interface.0.nat_ip_address
}

output "public_instance_ip" {
  value = yandex_compute_instance.public_instance.network_interface.0.ip_address
}

output "private_instance_ip_PUBLIK" {
  value = yandex_compute_instance.private_instance.network_interface.0.nat_ip_address
}

output "private_instance_ip" {
  value = yandex_compute_instance.private_instance.network_interface.0.ip_address
}

output "nat_instance_ip_PUBLIK" {
  value = yandex_compute_instance.nat_instance.network_interface.0.nat_ip_address
}

output "nat_instance_ip" {
  value = yandex_compute_instance.nat_instance.network_interface.0.ip_address
}

