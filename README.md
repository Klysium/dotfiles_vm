# 🚀 Script de Configuration Automatique VM

Un script bash complet pour configurer automatiquement vos machines virtuelles Debian/Ubuntu en environnement de développement sécurisé.

## ⚡ Installation Express

```bash
curl -fsSL https://raw.githubusercontent.com/Klysium/dotfiles_vm/main/install.sh | sudo bash
```

> **⚠️ Important :** Le script doit être exécuté en tant que root/sudo

## 📖 Table des matières

- [🎯 Fonctionnalités](#-fonctionnalités)
- [🔧 Prérequis](#-prérequis)
- [📥 Installation](#-installation)
- [⚙️ Configuration](#️-configuration)
- [🛠️ Utilisation](#️-utilisation)
- [🔒 Sécurité](#-sécurité)
- [📧 Configuration Email](#-configuration-email)
- [🐛 Dépannage](#-dépannage)
- [🤝 Contribution](#-contribution)

## 🎯 Fonctionnalités

### 🛠️ Outils de développement installés
- **Git** - Gestion de version
- **Node.js (LTS)** + **npm** - Environnement JavaScript
- **Bun** - Runtime JavaScript ultra-rapide
- **Python3** + **pip** - Environnement Python
- **Build tools** - gcc, make, build-essential

### 🖥️ Outils système
- **htop** / **btop** - Moniteurs système interactifs
- **tmux** / **screen** - Multiplexeurs de terminal
- **vim** / **nano** - Éditeurs de texte
- **curl** / **wget** - Outils de téléchargement
- **jq** - Processeur JSON en ligne de commande
- **tree** - Affichage arborescent des dossiers

### 🔐 Sécurité renforcée
- **fail2ban** - Protection contre les attaques par force brute
- **UFW (Uncomplicated Firewall)** - Firewall simplifié
- **SSH sécurisé** - Configuration renforcée
- **Gestion des utilisateurs** - Création sécurisée avec mots de passe forts

### 🎨 Personnalisation
- **MOTD personnalisé** - Message d'accueil avec infos système
- **Aliases bash** - Raccourcis utiles pour le développement
- **Environnement optimisé** - Configuration shell améliorée

### 📧 Notifications automatiques
- **Envoi d'emails** - Credentials envoyés automatiquement via Mailjet
- **Génération de mots de passe** - Mots de passe sécurisés automatiques

## 🔧 Prérequis

- **OS** : Debian 10+ ou Ubuntu 18.04+
- **Droits** : Accès root/sudo
- **Réseau** : Connexion internet active
- **Optionnel** : Compte Mailjet pour l'envoi d'emails

## 📥 Installation

### 🌐 Méthode 1 : Installation directe (Recommandée)

```bash
# Installation en une ligne
curl -fsSL https://raw.githubusercontent.com/Klysium/dotfiles_vm/main/install.sh | sudo bash
```

### 💾 Méthode 2 : Téléchargement et exécution locale

```bash
# Télécharger le script
wget https://raw.githubusercontent.com/Klysium/dotfiles_vm/main/install.sh

# Rendre exécutable
chmod +x install.sh

# Exécuter
sudo ./install.sh
```

### 🔄 Méthode 3 : Cloner le repository

```bash
# Cloner le projet
git clone https://github.com/Klysium/dotfiles_vm.git
cd dotfiles_vm

# Exécuter
sudo ./install.sh
```

## ⚙️ Configuration

### 📧 Configuration Mailjet (Optionnelle)

Pour activer l'envoi d'emails automatique :

1. **Créer un compte Mailjet**
   - Rendez-vous sur [mailjet.com](https://www.mailjet.com/)
   - Créez un compte gratuit

2. **Récupérer les clés API**
   - Connectez-vous à votre compte Mailjet
   - Allez dans `Account Settings` > `REST API`
   - Notez votre `API Key` et `Secret Key`

3. **Modifier le script**
   ```bash
   # Éditer le script install.sh
   nano install.sh
   
   # Remplacer ces lignes (vers le début du fichier) :
   MAILJET_API_KEY="votre_api_key_ici"
   MAILJET_SECRET_KEY="votre_secret_key_ici"
   MAILJET_FROM_EMAIL="admin@votredomaine.com"
   ```

4. **Vérifier votre domaine d'expédition**
   - Dans Mailjet, ajoutez et vérifiez votre domaine d'expédition
   - Ou utilisez l'email par défaut fourni par Mailjet

## 🛠️ Utilisation

### 🚀 Processus d'installation

Le script vous guidera à travers plusieurs étapes :

1. **Détection du système**
   ```
   Distribution détectée: Ubuntu 22.04
   ```

2. **Mise à jour du système**
   ```
   Mise à jour du système...
   ✓ Système mis à jour
   ```

3. **Installation des outils**
   ```
   Installation des outils de base...
   ✓ Outils de base installés
   ✓ Node.js v18.17.0 et npm 9.6.7 installés
   ✓ Bun installé
   ```

4. **Configuration de la sécurité**
   ```
   Configuration de la sécurité...
   ✓ Sécurité configurée (fail2ban, UFW, SSH)
   ```

5. **Création des utilisateurs**
   ```
   Combien d'utilisateurs voulez-vous créer ? 2
   
   Création de l'utilisateur 1/2
   Nom d'utilisateur : john
   Email : john@example.com
   Nom complet : John Doe
   ✓ Utilisateur john créé avec succès
   📧 Email envoyé à john@example.com
   ```

6. **Finalisation**
   ```
   ✓ Configuration terminée avec succès !
   
   Redémarrage recommandé pour finaliser la configuration
   Voulez-vous redémarrer maintenant ? (y/N)
   ```

### 🔍 Vérification post-installation

Après l'installation, vous pouvez vérifier que tout fonctionne :

```bash
# Vérifier les versions installées
node --version
npm --version
bun --version

# Vérifier les services de sécurité
sudo systemctl status fail2ban
sudo ufw status

# Voir le nouveau MOTD
cat /etc/motd
```

## 🔒 Sécurité

### 🛡️ Mesures de sécurité implémentées

- **SSH sécurisé**
  - Connexion root désactivée
  - Tentatives limitées à 3 essais
  - Timeout de connexion réduit

- **Firewall UFW**
  - Politique par défaut : DENY incoming
  - Ports autorisés : 22 (SSH), 80 (HTTP), 443 (HTTPS)

- **fail2ban**
  - Bannissement automatique après 3 tentatives échouées
  - Durée de bannissement : 1 heure
  - Surveillance des logs SSH

- **Utilisateurs**
  - Mots de passe générés automatiquement (16 caractères)
  - Ajout automatique au groupe sudo
  - Répertoires .ssh créés avec permissions correctes

### 🔑 Gestion des mots de passe

Les mots de passe sont générés avec cette méthode :
```bash
openssl rand -base64 32 | tr -d "=+/" | cut -c1-16
```

Exemple de mot de passe généré : `K3mP9nQ2xR7vL8sW`

## 📧 Configuration Email

### 📨 Template d'email envoyé

Voici le format de l'email automatiquement envoyé aux nouveaux utilisateurs :

```
Objet: Accès VM - nom_de_la_machine

Bonjour,

Votre compte a été créé sur la machine virtuelle hostname (192.168.1.100).

Informations de connexion :
- Nom d'utilisateur : john
- Mot de passe : K3mP9nQ2xR7vL8sW
- Adresse IP : 192.168.1.100

Vous pouvez vous connecter via SSH :
ssh john@192.168.1.100

Cordialement,
L'équipe DevOps
```

### 🔧 Personnaliser l'email

Pour modifier le template d'email, éditez la fonction `send_email()` dans le script :

```bash
# Localiser cette section dans install.sh
local email_body="Bonjour,

Votre compte a été créé sur la machine virtuelle $hostname ($ip_address).
..."
```

## 🐛 Dépannage

### ❌ Problèmes courants

**1. Erreur "Permission denied"**
```bash
# Solution : Exécuter avec sudo
sudo ./install.sh
```

**2. Erreur "Repository not found"**
```bash
# Vérifier l'URL et la connectivité
curl -I https://raw.githubusercontent.com/Klysium/dotfiles_vm/main/install.sh
```

**3. Échec d'installation de packages**
```bash
# Mettre à jour les dépôts manuellement
sudo apt update
sudo apt upgrade -y
```

**4. fail2ban ne démarre pas**
```bash
# Vérifier les logs
sudo journalctl -u fail2ban
# Redémarrer le service
sudo systemctl restart fail2ban
```

**5. Problème d'envoi d'email**
```bash
# Vérifier la configuration Mailjet
curl -X GET --user "api_key:secret_key" https://api.mailjet.com/v3/REST/apikey
```

### 📋 Commandes de diagnostic

```bash
# Vérifier l'état des services
sudo systemctl status fail2ban ufw ssh

# Voir les logs d'installation
sudo journalctl -f

# Tester la connectivité réseau
ping -c 4 8.8.8.8

# Vérifier les ports ouverts
sudo netstat -tlnp

# Voir les tentatives de connexion SSH
sudo tail -f /var/log/auth.log
```

### 🔍 Logs utiles

- **SSH** : `/var/log/auth.log`
- **fail2ban** : `/var/log/fail2ban.log`
- **UFW** : `/var/log/ufw.log`
- **Système** : `journalctl -f`

## 📊 MOTD Personnalisé

Après installation, voici ce qui s'affiche à la connexion :

```
╔══════════════════════════════════════════════════════════════╗
║                    VM DevOps                                ║
║              Configuration automatique VM Dev                ║
╚══════════════════════════════════════════════════════════════╝

Bienvenue sur la machine virtuelle de développement
Configurée automatiquement le Mon Jul  7 23:45:12 UTC 2025

Informations système :
  - OS: Ubuntu 22.04.3 LTS
  - Kernel: 5.15.0-78-generic
  - Uptime: up 2 hours, 34 minutes
  - Load: 0.15 0.10 0.05
  - Memory: 2.1G/4.0G
  - Disk: 15G/50G (30%)

Outils installés :
  - Git: 2.34.1
  - Node.js: v18.17.0
  - npm: 9.6.7
  - Bun: 1.0.0

Sécurité :
  - fail2ban: active
  - ufw: active

Documentation : https://github.com/Klysium/dotfiles_vm
```

## 🎛️ Aliases installés

Le script ajoute automatiquement ces aliases utiles :

```bash
# Navigation
alias ll='ls -alF'        # Liste détaillée
alias la='ls -A'          # Tous les fichiers
alias l='ls -CF'          # Liste compacte
alias ..='cd ..'          # Dossier parent
alias ...='cd ../..'      # Deux niveaux

# Outils
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
```

## 🤝 Contribution

### 🔄 Proposer des améliorations

1. **Fork** le repository
2. **Créer** une branche pour votre fonctionnalité
   ```bash
   git checkout -b feature/nouvelle-fonctionnalite
   ```
3. **Commit** vos modifications
   ```bash
   git commit -m "Ajout de la nouvelle fonctionnalité"
   ```
4. **Push** vers votre fork
   ```bash
   git push origin feature/nouvelle-fonctionnalite
   ```
5. **Créer** une Pull Request

### 💡 Idées d'améliorations

- [ ] Support pour CentOS/RHEL
- [ ] Installation de Docker
- [ ] Configuration de nginx
- [ ] Support pour les clés SSH automatiques
- [ ] Interface web de gestion
- [ ] Backup automatique des configurations

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 📞 Support

- **Issues GitHub** : [Créer une issue](https://github.com/Klysium/dotfiles_vm/issues)
- **Documentation** : Ce README
- **Email** : support@votredomaine.com

---

**⭐ Si ce script vous a été utile, n'hésitez pas à laisser une étoile sur GitHub !**

> Dernière mise à jour : Juillet 2025 | Version 1.0