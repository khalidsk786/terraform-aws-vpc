variable "project_name" {

}

variable "environment" {

}

variable "vpc_cidr" {

}

variable "enable_dns_hostnames" { #this is for enabling DNS hostnames in the VPC
  default = true
}

variable "common_tags" {
  type = map(any)
}

variable "vpc_tags" {
  type = map(any)

}

variable "igw_tags" {
  type = map(any)
}

variable "public_subnet_cidrs" {
  type = list(any)
  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Please provide  2 valid public subnet cidrs"
  }
}
variable "public_subnet_tags" {
  default = {}
}

variable "private_subnet_cidrs" {
  type = list(any)
  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Please provide  2 valid private subnet cidrs"
  }
}
variable "private_subnet_tags" {
  default = {}
}


variable "database_subnet_cidrs" {
  type = list(any)
  validation {
    condition     = length(var.database_subnet_cidrs) == 2
    error_message = "Please provide  2 valid private subnet cidrs"
  }
}
variable "database_subnet_tags" {
  default = {}
}

variable "nat_gateway_tags" {
    default = {}
  
}

variable "public_route_table_tags" {
  default = {}
}
variable "private_route_table_tags" {
  default = {}
  
}
variable "database_route_table_tags" {
  default = {}
  
}

variable "is_peering_required" {
    default = false
}

variable "vpc_peering_tags" {

    default = {}
  
}
