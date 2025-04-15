resource "yandex_vpc_network" "main" {
  name = "main-network"
}

resource "yandex_vpc_subnet" "private" {
  count       = 2
  name        = "private-${count.index}"
  zone        = "ru-central1-${count.index == 0 ? "a" : "b"}"
  network_id  = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.${count.index}.0/24"]
}

resource "yandex_vpc_subnet" "public" {
  name        = "public"
  zone        = "ru-central1-a"
  network_id  = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.3.0/24"]
}

# Пауза 30 сек после создания сети
resource "null_resource" "network_delay" {
  depends_on = [yandex_vpc_subnet.private, yandex_vpc_subnet.public]
  
  provisioner "local-exec" {
    command = "sleep 30"
  }
}