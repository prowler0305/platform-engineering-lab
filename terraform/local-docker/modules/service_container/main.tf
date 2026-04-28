terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "service" {
  name = var.image_name
  build {
    context    = var.build_context_path
    dockerfile = var.dockerfile_path
  }
}

resource "docker_container" "service" {
  name  = var.container_name
  image = docker_image.service.image_id

  env = var.env

  networks_advanced {
    name = var.network_name
  }

  dynamic "ports" {
    for_each = var.ports

    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }
}