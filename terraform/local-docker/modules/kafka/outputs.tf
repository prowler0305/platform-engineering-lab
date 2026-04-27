output "bootstrap_servers" {
  description = "Kafka bootstrap server for local services"
  value       = local.kafka_bootstrap_servers
}
output "image_name" {
  description = "Kafka image name"
  value       = docker_image.kafka.name
}
output "container_name" {
  description = "Kafka container name"
  value       = docker_container.kafka.name
}
