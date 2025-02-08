locals {
  resource_name = "${var.project_name}-${var.environment}"
  
  azs_name      = slice(data.aws_availability_zones.available.names, 0, 2) # Get the first two availability zones
}
