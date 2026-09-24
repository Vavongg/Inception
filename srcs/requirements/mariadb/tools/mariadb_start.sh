#!/bin/bash

# Exit immediately if error
set -e

echo "=== Mariadb Initialization ==="

# 1. Create socket directory and set permissions
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# 2. Check if database already exists
if [ ! -d "/var/lib/mysql/${SQL_DATABASE}" ]; then
    mysqld_safe &

    until mysqladmin ping --silent 2>/dev/null; do
        sleep 1
    done

    mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
    mysqladmin --password=${SQL_ROOT_PASSWORD} shutdown
fi

# 3. Start MariaDB server
echo "=== Starting Mariadb Service ==="
exec mysqld_safe