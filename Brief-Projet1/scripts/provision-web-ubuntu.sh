#!/usr/bin/env bash
set -euo pipefail

# Update & install Nginx
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

# Ensure /var/www/html exists (Vagrant synced folder mounts it automatically)
mkdir -p /var/www/html

# Set permissions (important for VirtualBox shared folders)
chown -R www-data:www-data /var/www/html || true
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Start and enable Nginx
systemctl enable --now nginx
systemctl reload nginx || true

echo "Web provisioning finished"
