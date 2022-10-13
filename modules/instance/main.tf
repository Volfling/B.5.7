terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.80.0"
    }
  }
}

data "yandex_compute_image" "my_image" {
  family = var.instance_family_image
}

resource "yandex_compute_instance" "vm" {
  name = "${var.instance_family_image}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.id
    }
  }

  network_interface {
    subnet_id = var.vpc_subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = file("C:/Users/Volfling/.ssh/id_rsa.pub")
  }
}

output "internal_ip_address_vm" {
  value = yandex_compute_instance.vm.network_interface.0.ip_address
}

output "external_ip_address_vm" {
  value = yandex_compute_instance.vm.network_interface.0.nat_ip_address
}

variable "instance_family_image" {
  description = "Instance image"
  type        = string
  default     = "lamp"

}

variable "vpc_subnet_id" {
  description = "VPC subnet network id"
  type        = string
}
