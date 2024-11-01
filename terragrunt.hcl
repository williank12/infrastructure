locals {
  # secret_vars = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.global.yaml")))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  huaweicloud_region = local.region_vars.locals.huaweicloud_region
  bucket_name = "oneboxterraform"
}

# Generate an Huaweicloud provider block
generate "huaweicloud_provider" {
  path      = "huaweicloud_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "huaweicloud" {
  region     = "${local.huaweicloud_region}"
  access_key = ""
  secret_key = ""
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    bucket   = "${local.bucket_name}"
    key      = "${path_relative_to_include()}/terraform.tfstate"
    region   = local.huaweicloud_region
    endpoint = "https://obs.sa-brazil-1.myhuaweicloud.com"
    # bucket   = "oneboxterraform"
    # key      = "terraform.tfstate"
    # region   = "us-east-1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_bucket_root_access  = true
    skip_bucket_enforced_tls = true
    disable_bucket_update    = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
