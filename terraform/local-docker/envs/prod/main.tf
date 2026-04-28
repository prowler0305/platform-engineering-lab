terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}
provider "docker" {}
module "kafka" {
  source              = "../../modules/kafka"
  network_name        = docker_network.lab.name
  container_name      = local.kafka_container_name
  kafka_host          = local.kafka_container_name
  kafka_internal_port = local.kafka_internal_port
  kafka_external_port = local.kafka_external_port
}

module "order_api" {
  source             = "../../modules/service_container"
  image_name         = local.order_api_image_name
  container_name     = local.order_api_container_name
  network_name       = docker_network.lab.name
  build_context_path = local.build_context_path
  dockerfile_path    = "services/order-api/Dockerfile"

  env = [
    "ENVIRONMENT=${local.environment}",
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
  source             = "../../modules/service_container"
  image_name         = local.order_processor_image_name
  container_name     = local.order_processor_container_name
  network_name       = docker_network.lab.name
  build_context_path = local.build_context_path
  dockerfile_path    = "services/order-processor/Dockerfile"

  env = [
    "ENVIRONMENT=${local.environment}",
    "KAFKA_BOOTSTRAP_SERVERS=${module.kafka.bootstrap_servers}"

  ]
  depends_on = [module.kafka]
}