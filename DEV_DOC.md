# DEV_DOC.md

# Inception Developer Documentation

## Prerequisites

The following software must be installed:

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

# Repository Structure

```text
.
├── Makefile
├── secrets/
└── srcs/
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

---

# Initial Configuration

## Domain Configuration

Add your domain to the hosts file.

Example:

Acces :

```text
sudo nano /etc/hosts
```

And add :

```text
127.0.0.1 sydubois.42.fr
37.59.120.163   sydubois.42.fr
```

---

## Environment Variables

Create or edit:

```text
srcs/.env
```

Example:

```env
#MARIADB
DB_DATABASE=wordpress_db
DB_USER=db_user

#WORDPRESS
WP_DOMAIN=sydubois.42.fr
WP_NAME=Inception

WP_ROOT=wproot
WP_ROOT_MAIL=wproot@hotmail.fr

WP_USER=wpuser
WP_USER_MAIL=wpuser@hotmail.fr

#NGINX
SSL_PATH="/etc/nginx/ssl"
```

---

## Docker Secrets

Generate secret files:

```bash
make secrets
```

This creates:

```text
secrets/
├── db_user_password
├── wp_user_password
└── wp_root_password
```

Populate each file with the appropriate password.

---

# Building the Project

Build all Docker images:

```bash
make build
```

The Makefile uses:

```bash
docker-compose -f srcs/docker-compose.yml build --no-cache
```

to ensure fresh image creation.

---

# Starting the Infrastructure

Launch all services:

```bash
make up
```

Equivalent command:

```bash
docker-compose -f srcs/docker-compose.yml up -d
```

---

# Service-by-Service Startup

For debugging purposes, individual services can be started:

MariaDB:

```bash
make db
```

WordPress:

```bash
make wp
```

Nginx:

```bash
make nx
```

---

# Stopping the Infrastructure

```bash
make down
```

Equivalent command:

```bash
docker-compose -f srcs/docker-compose.yml down
```

---

# Full Cleanup

```bash
make fclean
```

This command:

1. Stops containers.
2. Removes volumes.
3. Removes bind-mounted data directories:

   * `/home/<user>/data/mariadb`
   * `/home/<user>/data/wordpress`
4. Recreates empty data directories.

Useful when testing a fresh installation.

---

# Container Management

List running containers:

```bash
docker ps
```

Open a shell inside a container:

```bash
docker exec -it mariadb sh
docker exec -it wordpress sh
docker exec -it nginx sh
```
Open MYSQL inside a shell mariadb:

```bash
mysql -u root -p
```

request SQL inside a mariadb:

```bash
SHOW DATABASES;
USE wordpress_db;
SHOW TABLES;
SELECT* FROM wp_users;
```

Display logs:

```bash
docker-compose -f srcs/docker-compose.yml logs
```

Display logs for one service:

```bash
docker-compose -f srcs/docker-compose.yml logs wordpress
```

---

# Volumes and Data Persistence

The project stores data using bind mounts.

MariaDB data:

```text
/home/<user>/data/mariadb
```

Contains:

* databases
* tables
* users
* WordPress content stored in MariaDB

WordPress data:

```text
/home/<user>/data/wordpress
```

Contains:

* WordPress core files
* plugins
* themes
* uploads
* configuration files

Data remains available even if containers are recreated.

---

# Architecture

```text
Client Browser
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

Container communication occurs through the Docker network created by Docker Compose.

---

# Useful Debugging Commands

Verify MariaDB availability:

```bash
docker exec -it mariadb mysqladmin ping
```

Verify WordPress installation:

```bash
docker exec -it wordpress wp core is-installed \
    --allow-root \
    --path=/var/www/html

echo $?
```

Validate Nginx configuration:

```bash
docker exec -it nginx nginx -t
```

Inspect Docker volumes:

```bash
docker volume ls
```

Inspect Docker networks:

```bash
docker network ls
```

These commands help diagnose most issues encountered during development or evaluation.
