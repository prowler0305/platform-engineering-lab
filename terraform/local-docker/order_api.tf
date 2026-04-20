resource "docker_image" "order_api" {
  name = "order-api"
  build {
    context    = var.build_context_path
    dockerfile = "services/order-api/Dockerfile"
  }
}

resource "docker_container" "order_api" {
  depends_on = [docker_container.kafka]
  name       = "order-api"
  image      = docker_image.order_api.image_id
  networks_advanced {
    name = docker_network.lab.name
  }
  ports {
    internal = var.order_api_port
    external = var.order_api_port
  }
  env = [
    "KAFKA_BOOTSTRAP_SERVERS=${local.kafka_bootstrap_servers}",
    "APP_ENV_CONFIG=${var.app_env_config}"
  ]
}
