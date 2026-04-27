terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "order_processor" {
  name = "order-processor"
  build {
    context    = var.build_context_path
    dockerfile = "services/order-processor/Dockerfile"
  }
}

resource "docker_container" "order_processor" {
  name  = "order-processor"
  image = docker_image.order_processor.image_id
  networks_advanced {
    name = var.network_name
  }
  env = [
    "KAFKA_BOOTSTRAP_SERVERS=${var.bootstrap_servers}"
  ]
}