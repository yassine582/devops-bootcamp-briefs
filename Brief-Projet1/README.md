# Infrastructure Simple avec Vagrant

Ce projet met en place une infrastructure simple composée d’un serveur web (Ubuntu) et d’un serveur de base de données (CentOS), gérés avec **Vagrant**.


## Architecture

- **Machine 1 (web-server)** : Ubuntu 22.04 avec Nginx
- **Machine 2 (db-server)** : CentOS 9 avec MySQL 8.0

## Prérequis

- VirtualBox >= 6.1
- Vagrant >= 2.3.0
- Au moins 4 GB de RAM libre
- 40 GB d'espace disque disponible

## Déploiement

### 1. Cloner le projet

```bash
git clone <votre-repo>
cd brief-project
```

### 2. Démarrer l'infrastructure

```bash
vagrant up
```

### 3. Vérifier le déploiement

**Site web :**

- Accédez à l'IP publique de la machine web
- Ou utilisez : `vagrant ssh web-server` puis `ip addr show`

**Base de données :**

```bash
mysql -h localhost -P 3307 -u demo_user -p
# Mot de passe : demo123
```

## Configuration Réseau

| Machine    | IP Privée     | Services     | Ports        |
| ---------- | ------------- | ------------ | ------------ |
| web-server | 192.168.56.10 | Nginx (80)   | Public + SSH |
| db-server  | 192.168.56.20 | MySQL (3306) | 3307→3306    |

## Gestion des Machines

```bash
# Démarrer toutes les machines
vagrant up

# Démarrer une machine spécifique
vagrant up web-server
vagrant up db-server

# Se connecter en SSH
vagrant ssh web-server
vagrant ssh db-server

# Arrêter les machines
vagrant halt

# Détruire l'infrastructure
vagrant destroy
```

## Base de Données

**Connexion locale :**

```bash
mysql -h localhost -P 3307 -u demo_user -pdemo123 demo_db
```

**Commandes utiles :**

```sql
USE demo_db;
SELECT * FROM users;
SHOW TABLES;
```

## Synchronisation des Fichiers

- Le dossier `./website/` est automatiquement synchronisé avec `/var/www/html/` sur le serveur web (VirtualBox shared folder).
- Le dossier `./database/` est synchronisé avec `/vagrant/database/` sur le serveur db via **rsync** (compatible CentOS sans Guest Additions).

Modifiez les fichiers localement, ils seront immédiatement disponibles sur les machines.

## Troubleshooting

### Problèmes de réseau

```bash
# Vérifier la connectivité entre machines
vagrant ssh web-server -c "ping 192.168.56.20"
```

### Problèmes MySQL

```bash
# Vérifier le statut du service
vagrant ssh db-server -c "sudo systemctl status mysqld"

# Vérifier les logs
vagrant ssh db-server -c "sudo journalctl -u mysqld"
```

### Re-provisioning

```bash
# Re-provisionner une machine
vagrant provision web-server
vagrant provision db-server
```
