
resource "aws_eip" "nat_ip" {
  for_each = toset(var.public_ip_on_launch ? []:data.aws_availability_zones.available.names)
  tags  = var.tags
}

resource "aws_subnet" "public_subnet" {
  for_each = toset(var.public_ip_on_launch ? []:data.aws_availability_zones.available.names)
  cidr_block              = cidrsubnet(var.cidr_block, var.netbit_masks==0?local.netbits:var.netbit_masks,index(data.aws_availability_zones.available.names,each.value)+var.start_network)
  vpc_id                  = aws_vpc.this.id
}

resource "aws_nat_gateway" "nat_gw" {
  for_each = toset(var.public_ip_on_launch ? []:data.aws_availability_zones.available.names)
  allocation_id = aws_eip.nat_ip[each.value].id
  subnet_id     = aws_subnet.public_subnet[each.value].id
  tags          = var.tags
}

resource "aws_route_table" "nat_routing" {
  for_each = toset(var.public_ip_on_launch ? []:data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}

resource "aws_route" "route_to_default_gw" {
  for_each = toset(var.public_ip_on_launch ? []:data.aws_availability_zones.available.names)
  route_table_id         = aws_route_table.nat_routing[each.value].id
  gateway_id             = aws_nat_gateway.nat_gw[each.value].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "pub_route_table_association" {
  for_each = var.public_ip_on_launch ? toset([]):toset(data.aws_availability_zones.available.names)
  route_table_id = aws_route_table.nat_routing[each.value].id
  subnet_id      = aws_subnet.this[each.value].id
}

