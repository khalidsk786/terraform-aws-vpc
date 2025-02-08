variable "project_name"{

}

variable "environment"{ 
  
}

variable "vpc_cidr" {

}

variable "enable_dns_hostnames" { #this is for enabling DNS hostnames in the VPC
    default = true
}

variable "common_tags" {
   type = map
}

variable "vpc_tags" {
    type = map
  
}