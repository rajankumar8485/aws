resource "mongodbatlas_privatelink_endpoint" "this" {
  project_id    = "${stack_name}-mongodb-pvt-endpoint"
  provider_name = "AWS"
  region        = var.mongoatlas_region
}

resource "aws_vpc_endpoint" "this" {
  vpc_id             = var.vpc_id
  service_name       = mongodbatlas_privatelink_endpoint.this.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
}

resource "mongodbatlas_privatelink_endpoint_service" "this" {
  project_id          = mongodbatlas_privatelink_endpoint.this.project_id
  private_link_id     = mongodbatlas_privatelink_endpoint.this.private_link_id
  endpoint_service_id = aws_vpc_endpoint.this.id
  provider_name       = "AWS"
}