variable "name" {
  type        = string
  description = "Name prefix for tagged resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC id."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnets for the ALB."
}

variable "app_subnet_ids" {
  type        = list(string)
  description = "Private subnets for the EC2 app tier."
}

variable "alb_sg_id" {
  type        = string
  description = "Security group for the ALB."
}

variable "app_sg_id" {
  type        = string
  description = "Security group for the app tier."
}

variable "waf_web_acl_arn" {
  type        = string
  description = "WAF web ACL to associate with the ALB."
}

variable "app_port" {
  type        = number
  default     = 4000
  description = "Port the API listens on."
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type for the app tier."
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "db_host" {
  type        = string
  default     = ""
  description = "RDS endpoint passed to the app env."
}

variable "db_name" {
  type        = string
  default     = "wedding_register"
  description = "Database name passed to the app env."
}
