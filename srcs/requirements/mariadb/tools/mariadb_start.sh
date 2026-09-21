#!/bin/sh

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation du système de fichiers MariaDB..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

    echo "Création de la base de données et des utilisateurs..."

    mysqld_safe --datadir=/var/lib/mysql &
    
    until mariadb-admin ping --silent; do
        sleep 1
    done

    mariadb -u root <<EOF

ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${SQL_USER}'@'\%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    mariadb-admin -u root -p"${SQL_ROOT_PASSWORD}" shutdown
    echo "Initialisation de la base terminée."
fi

exec mariadbd --user=mysql --console