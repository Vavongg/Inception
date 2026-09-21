NAME = inception

DOCKER_COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = /home/ainthana/data

all: up

up:
	@mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
	docker compose -f $(DOCKER_COMPOSE_FILE) up -d --build

down:
	docker compose -f $(DOCKER_COMPOSE_FILE) down

clean:
	docker compose -f $(DOCKER_COMPOSE_FILE) down --rmi all --volumes

fclean: clean
	@docker system prune -a --volumes -f
	@sudo rm -rf $(DATA_PATH)
	@echo "Nettoyage complet effectué."

re: fclean all

.PHONY: all up down clean fclean re