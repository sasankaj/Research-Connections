include .env

default: up

COMPOSER_ROOT ?= /var/www/html
DRUPAL_ROOT ?= /var/www/html/web

green=\033[0;32m
green_bg=\033[42m
red=\033[0;31m
red_bg=\033[0;31m
yellow=\033[1;33m
NC=\033[0m

today=`date +%Y-%m-%d.%H:%M:%S`

.PHONY: echo-red
echo-red:
	echo -e "${red}$1${NC}";

.PHONY: echo-green
echo-green:
	echo -e "${green}$1${NC}";

.PHONY: echo-green-bg
echo-green-bg:
	echo -e "${green_bg}$1${NC}";

.PHONY: echo-red-bg
echo-red-bg:
	echo -e "${red_bg}$1${NC}";

.PHONY: echo-yellow
echo-yellow:
	echo -e "${yellow}$1${NC}";


## help	:	Print commands help.
.PHONY: help
ifneq (,$(wildcard docker.mk))
help : docker.mk
	@sed -n 's/^##//p' $<
else
help : Makefile
	@sed -n 's/^##//p' $<
endif

## up	:	Start up containers.
.PHONY: up
up:
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker-compose pull
	docker-compose up -d --remove-orphans
#	@echo ""
#	@echo ""
#	@echo "Your app has started up correctly. Please allow a few moments for us to sync your host into the container"
#	docker-compose -f ~/Projects/traefik.yml up -d
	@echo ""
	@echo ""
	@echo "${green} Your app is now available at: http://$(PROJECT_BASE_URL):8080 ${NC}"



.PHONY: mutagen
mutagen:
	docker-compose up -d mutagen
	mutagen project start -f mutagen/config.yml

## down	:	Stop containers.
.PHONY: down
down: stop

## start	:	Start containers without updating.
.PHONY: start
start:
	@echo "Starting containers for $(PROJECT_NAME) from where you left off..."
	@docker-compose start
	@echo ""
	@echo ""
	@echo "Your app is now available at: http://$(PROJECT_BASE_URL)"

## stop	:	Stop containers.
.PHONY: stop
stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose stop

## prune	:	Remove containers and their volumes.
##		You can optionally pass an argument with the service name to prune single container
##		prune mariadb	: Prune `mariadb` container and remove its volumes.
##		prune mariadb solr	: Prune `mariadb` and `solr` containers and remove their volumes.
.PHONY: prune
prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose down -v $(filter-out $@,$(MAKECMDGOALS))

## ps	:	List running containers.
.PHONY: ps
ps:
	@docker ps --filter name='$(PROJECT_NAME)*'

## shell	:	Access `php` container via shell.
##		You can optionally pass an argument with a service name to open a shell on the specified container
.PHONY: shell
shell:
	docker exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_$(or $(filter-out $@,$(MAKECMDGOALS)), 'php')' --format "{{ .ID }}") sh

## composer	:	Executes `composer` command in a specified `COMPOSER_ROOT` directory (default is `/var/www/html`).
##		To use "--flag" arguments include them in quotation marks.
##		For example: make composer "update drupal/core --with-dependencies"
.PHONY: composer
composer:
	docker exec $(shell docker ps --filter name='^/$(PROJECT_NAME)_php' --format "{{ .ID }}") composer --working-dir=$(COMPOSER_ROOT) $(filter-out $@,$(MAKECMDGOALS))

## drush	:	Executes `drush` command in a specified `DRUPAL_ROOT` directory (default is `/var/www/html/web`).
##		To use "--flag" arguments include them in quotation marks.
##		For example: make drush "watchdog:show --type=cron"
.PHONY: drush
drush:
	docker exec $(shell docker ps --filter name='^/$(PROJECT_NAME)_php' --format "{{ .ID }}") drush -r $(DRUPAL_ROOT) $(filter-out $@,$(MAKECMDGOALS))

## logs	:	View containers logs.
##		You can optinally pass an argument with the service name to limit logs
##		logs php	: View `php` container logs.
##		logs nginx php	: View `nginx` and `php` containers logs.
.PHONY: logs
logs:
	@docker-compose logs -f $(filter-out $@,$(MAKECMDGOALS))

# https://stackoverflow.com/a/6273809/1826109
%:
	@:

## db_export :	Export your current database to the mariadb-init directory.
db_export:
	docker-compose exec mariadb sh -c 'exec mysqldump -uroot -p"password" drupal9_rc' > ./mariadb-init/rc9_db_backup.sql

## db_import :	Import the new database from the mariadb-init directory.
db_import:
	docker-compose exec mariadb sh -c 'exec mysql -u root -p"password" drupal9_rc < /docker-entrypoint-initdb.d/rc9_db_backup.sql'

build:
	@echo "${green_bg} Step 1${NC}${green} Starting Containers ${NC}"
	@echo ""
	docker-compose pull
	docker-compose up -d --remove-orphans
#	docker-compose -f ~/Projects/traefik.yml up -d
	@echo "${green_bg} Step 2${NC}${green} Install Composer dependencies ${NC}"
	@echo ""
	make composer install
	@echo ""
	@echo ""
	@echo "${green_bg} Step 3${NC}${green} Import Latest Database ${NC}"
	@echo ""
	make db_import
	@echo ""
	@echo ""
	@echo "${green_bg} Step 4${NC}${green} Clear Site Cache ${NC}"
	@echo ""
	make drush cr
	@echo ""
	@echo ""
	@echo "${green} Your app is now available at: http://$(PROJECT_BASE_URL):8080 ${NC}"


rebuild:
	@echo "${green_bg} Step 1${NC}${green} Remove existing containers ${NC}"
	@echo ""
	make prune
	@echo ""
	@echo ""
	@echo "${green_bg} Step 2${NC}${green} Pull Latest changes from git ${NC}"
	@echo ""
	git pull
	@echo ""
	@echo ""
	@echo "${green_bg} Step 3${NC}${green} Checking hosts file ${NC}"
	@echo ""
	sh ./manage_hosts.sh addhost $(PROJECT_BASE_URL)
	@echo ""
	@echo ""
	@echo "${green_bg} Step 4${NC}${green} Starting Containers ${NC}"
	@echo ""
	make up
	@echo ""
	@echo ""
	@echo "${green_bg} Step 5${NC}${green} Install Composer dependencies ${NC}"
	@echo ""
	make composer install
	@echo ""
	@echo ""
	@echo "${green_bg} Step 6${NC}${green} Import Latest Database ${NC}"
	@echo ""
	docker-compose exec mariadb sh -c 'exec mysql -u root -p"password" drupal9_rc < /docker-entrypoint-initdb.d/rc9-db-backup.sql'
	@echo ""
	@echo ""
	@echo "${green_bg} Step 7${NC}${green} Import Configuration files ${NC}"
	@echo ""
	@echo "Skipping config import.."
	@echo ""
	@echo "${green_bg} Step 8${NC}${green} Clear Site Cache ${NC}"
	@echo ""
	make drush cr
	@echo ""
