packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}


source "amazon-ebs" "ubuntu_apache" {
  region        = var.region
  instance_type = var.instance_type
  ami_name      = "packer-ubuntu-apache-{{timestamp}}"

  
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # ID Oficial da Canonical (Ubuntu)
  }

  ssh_username = "ubuntu"

  # Boas práticas de FinOps e Governança
  tags = {
    Name        = "Packer-Ubuntu-Apache"
    Environment = "Challenge"
    ManagedBy   = "Packer"
    Project     = "DevOps-IaC"
  }
}

# Sequência de execução do Build
build {
  name    = "desafio-packer-apache"
  sources = ["source.amazon-ebs.ubuntu_apache"]

  #Preparar a máquina temporária instalando o Ansible
  provisioner "shell" {
    inline = [
      "echo 'Aguardando inicialização da instância...'",
      "sleep 10",
      "sudo apt-get update -y",
      "sudo apt-get install -y python3 ansible"
    ]
  }

  #Executa o playbook Ansible dentro da instância
  provisioner "ansible-local" {
    playbook_file = "ansible/apache.yml"
  }
}
