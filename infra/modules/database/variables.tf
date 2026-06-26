variable "name" {
  type        = string
  description = "Name prefix for tagged resources."
}

variable "data_subnet_ids" {
  type        = list(string)
  description = "Private data-tier subnets for the DB subnet group."
}

variable "db_sg_id" {
  type        = string
  description = "Security group allowing MySQL from the app tier."
}

variable "db_name" {
  type    = string
  default = "wedding_register"
}

variable "db_username" {
  type    = string
  default = "wedding"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "DB master password — supply via TF_VAR/SSM, never commit."
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "multi_az" {
  type    = bool
  default = false
}
