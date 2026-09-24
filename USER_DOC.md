# User Documentation (USER_DOC) - Inception

This guide provides instructions on how to deploy, access, manage, and verify the Inception web platform.

---

## 1. Domain & DNS Configuration

Before launching the project, map the domain ainthana.42.fr to your local machine (or VM IP) in the host /etc/hosts file:

    sudo nano /etc/hosts

Add the following line:

    127.0.0.1    ainthana.42.fr

---

## 2. Platform Deployment

All lifecycle commands are managed through the root Makefile.

### Starting the Infrastructure
To build custom images, prepare host directories, and start all services:

    make

### Stopping Services
To stop running containers without losing persistent database or website data:

    make down

### Resetting & Rebuilding
To purge containers, images, and wipe persistent storage host directories (/home/ainthana/data):

    make fclean
    make up

---

## 3. Accessing the Website & Admin Panel

### Public Website
Open your browser and navigate to:
https://ainthana.42.fr

Note: Because the Nginx server utilizes a self-signed TLS certificate generated via OpenSSL, your browser will display a security warning. Click Advanced and select Proceed to ainthana.42.fr to continue.

### WordPress Administration Panel
Access the login interface at:
https://ainthana.42.fr/wp-login.php

Pre-configured Accounts:
- Administrator:
  * Username: ainthana_boss
  * Password: Defined in srcs/.env (WP_ADMIN_PASSWORD)
- Author (Standard User):
  * Username: wp_author
  * Password: Defined in srcs/.env (WP_USER_PASSWORD)

---

## 4. Service Health Checks

You can run these commands directly on your host terminal to verify system state:

    # 1. Check container execution status
    docker ps

    # 2. Verify PID 1 processes inside containers
    docker top nginx
    docker top wordpress
    docker top mariadb

    # 3. Test HTTPS connectivity and TLS version
    curl -Iv https://ainthana.42.fr

    # 4. Verify host persistence directories
    ls -la /home/ainthana/data/mariadb
    ls -la /home/ainthana/data/wordpress