# Database module — RDS MySQL in the private data subnets, reachable only from
# the app tier's security group.

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.data_subnet_ids
  tags       = { Name = "${var.name}-db-subnets" }
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name}-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_sg_id]

  multi_az            = var.multi_az
  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false

  tags = { Name = "${var.name}-mysql", Tier = "data" }
}
