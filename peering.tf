resource "aws_vpc_peering_connection" "default" {
  count = var.is_peering_required ? 1 : 0
  vpc_id        = aws_vpc.main.id
  peer_vpc_id   = local.default_vpc_id
  auto_accept = true
  
  tags = merge(
   var.common_tags,
   var.vpc_peering_tags,
     {
        Name = "${local.resource_name}-default"
     }
  )
}


# route association with public subnets peering
resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1 : 0 # this condition is for creating the route for the peering connection
  route_table_id            = aws_route_table.public.id # this is the route table id
  destination_cidr_block    = local.default_vpc_cidr # this is the default vpc cidr block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
} # this condition is for routing the traffic to the peering connection beteen the vpcs
# private subnet peering route
resource "aws_route" "private_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = local.default_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}# this condition is for routing the traffic to the peering connection beteen the vpcs

# database subnet peering route

resource "aws_route" "database_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = local.default_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}# this condition is for routing the traffic to the peering connection beteen the vpcs
# default vpc peering route
resource "aws_route" "default_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.main.route_table_id #
  destination_cidr_block    = var.vpc_cidr # this is the our expense-dev vpc cidr block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
} 