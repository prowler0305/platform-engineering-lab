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

module "order_api" {
  source            = "./modules/order_api"
  network_name      = docker_network.lab.name
  bootstrap_servers = module.kafka.bootstrap_servers
  depends_on        = [module.kafka]
}

module "order_processor" {
  source            = "./modules/order_processor"
  network_name      = docker_network.lab.name
  bootstrap_servers = module.kafka.bootstrap_servers
  depends_on        = [module.kafka]
}