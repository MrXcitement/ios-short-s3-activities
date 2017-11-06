# dev (microservice) environment
WEB_DOCKERFILE=Dockerfile-web
WEB_IMAGE=kitura-server
WEB_CONTAINER_NAME=activities-server
WEB_CONTAINER_PORT=8080
WEB_HOST_PORT=80

# db environment
DB_DOCKERFILE=Dockerfile-db
DB_IMAGE=mysql-database
DB_CONTAINER_NAME=activities-database
DB_DATA_DIR=$(PWD)/Data
DB_SEED_DIR=$(PWD)/Seed
DB_DATABASE=game_night
DB_SEED_FILE=/Seed/$(DB_CONTAINER_NAME).sql
DB_CONTAINER_ID=$(shell docker ps -aq -f 'name=$(DB_CONTAINER_NAME)')
DB_HOST=$(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(DB_CONTAINER_ID))
DB_PORT=3306
DB_USER=root
DB_PASSWORD=password

# =============
# Build Images
# =============
images_build:
	docker build -t $(DB_IMAGE) -f $(DB_DOCKERFILE) .
	docker build -t $(WEB_IMAGE) -f $(WEB_DOCKERFILE) .

# =================
# Full Environment
# =================
env_start: db_run web_dev

env_start_clean: db_run_clean web_dev

env_start_seed: db_run_seed web_dev

# =============================
# Web (Microservice) Container
# =============================
web_dev:
	docker run --name $(WEB_CONTAINER_NAME) \
	-it --rm -v $(PWD):/src \
	-e MYSQL_HOST=$(DB_HOST) \
	-e MYSQL_PORT=$(DB_PORT) \
	-e MYSQL_USER=$(DB_USER) \
	-e MYSQL_PASSWORD=$(DB_PASSWORD) \
	-e MYSQL_DATABASE=$(DB_DATABASE) \
	-w /src \
	-p $(WEB_HOST_PORT):$(WEB_CONTAINER_PORT) $(WEB_IMAGE) /bin/bash

web_build:
	swift build -Xlinker -L/usr/local/lib

web_build_run: web_build
	./.build/debug/ActivitiesServer

web_clean:
	rm -rf .build
	rm Package.pins

# ===================
# Database Container
# ===================
db_run: db_stop
	docker run \
	-d \
	--name $(DB_CONTAINER_NAME) \
	-e MYSQL_ROOT_PASSWORD=$(DB_PASSWORD) \
	--expose $(DB_PORT) \
	-p $(DB_PORT):$(DB_PORT) \
	-v $(DB_DATA_DIR):/var/lib/mysql \
	$(DB_IMAGE) --character-set-server=utf8mb4 --collation-server=utf8mb4_bin

db_run_clean: db_stop db_clean
	docker run --name $(DB_CONTAINER_NAME) \
	-e MYSQL_DATABASE=$(DB_DATABASE) \
	-e MYSQL_ROOT_PASSWORD=$(DB_PASSWORD) \
	-v $(DB_DATA_DIR):/var/lib/mysql \
	-d --expose $(DB_PORT) $(DB_IMAGE) --character-set-server=utf8mb4 --collation-server=utf8mb4_bin

db_run_seed: db_stop db_clean
	docker run \
	-d \
	--name $(DB_CONTAINER_NAME) \
	-e MYSQL_ROOT_PASSWORD=$(DB_PASSWORD) \
	-e MYSQL_DATABASE=$(DB_DATABASE) \
	--expose $(DB_PORT) \
	-v $(DB_DATA_DIR):/var/lib/mysql \
	-v $(DB_SEED_DIR):/docker-entrypoint-initdb.d \
	$(DB_IMAGE) --character-set-server=utf8mb4 --collation-server=utf8mb4_bin

db_connect_bash:
	docker exec -it $(DB_CONTAINER_ID) /bin/bash

db_connect_shell:
	docker run --name mysql-shell -it \
	--rm mysql sh -c 'exec mysql -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASSWORD) --default-character-set=utf8mb4'

db_dump:
	docker run --name mysqldump-shell \
	-v $(DB_SEED_DIR):/Seed \
	--rm mysql sh -c 'exec mysqldump -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASSWORD) $(DB_DATABASE) --default-character-set=utf8mb4 > $(DB_SEED_FILE)'

db_stop:
	@docker stop $(DB_CONTAINER_NAME) || true && docker rm $(DB_CONTAINER_NAME) || true

db_clean:
	rm -rf $(DB_DATA_DIR)
	mkdir -p $(DB_DATA_DIR)
