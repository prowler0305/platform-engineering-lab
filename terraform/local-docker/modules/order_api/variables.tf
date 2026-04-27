variable "network_name" {
  description = "Name of the Docker network for the local platform lab"
  type        = string
}
variable "build_context_path" {
  description = "Path to the event driven systems source files for image building"
  type        = string
  default     = "../../../event_driven_processing_system"
}
variable "order_api_port" {
  description = "Port value for the order api container"
  type        = number
  default     = 5000
}
variable "bootstrap_servers" {
  description = "Kafka bootstrap server and port to reach kafka"
  type        = string
}
variable "app_env_config" {
  description = "Order Api application configuration environment to use."
  type        = string
  default     = "order_api.config.ProductionConfig"
}
