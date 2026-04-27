variable "network_name" {
  description = "Name of the Docker network for the local platform lab"
  type        = string
}
variable "build_context_path" {
  description = "Path to the event driven systems source files for image building"
  type        = string
  default     = "../../../event_driven_processing_system"
}
variable "bootstrap_servers" {
  description = "Kafka bootstrap server and port to reach kafka"
  type        = string
}
