#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Nginx Initialization ==="

# 1. Create directory for SSL keys
mkdir -p /etc/nginx/ssl

# 2. Generate SSL certificate if it does not exist
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    echo "Generating self-signed SSL certificate for ${DOMAIN_NAME}..."

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42Paris/CN=${DOMAIN_NAME}"

    echo "SSL certificate successfully generated."
else
    echo "SSL certificate already present."
fi

# 3. Start Nginx in foreground
echo "=== Starting Nginx Server ==="
exec nginx -g "daemon off;"