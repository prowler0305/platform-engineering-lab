variable "network_name" {
  description = "Name of the Docker network for the local platform lab"
  type        = string
}
variable "kafka_host" {
  description = "Kafka host name"
  type        = string
  default     = "kafka"
}
variable "kafka_internal_port" {
  description = "Kafka internal interface port"
  type        = number
  default     = 9092
}

variable "kafka_external_port" {
  description = "Kafka external port access"
  type        = number
}

variable "container_name" {
  description = "Name to be used for kafka container"
  type        = string
}