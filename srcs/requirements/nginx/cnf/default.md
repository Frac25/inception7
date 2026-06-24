Ce fichier configure le serveur **Nginx** qui sert de frontal HTTPS pour l'application PHP (ici WordPress exécuté dans un conteneur nommé `wordpress`).

Décomposition ligne par ligne :

```nginx
server {
```

Début d'un bloc **server**, c'est-à-dire un hôte virtuel Nginx.

---

### Écoute HTTPS

```nginx
listen 443 ssl;
listen [::]:443 ssl;
```

* `listen 443 ssl;` : écoute les connexions HTTPS sur le port 443 en IPv4.
* `listen [::]:443 ssl;` : même chose pour IPv6.
* `ssl` indique que les connexions utilisent TLS/SSL.

---

### Nom de domaine

```nginx
server_name _;
```

* `_` agit comme un serveur par défaut.
* Nginx répondra à toute requête reçue sur ce port, quel que soit le nom de domaine demandé.

---

### Certificat TLS

```nginx
ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;
```

Spécifie :

* le certificat public ;
* la clé privée associée.

---

### Versions TLS autorisées

```nginx
ssl_protocols TLSv1.3 TLSv1.2;
```

N'autorise que :

* TLS 1.2
* TLS 1.3

---

### Répertoire racine

```nginx
root /var/www/html;
```

Définit où Nginx cherche les fichiers du site.

---

### Fichier par défaut

```nginx
index index.php;
```
---

## Gestion des URLs

```nginx
location / {
    try_files $uri $uri/ /index.php?$args;
}
```

Cette partie est essentielle pour WordPress.

### `try_files`

Nginx teste successivement :

```nginx
$uri
```

Le fichier demandé existe-t-il ?

Exemple :

```
/wp-content/image.jpg
```

↓

```
/var/www/html/wp-content/image.jpg
```

Si oui, il est servi directement.

---

Sinon :

```nginx
$uri/
```

Vérifie si c'est un répertoire.

---

Sinon :

```nginx
/index.php?$args
```

La requête est redirigée vers :

```
index.php
```

avec les paramètres GET conservés.

---

## Traitement PHP

```nginx
location ~ \.php$ {
```

Le `~` signifie "expression régulière".

Cette règle s'applique à tout fichier finissant par : .php

---

### Configuration FastCGI standard

```nginx
include snippets/fastcgi-php.conf;
```

Charge une configuration fournie par la distribution.

Elle contient généralement :

```nginx
fastcgi_param SCRIPT_FILENAME ...
fastcgi_param QUERY_STRING ...
```

Ces paramètres sont nécessaires pour que PHP-FPM sache quel script exécuter.

---

### Envoi à PHP-FPM

```nginx
fastcgi_pass wordpress:9000;
```

Nginx n'exécute pas PHP lui-même.

Il transmet la requête à un serveur PHP-FPM :

* hôte : `wordpress`
* port : `9000`

Schéma :

```
Navigateur
    ↓ HTTPS
Nginx
    ↓ FastCGI
wordpress:9000 (PHP-FPM)
    ↓
MariaDB
```

---

## Exemple complet

Requête :

```
https://site.fr/wp-login.php
```

1. Nginx reçoit la requête sur le port 443.
2. La règle `location ~ \.php$` correspond.
3. Nginx transmet l'exécution à :

```text
wordpress:9000
```

4. PHP-FPM exécute :

```text
/var/www/html/wp-login.php
```

5. PHP génère du HTML.
6. Le résultat est renvoyé à Nginx.
7. Nginx renvoie la réponse HTTPS au navigateur.

---