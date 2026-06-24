*This project has been created as part of the 42 curriculum by sydubois.*

# Inception

## Description

Inception is a system administration and containerization project from the 42 curriculum.

The goal of the project is to build a complete web infrastructure using Docker and Docker Compose. Instead of installing services directly on the host machine, each service runs inside its own isolated container.

This project deploys a WordPress website accessible through HTTPS and backed by a MariaDB database. All services communicate through a dedicated Docker network.

### Services

The infrastructure contains the following containers:

| Service   | Purpose                                        |
| --------- | ---------------------------------------------- |
| Nginx     | HTTPS web server and reverse proxy             |
| WordPress | Content Management System running with PHP-FPM |
| MariaDB   | Database server used by WordPress              |

rq : Nginx: HTTPS web server that handles SSL/TLS encryption and forwards PHP requests to the WordPress PHP-FPM container.

### Project Architecture

```text
Internet
    |
    v
Nginx (HTTPS)
    |
    v
WordPress (PHP-FPM)
    |
    v
MariaDB
```

---

# Project Design Choices

## Why Docker?

Docker allows applications and services to run inside lightweight isolated environments called containers.

Benefits:

* Reproducible deployments
* Service isolation
* Easier maintenance
* Simplified dependency management
* Faster startup compared to virtual machines

Each service in this project runs in its own dedicated container.

---

## Sources Used

The project uses:

* Debian Bullseye as the base operating system
* Nginx
* WordPress
* PHP-FPM
* MariaDB
* Docker Compose

Official images are not used directly. Each service is built from a custom Dockerfile as required by the subject.

---

# Technical Comparisons

## Virtual Machines vs Docker

### Virtual Machines

A virtual machine emulates an entire operating system.

Advantages:

* Strong isolation
* Independent kernel

Disadvantages:

* Higher resource consumption
* Longer startup times
* Larger disk usage

### Docker Containers

Containers share the host kernel while isolating processes and filesystems.

Advantages:

* Lightweight
* Fast startup
* Lower resource usage
* Easy deployment

Disadvantages:

* Weaker isolation than a full virtual machine

### Choice for this Project

Docker containers were chosen because they provide lightweight service isolation while remaining efficient and easy to manage.

---

## Secrets vs Environment Variables

### Environment Variables

Environment variables are commonly used to configure applications.

Advantages:

* Easy to use
* Easy to modify

Disadvantages:

* Visible through process inspection
* May appear in logs

### Docker Secrets

Docker Secrets store sensitive information separately from application configuration.

Advantages:

* Better security
* Restricted access
* Not stored directly in images

Disadvantages:

* Slightly more complex setup

### Choice for this Project

Environment variables are used for configuration values such as:

* Domain name
* Database name
* Usernames

Docker Secrets are used for sensitive information such as:

* Database passwords
* WordPress passwords

---

## Docker Network vs Host Network

### Host Network

Containers share the host network stack.

Advantages:

* Minimal overhead

Disadvantages:

* Reduced isolation
* Potential port conflicts

### Docker Bridge Network

Containers communicate through an isolated virtual network.

Advantages:

* Better isolation
* Internal DNS resolution
* Easier service discovery

Disadvantages:

* Slight networking overhead

### Choice for this Project

A dedicated Docker network is used to allow services to communicate securely while remaining isolated from the host.

---

## Docker Volumes vs Bind Mounts

### Docker Volumes

Managed directly by Docker.

Advantages:

* Portable
* Easy backup and management
* Docker-managed lifecycle

Disadvantages:

* Less direct visibility from the host

### Bind Mounts

Map a specific host directory into a container.

Advantages:

* Direct access from host
* Easy inspection

Disadvantages:

* Host-dependent paths
* Requires manual management

### Choice for this Project

This project uses bind mounts (in .yml):

```text
/home/${USER}/data/mariadb
/home/${USER}/data/wordpress 
```

This allows data persistence while keeping database and WordPress files directly accessible from the host system.

---

# Instructions

## Prerequisites

Required software:

* Docker
* Docker Compose
* GNU Make

Verify installation:

```bash
docker --version
docker-compose --version
make --version
```

---

## Configure the Environment

Create and configure:

```text
srcs/.env
```

Create Docker secrets:

```bash
make secrets
```

Fill the generated files with appropriate passwords.

---

## Build the Project

```bash
make build
```

---

## Start the Infrastructure

```bash
make up
```

or simply:

```bash
make
```

---

## Stop the Infrastructure

```bash
make down
```

---
## Cleanup

```bash
make clean
```

This command removes:

* Containers
* Images

---

## Full Cleanup

```bash
make fclean
```

This command removes:

* Containers
* Images
* Volumes
* Persistent data directories
* Secrets

and recreates a clean environment.

---

# Usage

Access the website:

```text
https://<DOMAIN>
```

Example:

```text
https://sydubois.42.fr
```

Access the administration panel:

```text
https://sydubois.42.fr/wp-admin
```

Because the SSL certificate is self-signed, the browser may display a security warning.

---

# Data Persistence

The project stores persistent data outside containers.

MariaDB data:

```text
/home/${USER}/data/mariadb
```

WordPress data:

```text
/home/${USER}/data/wordpress
```

Data remains available after container recreation.

---

# Resources

## Official Documentation

Docker:

https://docs.docker.com/

Docker Compose:

https://docs.docker.com/compose/

Nginx:

https://nginx.org/en/docs/

WordPress:

https://wordpress.org/support/

WP-CLI:

https://wp-cli.org/

MariaDB:

https://mariadb.com/kb/en/documentation/

PHP-FPM:

https://www.php.net/manual/en/install.fpm.php

---

## Learning Resources

Docker Networking:

https://docs.docker.com/network/

Docker Volumes:

https://docs.docker.com/storage/volumes/

Docker Secrets:

https://docs.docker.com/engine/swarm/secrets/

Nginx Reverse Proxy:

https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/

---

## AI Usage

Artificial Intelligence tools were used as a learning and documentation aid.

AI assistance was used for:

* Understanding Docker concepts
* Understanding Docker networking and volumes
* Reviewing shell scripts
* Improving code comments
* Improving technical documentation
* Clarifying WordPress and PHP-FPM configuration
* A lot of more

https://nginx.org/en/docs/beginners_guide.html#conf_structure

https://tuto.grademe.fr/inception/
