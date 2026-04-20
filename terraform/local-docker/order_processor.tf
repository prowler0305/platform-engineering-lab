resource "docker_image" "order_processor" {
  name = "order-processor"
  build {
    context    = var.build_context_path
    dockerfile = "services/order-processor/Dockerfile"
  }
}

resource "docker_container" "order_processor" {
  depends_on = [docker_container.kafka]
  name       = "order-processor"
  image      = docker_image.order_processor.image_id
  networks_advanced {
    name = docker_network.lab.name
  }
  env = [
    "KAFKA_BOOTSTRAP_SERVERS=${local.kafka_bootstrap_servers}"
  ]
}