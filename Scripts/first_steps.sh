#!/bin/bash

set -e

# Função para pedir a senha sudo
get_sudo_password() {
    PASSWORD=$(zenity --password --title="Autenticação sudo")
    if [ -z "$PASSWORD" ]; then
        zenity --error --text="Senha não fornecida. Saindo..."
        exit 1
    fi
}

# Função para executar comandos com sudo
run_sudo() {
    echo "$PASSWORD" | sudo -S "$@"
}

# Função para atualizar lista de pacotes
update_packages() {
    echo "# Atualizando lista de pacotes..."
    run_sudo apt-get update
    echo "10" # Progresso 10%
}

# Função para instalar pacotes via apt-get
install_packages() {
    run_sudo apt-get install -y "$@" --no-upgrade
}

# Instalar Google Chrome
install_chrome() {
        echo "# Baixando e instalando Google Chrome..."
        run_sudo wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        run_sudo dpkg -i google-chrome-stable_current_amd64.deb || run_sudo apt-get install -f -y
        install_packages libnss3
    echo "20" # Progresso 20%
}

# Instalar Slack
install_slack() {
        echo "# Instalando Slack..."
        run_sudo snap install slack
    echo "30" # Progresso 30%
}

# Instalar Visual Studio Code
install_vscode() {
        echo "# Adicionando repositório do VSCode..."
        run_sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        run_sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        update_packages
        install_packages code
    echo "40" # Progresso 40%
}

# Instalar ferramentas de desenvolvimento essenciais
install_dev_tools() {
    echo "# Instalando ferramentas de desenvolvimento essenciais..."
    install_packages build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git
    echo "50" # Progresso 50%
}

# Instalar apt-transport-https e outras dependências
install_transport_https() {
    echo "# Instalando apt-transport-https e outras dependências..."
    install_packages apt-transport-https ca-certificates gnupg curl
    echo "60" # Progresso 60%
}

# Instalar Google Cloud CLI
install_gcloud() {
        echo "# Instalando Google Cloud CLI..."
        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | run_sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | run_sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        update_packages
        install_packages google-cloud-cli

    echo "70" # Progresso 70%
}

# Instalar kubectl
install_kubectl() {
    echo "# Instalando kubectl..."
    run_sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | run_sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    run_sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | run_sudo tee /etc/apt/sources.list.d/kubernetes.list
    run_sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
    update_packages
    install_packages kubectl
    echo "80" # Progresso 80%
}

# Instalar Docker
install_docker() {
        echo "# Instalando Docker..."
        install_packages docker-ce docker-ce-cli containerd.io
    echo "90" # Progresso 90%
}

# Instalar Git
install_git() {
    echo "# Instalando Git..."
    install_packages git-all
    echo "95" # Progresso 95%
}

# Instalar curl
install_curl() {
    echo "# Instalando curl..."
    install_packages curl
}

# Gerar chave SSH
generate_ssh_key() {
    local email="$1"
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo "# Gerando chave SSH para $email..."
        run_sudo ssh-keygen -t rsa -b 4096 -C "$email" -N "" -f ~/.ssh/id_rsa
    fi
    echo "100" # Progresso 100%
}

# Solicitar a senha sudo
get_sudo_password

# Mostrar a caixa de diálogo de seleção
packages=$(zenity --list --title="Selecione os pacotes para instalar" --text="Escolha os pacotes que deseja instalar:" --checklist --column="Selecionar" --column="Pacote" \
    FALSE "Google Chrome" \
    FALSE "Slack" \
    FALSE "VSCode" \
    FALSE "Ferramentas de Desenvolvimento" \
    FALSE "Apt Transport HTTPS" \
    FALSE "Google Cloud CLI" \
    FALSE "kubectl" \
    FALSE "Docker" \
    FALSE "Git" \
    --separator=":")

# Verificar se o usuário cancelou a seleção
if [ -z "$packages" ]; then
    zenity --error --text="Nenhum pacote foi selecionado. Saindo..."
    exit 1
fi

# Solicitar e-mail para a chave SSH
email=$(zenity --entry --title="Geração de chave SSH" --text="Digite seu e-mail para a geração da chave SSH:")

if [ -z "$email" ]; then
    zenity --error --text="E-mail não fornecido. Saindo..."
    exit 1
fi

(
# Executar as funções de instalação com base na seleção do usuário
update_packages

# Instala o curl
install_curl

IFS=":" read -ra selected_packages <<< "$packages"
for package in "${selected_packages[@]}"; do
    case $package in
        "Google Chrome")
            install_chrome
            ;;
        "Slack")
            install_slack
            ;;
        "VSCode")
            install_vscode
            ;;
        "Ferramentas de Desenvolvimento")
            install_dev_tools
            ;;
        "Apt Transport HTTPS")
            install_transport_https
            ;;
        "Google Cloud CLI")
            install_gcloud
            ;;
        "kubectl")
            install_kubectl
            ;;
        "Docker")
            install_docker
            ;;
        "Git")
            install_git
            ;;
    esac
done

generate_ssh_key "$email"

) | zenity --progress --title="Instalação de Pacotes" --text="Iniciando..." --percentage=0 --auto-close --auto-kill

zenity --info --text="Instalação e configuração concluídas!"
