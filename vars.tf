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

variable "public_ip_on_launch" {
  type        = string
  description = "Map public ip by default on launched resources"
  default     = true
}

