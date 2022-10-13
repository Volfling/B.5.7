terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.80.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = file("C:/Users/Volfling/key.json")
  cloud_id                 = "b1g8lprqm6oj5v0bqmi8"
  folder_id                = "b1go6quhdh703as66uqt"                     
  zone                     =  "ru-central1-a"
} 

resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "subnet1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}

module "ya_instance_1" {
  source                = "C:/Users/Volfling/terraform/test/modules/instance"
  instance_family_image = "lemp"
  vpc_subnet_id         = "${yandex_vpc_subnet.subnet1.id}"
}

module "ya_instance_2" {
  source                = "C:/Users/Volfling/terraform/test/modules/instance"
  instance_family_image = "lamp"
  vpc_subnet_id         = "${yandex_vpc_subnet.subnet1.id}"
}

resource "yandex_lb_target_group" "foo" {
  name      = "my-target-group"
  region_id = "ru-central1"

  target {
    subnet_id = "${yandex_vpc_subnet.subnet1.id}"
    address   = module.ya_instance_1.internal_ip_address_vm
  }

  target {
    subnet_id = "${yandex_vpc_subnet.subnet1.id}"
    address   = module.ya_instance_2.internal_ip_address_vm
  }
}

module "ya_listener" {
  source                = "C:/Users/Volfling/terraform/test/modules/lb"
  target_group_id       = "${yandex_lb_target_group.foo.id}"
}

output "internal_ip_address_vm_1" {
  value = module.ya_instance_1.internal_ip_address_vm
}

output "external_ip_address_vm_1" {
  value = module.ya_instance_1.external_ip_address_vm
}

output "internal_ip_address_vm_2" {
  value = module.ya_instance_2.internal_ip_address_vm
}

output "external_ip_address_vm_2" {
  value = module.ya_instance_2.external_ip_address_vm
}