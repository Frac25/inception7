# USER_DOC.md

# Inception User Documentation

## Overview

This project deploys a complete WordPress infrastructure using Docker containers.

The stack provides the following services:

* **Nginx**: HTTPS web server.
* **WordPress**: CMS running on PHP-FPM.
* **MariaDB**: database server used by WordPress.

All services communicate through a private Docker network.

---

# Starting the Project

From the root of the repository:

```bash
make
```

or

```bash
make build
make up
```

The build process creates all Docker images and starts the services.

---

# Stopping the Project

Stop all running containers:

```bash
make down
```

---

# Cleaning Docker Resources

Remove containers, unused images, networks and volumes:

```bash
make clean
```

Perform a complete cleanup including project data:

```bash
make fclean
```

This command removes:

* Containers
* Volumes
* WordPress files
* MariaDB data

and recreates clean data directories.

---

# Accessing the Website

Open a browser and navigate to:

```text
https://<DOMAIN>
```

Example:

```text
https://sydubois.42.fr
```

Because the project uses a self-signed SSL certificate, your browser may display a security warning.

---

# Accessing the WordPress Administration Panel

Open:

```text
https://<DOMAIN>/wp-admin
```

Example:

```text
https://sydubois.42.fr/wp-admin
```

Log in using the administrator credentials configured during installation.

---

# Credentials Management

Passwords are stored using Docker secrets.

Location:

```text
secrets/
```

Files:

```text
db_user_password
wp_user_password
wp_root_password
```

Environment variables such as usernames, emails and domain names are configured in:

```text
srcs/.env
```

---

# Checking Service Status

Display running containers:

```bash
docker ps
```

Display project services:

```bash
docker-compose -f srcs/docker-compose.yml ps
```

View logs:

```bash
docker-compose -f srcs/docker-compose.yml logs
```

View logs for a specific service:

```bash
docker-compose -f srcs/docker-compose.yml logs nginx
docker-compose -f srcs/docker-compose.yml logs wordpress
docker-compose -f srcs/docker-compose.yml logs mariadb
```

---

# Verifying Correct Operation

The project is considered operational if:

* All containers are running.
* The website is reachable through HTTPS.
* WordPress administration is accessible.
* No critical errors appear in container logs.

Quick verification:

```bash
docker ps
```

Then open:

```text
https://<DOMAIN>
```
Example:

```text
https://sydubois.42.fr
```

and

```text
https://<DOMAIN>/wp-admin
```

Example:

```text
https://sydubois.42.fr/wp-admin
```