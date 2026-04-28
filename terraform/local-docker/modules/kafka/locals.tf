locals {
  kafka_bootstrap_servers = "${var.kafka_host}:${var.kafka_internal_port}"
}