# Elastic Compute Cloud Instance for Web Server
resource "aws_instance" "web_server" {
  count         = length(var.az)
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  vpc_security_group_ids = [aws_security_group.sg_web.id]

  tags = {
    Name = "pj_web_server_${element(var.short_az, count.index)}"
  }
}

# Elastic Compute Cloud Instance for Database Server
resource "aws_instance" "db_server" {
  count         = length(var.az)
  ami           = data.aws_ami.ubuntu_22_04.id
  instance_type = "t2.micro"
  subnet_id     = element(aws_subnet.private.*.id, count.index)

  vpc_security_group_ids = [aws_security_group.sg_db.id]

  tags = {
    Name = "pj_database_server_${element(var.short_az, count.index)}"
  }
}

