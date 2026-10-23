# 🚀 Desafio IaC - Provisionamento Imutável na AWS (Packer, Ansible & Terraform)

Este repositório contém a solução completa de Infraestrutura como Código (IaC) para o provimento automatizado de um servidor web **Apache2** imutável na **Amazon Web Services (AWS)**, integrado a uma esteira de CI/CD via **GitHub Actions**.

---

## 📁 Estrutura do Repositório

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

---

## 🛠️ Tecnologias Utilizadas

* **Provedor de Nuvem:** Amazon Web Services (AWS) — Região `us-east-1`
* **Packer:** Criação da imagem de sistema operacional imutável (AMI).
* **Ansible:** Gerenciamento de configuração para provisionamento do servidor Apache2 e aplicação web.
* **Terraform:** Provisionamento declarativo da infraestrutura (VPC, Subnet, Security Group e EC2).
* **GitHub Actions:** Esteira de Integração e Entrega Contínuas (CI/CD).

---

## 📋 Entregáveis da Atividade

### 1. Configuração do Packer (`packer/desafio.pkr.hcl`)

O arquivo abaixo configura a criação da imagem base na AWS com a execução do Ansible como provisionador:

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

---

### 2. Configuração do Ansible (`ansible/apache.yml`)

O playbook abaixo é responsável por instalar o Apache e implantar a página HTML personalizada na imagem:

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

---

### 3. Registro do Provedor e Etapas Executadas

* **Provedor Utilizado:** Amazon Web Services (AWS) — Região `us-east-1`.
* **Resumo Executivo do Fluxo:**
  1. **Construção de Imagem Imutável (Packer):** O Packer provisionou uma máquina temporária EC2 na AWS, instalou o Ansible e executou a compilação da nova AMI `packer-ubuntu-apache-*`.
  2. **Configuração do Software (Ansible):** O Ansible garantiu a instalação do servidor web `apache2` e a substituição do `index.html` padrão pela aplicação personalizada.
  3. **Provisionamento da Infraestrutura (Terraform):** O Terraform consultou a AMI criada pelo Packer, configurou o Security Group abrindo a porta 80 (HTTP) e implantou a instância EC2 na subnet pública da VPC Padrão.
  4. **Automação de CI/CD (GitHub Actions):** Pipeline configurada em `.github/workflows/deploy.yml` para disparar a verificação, build e deploy automaticamente a cada commit na branch `main`.

---

### 4. Lista de Evidências Anexadas ao Projeto

Os seguintes registros comprovam a conclusão bem-sucedida do ciclo de entrega:
1. **Log do Packer Build:** Registro no terminal demonstrando a criação bem-sucedida da AMI na AWS.
2. **AMI na AWS Console:** Captura de tela do painel EC2 > AMIs exibindo a imagem criada e disponível.
3. **Instância EC2 Ativa:** Registro da instância em estado `Running` associada ao Security Group liberado na porta 80.
4. **Validação HTTP:** Captura de tela do navegador exibindo a página HTML personalizada através do IP público da EC2.

---

## ⚙️ Como Utilizar o Projeto

### Pré-requisitos
* AWS CLI configurado com credenciais válidas (`aws configure`).
* Ferramentas instaladas: Packer, Ansible e Terraform.

---

### Passo 1: Construir a AMI com o Packer
cd packer
packer init desafio.pkr.hcl
packer build desafio.pkr.hcl

---

### Passo 2: Implantar a Infraestrutura com o Terraform
cd ../terraform
terraform init
terraform apply -auto-approve

Ao final, o Terraform retornará a URL pública de acesso:
Outputs:
web_url = "http://<IP_PUBLICO_EC2>"

---

### Passo 3: Testar e Validar
Você pode testar diretamente via terminal com o `curl` ou abrindo o IP no seu navegador:
curl -I http://<IP_PUBLICO_EC2>

---

### Passo 4: Destruir os Recursos
Para evitar custos desnecessários na conta AWS ao finalizar os testes:
cd terraform
terraform destroy -auto-approve
