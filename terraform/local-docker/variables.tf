variable "network_name" {
  description = "Name of the Docker network for the local platform lab"
  type        = string
  default     = "platform-lab"
}
variable "kafka_host" {
  description = "Kafka host name"
  type        = string
  default     = "kafka"
}
variable "kafka_port" {
  description = "Kafka interface port"
  type        = number
  default     = 9092
}
variable "order_api_port" {
  description = "Port value for the order api container"
  type        = number
  default     = 5000
}
variable "app_env_config" {
  description = "Order Api application configuration environment to use."
  type        = string
  default     = "order_api.config.ProductionConfig"
}
variable "build_context_path" {
  description = "Path to the event driven systems source files for image building"
  type        = string
  default     = "../../../event_driven_processing_system"
}