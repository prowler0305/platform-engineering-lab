# ------------------------------------------------------------------------------
# Terraform Backend Configuration
#
# This defines where Terraform stores its state file.
#
# We are currently using the "local" backend:
# - State is stored on disk in this environment directory
# - Each environment (dev/qa/prod) has its own isolated state file
#
# In real-world setups, this is replaced with a remote backend (e.g. S3):
# - Centralized state storage
# - Shared across team members and CI/CD pipelines
# - Enables state locking (via DynamoDB) to prevent concurrent applies
#
# Example remote backend (AWS S3 + DynamoDB locking):
#
# backend "s3" {
#   bucket         = "company-terraform-state"
#   key            = "platform-lab/dev/terraform.tfstate"
#   region         = "us-east-1"
#   dynamodb_table = "terraform-locks"
# }
#
# Key concept:
# Backend = source of truth for infrastructure state
# ------------------------------------------------------------------------------
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
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