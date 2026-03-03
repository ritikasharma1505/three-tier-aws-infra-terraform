# ---------------- DB Subnet Group ----------------
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${var.project_name}-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_db_az1.id,
    aws_subnet.private_db_az2.id
  ]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# ---------------- RDS Instance ----------------
resource "aws_db_instance" "db" {
  identifier             = "${var.project_name}-db"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "admin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true
  multi_az            = false           // set true to create a Standby DB(AZ2)

  tags = {
    Name = "${var.project_name}-rds"
  }
}

# --------------- RDS Read Replica -------------
# resource "aws_db_instance" "read_replica" {
#   identifier          = "${var.project_name}-read-replica"

#   replicate_source_db = aws_db_instance.db.id

#   instance_class      = "db.t3.micro"
#   publicly_accessible = false

#   vpc_security_group_ids = [aws_security_group.rds_sg.id]

#   skip_final_snapshot = true

#   depends_on = [aws_db_instance.db]
# }