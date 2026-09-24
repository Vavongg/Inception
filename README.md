*This project has been created as part of the 42 curriculum by ainthana.*

# Inception

## Description
The **Inception** project is a System Administration and DevOps project at École 42. Its primary goal is to build a fully functional, secure, and isolated web infrastructure using **Docker Compose**. The stack relies entirely on custom Docker images built from **Debian Bookworm**, orchestrating a LEMP environment consisting of three distinct services:
- **Nginx**: Serves as the sole entry point, handling incoming HTTPS traffic exclusively over TLS v1.2/v1.3 on port 443.
- **WordPress + PHP-FPM**: Manages website content via PHP 8.2-FPM listening on port 9000, pre-configured with non-admin credentials and automated user provisioning using WP-CLI.
- **MariaDB**: Operates as a relational database system running on port 3306, completely isolated within a dedicated internal network.

All services are built with strict security practices, non-root initialization procedures, proper PID 1 management, and persistent storage mapping to specific host directories.

---

## Project Description & Architecture Design Choices

### Docker Usage and Included Sources
The repository is structured following the principle of **Separation of Concerns**. Each service resides in its own isolated directory under `srcs/requirements/`, containing its dedicated `Dockerfile`, configuration files (`conf/`), and entrypoint initialization scripts (`tools/`):
- `srcs/requirements/nginx/`: Nginx configuration, OpenSSL self-signed certificate generation, and foreground execution script.
- `srcs/requirements/wordpress/`: PHP-FPM pool configuration, automated WP-CLI installation, core configuration, and non-admin user setup script.
- `srcs/requirements/mariadb/`: Server configuration (`50-server.cnf`), database initialization, secure password setup, and MariaDB daemon management.
- `srcs/docker-compose.yml`: Global orchestration defining bridge networking, container health dependencies, environment variables, and local volume drivers.
- `srcs/.env`: Environment secrets file storing credentials, database names, and domain definitions.

### Main Technical Comparisons

#### 1. Virtual Machines vs Docker
- **Virtual Machines**: Virtualize an entire hardware stack using a hypervisor (e.g., VirtualBox, KVM). Every VM runs a complete guest operating system, which consumes significant CPU, RAM, and disk storage while causing slow boot times.
- **Docker Containers**: Provide OS-level virtualization by sharing the host system's Linux kernel (via Linux namespaces and cgroups). Containers run as isolated processes directly on the host, making them extremely lightweight, fast to launch, and highly efficient in resource utilization.

#### 2. Secrets vs Environment Variables
- **Environment Variables (`.env`)**: Pass dynamic configuration settings (such as service names, ports, or usernames) into container runtime environments. While convenient, plain environment variables can be inspected via process listing (`docker inspect`) or logged in shell histories, making them less ideal for highly sensitive production secrets.
- **Secrets (e.g., Docker Secrets / Vault)**: Encrypt and manage sensitive credentials at rest and in transit. They are mounted strictly into temporary in-memory files (RAM) inside specific containers, preventing sensitive data from exposure in image layers or environment outputs. In this project, environment variables are loaded securely through a non-committed `srcs/.env` file.

#### 3. Docker Network vs Host Network
- **Host Network (`network_mode: "host"`)**: Removes network isolation between the container and the Docker host. The container shares the host's IP address and network interfaces directly, exposing all open container ports directly to the public/host network.
- **Docker Network (`driver: bridge`)**: Creates a private, isolated virtual bridge network (`inception_network`). Services communicate securely using Docker's internal DNS resolution (e.g., `wordpress:9000`, `mariadb:3306`) without exposing internal database or application ports to the host or outside world. Only Nginx explicitly maps port `443` to the host.

#### 4. Docker Volumes vs Bind Mounts
- **Direct Bind Mounts**: Directly map a file or directory from the host filesystem into a container directory. While simple, they bypass Docker volume management tools, depend heavily on specific host path structures, and are explicitly restricted for primary service storage by the project rules.
- **Docker Named Volumes (with Local Bind Driver Options)**: Fully declared and managed via the Docker volume subsystem (`docker volume ls`). To meet both the Named Volume rule and the host storage path constraint (`/home/ainthana/data/`), Docker local driver options (`driver_opts` with `type: 'none'`, `o: 'bind'`, and `device: '/home/ainthana/data/...'`) are utilized. This ensures Docker manages the volume lifecycle while persisting data directly into the mandatory host directories.

---

## Instructions

### Prerequisites
- A Linux host environment (Debian/Ubuntu recommended) or VM.
- **Docker** and **Docker Compose** installed.
- `sudo` privileges (required by the Makefile to manage local host storage permissions at `/home/ainthana/data`).

### Building and Running
To compile, set up host directories, build custom images, and launch the stack:

```bash
# Clone the repository
git clone <repository_url> Inception
cd Inception

# Build and start the infrastructure
make
```
## Resources

### Documentation & References
- **Stéphane Robert's Blog**:
  - [Documentation de Conteneurisation](https://blog.stephane-robert.info/docs/conteneurisation/)
  - [Moteurs de Conteneurs - Docker](https://blog.stephane-robert.info/docs/conteneurs/moteurs-conteneurs/docker/)
  - [Rédiger un Dockerfile](https://blog.stephane-robert.info/docs/conteneurs/images-conteneurs/ecrire-dockerfile/)
  - [Django & Tests Unitaires sous Docker](https://blog.stephane-robert.info/post/django-test-unitaire-docker/)
- **Official Documentation**:
  - [Nginx Official Documentation](https://nginx.org/en/docs/)
  - [WordPress & WP-CLI Documentation](https://developer.wordpress.org/cli/commands/)
  - [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
  - [Docker & Docker Compose Documentation](https://docs.docker.com/)

