# Commandes Docker présentes dans Makefile, avec le rôle de chaque option.

---

# 1. Construction des images

```bash
docker-compose -f srcs/docker-compose.yml build --no-cache
```

## docker-compose

Outil qui lit un fichier `docker-compose.yml` et exécute les actions décrites dedans.

---

## -f

```bash
-f srcs/docker-compose.yml
```

Indique explicitement quel fichier Compose utiliser.

Sans :

```bash
docker-compose build
```

Docker chercherait automatiquement :

```text
docker-compose.yml
```

dans le répertoire courant.

---

## build

```bash
docker-compose build
```

Construit les images à partir des Dockerfiles.

Dans ton projet :

```text
requirements/nginx/Dockerfile
requirements/wordpress/Dockerfile
requirements/mariadb/Dockerfile
```

seront exécutés.

---

## --no-cache

```bash
docker-compose build --no-cache
```

Force Docker à reconstruire toutes les couches.

Sans cette option :

```bash
RUN apt-get install nginx
```

peut être récupéré depuis le cache.

Avec :

```bash
--no-cache
```

tout est réexécuté.

Très utile pour Inception.

---

# 2. Démarrage des services

```bash
docker-compose -f srcs/docker-compose.yml up -d
```

---

## up

Crée et démarre les conteneurs.

Docker :

1. crée le réseau
2. crée les volumes
3. crée les conteneurs
4. les démarre

---

## -d

```bash
up -d
```

Mode détaché.

Le terminal est rendu immédiatement.

Sans :

```bash
docker-compose up
```

tu verrais les logs en direct.

---

# 3. Démarrer un seul service

```bash
docker-compose up -d mariadb
```

ou

```bash
docker-compose up -d wordpress
```

ou

```bash
docker-compose up -d nginx
```

---

Le mot placé à la fin :

```bash
mariadb
```

désigne le service.

Docker démarre uniquement ce service et ses dépendances.

Exemple :

```bash
docker-compose up -d wordpress
```

démarrera :

```text
mariadb
wordpress
```

car :

```yaml
depends_on:
  - mariadb
```

---

# 4. Arrêt du projet

```bash
docker-compose -f srcs/docker-compose.yml down
```

---

## down

Arrête et supprime :

* les conteneurs
* les réseaux créés par Compose

Mais conserve :

* les volumes
* les images

---

Exemple :

Avant :

```text
container nginx
container wordpress
container mariadb
network inception
volume wordpress
volume mariadb
```

Après :

```text
volume wordpress
volume mariadb
```

restent présents.

---

# 5. Suppression complète du projet

```bash
docker-compose down -v --remove-orphans
```

---

## -v

```bash
down -v
```

Supprime également les volumes.

Sans :

```bash
volume wordpress
volume mariadb
```

restent sur la machine.

Avec :

```bash
-v
```

ils sont supprimés.

---

## --remove-orphans

Supprime les conteneurs "orphelins".

Exemple :

Avant :

```yaml
services:
  nginx:
  wordpress:
  mariadb:
  redis:
```

Puis tu retires :

```yaml
redis:
```

du fichier.

Le conteneur Redis existe encore.

Cette option le supprime.

---

# 6. Nettoyage global Docker

```bash
docker system prune -af
```

---

## system prune

Nettoie les ressources inutilisées :

* conteneurs arrêtés
* réseaux inutilisés
* images inutilisées
* cache build

---

## -a

```bash
docker system prune -a
```

Supprime aussi les images non utilisées.

Sans :

```bash
-a
```

Docker garde certaines images.

---

## -f

```bash
-f
```

Force l'exécution sans demander :

```text
Are you sure? [y/N]
```

---

# 7. Nettoyage des volumes

```bash
docker volume prune -f
```

---

## volume prune

Supprime les volumes non utilisés.

Exemple :

```text
wordpress_old
mariadb_old
```

plus attachés à aucun conteneur.

Ils seront supprimés.

---

## -f

Confirmation automatique.

---

# 8. Nettoyage des réseaux

```bash
docker network prune -f
```

---

## network prune

Supprime les réseaux inutilisés.

Exemple :

```text
inception_old
test_network
```

plus utilisés.

Ils seront supprimés.

---

# Résumé rapide

| Commande                    | Effet                                  |
| --------------------------- | -------------------------------------- |
| `docker-compose build`      | construit les images                   |
| `--no-cache`                | ignore le cache Docker                 |
| `docker-compose up`         | crée et démarre                        |
| `-d`                        | arrière-plan                           |
| `docker-compose up mariadb` | démarre seulement MariaDB              |
| `docker-compose down`       | arrête et supprime les conteneurs      |
| `-v`                        | supprime aussi les volumes             |
| `--remove-orphans`          | supprime les conteneurs non référencés |
| `docker system prune`       | nettoyage global                       |
| `-a`                        | supprime aussi les images inutilisées  |
| `docker volume prune`       | supprime les volumes inutilisés        |
| `docker network prune`      | supprime les réseaux inutilisés        |
| `-f`                        | ne demande pas confirmation            |

Pour l'oral d'Inception, les commandes qu'on te demande le plus souvent d'expliquer sont généralement :

```bash
docker-compose up -d
docker-compose down -v
docker-compose build --no-cache
docker system prune -af
```

et surtout la différence entre :

```bash
docker-compose down
```

et

```bash
docker-compose down -v
```

car elle touche directement à la persistance des données MariaDB et WordPress.
