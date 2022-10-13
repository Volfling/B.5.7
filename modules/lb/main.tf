terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.80.0"
    }
  }
}

resource "yandex_lb_network_load_balancer" "foo" {
  name = "my-network-load-balancer"

  listener {
    name = "my-listener"
    port = 80

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = var.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

variable "target_group_id" {
  type        = string
}