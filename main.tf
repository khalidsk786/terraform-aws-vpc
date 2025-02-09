resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = var.enable_dns_hostnames

  # tags = {
  #     Name = "main" # this will print the name of the VPC in the AWS console
  # }
  #mandotrory tags
  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
      # Name = "${var.project_name}-${var.environment}"
      Name = local.resource_name
    }
  )
}
# internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
      Name = local.resource_name # ig means internet gateway
    }
  )
}
#Resource: aws_subnet public
#expense-dev-public-us-east-1a
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs) #this conditon is  for creating multiple subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index] # this condition explains that the cidr block of the subnet will be the same as the cidr block of the VPC
  availability_zone       = local.azs_name[count.index]          # this condition explains that the subnet will be created in the same availability zone as the VPC
  map_public_ip_on_launch = true                                 # this condition is for enabling customer owned IP on launch
  tags = merge(
    var.common_tags,
    var.public_subnet_tags,
    {
      Name = "${local.resource_name}-public-${local.azs_name[count.index]}" # this condition is for naming the subnet
    }
  )
}
# private subnet
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs) #this conditon is  for creating multiple subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index] # this condition explains that the cidr block of the subnet will be the same as the cidr block of the VPC
  availability_zone = local.azs_name[count.index]           # this condition explains that the subnet will be created in the same availability zone as the VPC
  #map_public_ip_on_launch = true # this condition is for enabling customer owned IP on launch
  tags = merge(
    var.common_tags,
    var.private_subnet_tags,
    {
      Name = "${local.resource_name}-private-${local.azs_name[count.index]}" # this condition is for naming the subnet
    }
  )
}
# database subnet
resource "aws_subnet" "database" {
  count             = length(var.database_subnet_cidrs) #this conditon is  for creating multiple subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index] # this condition explains that the cidr block of the subnet will be the same as the cidr block of the VPC
  availability_zone = local.azs_name[count.index]           # this condition explains that the subnet will be created in the same availability zone as the VPC
  #map_public_ip_on_launch = true # this condition is for enabling customer owned IP on launch
  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
    {
      Name = "${local.resource_name}-database-${local.azs_name[count.index]}" # this condition is for naming the subnet
    }
  )
}
#Resource: elastic_ip
resource "aws_eip" "nat" {
  # instance = aws_instance.web.id
  domain   = "vpc"
}
#Resource: aws_nat_gateway
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge (
    var.common_tags,
    var.nat_gateway_tags,
    {
    Name = local.resource_name
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}
# route table creation for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id


  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
    Name = "${local.resource_name}-public"
    }
  )
}


#route table creation for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id


  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
    {
    Name = "${local.resource_name}-private"
    }
  )
}


#route table creation for database subnet
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id


  tags = merge(
    var.common_tags,
    var.database_route_table_tags,
    {
    Name = "${local.resource_name}-database"
    }
  )
}

# route table subnet association with public subnet
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id # this condition is for routing the traffic to the internet gateway
}
# route table subnet association with private subnet
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.example.id
}
# route table subnet association with database subnet
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.example.id
}
# route association with public subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# route association with private subnets
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# route association with database subnets
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
