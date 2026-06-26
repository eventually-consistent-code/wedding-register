variable "name" {
  description = "Name prefix for tagged resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC the security groups live in."
  type        = string
}

variable "app_port" {
  description = "Port the app tier listens on."
  type        = number
  default     = 4000
}
