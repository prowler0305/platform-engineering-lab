output "kafka_bootstrap_server" {
  description = "Kafka bootstrap server for local services"
  value       = local.kafka_bootstrap_servers
}

output "network_name" {
  description = "Docker network name"
  value       = docker_network.lab.name
}

output "order_api_container" {
  description = "Order API container name"
  value       = docker_container.order_api.name
}

output "order_processor_container" {
  description = "Order Processor container name"
  value       = docker_container.order_processor.name
}
