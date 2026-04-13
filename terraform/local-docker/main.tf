terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}
provider "docker" {}
resource "docker_image" "kafka" {
  name = "confluentinc/cp-kafka:7.5.0"
}
resource "docker_container" "kafka" {
  name = "kafka"
  image = docker_image.kafka.image_id
  networks_advanced {
    name = docker_network.lab.name
  }
  ports {
    internal = 9092
    external = 9092
  }
  env = [
    "KAFKA_NODE_ID=1",
    "KAFKA_PROCESS_ROLES=broker,controller",
    "CLUSTER_ID=MkU3OEVBNTcwNTJENDM2Qk",
    "KAFKA_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093",
    "KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092",
    "KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER",
    "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT",
    "KAFKA_CONTROLLER_QUORUM_VOTERS=1@kafka:9093",
    "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1",
    "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1",
    "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1",
    "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0",
    "KAFKA_AUTO_CREATE_TOPICS_ENABLE=true"
  ]
}
resource "docker_network" "lab" {
  name = "platform-lab"
}

resource "docker_image" "order-api" {
  name = "order-api"
  build {
    context = "../../../event_driven_processing_system"
    dockerfile = "services/order-api/Dockerfile"
  }
}

resource "docker_container" "order-api" {
  depends_on = [docker_container.kafka]
  name = "order-api"
  image = docker_image.order-api.image_id
  networks_advanced {
    name = docker_network.lab.name
  }
  ports {
    internal = 5000
    external = 5000
  }
  env = [
    "KAFKA_BOOTSTRAP_SERVERS=kafka:9092",
    "APP_ENV_CONFIG=order_api.config.ProductionConfig"
  ]
}

resource "docker_image" "order-processor" {
  name = "order-processor"
  build {
    context = "../../../event_driven_processing_system"
    dockerfile = "services/order-processor/Dockerfile"
  }
}

resource "docker_container" "order-processor" {
  depends_on = [docker_container.kafka]
  name = "order-processor"
  image = docker_image.order-processor.image_id
  networks_advanced {
    name = docker_network.lab.name
  }
  env = [
    "KAFKA_BOOTSTRAP_SERVERS=kafka:9092"
  ]
}