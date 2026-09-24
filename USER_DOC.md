# User Documentation (USER_DOC) - Inception

This guide explains how an end user or administrator can deploy, manage, access, and verify the Inception web infrastructure.

---

## 1. Services Provided by the Stack

The infrastructure deploys a complete LEMP web platform consisting of three isolated services:
* **Nginx**: Front-end web server and reverse proxy. Handles HTTPS connections (port 443) and secures traffic using TLS v1.2/v1.3 encryption.
* **WordPress**: Content Management System (CMS) powered by PHP 8.2-FPM (port 9000). Serves the website pages and administration interface.
* **MariaDB**: Relational Database Management System (port 3306). Stores WordPress content, user profiles, and site settings.

---

## 2. Platform Deployment

All lifecycle operations are managed via the root Makefile.

### Starting the Project
To build custom images, create host storage directories, and launch all services:

    make

### Stopping the Project
To stop running containers without destroying persistent data:

    make down

### Resetting & Rebuilding
To completely purge containers, images, and stored host data (/home/ainthana/data):

    make fclean
    make up

---

## 3. Accessing the Website & Admin Panel

### Domain Configuration
Add the domain mapping to your host `/etc/hosts` file:

    127.0.0.1    ainthana.42.fr

### Public Website
Access the main website at:
https://ainthana.42.fr

*Note: Accept the browser security warning caused by the self-signed TLS certificate.*

### WordPress Administration Interface
Access the login page at:
https://ainthana.42.fr/wp-login.php

---

## 4. Locating and Managing Credentials

All sensitive credentials and variables are centralized in the `srcs/.env` file.

### Credentials Location
    srcs/.env

### Default Pre-configured Accounts
* **Administrator Account**:
  * Username: `ainthana_boss`
  * Password: Defined by `WP_ADMIN_PASSWORD` in `srcs/.env`
* **Author Account**:
  * Username: `wp_author`
  * Password: Defined by `WP_USER_PASSWORD` in `srcs/.env`

To change any credential, edit `srcs/.env` and restart the stack using `make re`.

---

## 5. Checking Service Health

Verify that all services are running properly with these terminal commands:

    # 1. Check container execution status
    docker ps

    # 2. Verify main processes running as PID 1
    docker top nginx
    docker top wordpress
    docker top mariadb

    # 3. Test HTTPS response
    curl -Iv https://ainthana.42.fr

    # 4. Verify host persistent storage directories
    ls -la /home/ainthana/data/mariadb
    ls -la /home/ainthana/data/wordpress
