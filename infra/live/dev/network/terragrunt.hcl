include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/infra/modules/network"
}

inputs = {
  vpc_cidr = "10.20.0.0/16"
}
