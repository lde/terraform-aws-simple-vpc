terraform {
  required_version = ">= 0.12"

}

locals {
  m_factor=var.public_ip_on_launch ?1:2
  netbits = ceil(log(length(data.aws_availability_zones.available.names)*local.m_factor,2))
  net_offset=var.public_ip_on_launch ?0:length(data.aws_availability_zones.available.names)
  full_offset=local.net_offset+var.start_network
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags                 = merge(var.vpc_tags, var.tags)
}

resource "aws_subnet" "this" {
  for_each = toset(data.aws_availability_zones.available.names)
  cidr_block = cidrsubnet(var.cidr_block,local.netbits,index(data.aws_availability_zones.available.names,each.value)+local.full_offset)
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value
  map_public_ip_on_launch = var.public_ip_on_launch
  tags                    = var.tags
}


resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  tags = var.tags
}

resource "aws_route" "default_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
  route_table_id         = aws_route_table.this.id
}

resource "aws_main_route_table_association" "this" {
  route_table_id = aws_route_table.this.id
  vpc_id         = aws_vpc.this.id
}
