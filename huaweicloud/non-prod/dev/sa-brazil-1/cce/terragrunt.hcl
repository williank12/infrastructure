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
  source = "https://github.com/terraform-huaweicloud-modules/terraform-huaweicloud-cce"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id
  subnet_ids         = dependency.vpc.outputs.subnet_ids
  availability_zones = []

  cluster_flavor         = "cce.s1.small"
  container_network_type = "eni"
  cluster_name           = "${local.region_vars.name_definition}-cce"
  subnet_id              = [local.subnet_ids]
  is_delete_all          = true

  node_pools_configuration = [
    {
      name               = "${local.region_vars.name_definition}-cce-nodepool"
      flavor_id          = "s6.large.2"
      os                 = "EulerOS 2.9"
      initial_node_count = 1
      password           = "Test@123" ### corrigir no môdulo
      tags = {
        Creator = "terraform-huaweicloud-cce"
      }

      data_volumes = [{
        type = "SSD"
        size = 100
      }]

      extend_params = {
        max_pods = 5
      }
    }
  ]
}
