# Image du conteneur Wordpress

# Image de base

```dockerfile
FROM debian:bullseye
```

Définit l'image de départ.

---

# Installation des paquets

```dockerfile
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php7.4 iputils-ping php7.4-fpm php7.4-mysql curl mariadb-client \
    && rm -rf /var/lib/apt/lists/*
```

---

## apt-get update

Télécharge la liste des paquets disponibles.

---

## apt-get upgrade -y

Met à jour les paquets déjà présents.
-y répond automatiquement "yes".

---

# php7.4

```dockerfile
php7.4
```

Installe l'interpréteur PHP.

---

# php7.4-fpm

```dockerfile
php7.4-fpm
```

Installe PHP-FPM.

FPM signifie :

```text
FastCGI Process Manager
```

C'est lui qui exécute les fichiers PHP pour Nginx.

Architecture :

```text
Navigateur
     ↓
Nginx
     ↓
PHP-FPM
     ↓
WordPress
```

---

# php7.4-mysql

```dockerfile
php7.4-mysql
```

Ajoute l'extension MySQL à PHP.
Sans elle WordPress ne pourrait pas utiliser MariaDB.

---

# iputils-ping

Pour le débogage.

Par exemple :

```bash
ping mariadb
```

permet de vérifier le réseau Docker.

---

# curl

Il servira à installer WP-CLI.

---

# mariadb-client

```dockerfile
mariadb-client
```

Installe :

```bash
mysql
mysqladmin
```
---

# Nettoyage du cache APT

```dockerfile
rm -rf /var/lib/apt/lists/*
```
Supprime le cache des paquets.

---

# Installation de WP-CLI

```dockerfile
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
```

Télécharge WP-CLI.

WP-CLI est l'outil officiel permettant de gérer WordPress en ligne de commande.

---

# Installation dans le PATH

```dockerfile
RUN mv wp-cli.phar /usr/local/bin/wp
```

---

# ENTRYPOINT

```dockerfile
ENTRYPOINT ["bash", "/tmp/init_wp.sh"]
```
