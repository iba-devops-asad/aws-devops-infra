resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id  # <-- Added second AZ
  ]

  tags = {
    Name = "RDS Subnet Group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "mysql-db"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "MyPassword123!"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_mysql_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  storage_encrypted      = false
}

resource "aws_db_instance" "postgres" {
  identifier             = "postgres-db"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15.13"
  instance_class         = "db.t3.micro"
  username               = "pgadmin"
  password               = "PgPassword123!"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_postgres_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  storage_encrypted      = false
}

