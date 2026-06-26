include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/infra/modules/database"
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    vpc_id          = "vpc-mock"
    data_subnet_ids = ["subnet-me", "subnet-mf"]
  }
}

dependency "security" {
  config_path = "../security"
  mock_outputs = {
    db_sg_id = "sg-mock"
  }
}

inputs = {
  data_subnet_ids = dependency.network.outputs.data_subnet_ids
  db_sg_id        = dependency.security.outputs.db_sg_id
  # Password comes from the environment (TF_VAR_db_password) or SSM — never committed.
  db_password = get_env("TF_VAR_db_password", "change-me-before-apply")
}
