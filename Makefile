# variables
SERVER_NAME=activities-server

DB_CONTAINER_NAME=activities-database
DB_DATA_DIR=$(PWD)/Data
DB_SEED_DIR=$(PWD)/Seed
DB_DATABASE=game_night
DB_USER=root
DB_PASSWORD=password
DB_HOST=172.17.0.2
DB_PORT=3306
DB_IMAGE=mysql-database

# targets
hello_s3: hello_swift hello_kitura
	@echo "what are you building?"
	@echo "a microservice?"

hello_swift:
	@echo "hello swift"

hello_kitura:
	@echo "hello kitura"

web_run_bash: web_build
	docker run --name $(SERVER_NAME) \
		-it --rm -v $(PWD):/src \
		-w /src \
		-p 80:8080 kitura-server /bin/bash

web_build:
	docker build -t kitura-server -f Dockerfile-web .

db_run_seed: db_stop db_clean
	docker run \
		-d \
		--name $(DB_CONTAINER_NAME) \
		-e MYSQL_ROOT_PASSWORD=$(DB_PASSWORD) \
		-e MYSQL_DATABASE=$(DB_DATABASE) \
		--expose $(DB_PORT) \
		-p $(DB_PORT):$(DB_PORT) \
		-v $(DB_SEED_DIR):/docker-entrypoint-initdb.d \
		-v $(DB_DATA_DIR):/var/lib/mysql \
		$(DB_IMAGE) \
		--character-set-server=utf8mb4 --collation-server=utf8mb4_bin

db_stop:
	@docker stop $(DB_CONTAINER_NAME) || true && docker rm $(DB_CONTAINER_NAME) || true

db_clean:
	rm -rf $(DB_DATA_DIR)
	mkdir -p $(DB_DATA_DIR)

db_connect_shell:
	docker run --name mysql-shell -it \
		--rm mysql sh -c 'exec mysql -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASSWORD) --default-character-set=utf8mb4'
