#!/bin/bash

sleep 10

cd /var/www/wordpress

if [ ! -f "wp-config.php" ]; then
    echo "Téléchargement et configuration de WordPress via WP-CLI..."

    # Télécharger les fichiers sources de WordPress
    wp core download --allow-root

    # Générer le fichier wp-config.php avec les identifiants MariaDB
    wp config create \
        --dbname="${SQL_DATABASE}" \
        --dbuser="${SQL_USER}" \
        --dbpass="${SQL_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --allow-root

    # Installer le site WordPress et créer le compte Administrateur
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    # Créer le second utilisateur basique
    wp user create \
        "${WORDPRESS_USER}" \
        "${WORDPRESS_EMAIL}" \
        --role=author \
        --user_pass="${WORDPRESS_PASSWORD}" \
        --allow-root

    echo "Installation de WordPress terminée avec succès !"
fi

# Créer le dossier /run/php s'il n'existe pas (nécessaire pour le PID de php-fpm)
mkdir -p /run/php

# Démarrage de PHP-FPM 7.4 en foreground (-F)
echo "Démarrage de PHP-FPM..."
exec php-fpm7.4 -F