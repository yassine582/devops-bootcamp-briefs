#!/bin/bash

# Update system
dnf update -y

# Install MySQL server
dnf install -y mysql-server

# Start and enable MySQL
systemctl start mysqld
systemctl enable mysqld

# Configure firewall
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --reload

# Secure MySQL installation
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root123';"
mysql -u root -proot123 -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -proot123 -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -u root -proot123 -e "DROP DATABASE IF EXISTS test;"
mysql -u root -proot123 -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

# Create database and user
mysql -u root -proot123 -e "CREATE DATABASE IF NOT EXISTS demo_db;"
mysql -u root -proot123 -e "CREATE USER IF NOT EXISTS 'demo_user'@'%' IDENTIFIED BY 'demo123';"
mysql -u root -proot123 -e "GRANT ALL PRIVILEGES ON demo_db.* TO 'demo_user'@'%';"
mysql -u root -proot123 -e "FLUSH PRIVILEGES;"

# Create tables and insert demo data
mysql -u root -proot123 demo_db < /vagrant/database/create-table.sql
mysql -u root -proot123 demo_db < /vagrant/database/insert-demo-data.sql

# Configure MySQL for remote connections
sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf 2>/dev/null || true

# For CentOS, edit the correct config file
cat >> /etc/my.cnf << EOF

[mysqld]
bind-address = 0.0.0.0
EOF

# Restart MySQL
systemctl restart mysqld

echo "Database server provisioning completed successfully!"
echo "Database: demo_db"
echo "User: demo_user / Password: demo123"
echo "Root password: root123"