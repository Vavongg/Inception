#!/bin/bash

# Exit immediately if an error occurs
set -e

echo "=== WordPress Initialization ==="

# 1. Wait for MariaDB network availability before proceeding
until mariadb-admin ping -h"mariadb" -u"${SQL_USER}" -p"${SQL_PASSWORD}" --silent; do
    echo "    MariaDB not ready yet, retrying..."
    sleep 2
done

# 2. Install and configure WordPress if not already set up
if [ ! -f /var/www/wordpress/wp-config.php ]; then
    echo "First run detected: installing WordPress..."

    # Download WordPress core files via WP-CLI
    wp core download --allow-root
    
    # Generate the database configuration file
    wp config create \
        --dbname="${SQL_DATABASE}" \
        --dbuser="${SQL_USER}" \
        --dbpass="${SQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

    # Install WordPress core and create the main administrator account
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    # Create the mandatory second standard user (author role)
    wp user create \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    echo "WordPress installation completed successfully."
else
    echo "WordPress already configured. Skipping installation."
fi

# Ensure PHP-FPM socket directory exists
mkdir -p /run/php

# 3. Start PHP-FPM in the foreground (PID 1) to keep the container running
echo "=== Starting PHP-FPM Service ==="
exec /usr/sbin/php-fpm8.2 -F