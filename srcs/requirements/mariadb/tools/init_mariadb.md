# Entrypoint du conteneur MariaDB

Objectif :

1. Initialiser MariaDB au premier démarrage.
2. Créer la base WordPress et l'utilisateur SQL.
3. Ne plus refaire l'initialisation aux démarrages suivants.
4. Lancer MariaDB au premier plan.

---

# Vue d'ensemble

```text
Container démarre
        ↓
Lecture du secret
        ↓
Création des dossiers nécessaires
        ↓
Initialisation MariaDB (si nécessaire)
        ↓
Création base + utilisateur SQL (1 seule fois)
        ↓
Lancement définitif de MariaDB
```

---

# Shebang

```sh
#!/bin/sh
```

Indique que le script doit être exécuté avec le shell POSIX.

---

# Arrêt en cas d'erreur

```sh
set -e
```

Si une commande échoue le script s'arrête immédiatement.
Cela évite de continuer avec une base mal configurée.

---

# Lecture du secret

```sh
DB_USER_PASSWORD=$(cat /run/secrets/db_user_password)
```

Lit le mot de passe stocké dans le secret Docker.

---

# Fichier témoin

```sh
DB_INITIALIZED="/var/lib/mysql/inited"
```

Ce fichier sert de marqueur. S'il existe cela signifie que la base a déjà été configurée."

---

# Préparation du dossier runtime

```sh
mkdir -p /run/mysqld
```

Crée :

```text
/run/mysqld
```

qui contiendra :

```text
mysqld.sock
mysqld.pid
```

---

```sh
chown -R mysql:mysql /run/mysqld
```

Donne la propriété du dossier à l'utilisateur MariaDB.

---

# Vérification de l'existence de la base système

```sh
if [ ! -d "/var/lib/mysql/mysql" ]; then
```

Le dossier :

```text
/var/lib/mysql/mysql
```

contient les tables internes de MariaDB.

Si ce dossier n'existe pas :

```text
MariaDB n'a jamais été initialisé.
```

---

# Création du datadir

```sh
mkdir -p /var/lib/mysql
```

Crée le dossier des données.

---

```sh
chown -R mysql:mysql /var/lib/mysql
```

Assigne les permissions au compte MariaDB.

---

# Initialisation MariaDB

```sh
mysql_install_db --user=mysql --datadir=/var/lib/mysql
```

Crée les tables système :

```text
mysql.user
mysql.db
mysql.tables_priv
...
```
---

# Initialisation applicative

```sh
if [ ! -f "$DB_INITIALIZED" ]; then
```

Cette partie est exécutée uniquement la première fois.

---

# Démarrage temporaire

```sh
mysqld_safe --user=mysql --datadir=/var/lib/mysql &
```

Lance MariaDB en arrière-plan.

Le `&` signifie :

```text
Continuer le script immédiatement.
```

---

# PID du processus

```sh
DB_PID="$!"
```

`$!` contient le PID du dernier processus lancé en arrière-plan.

---

# Attente du démarrage

```sh
while ! mysqladmin ping --silent; do
	sleep 2
done
```

Boucle jusqu'à ce que MariaDB réponde.

---

# Création du script SQL

```sh
echo "CREATE DATABASE IF NOT EXISTS $DB_DATABASE ;" > db1.sql
echo "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_USER_PASSWORD' ;"
```
---

## Pourquoi `%` ?

```sql
'wpuser'@'%'
```

Autorise les connexions depuis n'importe quelle machine.

Dans Docker :

```text
wordpress → mariadb
```

WordPress arrive depuis un autre conteneur.

---

# Attribution des droits

```sh
GRANT ALL PRIVILEGES ON $DB_DATABASE.* TO '$DB_USER'@'%';
```
Donne tous les droits sur la base WordPress.

---

# Rechargement des privilèges

```sh
FLUSH PRIVILEGES;
```

Demande à MariaDB de recharger immédiatement les permissions.

---

# Exécution du script SQL

```sh
mysql < db1.sql
```

Injecte les commandes SQL dans MariaDB.

---

# Arrêt du serveur temporaire

```sh
mysqladmin shutdown
```

Arrête proprement MariaDB.

---

# Attente de fin

```sh
wait "$DB_PID" || true
```

Attend que le processus MariaDB soit réellement terminé.

Le :

```sh
|| true
```

empêche une erreur éventuelle de casser le script.

---

# Création du marqueur

```sh
touch $DB_INITIALIZED
```
---

# Lancement définitif

```sh
exec mysqld --user=mysql --console
```

C'est la ligne la plus importante.

`exec` remplace le shell par :

```text
mysqld
```

Le processus MariaDB devient alors le PID 1 du conteneur.

---
