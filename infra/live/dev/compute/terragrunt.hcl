include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/infra/modules/compute"
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    vpc_id            = "vpc-mock"
    public_subnet_ids = ["subnet-ma", "subnet-mb"]
    app_subnet_ids    = ["subnet-mc", "subnet-md"]
  }
}

dependency "security" {
  config_path = "../security"
  mock_outputs = {
    alb_sg_id       = "sg-alb-mock"
    app_sg_id       = "sg-app-mock"
    waf_web_acl_arn = "arn:aws:wafv2:us-east-1:000000000000:regional/webacl/mock/mock"
  }
}

dependency "database" {
  config_path = "../database"
  mock_outputs = {
    db_host = "mock.rds.amazonaws.com"
  }
}

inputs = {
  vpc_id            = dependency.network.outputs.vpc_id
  public_subnet_ids = dependency.network.outputs.public_subnet_ids
  app_subnet_ids    = dependency.network.outputs.app_subnet_ids
  alb_sg_id         = dependency.security.outputs.alb_sg_id
  app_sg_id         = dependency.security.outputs.app_sg_id
  waf_web_acl_arn   = dependency.security.outputs.waf_web_acl_arn
  db_host           = dependency.database.outputs.db_host
  instance_type     = "t3.micro"
  desired_capacity  = 2
}
