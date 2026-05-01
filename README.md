# Terraform Infrastructure – Multi-Environment Event-Driven System

## Overview

This repository contains a **Terraform-based infrastructure setup** that provisions a local, containerized event-driven system using Docker.

The final setup demonstrates:

- Multi-environment deployments (`dev`, `qa`, `prod`)
- Reusable Terraform modules
- Isolated state per environment
- Environment-specific container/network naming
- Infrastructure-driven application configuration
- Production-inspired workflows such as backend configuration and saved plans

---

## Final Architecture

Each environment runs independently on the same host:

```text
dev:
  dev-kafka
  dev-order-api
  dev-order-processor
  platform-lab-dev

qa:
  qa-kafka
  qa-order-api
  qa-order-processor
  platform-lab-qa

prod:
  prod-kafka
  prod-order-api
  prod-order-processor
  platform-lab-prod
```

Each environment has:

- Its own Docker network
- Unique container names
- Unique exposed host ports
- Independent Terraform state
- Environment-specific runtime configuration

---

## Directory Structure

```text
terraform/
  modules/
    kafka/
    service_container/

  envs/
    dev/
      main.tf
      locals.tf
      network.tf
      outputs.tf

    qa/
      main.tf
      locals.tf
      network.tf
      outputs.tf

    prod/
      main.tf
      locals.tf
      network.tf
      outputs.tf
```

---

## Module Design

### Kafka Module

The Kafka module is purpose-built because Kafka has infrastructure-specific behavior:

- KRaft-mode Kafka configuration
- Kafka listener configuration
- Advertised listener configuration
- Bootstrap server output for application services

Example output:

```hcl
output "bootstrap_server" {
  value = "${var.kafka_host}:${var.kafka_port}"
}
```

### Service Container Module

The `service_container` module is a reusable Docker service pattern used by:

- `order-api`
- `order-processor`

It handles:

- Docker image build
- Docker container creation
- Environment variables
- Docker network attachment
- Optional port exposure

---

## Multi-Environment Strategy

Each environment is its own Terraform root module:

```text
envs/dev
envs/qa
envs/prod
```

Environment-specific values are driven from `locals.tf`:

```hcl
locals {
  environment = "dev"

  network_name = "platform-lab-${local.environment}"

  kafka_container_name = "${local.environment}-kafka"

  order_api_container_name       = "${local.environment}-order-api"
  order_processor_container_name = "${local.environment}-order-processor"
}
```

This keeps the module code reusable while allowing each environment to deploy independently.

---

## Networking Model

Each environment creates its own isolated Docker network:

```hcl
resource "docker_network" "lab" {
  name = local.network_name
}
```

Services communicate through Docker DNS:

```text
dev-order-processor  -> dev-kafka:9092
qa-order-processor   -> qa-kafka:9092
prod-order-processor -> prod-kafka:9092
```

---

## Port Strategy

To allow all environments to run simultaneously, each environment uses unique host ports while keeping internal container ports consistent.

| Environment | Kafka Host Port | Kafka Container Port |
|------------|-----------------|----------------------|
| dev        | 9092            | 9092                 |
| qa         | 19092           | 9092                 |
| prod       | 29092           | 9092                 |

This mirrors the distinction between external access and internal service-to-service communication.

---

## Terraform and Application Configuration

> **Related Application Code**
>
> This infrastructure is designed to work with the event-driven application in:
>
> 👉 https://github.com/prowler0305/event_driven_processing_system
>
> The application demonstrates how runtime configuration is resolved using a combination of environment variables and TOML configuration, allowing Terraform to inject environment-specific values while maintaining a shared default configuration.
>
> Example implementation:
>
> 👉 Order Processor TOML [config.py](https://github.com/prowler0305/event_driven_processing_system/blob/7caf331b78a4aab6146dc1557c756d5c691a45f7/services/order-processor/src/order_processor/config/config.py#L18)

Terraform injects environment-specific Kafka connection details into the services:

```hcl
env = [
  "KAFKA_BOOTSTRAP_SERVERS=${module.kafka.bootstrap_server}"
]
```

The application reads the environment variable before falling back to static TOML config:

```python
@property
def kafka_bootstrap_servers(self):
    return os.getenv("KAFKA_BOOTSTRAP_SERVERS", self._config["kafka"]["bootstrap_servers"])
```

This allows the same application image/config pattern to run across multiple environments without hardcoded broker names.

---

## State Management

Each environment has its own Terraform state:

```text
envs/dev/terraform.tfstate
envs/qa/terraform.tfstate
envs/prod/terraform.tfstate
```

Each environment explicitly defines a backend:

```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

For a real team setup, this local backend would typically become a remote backend:

```hcl
backend "s3" {
  bucket         = "terraform-state"
  key            = "platform-lab/dev/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-locks"
}
```

In that model:

- S3 stores the shared Terraform state file
- DynamoDB provides locking so only one apply can run at a time

---

## Plan and Apply Workflow

This setup also uses the saved plan workflow:

```bash
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

This mirrors CI/CD workflows where a plan is generated, reviewed, and then applied exactly as reviewed.

---

## Infrastructure Evolution

This Terraform setup progressed through several stages:

### 1. Flat Terraform Resources

The initial setup defined Docker network, Kafka, order API, and order processor resources directly in the root module.

### 2. Kafka Module

Kafka was extracted into its own module. This introduced:

- Module inputs
- Module outputs
- Provider declarations inside modules
- Safe state migration with `terraform state mv`

### 3. Service Modules

`order-api` and `order-processor` were moved into modules, preserving existing infrastructure through state migration.

### 4. Reusable Service Container Module

The two service modules were replaced with a single reusable `service_container` module. This removed duplicated Terraform code and turned the services into separate instances of the same infrastructure pattern.

### 5. Multi-Environment Layout

The project was expanded into isolated `dev`, `qa`, and `prod` root modules. Each environment now has its own names, ports, network, and state.

### 6. Backend and Workflow Concepts

Backend configuration and saved plan workflows were added to demonstrate production-style Terraform usage.

---

## Key Takeaways

This project demonstrates:

- Terraform module design
- Safe state refactoring
- Reusable infrastructure patterns
- Multi-environment isolation
- Docker networking and host port separation
- Infrastructure-driven application configuration
- Backend/state concepts
- Saved plan/apply workflow
- Understanding of why state locking matters in team environments

---

## Summary

This Terraform setup evolved from a simple flat Docker deployment into a reusable, multi-environment infrastructure model.

It demonstrates the transition from learning Terraform syntax to applying Terraform as an infrastructure design tool.