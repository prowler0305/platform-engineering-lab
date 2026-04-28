locals {
  environment        = "prod"
  network_name       = "platform-lab-${local.environment}"
  build_context_path = abspath("${path.root}/../../../../../event_driven_processing_system")


  kafka_container_name = "${local.environment}-kafka"
  kafka_internal_port  = 9092
  kafka_external_port  = 29092

  order_api_container_name = "${local.environment}-order-api"
  order_api_image_name     = "order-api"
  order_api_port           = 25000

  order_processor_container_name = "${local.environment}-order-processor"
  order_processor_image_name     = "order-processor"
}
