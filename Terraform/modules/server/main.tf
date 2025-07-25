resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and HTTP for Jenkins"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # تعديل لاحقًا إذا أردت
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_instance" "jenkins" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = file("${path.root}/jenkins.sh")
  monitoring = true

  tags = {
    Name        = "jenkins-server"
    Role        = "jenkins"
    Environment = var.env
  }
}

# resource "aws_cloudwatch_log_group" "jenkins_log_group" {
#   name = "/ec2/jenkins"
#   retention_in_days = 7
# }
resource "aws_cloudwatch_log_group" "jenkins_log_group" {
  name              = "/ec2/jenkins"
  retention_in_days = 14

  lifecycle {
    prevent_destroy = true
    create_before_destroy = false
    ignore_changes = [name]
  }

  tags = {
    Name = "Jenkins Log Group"
  }
}
