# Developer Documentation (DEV_DOC) - Inception

This document details the architectural choices, network topology, storage drivers, and process management implemented in the **Inception** project.

---

## 1. System Architecture & Base Image

The infrastructure operates as a multi-container LEMP stack built entirely from custom Docker images based on **Debian Bookworm** (`debian:bookworm`).

### Service Roles
* **Nginx**: Operates as the front-facing reverse proxy and sole entry point. Handles SSL termination (TLS v1.2 / TLS v1.3) on port `443`.
* **WordPress**: Runs PHP 8.2-FPM listening on port `9000`. Executes application code and interfaces with MariaDB via WP-CLI automation.
* **MariaDB**: Relational database server running on port `3306`. Stores WordPress tables and application state.

---

## 2. Networking & Container Isolation

All containers are connected through a single user-defined bridge network named `inception_network`.

### Security Constraints
* **Internal Communication**: WordPress connects to MariaDB via `mariadb:3306`, and Nginx proxies FastCGI requests to `wordpress:9000`. Communication relies entirely on Docker's embedded DNS server.
* **Host Port Exposure**: Neither `mariadb` (3306) nor `wordpress` (9000) bind any ports to the host system. Only `nginx` exposes port `443` to the host (`443:443`), preventing direct external access to backend services.

---

## 3. Persistent Storage & Local Driver Binding

To satisfy both the **Docker Named Volume** requirement and the strict **host path mapping** constraint (`/home/ainthana/data/`), volumes use local bind mount options in `docker-compose.yml`:

```yaml
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