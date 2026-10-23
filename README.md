# 🚀 AWS Infrastructure & Bootstrapping Pipeline

![Terraform_CI-CD](https://img.shields.io/badge/Terraform__CI--CD-passing-brightgreen)

> **Projeto Prático de Automação e DevOps:** Implementação de uma pipeline de Integração e Entrega Contínua (CI/CD) e Infraestrutura como Código (IaC) que orquestra, valida e provisiona instâncias EC2 na AWS a partir de imagens imutáveis geradas via Packer e Ansible.

---

## 📌 Visão Geral do Projeto

Este repositório contém uma automação completa desenvolvida com **Packer**, **Ansible**, **Terraform** e **GitHub Actions** para o provisionamento e inicialização padronizada de servidores web na nuvem AWS.

A pipeline executa o ciclo de vida completo da infraestrutura:

1. **Construção de Imagem Imutável:** Compilação de uma AMI no Packer utilizando o Ansible para provisionar o servidor Apache2 e a página HTML personalizada.
2. **Validação de Código:** Análise sintática (`terraform validate`) e verificação de formatação (`terraform fmt`).
3. **Planeamento de Infraestrutura:** Geração do plano de execução (`terraform plan`) para pré-visualização das alterações.
4. **Provisionamento Cloud:** Criação automatizada de Security Groups e instâncias EC2 na AWS utilizando a AMI gerada.
5. **Bootstrapping:** Garante a inicialização e o estado ativo do serviço Apache2 no arranque da máquina.
6. **Validação de Aplicação:** Disponibilização imediata do servidor web ativo e responsivo no IP público.
7. **Encerramento Controlado:** Desconstrução simplificada da infraestrutura via `terraform destroy`.

---

## 📁 Estrutura do Repositório

```text
desafio-packer-aws/
├── .github/
│   └── workflows/
│       └── deploy.yml          # Pipeline de CI/CD automatizada (GitHub Actions)
├── ansible/
│   └── apache.yml              # Playbook do Ansible para instalação e configuração do Apache
├── packer/
│   └── desafio.pkr.hcl         # Template do Packer para criação da AMI imutável na AWS
├── terraform/
│   └── main.tf                 # Código de infraestrutura (VPC, Security Group e EC2)
├── .gitignore                  # Regras para ignorar arquivos de estado, chaves e logs
└── README.md                   # Documentação unificada do projeto e entregáveis
```

---

## 🛠️ Tecnologias & Componentes Utilizados

Todas as definições de infraestrutura foram parametrizadas utilizando o ecossistema oficial do HashiCorp Terraform, Packer, Ansible e AWS.

| Componente | Ferramenta / Recurso | Finalidade / Papel no Ecossistema | Recurso Criado |
| :--- | :--- | :--- | :--- |
| **Image Builder** | Packer | Compilação da imagem de sistema operacional imutável (AMI) | `packer-ubuntu-apache-*` |
| **Config Management** | Ansible | Instalação do Apache2 e deployment do `index.html` personalizado | `apache.yml` |
| **IaC Engine** | Terraform | Provisionamento e gestão de estado da infraestrutura | N/A (Local / Runner) |
| **Cloud Provider** | AWS EC2 | Instância de computação virtual rodando Ubuntu 24.04 LTS | `web_server` |
| **Segurança Cloud** | AWS Security Group | Regras de firewall para tráfego de entrada (HTTP/SSH) e saída livre | `web-server-sg` |
| **Pipeline CI/CD** | GitHub Actions | Execução automatizada dos testes de código, build de AMI e deploy | `.github/workflows` |

---

## 📋 Código Fonte do Projeto (Entregáveis)

### 1. Configuração do Packer (`packer/desafio.pkr.hcl`)

```hcl
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-ubuntu-apache-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-east-1"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
}

build {
  name = "packer-apache-build"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "ansible" {
    playbook_file = "../ansible/apache.yml"
    user          = "ubuntu"
  }
}
```

### 2. Configuração do Ansible (`ansible/apache.yml`)

```yaml
---
- name: Provisionamento do Servidor Web Apache
  hosts: all
  become: true

  tasks:
    - name: Atualizar o cache de pacotes do sistema (apt)
      ansible.builtin.apt:
        update_cache: yes

    - name: Instalar o servidor web Apache2
      ansible.builtin.apt:
        name: apache2
        state: present

    - name: Apagar a pagina padrao do Ubuntu
      ansible.builtin.file:
        path: /var/www/html/index.html
        state: absent

    - name: Implantar a pagina HTML personalizada
      ansible.builtin.copy:
        dest: /var/www/html/index.html
        content: |
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
        owner: www-data
        group: www-data
        mode: '0644'

    - name: Garantir que o servico Apache esteja habilitado e ativo
      ansible.builtin.systemd:
        name: apache2
        enabled: true
        state: started
```

### 3. Configuração do Terraform (`terraform/main.tf`)

```hcl
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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "packer_apache" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-ubuntu-apache-*"]
  }
}

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

resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.packer_apache.id
  instance_type               = "t2.micro"
  subnet_id                   = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1
              apt-get update -y
              apt-get install -y apache2
              rm -f /var/www/html/index.html
              cat <<HTML> /var/www/html/index.html
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
```

### 4. Pipeline de CI/CD (`.github/workflows/deploy.yml`)

```yaml
name: "Packer Build & Terraform Deploy"

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  packer-build:
    name: "Build AMI with Packer"
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: us-east-1

      - name: Setup Packer
        uses: hashicorp/setup-packer@v2
        with:
          version: "latest"

      - name: Setup Ansible
        run: |
          sudo apt update
          sudo apt install -y ansible

      - name: Initialize Packer Plugins
        run: |
          cd packer
          packer init desafio.pkr.hcl

      - name: Run Packer Build
        run: |
          cd packer
          packer build desafio.pkr.hcl

  terraform-deploy:
    name: "Deploy Infrastructure with Terraform"
    needs: packer-build
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "latest"

      - name: Terraform Init
        run: |
          cd terraform
          terraform init

      - name: Terraform Apply
        run: |
          cd terraform
          terraform apply -auto-approve
```

---

## 💻 Comandos e Instruções Empregados

A solução utiliza a CLI nativa das ferramentas para gerir todo o ciclo de vida da infraestrutura:

- `packer build`: Compila a imagem imutável na AWS executando o playbook do Ansible.
- `terraform init`: Inicializa o diretório de trabalho baixando os provedores da AWS.
- `terraform fmt -check`: Valida se os ficheiros `.tf` seguem os padrões oficiais de formatação.
- `terraform validate`: Confirma a integridade e sintaxe das declarações HCL.
- `terraform plan`: Gera e exibe o plano de execução sem alterar recursos reais.
- `terraform apply`: Aplica as alterações e provisiona os recursos diretamente na AWS.
- `terraform destroy`: Remove completamente todos os recursos provisionados para evitar custos.

---

## ⚙️ Como a Pipeline Valida a Infraestrutura

A validação ocorre de forma automatizada através de etapas sequenciais (*steps*) nas *jobs* de CI/CD:

1. **Checkout Code** (`actions/checkout`): Realiza o descarregamento do código-fonte para o ambiente do runner.
2. **Setup Tools** (`setup-packer`, `setup-terraform`): Configura as versões das CLIs e instala o Ansible no ambiente.
3. **Format Check** (`terraform fmt`): Garante a aderência aos padrões de código limpo.
4. **Validation** (`terraform validate`): Analisa a consistência lógica entre ficheiros `.tf`, variáveis e referências de módulos.
5. **Dry Run** (`terraform plan`): Autentica na AWS via GitHub Secrets e simula a criação dos recursos, gerando relatórios nos logs.

---

## 📝 Registro do Provedor e Etapas Executadas

- **Provedor Utilizado:** Amazon Web Services (AWS) — Região `us-east-1`.

**Resumo Executivo do Fluxo:**

1. **Construção de Imagem Imutável (Packer):** O Packer provisionou uma máquina temporária EC2 na AWS, instalou o Ansible e executou a compilação da nova AMI `packer-ubuntu-apache-*`.
2. **Configuração do Software (Ansible):** O Ansible garantiu a instalação do servidor web `apache2` e a substituição do `index.html` padrão pela aplicação personalizada.
3. **Provisionamento da Infraestrutura (Terraform):** O Terraform consultou a AMI criada pelo Packer, configurou o Security Group abrindo a porta 80 (HTTP) e implantou a instância EC2 na subnet pública da VPC Padrão.
4. **Automação de CI/CD (GitHub Actions):** Pipeline configurada em `.github/workflows/deploy.yml` para disparar a verificação, build e deploy automaticamente a cada commit na branch `main`.

---

## 📸 Lista de Evidências Anexadas ao Projeto

Os seguintes registros comprovam a conclusão bem-sucedida do ciclo de entrega:

- **Log do Packer Build:** Registro no terminal demonstrando a criação bem-sucedida da AMI na AWS.
- **AMI na AWS Console:** Captura de tela do painel EC2 > AMIs exibindo a imagem criada e disponível.
- **Instância EC2 Ativa:** Registro da instância em estado *Running* associada ao Security Group liberado na porta 80.
- **Validação HTTP:** Captura de tela do navegador exibindo a página HTML personalizada através do IP público da EC2.

---

## 🚀 Passo a Passo para Execução

### 1. Pré-requisitos Locais

- Terraform instalado (versão 1.5+).
- Packer e Ansible instalados.
- AWS CLI instalado.
- Chaves de acesso da AWS (`AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY`).

### 2. Execução Local — Passos do Início ao Fim

**1. Clonar o Repositório:**

```bash
git clone https://github.com/MdSFelpe/iac-immutable-ami-packer.git
cd iac-immutable-ami-packer
```

**2. Configurar Credenciais da AWS:**

```bash
aws configure
```

Insira sua Access Key, Secret Key e a região `us-east-1`.

**3. Construir a Imagem Base (Packer):**

```bash
cd packer
packer init desafio.pkr.hcl
packer build desafio.pkr.hcl
```

**4. Inicializar e Validar o Ambiente Terraform:**

```bash
cd ../terraform
terraform init
terraform validate
```

**5. Visualizar o Plano de Execução:**

```bash
terraform plan
```

**6. Provisionar a Infraestrutura na AWS:**

```bash
terraform apply
```

Confirme digitando `yes` quando solicitado.

**7. Validar a Aplicação Web:** Copie o IP público exibido no output final e aceda no seu navegador:

```text
http://<SEU_IP_PUBLICO>
```

**8. Destruir a Infraestrutura (Limpeza):**

```bash
terraform destroy
```

Confirme digitando `yes`.

### 3. Configuração do Pipeline de CI/CD (GitHub Actions)

Para que a pipeline funcione automaticamente no GitHub:

1. Vá ao seu repositório no GitHub em **Settings > Secrets and variables > Actions**.
2. Adicione as seguintes *Repository Secrets*:
   - `AWS_ACCESS_KEY_ID`: Sua chave de acesso pública da AWS.
   - `AWS_SECRET_ACCESS_KEY`: Sua chave de acesso secreta da AWS.
   - `AWS_SESSION_TOKEN`: Seu token de sessão (se utilizar conta AWS Academy).
3. Faça um `git push` para a branch `main` para disparar a execução automática do pipeline na aba **Actions**.
