terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "kafka" {
  name = "confluentinc/cp-kafka:7.5.0"
}
resource "docker_container" "kafka" {
  name  = var.container_name
  image = docker_image.kafka.image_id
  networks_advanced {
    name = var.network_name
  }
  ports {
    internal = var.kafka_internal_port
    external = var.kafka_external_port
  }
  env = [
    "KAFKA_NODE_ID=1",
    "KAFKA_PROCESS_ROLES=broker,controller",
    "CLUSTER_ID=MkU3OEVBNTcwNTJENDM2Qk",
    "KAFKA_LISTENERS=PLAINTEXT://:${var.kafka_internal_port},CONTROLLER://:9093",
    "KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://${var.kafka_host}:${var.kafka_internal_port}",
    "KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER",
    "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT",
    "KAFKA_CONTROLLER_QUORUM_VOTERS=1@${var.kafka_host}:9093",
    "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1",
    "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1",
    "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1",
    "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0",
    "KAFKA_AUTO_CREATE_TOPICS_ENABLE=true"
  ]
}
