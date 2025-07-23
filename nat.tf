locals {
  az_list = toset(data.aws_availability_zones.available.names)
  az_to_nat = toset(var.public_ip_on_launch ? [] : (var.resilient_nat_gw ? local.az_list : [
    data.aws_availability_zones.available.names[0]
  ]))
}

resource "aws_eip" "nat_ip" {
  for_each = local.az_to_nat

  tags = merge(
    var.tags,
    var.nat_ip_tags
  )
}

resource "aws_subnet" "public_subnet" {
  for_each          = toset(var.public_ip_on_launch ? [] : local.az_list)
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.cidr_block, var.netbit_masks == 0 ? local.netbits : var.netbit_masks, index(data.aws_availability_zones.available.names, each.value) + var.start_network)
  vpc_id            = aws_vpc.this.id

  tags = merge(
    var.tags,
    var.public_subnets_tags
  )
}

resource "aws_nat_gateway" "nat_gw" {
  for_each      = local.az_to_nat
  allocation_id = aws_eip.nat_ip[each.value].id
  subnet_id     = aws_subnet.public_subnet[each.value].id

  tags = merge(
    var.tags,
    var.nat_gateway_tags,
  )
}

resource "aws_route_table" "nat_routing" {
  for_each = local.az_to_nat
  vpc_id   = aws_vpc.this.id
  tags = merge(
    var.tags,
    var.private_route_table_tags,
  )
}

resource "aws_route" "route_to_default_gw" {
  for_each               = local.az_to_nat
  route_table_id         = aws_route_table.nat_routing[each.value].id
  nat_gateway_id         = aws_nat_gateway.nat_gw[each.value].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "pub_route_table_association" {
  for_each       = var.public_ip_on_launch ? toset([]) : toset(data.aws_availability_zones.available.names)
  route_table_id = aws_route_table.nat_routing[var.resilient_nat_gw ? each.value : one(local.az_to_nat)].id
  subnet_id      = aws_subnet.this[each.value].id
}

