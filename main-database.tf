resource "aws_db_instance" "pht_db_instance" {
  allocated_storage = var.db_storage # 10Gi
  instance_class    = var.db_instance_class

  engine         = var.db_engine
  engine_version = var.db_engine_version

  vpc_security_group_ids = aws_security_group.pht_security_groups["rds"].id
  db_subnet_group_name   = aws_db_subnet_group.pht_db_subnet_group[*].name

  identifier = var.db_identifier
  db_name    = var.dbname
  username   = var.dbuser
  password   = var.dbpassword


  skip_final_snapshot = var.skip_db_snapshot

  tags = {
    Name = "${var.name_prefix}-database"
  }

}
