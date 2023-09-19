.PHONY: check-env
check-env:
ifndef DOMAIN_NAME
	$(warning env DOMAIN_NAME is undefined)
endif
ifndef CHAIN_ID
	$(error env CHAIN_ID is undefined)
endif
ifndef HOST_IP
	$(error env HOST_IP is undefined)
endif

.PHONY: install-docker
install-docker:
	bash ./scripts/install-docker.bash

.PHONY: install-acme
install-acme:
	curl https://get.acme.sh | sh -s email=admin@bitcoincode.technology || true
	bash ./scripts/issue-cert.bash

.PHONY: create-genesis
create-genesis: check-env
	bash ./scripts/create-genesis.bash

.PHONY: start-bootnode
start-bootnode: check-env
	cat ./docker-compose.yaml | envsubst | docker-compose -f - pull
	cat ./docker-compose.yaml | envsubst | docker-compose -f - up -d bootnode

.PHONY: start
start: check-env
	cat ./docker-compose.yaml | envsubst | docker-compose -f - pull
	cat ./docker-compose.yaml | envsubst | docker-compose -f - up -d

.PHONY: stop
stop:
	docker compose stop

.PHONE: delete-state
delete-state:
	rm -rf ./datadir genesis.json

.PHONE: reset
reset: stop delete-state create-genesis start

.PHONY: all
all: create-genesis start