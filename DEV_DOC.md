# Developer Documentation (DEV_DOC) - Inception

This document details environment setup, architectural design, volume management, and process execution for developers working on the Inception project.

---

## 1. Setting Up the Environment from Scratch

### Prerequisites
* Operating System: Debian Bookworm or Ubuntu 22.04+ (or equivalent Linux VM).
* Packages required: `docker.io`, `docker-compose-v2`, `make`, `git`, `curl`, `sudo`.
* User permissions: User must belong to the `docker` and `sudo` groups.

### Initial Configuration & Secrets Setup
1. Clone the repository:

       git clone <repository_url> Inception
       cd Inception

2. Create the configuration secrets file `srcs/.env`:

       cat <<EOF > srcs/.env
       DOMAIN_NAME=ainthana.42.fr
       SQL_DATABASE=wordpress
       SQL_USER=wpuser
       SQL_PASSWORD=wp_user_pass42
       SQL_ROOT_PASSWORD=super_root_pass42
       WP_TITLE=Inception
       WP_ADMIN_USER=ainthana_boss
       WP_ADMIN_PASSWORD=admin_pass42
       WP_ADMIN_EMAIL=ainthana@student.42.fr
       WP_USER=wp_author
       WP_USER_PASSWORD=author_pass42
       WP_USER_EMAIL=author@student.42.fr
       EOF

---

## 2. Building & Launching the Project

### Using Makefile (Recommended)
    make         # Build images, prepare directories, start containers
    make down    # Stop running containers
    make clean   # Stop containers and remove images/networks
    make fclean  # Full purge (containers, images, volumes, host data)
    make re      # Rebuild everything from scratch

### Direct Docker Compose Commands
    docker compose -f srcs/docker-compose.yml up --build -d
    docker compose -f srcs/docker-compose.yml down

---

## 3. System Architecture & Service Roles

Base Image: Custom Docker images built from `debian:bookworm`.

* **Nginx**: Front-facing HTTPS proxy (port 443). Handles TLS v1.2/v1.3 termination.
* **WordPress**: PHP 8.2-FPM application server (port 9000).
* **MariaDB**: Relational database engine (port 3306).

Network Isolation: Bridge network `inception_network`. Only Nginx exposes port 443 to the host. Services communicate internally via Docker DNS (`mariadb:3306`, `wordpress:9000`).

---

## 4. Persistent Storage & Volume Management

### Data Location & Persistence
Project data is stored directly on the host machine inside `/home/ainthana/data/`:
* Database files: `/home/ainthana/data/mariadb`
* WordPress site files: `/home/ainthana/data/wordpress`

Docker Named Volumes are mapped to these paths via local driver options in `docker-compose.yml`:

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

### Commands to Manage Volumes
    # List active Docker volumes
    docker volume ls

    # Inspect volume details and bind paths
    docker volume inspect mariadb_data
    docker volume inspect wordpress_data

    # Check host file contents directly
    ls -la /home/ainthana/data/mariadb
    ls -la /home/ainthana/data/wordpress

---

## 5. Process Management & PID 1 Execution

Entrypoints use array syntax (`ENTRYPOINT ["/script.sh"]`) combined with `exec` at the end of initialization scripts:
* Nginx: `exec nginx -g "daemon off;"`
* WordPress: `exec php-fpm8.2 -F`
* MariaDB: `exec mysqld_safe`

This replaces the shell process so the main service runs as PID 1, allowing proper system signal propagation (`SIGTERM`).

---

## 6. Container Debugging Commands

    # Inspect running processes inside containers
    docker top nginx
    docker top wordpress
    docker top mariadb

    # View container logs
    docker logs -f nginx
    docker logs -f wordpress
    docker logs -f mariadb

    # Open shell inside container
    docker exec -it wordpress sh
