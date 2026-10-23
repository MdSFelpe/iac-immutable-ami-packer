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

## 🛠️ Tecnologias & Componentes Utilizados

Todas as definições de infraestrutura foram parametrizadas utilizando o ecossistema oficial do **HashiCorp Terraform**, **Packer**, **Ansible** e **AWS**.

| Componente | Ferramenta / Recurso | Finalidade / Papel no Ecossistema | Recurso Criado |
| :--- | :--- | :--- | :--- |
| **Image Builder** | `Packer` | Compilação da imagem de sistema operacional imutável (AMI) | `packer-ubuntu-apache-*` |
| **Config Management** | `Ansible` | Instalação do Apache2 e deployment do `index.html` personalizado | `apache.yml` |
| **IaC Engine** | `Terraform` | Provisionamento e gestão de estado da infraestrutura | `N/A (Local / Runner)` |
| **Cloud Provider** | `AWS EC2` | Instância de computação virtual rodando Ubuntu 24.04 LTS | `web_server` |
| **Segurança Cloud** | `AWS Security Group` | Regras de firewall para tráfego de entrada (HTTP/SSH) e saída livre | `web-server-sg` |
| **Pipeline CI/CD** | `GitHub Actions` | Execução automatizada dos testes de código, build de AMI e deploy | `.github/workflows` |

---

## 💻 Comandos e Instruções Empregados

A solução utiliza a CLI nativa das ferramentas para gerir todo o ciclo de vida da infraestrutura:

* `packer build` : Compila a imagem imutável na AWS executando o playbook do Ansible.
* `terraform init` : Inicializa o diretório de trabalho baixando os provedores da AWS.
* `terraform fmt -check` : Valida se os ficheiros `.tf` seguem os padrões oficiais de formatação.
* `terraform validate` : Confirma a integridade e sintaxe das declarações HCL.
* `terraform plan` : Gera e exibe o plano de execução sem alterar recursos reais.
* `terraform apply` : Aplica as alterações e provisiona os recursos diretamente na AWS.
* `terraform destroy` : Remove completamente todos os recursos provisionados para evitar custos.

---

## ⚙️ Como a Pipeline Valida a Infraestrutura

A validação ocorre de forma automatizada através de etapas sequenciais (*steps*) na *job* de CI/CD:

1. **Checkout Code (`actions/checkout`)**: Realiza o descarregamento do código-fonte para o ambiente do runner.
2. **Setup Tools (`setup-packer`, `setup-terraform`)**: Configura as versões exatas das CLIs e instala o Ansible no ambiente.
3. **Format Check (`terraform fmt`)**: Garante a aderência aos padrões de código limpo.
4. **Validation (`terraform validate`)**: Analisa a consistência lógica entre ficheiros `.tf`, variáveis e referências de módulos.
5. **Dry Run (`terraform plan`)**: Autentica na AWS via *GitHub Secrets* e simula a criação dos recursos, gerando relatórios nos logs.

---

## 🚀 Passo a Passo para Execução

### 1. Pré-requisitos Locais

* `Terraform` instalado (versão 1.5+).
* `Packer` e `Ansible` instalados.
* `AWS CLI` instalado.
* Chaves de acesso da AWS (`AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY`).

### 2. Execução Local

1. **Clonar o Repositório:**

   ```bash
   git clone [https://github.com/MdSFelpe/iac-immutable-ami-packer.git](https://github.com/MdSFelpe/iac-immutable-ami-packer.git)
   cd iac-immutable-ami-packer
