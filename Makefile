#__INCEPTION_MAKEFILE__#

#colors
RED = \033[0;31m
GREEN = \033[0;32m
BLUE = \033[0;34m
RESET = \033[0m

#defines
PROJECT = inception
SRC_DIR = srcs
DOC_COMPOSE = $(SRC_DIR)/docker-compose.yml

#modifications
.PHONY: all build up db wp nx down clean fclean re secrets
.SILENT:

#commands
all: build up

build:
	echo "$(BLUE)building $(PROJECT)...$(RESET)"
	docker compose -f $(DOC_COMPOSE) build --no-cache && \
	echo "$(GREEN) $(PROJECT) succesfully built!$(RESET)" || \
	echo "$(RED) $(PROJECT) failed the building process!$(RESET)"

clean: down
	echo "$(BLUE)removing everything...$(RESET)"
	docker system prune -af
	docker volume prune -f
	docker network prune -f

fclean:
	echo "Stopping containers..."
	docker compose -f srcs/docker-compose.yml down -v --remove-orphans

	echo "Removing bind mount directories..."
	sudo rm -rf /home/$(USER)/data/mariadb
	sudo rm -rf /home/$(USER)/data/wordpress

	echo "Removing secrets..."
	sudo rm -rf ./secrets

	echo "Removing .env ..."
	sudo rm -rf ./srcs/.env

	echo "Full clean completed."

re: clean build up

secrets:
	mkdir -p ./secrets
	touch secrets/db_user_password
	touch secrets/wp_user_password
	touch secrets/wp_root_password
	touch srcs/.env
	mkdir -p /home/$(USER)/data/mariadb
	mkdir -p /home/$(USER)/data/wordpress

# for single testing
up:
	echo "$(BLUE)starting $(PROJECT)...$(RESET)"
	docker compose -f $(DOC_COMPOSE) up -d

db:
	echo "$(BLUE)starting mariadb...$(RESET)"
	docker compose -f $(DOC_COMPOSE) up -d mariadb

wp:
	echo "$(BLUE)starting wordpress...$(RESET)"
	docker compose -f $(DOC_COMPOSE) up -d wordpress

nx:
	echo "$(BLUE)starting nginx...$(RESET)"
	docker compose -f $(DOC_COMPOSE) up -d nginx

down:
	echo "$(BLUE)stopping $(PROJECT)...$(RESET)"
	docker compose -f $(DOC_COMPOSE) down