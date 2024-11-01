# Include core configuration in root
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  region_vars = include.root.locals.region_vars.locals
  account_vars = find_in_parent_folders("account.hcl")
  env_vars = find_in_parent_folders("env.hcl")
}

terraform {
  # source = "https://github.com/williank12/terraform-modules.git/terraform-huaweicloud-vpc"
  source = "https://github.com/terraform-huaweicloud-modules/terraform-huaweicloud-vpc"
}

inputs = {
  vpc_name       = "${local.region_vars.name_definition}-vpc"
  vpc_cidr = "172.16.0.0/16"

  subnets_configuration = [
    {
      name = "${local.region_vars.name_definition}-subnet-1",
      cidr = "172.16.66.0/24"
    },
    {
      name = "${local.region_vars.name_definition}-subnet-2",
      cidr = "172.16.76.0/24"
    }
  ]

  is_security_group_create = false
}
