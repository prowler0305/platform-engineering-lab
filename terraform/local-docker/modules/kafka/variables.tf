variable "network_name" {
  description = "Name of the Docker network for the local platform lab"
  type        = string
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
