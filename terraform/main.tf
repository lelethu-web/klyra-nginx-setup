provider "aws" {
  region = "eu-north-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "web_sg" {
  name        = "klyra-nginx-sg-003"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-043339ea831b48099"
  instance_type           = "t3.micro"
  key_name                = "klyra-nginx-key-2"
  vpc_security_group_ids  = [aws_security_group.web_sg.id]

  tags = {
    Name = "klyra-nginx-ec2"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
