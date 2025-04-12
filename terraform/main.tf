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