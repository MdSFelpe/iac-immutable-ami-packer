terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Busca a VPC Padrão da conta
data "aws_vpc" "default" {
  default = true
}

# 2. Busca as Subnets associadas à VPC Padrão
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 3. Busca a AMI gerada pelo Packer
data "aws_ami" "packer_apache" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-ubuntu-apache-*"]
  }
}

# 4. Cria o Security Group na VPC Padrão liberando HTTP e SSH
resource "aws_security_group" "web_sg" {
  name        = "desafio-packer-apache-sg-v3"
  description = "Permite trafego HTTP e SSH publico"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name      = "SG-Packer-Apache"
    ManagedBy = "Terraform"
  }
}

# 5. Instância EC2 atrelada explicitamente à Subnet Pública e Security Group
resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.packer_apache.id
  instance_type               = "t2.micro"
  subnet_id                   = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

user_data = <<-EOF
              
              exec > /var/log/user-data.log 2>&1
              
              # 1. Garante a instalação do Apache
              apt-get update -y
              apt-get install -y apache2
              
              # 2. Apaga a página padrão do Ubuntu
              rm -f /var/www/html/index.html
              
              # 3. Cria a página HTML
              cat <<HTML > /var/www/html/index.html
              <!DOCTYPE html>
              <html lang="pt-br">
              <head>
                  <meta charset="UTF-8">
                  <title>Desafio IaC - Packer & Terraform</title>
                  <style>
                      body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f4f9; text-align: center; }
                      .container { background: white; padding: 40px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); max-width: 600px; margin: 0 auto; }
                      h1 { color: #2e7d32; }
                      p { color: #555; font-size: 16px; }
                      .badge { background-color: #e8f5e9; color: #2e7d32; padding: 8px 16px; border-radius: 20px; font-weight: bold; display: inline-block; }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1>Servidor Apache Provisionado!</h1>
                      <div class="badge">Status: Ativo</div>
                      <p>Infraestrutura criada com sucesso utilizando <strong>Packer</strong>, <strong>Ansible</strong> e <strong>Terraform</strong> na AWS.</p>
                  </div>
              </body>
              </html>
              HTML

              # 4. Define permissões e reinicia o serviço
              chown -R www-data:www-data /var/www/html
              systemctl unmask apache2
              systemctl enable apache2
              systemctl restart apache2
              EOF  
tags = {
    Name        = "EC2-Packer-Apache"
    Environment = "Challenge"
    ManagedBy   = "Terraform"
  }
}

output "public_ip" {
  description = "IP Publico da instancia EC2"
  value       = aws_instance.web_server.public_ip
}

output "web_url" {
  description = "URL para aceder ao servidor web"
  value       = "http://${aws_instance.web_server.public_ip}"
}
