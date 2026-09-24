# Developer Documentation (DEV_DOC) - Inception

This document details the architectural choices, network topology, storage drivers, process management, and security configurations implemented in the Inception project.

---

## 1. System Architecture & Base Image

The infrastructure operates as a multi-container LEMP stack built entirely from custom Docker images based on Debian Bookworm (debian:bookworm).

### Service Roles
* Nginx: Operates as the front-facing reverse proxy and sole entry point. Handles SSL termination (TLS v1.2 / TLS v1.3) on port 443.
* WordPress: Runs PHP 8.2-FPM listening on port 9000. Executes application code and interfaces with MariaDB via WP-CLI automation.
* MariaDB: Relational database server running on port 3306. Stores WordPress tables and application state.

---

## 2. Networking & Container Isolation

All containers are connected through a single user-defined bridge network named inception_network.

### Security Constraints
* Internal Communication: WordPress connects to MariaDB via mariadb:3306, and Nginx proxies FastCGI requests to wordpress:9000. Communication relies entirely on Docker's embedded DNS server.
* Host Port Exposure: Neither mariadb (3306) nor wordpress (9000) bind any ports to the host system. Only nginx exposes port 443 to the host (443:443), preventing direct external access to backend services.

---

## 3. Persistent Storage & Local Driver Binding

To satisfy both the Docker Named Volume requirement and the strict host path mapping constraint (/home/ainthana/data/), volumes use local bind mount options in docker-compose.yml:

    volumes:
      mariadb_data:
        name: mariadb_data
        driver: local
        driver_opts:
          type: 'none'
          o: 'bind'
          device: '/home/ainthana/data/mariadb'

      wordpress_data:
        name: wordpress_data
        driver: local
        driver_opts:
          type: 'none'
          o: 'bind'
          device: '/home/ainthana/data/wordpress'

### Lifecycle & Persistence
* Directories on the host are initialized via the Makefile prior to bringing up the stack (mkdir -p /home/ainthana/data/...).
* Data remains fully intact across container destruction (docker compose down) and is only purged during a full cleanup (make fclean).

---

## 4. Process Management & PID 1 Execution

To comply with 42 evaluation rules regarding process management and signal propagation:

1. Exec Form Entrypoints: All Dockerfiles specify entrypoints using array syntax:
   ENTRYPOINT ["/usr/local/bin/script_start.sh"]
2. Signal Forwarding via exec: Entrypoint shell scripts perform initialization checks and conclude by replacing the shell process with the main daemon using exec:
   * Nginx: exec nginx -g "daemon off;"
   * WordPress: exec php-fpm8.2 -F
   * MariaDB: exec mysqld_safe
3. PID 1 State: This ensures master processes execute directly as PID 1 (or under official wrappers like mysqld_safe), allowing immediate reception and handling of SIGTERM signals upon docker stop.

---

## 5. Security, Secrets & Environment Variables

Runtime parameters are centralized in srcs/.env and injected into containers via env_file:
* PHP-FPM Environment: PHP-FPM pool configuration (www.conf) includes clear_env = no to ensure environment variables are preserved for WP-CLI execution.
* Non-Admin Credentials: Database root credentials (SQL_ROOT_PASSWORD) and non-admin WordPress user credentials (WP_ADMIN_USER, WP_USER) are strictly separated and isolated from version control.
* TLS Termination: OpenSSL self-signed certificates are generated during the Nginx build process, restricting allowed protocols to TLS v1.2 and TLS v1.3.

---

## 6. Developer & Debugging Tools

Commands for inspecting container internal states during evaluation:

    # Check running processes inside containers
    docker top nginx
    docker top wordpress
    docker top mariadb

    # Inspect internal container logs
    docker logs nginx
    docker logs wordpress
    docker logs mariadb

    # Execute interactive shell inside a container
    docker exec -it wordpress sh
