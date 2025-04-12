provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "default" {
  name = "mkuliaev-net"
}

resource "yandex_vpc_subnet" "subnets" {
  count = 3
  name           = "mkuliaev-subnet-${count.index}"
  zone           = element(["ru-central1-a", "ru-central1-b", "ru-central1-c"], count.index)
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.${count.index}.0/24"]
}


resource "yandex_compute_instance" "master" {
  name = "mkuliaev-master"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnets[0].id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.public_key_path)}"
  }
}

resource "yandex_compute_instance" "worker" {
  count = 2
  name  = "mkuliaev-worker-${count.index}"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnets[count.index + 1].id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.public_key_path)}"
  }
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}