#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== WordPress Initialization ==="

# 1. Wait for MariaDB server availability
echo "Waiting for MariaDB connection..."
until mariadb-admin ping -h"mariadb" --silent; do
    echo "    MariaDB is not ready yet, retrying in 2 seconds..."
    sleep 2
done
echo "Connection to MariaDB successful!"

# 2. Check if WordPress is already configured
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "First run detected: starting WordPress installation..."

    # Download WordPress core files
    echo "Downloading WordPress core files..."
    wp core download --allow-root
	
    # Generate wp-config.php configuration file
    echo "Creating wp-config.php configuration file..."
    wp config create \
        --dbname="${SQL_DATABASE}" \
        --dbuser="${SQL_USER}" \
        --dbpass="${SQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

    # Automatically install WordPress core and administrator account
    echo "Installing WordPress core and administrator account..."
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    # Create standard second user
    echo "Creating standard user ('${WP_USER}')..."
    wp user create \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    echo "WordPress installation and configuration completed successfully!"
else
    echo "WordPress is already configured (wp-config.php present). Skipping installation."
fi

# 3. Prepare PHP-FPM runtime directory
mkdir -p /run/php

# 4. Start PHP-FPM 8.2 in foreground
echo "=== Starting PHP-FPM (PHP 8.2) Service ==="
exec /usr/sbin/php-fpm8.2 -F