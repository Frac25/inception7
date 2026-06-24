Ce script est l'**entrypoint du conteneur Nginx**. Son rôle est :

1. Vérifier si un certificat SSL existe.
2. Le créer s'il n'existe pas.
3. Appliquer les permissions.
4. Démarrer Nginx au premier plan.

---

# Shebang

```sh
#!/bin/sh
```

Indique que le script doit être exécuté avec le shell POSIX.

---

# Options du shell

```sh
set -eu
```

Il y a ici deux options.

---

## `-e`

```sh
set -e
```

Le script s'arrête immédiatement si une commande échoue.

---

## `-u`

```sh
set -u
```

Interdit l'utilisation de variables non définies.

---

# Vérification du certificat

```sh
if [ ! -f "$SSL_PATH/nginx-selfsigned.crt" ]; then
```

`-f` vérifie si un fichier existe.

---

# Génération du certificat

```sh
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
```

Cette commande crée :

* une clé privée
* un certificat autosigné

---

## `req`

Création d'une demande de certificat.

---

## `-x509`

Demande à OpenSSL de générer directement un certificat.

---

## `-nodes`

Signifie :

```text
No DES
```

La clé privée ne sera pas protégée par un mot de passe.

Ainsi Nginx peut démarrer automatiquement.

---

## `-days 365`

Le certificat est valide :

```text
365 jours
```

---

## `-newkey rsa:2048`

Crée une nouvelle clé RSA de :

```text
2048 bits
```

---

# Clé privée

```sh
-keyout "$SSL_PATH/nginx-selfsigned.key"
```

Cette clé doit rester secrète.

---

# Certificat

```sh
-out "$SSL_PATH/nginx-selfsigned.crt"
```

Il est envoyé au navigateur.

---

# Informations du certificat

```sh
-subj "/C=CH/ST=Vaud/L=Lausanne/O=sydubois/CN=Inception"
```

Évite les questions interactives.

---

# Permissions de la clé

```sh
chmod 600 "$SSL_PATH/nginx-selfsigned.key"
```

Donne :

```text
rw-------
```

Seul le propriétaire peut lire la clé privée.

C'est important pour la sécurité.

---

# Permissions du certificat

```sh
chmod 644 "$SSL_PATH/nginx-selfsigned.crt"
```

Donne :

```text
rw-r--r--
```

Le certificat peut être lu par tous.

Ce n'est pas un secret.

---


# Démarrage de Nginx

```sh
exec nginx -g "daemon off;"
```

C'est la ligne la plus importante.

---

## `nginx`

Lance le serveur web.

---

## `-g`

Permet de passer une directive de configuration.

---

## `daemon off;`

Avec :

```text
daemon off;
```

Nginx reste au premier plan.

---

## Pourquoi `exec` ?

```sh
exec nginx ...
```

remplace le shell par Nginx.

Ainsi :

```text
PID 1 = nginx
```

Docker peut :

* arrêter proprement le conteneur,
* envoyer les signaux correctement,
* gérer les logs.

---


