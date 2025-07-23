variable "cidr_block" {
  description = "cidr block of subnet"
  default     = "192.168.1.0/24"
}

variable "tags" {
  description = "A map of tags to add to resources"
  type        = map(string)
  default = {
    Name = "Terraform VPC_elts"
  }
}

variable "vpc_tags" {
  description = "A map of tags to add to vpc only"
  type        = map(string)
  default = {
    Name = "Terraform VPC"
  }
}

variable "private_subnets_tags" {
  description = "A map of tags to add to private subnets"
  type        = map(string)
  default     = {}

}

variable "public_subnets_tags" {
  description = "A map of tags to add to public subnets"
  type        = map(string)
  default     = {}

}

variable "route_table_tags" {
  description = "A map of tags to add to route tables"
  type        = map(string)
  default     = {}
}

variable "nat_ip_tags" {
  description = "A map of tags to add to nat eip"
  type        = map(string)
  default     = {}
}

variable "nat_gateway_tags" {
  description = "A map of tags to add to nat gateways"
  type        = map(string)
  default     = {}
}

variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  type        = map(string)
  default     = {}
}

variable "private_route_table_tags" {
  description = "Additional tags for the private route tables"
  type        = map(string)
  default     = {}
}

variable "public_ip_on_launch" {
  type        = bool
  description = "Map public ip by default on launched resources"
  default     = true
}

variable "netbit_masks" {
  type        = number
  description = "override default netbits masks"
  default     = 0
}

variable "start_network" {
  type        = number
  description = "Num of first network"
  default     = 0
}

variable "resilient_nat_gw" {
  type        = bool
  description = "Use one net GW per AZ"
  default     = false
}
