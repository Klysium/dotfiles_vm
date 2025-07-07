#!/bin/bash

# Script de configuration automatique pour VMs Debian/Ubuntu
# Auteur: Marius B
# Version: 1.0

set -euo pipefail

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration Mailjet (à remplir avec vos clés)
MAILJET_API_KEY=""
MAILJET_SECRET_KEY=""
MAILJET_FROM_EMAIL=""
MAILJET_FROM_NAME="VM Setup Bot"

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fonction pour générer un mot de passe sécurisé
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-16
}

# Fonction pour envoyer un email via Mailjet
send_email() {
    local to_email="$1"
    local username="$2"
    local password="$3"
    local hostname="$4"
    local ip_address="$5"
    
    if [[ -z "$MAILJET_API_KEY" || -z "$MAILJET_SECRET_KEY" ]]; then
        log_warning "Configuration Mailjet manquante, email non envoyé"
        return 0
    fi
    
    local email_body="Bonjour,

Votre compte a été créé sur la machine virtuelle $hostname ($ip_address).

Informations de connexion :
- Nom d'utilisateur : $username
- Mot de passe : $password
- Adresse IP : $ip_address

Vous pouvez vous connecter via SSH :
ssh $username@$ip_address

Cordialement,
L'équipe DevOps"
    
    curl -s -X POST \
        --user "$MAILJET_API_KEY:$MAILJET_SECRET_KEY" \
        https://api.mailjet.com/v3.1/send \
        -H "Content-Type: application/json" \
        -d "{
            \"Messages\": [{
                \"From\": {
                    \"Email\": \"$MAILJET_FROM_EMAIL\",
                    \"Name\": \"$MAILJET_FROM_NAME\"
                },
                \"To\": [{
                    \"Email\": \"$to_email\"
                }],
                \"Subject\": \"Accès VM - $hostname\",
                \"TextPart\": \"$email_body\"
            }]
        }" > /dev/null
    
    if [ $? -eq 0 ]; then
        log_success "Email envoyé à $to_email"
    else
        log_error "Erreur lors de l'envoi de l'email à $to_email"
    fi
}

# Fonction pour vérifier si on est root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Ce script doit être exécuté en tant que root"
        exit 1
    fi
}

# Fonction pour détecter la distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        log_error "Distribution non supportée"
        exit 1
    fi
    
    case $OS in
        "Ubuntu"*|"Debian"*)
            log_info "Distribution détectée: $OS $VER"
            ;;
        *)
            log_error "Distribution non supportée: $OS"
            exit 1
            ;;
    esac
}

# Fonction pour mettre à jour le système
update_system() {
    log_info "Mise à jour du système..."
    apt update && apt upgrade -y
    apt install -y curl wget gnupg2 software-properties-common apt-transport-https ca-certificates
    log_success "Système mis à jour"
}

# Fonction pour installer les outils de base
install_base_tools() {
    log_info "Installation des outils de base..."
    
    # Outils système
    apt install -y \
        git \
        curl \
        wget \
        htop \
        btop \
        vim \
        nano \
        unzip \
        zip \
        tree \
        jq \
        tmux \
        screen \
        net-tools \
        lsof \
        strace \
        tcpdump \
        nmap \
        dnsutils \
        build-essential \
        python3 \
        python3-pip \
        openssl
    
    log_success "Outils de base installés"
}

# Fonction pour installer Node.js et npm
install_nodejs() {
    log_info "Installation de Node.js et npm..."
    
    # Installation de Node.js via NodeSource
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt install -y nodejs
    
    # Vérification des versions
    node_version=$(node --version)
    npm_version=$(npm --version)
    
    log_success "Node.js $node_version et npm $npm_version installés"
}

# Fonction pour installer Bun
install_bun() {
    log_info "Installation de Bun..."
    
    # Installation de Bun
    curl -fsSL https://bun.sh/install | bash
    
    # Ajout de Bun au PATH pour tous les utilisateurs
    echo 'export PATH="$HOME/.bun/bin:$PATH"' >> /etc/profile
    
    log_success "Bun installé"
}

# Fonction pour configurer la sécurité
configure_security() {
    log_info "Configuration de la sécurité..."
    
    # Installation de fail2ban
    apt install -y fail2ban
    
    # Configuration de fail2ban
    cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF
    
    # Configuration du firewall (UFW)
    apt install -y ufw
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    
    # Configuration SSH sécurisée
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    
    # Modification des paramètres SSH
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
    
    # Ajout de paramètres de sécurité SSH
    echo "
# Paramètres de sécurité additionnels
Protocol 2
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
MaxSessions 4
" >> /etc/ssh/sshd_config
    
    # Redémarrage des services
    systemctl restart fail2ban
    systemctl restart ssh
    systemctl enable fail2ban
    
    log_success "Sécurité configurée (fail2ban, UFW, SSH)"
}

# Fonction pour créer les utilisateurs
create_users() {
    log_info "Configuration des utilisateurs..."
    
    # Obtenir l'adresse IP de la machine
    IP_ADDRESS=$(hostname -I | awk '{print $1}')
    HOSTNAME=$(hostname)
    
    echo ""
    read -p "Combien d'utilisateurs voulez-vous créer ? " num_users
    
    if ! [[ "$num_users" =~ ^[0-9]+$ ]] || [ "$num_users" -le 0 ]; then
        log_error "Nombre d'utilisateurs invalide"
        return 1
    fi
    
    for ((i=1; i<=num_users; i++)); do
        echo ""
        log_info "Création de l'utilisateur $i/$num_users"
        
        read -p "Nom d'utilisateur : " username
        read -p "Email : " email
        read -p "Nom complet : " fullname
        
        # Vérification si l'utilisateur existe déjà
        if id "$username" &>/dev/null; then
            log_warning "L'utilisateur $username existe déjà, passage au suivant"
            continue
        fi
        
        # Génération du mot de passe
        password=$(generate_password)
        
        # Création de l'utilisateur
        useradd -m -s /bin/bash -c "$fullname" "$username"
        echo "$username:$password" | chpasswd
        
        # Ajout au groupe sudo
        usermod -aG sudo "$username"
        
        # Création du répertoire .ssh
        mkdir -p "/home/$username/.ssh"
        chmod 700 "/home/$username/.ssh"
        touch "/home/$username/.ssh/authorized_keys"
        chmod 600 "/home/$username/.ssh/authorized_keys"
        chown -R "$username:$username" "/home/$username/.ssh"
        
        # Configuration du bashrc
        cat >> "/home/$username/.bashrc" << 'EOF'

# Alias personnalisés
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Ajout de Bun au PATH
export PATH="$HOME/.bun/bin:$PATH"
EOF
        
        log_success "Utilisateur $username créé avec succès"
        log_info "Mot de passe généré : $password"
        
        # Envoi de l'email
        send_email "$email" "$username" "$password" "$HOSTNAME" "$IP_ADDRESS"
    done
}

# Fonction pour configurer le MOTD
configure_motd() {
    log_info "Configuration du MOTD..."
    
    # Suppression des MOTD par défaut
    rm -f /etc/motd
    rm -f /etc/update-motd.d/*
    
    # Création du nouveau MOTD
    cat > /etc/update-motd.d/00-header << 'EOF'
#!/bin/sh
figlet "VM DevOps" 2>/dev/null || echo "=== VM DevOps ==="
echo ""
echo "Bienvenue sur la machine virtuelle de développement"
echo "Configurée automatiquement le $(date)"
echo ""
EOF
    
    cat > /etc/update-motd.d/10-sysinfo << 'EOF'
#!/bin/sh
echo "Informations système :"
echo "  - OS: $(lsb_release -d | cut -f2)"
echo "  - Kernel: $(uname -r)"
echo "  - Uptime: $(uptime -p)"
echo "  - Load: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
echo "  - Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo "  - Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
echo ""
EOF
    
    cat > /etc/update-motd.d/90-footer << 'EOF'
#!/bin/sh
echo "Outils installés :"
echo "  - Git: $(git --version | awk '{print $3}')"
echo "  - Node.js: $(node --version)"
echo "  - npm: $(npm --version)"
echo "  - Bun: $(~/.bun/bin/bun --version 2>/dev/null || echo 'Non installé')"
echo ""
echo "Sécurité :"
echo "  - fail2ban: $(systemctl is-active fail2ban)"
echo "  - ufw: $(ufw status | head -n1 | awk '{print $2}')"
echo ""
echo "Documentation : https://github.com/Klysium/dotfiles_vm"
echo ""
EOF
    
    # Rendre les scripts exécutables
    chmod +x /etc/update-motd.d/*
    
    # Installation de figlet pour le titre
    apt install -y figlet
    
    log_success "MOTD configuré"
}

# Fonction pour effectuer le nettoyage final
cleanup() {
    log_info "Nettoyage final..."
    
    # Nettoyage des packages
    apt autoremove -y
    apt autoclean
    
    # Nettoyage des logs
    journalctl --vacuum-time=7d
    
    log_success "Nettoyage terminé"
}

# Fonction principale
main() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    VM Setup Script v1.0                     ║
║              Configuration automatique VM Dev                ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log_info "Démarrage de la configuration automatique..."
    
    # Vérifications préliminaires
    check_root
    detect_distro
    
    # Configuration du système
    update_system
    install_base_tools
    install_nodejs
    install_bun
    configure_security
    create_users
    configure_motd
    cleanup
    
    echo ""
    log_success "Configuration terminée avec succès !"
    echo ""
    log_info "Résumé des actions effectuées :"
    echo "  ✓ Système mis à jour"
    echo "  ✓ Outils de développement installés"
    echo "  ✓ Node.js, npm et Bun installés"
    echo "  ✓ Sécurité configurée (fail2ban, UFW)"
    echo "  ✓ Utilisateurs créés"
    echo "  ✓ MOTD personnalisé"
    echo ""
    log_warning "Redémarrage recommandé pour finaliser la configuration"
    echo ""
    read -p "Voulez-vous redémarrer maintenant ? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Redémarrage en cours..."
        reboot
    fi
}

# Gestion des signaux
trap 'log_error "Script interrompu"; exit 1' INT TERM

# Exécution du script principal
main "$@"