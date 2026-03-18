mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["a", "b", "c"]
    }
  }
}
test {
  parallel = true
}

run "default_configuration" {
  assert {
    condition     = length(output.subnets_id) == length(data.aws_availability_zones.available.names)
    error_message = "Bad number of subnets on default configuration."
  }
}

run "pn_configuration" {
  variables {
    public_ip_on_launch = false
    resilient_nat_gw    = true
  }
  assert {
    condition     = length(data.aws_availability_zones.available.names) == length(output.pub_subnets)
    error_message = "Bad number of subnets on Public Network configuration."

  }
  assert {
    condition     = length(data.aws_availability_zones.available.names) == length(output.nat_ip)
    error_message = "Bad number of nat Gateway."
  }
}

run "blackilst_with_pn" {
  variables {
    public_ip_on_launch = false
    resilient_nat_gw    = true
    az_blacklist        = ["a"]
  }
  assert {
    condition     = length(data.aws_availability_zones.available.names) - 1 == length(output.pub_subnets)
    error_message = "Bad number of subnets on Public Network configuration."
  }
}

run "blacklist_without_pn" {
  variables {
    az_blacklist = ["a"]
  }
  assert {
    condition     = length(data.aws_availability_zones.available.names) - 1 == length(output.subnets_id)
    error_message = "Bad number of subnets on private Network configuration."
  }

}
