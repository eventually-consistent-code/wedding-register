include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/infra/modules/security"
}

# Mock outputs let `validate`/`plan` run before network is applied.
dependency "network" {
  config_path = "../network"
  mock_outputs = {
    vpc_id            = "vpc-mock"
    public_subnet_ids = ["subnet-ma", "subnet-mb"]
    app_subnet_ids    = ["subnet-mc", "subnet-md"]
    data_subnet_ids   = ["subnet-me", "subnet-mf"]
  }
}

inputs = {
  vpc_id   = dependency.network.outputs.vpc_id
  app_port = 4000
}
