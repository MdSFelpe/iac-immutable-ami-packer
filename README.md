# 🚀 Desafio IaC - Provisionamento Imutável na AWS (Packer, Ansible & Terraform)

Este repositório contém a solução completa de Infraestrutura como Código (IaC) para o provimento automatizado de um servidor web **Apache2** imutável na **Amazon Web Services (AWS)**, integrado a uma esteira de CI/CD via **GitHub Actions**.

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
