# Terragrunt root — keeps backend + provider DRY for every component under
# live/. Each component `include`s this and only declares its own inputs +
# dependencies. State is one S3 key per component (path_relative_to_include).

locals {
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region = local.env.locals.region
  name   = local.env.locals.name
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.name}-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "${local.name}-tflock"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.region}"
      default_tags {
        tags = {
          Project   = "${local.name}"
          ManagedBy = "terragrunt"
        }
      }
    }
  EOF
}

inputs = {
  name = local.name
}
