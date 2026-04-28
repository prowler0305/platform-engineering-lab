terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}
provider "docker" {}
module "kafka" {
  source       = "./modules/kafka"
  network_name = docker_network.lab.name
}

# Replaces the order_api and order_processor module wiring above with reusable
# service_container module object.
module "order_api" {
  source          = "./modules/service_container"
  image_name      = "order-api"
  container_name  = "order-api"
  network_name    = docker_network.lab.name
  dockerfile_path = "services/order-api/Dockerfile"

  env = [
    "KAFKA_BOOTSTRAP_SERVERS=${module.kafka.bootstrap_servers}",
    "APP_ENV_CONFIG=order_api.config.ProductionConfig"
  ]

  ports = [
    {
      internal = local.order_api_port
      external = local.order_api_port
    }
  ]
  depends_on = [module.kafka]
}

module "order_processor" {
  source          = "./modules/service_container"
  image_name      = "order-processor"
  container_name  = "order-processor"
  network_name    = docker_network.lab.name
  dockerfile_path = "services/order-processor/Dockerfile"

  env = [
    "KAFKA_BOOTSTRAP_SERVERS=${module.kafka.bootstrap_servers}"

  ]
  depends_on = [module.kafka]
}