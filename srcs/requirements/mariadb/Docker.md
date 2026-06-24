Ce Dockerfile sert à **construire l image du conteneur MariaDB**. 


| Ligne                            | Rôle                         |
| -------------------------------- | ---------------------------- |
| `FROM debian:bullseye`           | image de base                |
| `RUN apt-get update`             | met à jour les paquets       |
| `apt-get upgrade -y`             | met à jour le système        |
| `apt-get install mariadb-server` | installe MariaDB             |
| `rm -rf /var/lib/apt/lists/*`    | réduit la taille de l image  |
| `mkdir -p /run/mysqld`           | crée le dossier runtime      |
| `chown mysql:mysql`              | donne les droits à MariaDB   |
| `COPY 50-server.cnf`             | copie la configuration       |
| `COPY init_mariadb.sh`           | copie le script              |
| `chmod +x`                       | rend le script exécutable    |
| `ENTRYPOINT`                     | lance le script au démarrage |
