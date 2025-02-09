locals {
  resource_name = "${var.project_name}-${var.environment}"
  
  azs_name      = slice(data.aws_availability_zones.available.names, 0, 2) # Get the first two availability zones
  default_vpc_id = data.aws_vpc.default.id  # this is the default vpc id
  default_vpc_cidr = data.aws_vpc.default.cidr_block # this is the default vpc cidr block
}
