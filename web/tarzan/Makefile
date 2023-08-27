# Makefile

# Define common variables
DJANGO_MANAGE = python manage.py
DOCKER_COMPOSE = docker-compose

# Define synchronization tasks
up:
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

migrate:
	$(DJANGO_MANAGE) migrate

createsuperuser:
	$(DJANGO_MANAGE) createsuperuser