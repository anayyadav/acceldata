resource "aws_db_instance" "postgresql" {
  allocated_storage                  = var.allocated_storage
  max_allocated_storage              = var.max_allocated_storage
  engine                             = "postgres"
  engine_version                     = var.engine_version
  identifier                         = var.database_identifier
  snapshot_identifier                = var.snapshot_identifier
  instance_class                     = var.instance_type
  storage_type                       = var.storage_type
  iops                               = var.iops
  db_name                            = var.database_name
  password                           = var.database_password
  username                           = var.database_username
  backup_retention_period            = var.backup_retention_period
  backup_window                      = var.backup_window
  maintenance_window                 = var.maintenance_window
  auto_minor_version_upgrade         = var.auto_minor_version_upgrade
  multi_az                           = var.multi_az
  port                               = var.database_port
  skip_final_snapshot                = var.skip_final_snapshot
  publicly_accessible                = var.publicly_accessible
  vpc_security_group_ids             = [aws_security_group.postgres-sg.id]
  db_subnet_group_name               = aws_security_group.postgres-sg.name
  parameter_group_name               = aws_db_parameter_group.postgresql.name
  storage_encrypted                  = var.storage_encrypted
  deletion_protection                = var.deletion_protection
  apply_immediately                  = true
  copy_tags_to_snapshot              = var.copy_tags_to_snapshot

  tags = merge(
    {
      tool        = "terraform"
      infra-env         = var.infra-env
      infra-service     = var.infra-service
    },
    var.tags
  )
  lifecycle {
    ignore_changes = [db_name,password]
}
}

resource "aws_db_parameter_group" "postgresql" {
  name   = "my-pg"
  family = "postgres13"

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_security_group" "postgres-sg" {
  name        = "${var.env}-postgres-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                = "${var.env}-postgres-sg"
    infra-env           = var.infra-env
    infra-service     = var.infra-service
  }
}

resource "aws_security_group_rule" "allow_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.VPC_cidr_block]
  security_group_id = aws_security_group.postgres-sg.id
}