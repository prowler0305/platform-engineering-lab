variable "image_name" {
  description = "Docker image name"
  type        = string
}

variable "container_name" {
  description = "Docker container name"
  type        = string
}

variable "network_name" {
  description = "Docker network name"
  type        = string
}

variable "env" {
  description = "Environment variables for the container"
  type        = list(string)
  default     = []
}

variable "ports" {
  description = "Container port mappings"
  type = list(object({
    internal = number
    external = number
  }))
  default = []
}

variable "build_context_path" {
  description = "Path to the event driven systems source files for image building"
  type        = string
  default     = "../../../event_driven_processing_system"
}

variable "dockerfile_path" {
  description = "Path to the Dockerfile"
  type        = string
}