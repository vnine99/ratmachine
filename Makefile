SRC_DIR := src
SRC_FILES := $(shell find src/ -type f -regex ".*\.cr")

.PHONY: dev config
dev:
	docker-compose up

config:
	amber encrypt production

bin/ratmachine: $(SRC_FILES)
	npm run-script build
	shards build ratmachine --release

build: bin/ratmachine
	@echo "Built ratmachine to bin/ratmachine"

deploy: build
	ssh -i ~/.ssh/ratwires -p 460 root@ratwires.space "systemctl stop ratmachine"
	rsync -rtvp -e 'ssh -p 460' --progress . root@ratwires.space:/var/www/ratwires.space
	ssh -i ~/.ssh/ratwires -p 460 root@ratwires.space "systemctl start ratmachine"
