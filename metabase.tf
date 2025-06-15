resource "aws_instance" "metabase" {
  ami                         = "ami-043b59f1d11f8f189" # Ubuntu 22.04 LTS for us-west-1
  instance_type               = "t2.micro"              # Free Tier eligible
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              systemctl enable docker
              systemctl start docker
              docker run -d -p 3000:3000 --name metabase metabase/metabase
              EOF

  tags = {
    Name = "metabase-server"
  }
}

