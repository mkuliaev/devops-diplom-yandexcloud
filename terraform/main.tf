# Бастион хост
resource "yandex_compute_instance" "bastion" {
  depends_on = [null_resource.network_delay]
  
  name        = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39gh" # Ubuntu 22.04
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

# Веб-серверы
resource "yandex_compute_instance" "web" {
  count       = 2
  depends_on  = [null_resource.network_delay]
  
  name        = "web-${count.index}"
  platform_id = "standard-v3"
  zone        = "ru-central1-${count.index == 0 ? "a" : "b"}"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39gh"
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private[count.index].id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}