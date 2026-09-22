#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== MariaDB Initialization ==="

# 1. Directory and permission setup
echo "Setting up directories and permissions..."
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# 2. Check if database already exists
if [ ! -d "/var/lib/mysql/${SQL_DATABASE}" ]; then
    echo "First run: creating data directory..."

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
    echo "System tables created."

    echo "Configuring database and user access..."

    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'\%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    echo "--> Database '${SQL_DATABASE}' and user '${SQL_USER}' successfully created!"
else
    echo "--> Database already initialized. Skipping configuration."
fi

# 3. Start server in foreground with console logging
echo "=== Starting MariaDB Server ==="
exec mysqld --user=mysql --console