# Fichier de configuration du serveur MariaDB


C'est le principal fichier de configuration du serveur MariaDB. Il est lu au démarrage de mysqld

Comment il est utilisé


Au démarrage :

```text
mysqld
    ↓
lit les fichiers .cnf
    ↓
charge les paramètres
    ↓
ouvre le port SQL
    ↓
utilise le datadir
    ↓
accepte les connexions
```

Il faut distinguer **les sections** (`[mysqld]`, `[mariadb]`, etc.) et les **directives** (`socket=...`, `datadir=...`).

---

# 1. Les sections

## `[server]`

Section générique lue par tous les serveurs MariaDB.

Les options placées ici s'appliquent généralement à tous les types de serveurs MariaDB.

---

## `[mysqld]`

Section utilisée par le serveur MariaDB principal (le démon).

C'est ici qu'on configure le comportement du serveur qui écoute les connexions.

La plupart de tes paramètres sont dans cette section.

---

## `[embedded]`

Concerne MariaDB embarqué dans une application.

---

## `[mariadb]`

Section spécifique à MariaDB.

Permet d'ajouter des options que MySQL ne comprendrait pas.

---

## `[mariadb-10.11]`

Section spécifique à une version précise.

---

# 2. Les directives utilisées

## socket

```ini
socket = /run/mysqld/mysqld.sock
```

Chemin du socket Unix.

Permet à un programme local de communiquer avec MariaDB sans passer par TCP/IP.

Exemple :

```bash
mysql -u root -p
```

utilise souvent ce socket.

---

## pid-file

```ini
pid-file = /run/mysqld/mysqld.pid
```

Fichier contenant le PID du processus MariaDB.

Exemple :

```text
1234
```

Le système peut ensuite retrouver facilement le processus.

---

## basedir

```ini
basedir = /usr
```

Répertoire où MariaDB est installé.

On y trouve les binaires :

```text
/usr/bin/mysql
/usr/bin/mysqld
```

---

## bind-address

```ini
bind-address = 0.0.0.0
```

Très important dans Docker.

### Sans ça

Par défaut :

```ini
bind-address = 127.0.0.1
```

MariaDB n'accepte que les connexions locales.

Donc :

```text
wordpress ---> mariadb
```

ne fonctionnerait pas.

---

### Avec

```ini
bind-address = 0.0.0.0
```

MariaDB écoute sur toutes les interfaces réseau.

Le conteneur WordPress peut se connecter :

```bash
mysql -h mariadb
```

---

## character-set-server

```ini
character-set-server = utf8mb4
```

Définit l'encodage par défaut.

`utf8mb4` est l'encodage recommandé.

Il supporte :

```text
é
à
€
😀
🚀
🎉
```

---

### Pourquoi pas utf8 ?

L'ancien :

```ini
utf8
```

ne supporte que 3 octets.

Les emojis nécessitent souvent 4 octets.

D'où :

```ini
utf8mb4
```

---

## collation-server

```ini
collation-server = utf8mb4_general_ci
```

Détermine comment MariaDB compare les chaînes.

---

### ci

```text
ci = case insensitive
```

Donc :

```sql
SELECT * FROM users
WHERE name = 'sylvain';
```

trouvera :

```text
Sylvain
SYLVAIN
sylvain
```

---

### Exemple

```sql
'a' = 'A'
```

renvoie :

```text
TRUE
```

avec cette collation.

---

## datadir

```ini
datadir = /var/lib/mysql
```

Répertoire où MariaDB stocke :

* bases de données
* tables
* index
* journaux

Dans ton conteneur :

```text
/var/lib/mysql
```

est monté sur ton volume :

```text
/home/<user>/data/mariadb
```

via :

```yaml
volumes:
  - mariadb:/var/lib/mysql
```

---

## expire_logs_days

```ini
expire_logs_days = 10
```

Concerne les binary logs.

MariaDB supprimera automatiquement les logs binaires vieux de plus de 10 jours.

---

### Binary logs

Ils enregistrent :

```sql
INSERT
UPDATE
DELETE
```

pour :

* réplication
* restauration
* audit

---



---

# Les 5 lignes les plus importantes pour Inception


```ini
bind-address = 0.0.0.0
```

➡ permet à WordPress de joindre MariaDB depuis un autre conteneur.

---

```ini
datadir = /var/lib/mysql
```

➡ emplacement des données de la base.

---

```ini
socket = /run/mysqld/mysqld.sock
```

➡ communication locale via socket Unix.

---

```ini
character-set-server = utf8mb4
```

➡ support complet de l'UTF-8 et des emojis.

---

```ini
collation-server = utf8mb4_general_ci
```

➡ comparaisons de texte insensibles à la casse (`A = a`).
