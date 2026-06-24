# DOCKER COMPOSE

`docker-compose.yml` contient 4 sections :

```yaml
networks:
volumes:
services:
secrets:
```

Chaque section a un rôle différent.

# 1. networks

```yaml
networks:
  inception:
    driver: bridge
    name: inception
```

Tu définis ici un réseau Docker nommé `inception`.

Tous les conteneurs qui utilisent :

```yaml
networks:
  - inception
```

seront connectés au même réseau privé.

Grâce à ça :

```bash
wordpress → mariadb
nginx → wordpress
```

peuvent communiquer par leur nom de service.

Par exemple dans WordPress :

```bash
mysql -h mariadb
```

fonctionne parce que `mariadb` est résolu automatiquement par Docker.

---

# 2. volumes

```yaml
volumes:
  wordpress:
    ...
  
  mariadb:
    ...
```

Ici tu déclares des volumes nommés.

Ce ne sont pas encore des montages dans les conteneurs.

Tu dis simplement à Docker :

> "Il existe un volume appelé wordpress"
>
> "Il existe un volume appelé mariadb"

Le détail :

```yaml
wordpress:
  name: wordpress
  driver: local
  driver_opts:
    device: /home/${USER}/data/wordpress
    o: bind
    type: none
```

signifie :

```text
Volume Docker "wordpress"
          ↓
/home/<user>/data/wordpress
```

Donc les fichiers sont réellement stockés sur l'hôte.

Même si le conteneur est supprimé :

```bash
docker compose down
```

les données restent.

---

# 3. services

C'est la partie la plus importante.

```yaml
services:
```

Chaque entrée représente un conteneur.

Dans ton cas :

```yaml
services:
  nginx:
  wordpress:
  mariadb:
```

Tu auras donc 3 conteneurs.

---

# 3.1 Service nginx

```yaml
nginx:
```

Tout ce qui est indenté sous cette clé appartient au conteneur nginx.

---

### container_name

```yaml
container_name: nginx
```

Nom du conteneur.

---

### build

```yaml
build: ./requirements/nginx/.
```

Docker va construire l'image à partir du Dockerfile présent dans :

```text
requirements/nginx/
```

---

### ports

```yaml
ports:
  - "443:443"
```

Association :

```text
machine hôte     conteneur
     443     →      443
```

Les connexions HTTPS arrivent sur Nginx.

---

### depends_on

```yaml
depends_on:
  - wordpress
```

Docker démarre WordPress avant Nginx.

Attention :

ça ne garantit pas que WordPress est prêt.

Ça garantit seulement que son conteneur a été lancé.

---

### volumes

```yaml
volumes:
  - wordpress:/var/www/html
```

Le volume nommé :

```yaml
volumes:
  wordpress:
```

est monté dans :

```text
/var/www/html
```

du conteneur nginx.

Nginx voit donc les fichiers WordPress.

---

### env_file

```yaml
env_file:
  - ./.env
```

Charge les variables du fichier :

```text
.env
```
---

### networks

```yaml
networks:
  - inception
```

Connexion au réseau privé.

---

### restart

```yaml
restart: always
```

Redémarrage automatique en cas de crash ou reboot.

---

# 3.2 Service wordpress

Même principe :

```yaml
wordpress:
```

---

### build

```yaml
build: ./requirements/wordpress/.
```

Construit l'image PHP-FPM.

---

### depends_on

```yaml
depends_on:
  - mariadb
```

MariaDB démarre avant WordPress.

---

### volumes

```yaml
volumes:
  - wordpress:/var/www/html
```

Le même volume que Nginx.

Donc :

```text
WordPress écrit
        ↓
Volume
        ↓
Nginx lit
```

Les deux partagent les mêmes fichiers.

---

### secrets

```yaml
secrets:
  - wp_root_password
  - wp_user_password
  - db_user_password
```

Docker monte automatiquement :

```text
/run/secrets/wp_root_password
/run/secrets/wp_user_password
/run/secrets/db_user_password
```

dans le conteneur.

Ton script peut alors faire :

```bash
cat /run/secrets/db_user_password
```

---

# 3.3 Service mariadb

Même logique.

Il utilise :

```yaml
volumes:
  - mariadb:/var/lib/mysql
```

Donc :

```text
Base MariaDB
      ↓
Volume mariadb
      ↓
/home/<user>/data/mariadb
```

Les données persistent.

---

# 4. secrets

Definition des secrets disponibles pour le projet.

```yaml
secrets:
  db_user_password:
    file: ../secrets/db_user_password
```

signifie :

```text
Nom logique :
db_user_password

Contenu :
../secrets/db_user_password
```

Docker lit ce fichier.

Ensuite les services choisissent s'ils veulent ce secret.

Par exemple :

```yaml
wordpress:
  secrets:
    - db_user_password
```

=> accès autorisé.

---

# Vue d'ensemble

On peut représenter ton fichier ainsi :

```text
docker-compose.yml
│
├── networks
│   └── inception
│
├── volumes
│   ├── wordpress
│   └── mariadb
│
├── services
│   ├── nginx
│   │   ├── build
│   │   ├── ports
│   │   ├── volumes
│   │   └── networks
│   │
│   ├── wordpress
│   │   ├── build
│   │   ├── volumes
│   │   ├── secrets
│   │   └── networks
│   │
│   └── mariadb
│       ├── build
│       ├── volumes
│       ├── secrets
│       └── networks
│
└── secrets
    ├── db_user_password
    ├── wp_root_password
    └── wp_user_password
```

L'idée centrale est que les sections du haut (`networks`, `volumes`, `secrets`) **déclarent des ressources**, puis les sections sous `services` **consomment ces ressources** en les référençant par leur nom. C'est ce lien qui permet à Nginx, WordPress et MariaDB de partager un réseau, des données persistantes et des secrets.
