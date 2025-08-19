
BASE_DIR := /opt/fhir-patrick

REPOS := fhir-collector fhir-worker fhir-api

DIRS_fhir-collector := logs localstack-data valkey
DIRS_fhir-worker := logs
DIRS_fhir-api := logs mongo/data



# -----------------------------


# 2. Parar containers existentes
.PHONY: stop-containers
stop-containers:
	@for repo in $(REPOS); do \
		if [ -d "$(BASE_DIR)/$$repo" ]; then \
			(cd "$(BASE_DIR)/$$repo" && docker compose down || true); \
		fi \
	done

# 3. Criar rede docker fhir-network
.PHONY: docker-network
docker-network:
	docker network inspect fhir-network >/dev/null 2>&1 || docker network create fhir-network

# 4. Apagar diretórios se existirem
.PHONY: clean-dirs
clean-dirs:
	@for repo in $(REPOS); do \
		sudo rm -rf "$(BASE_DIR)/$$repo"; \
	done

# 5. Criar diretórios base
.PHONY: create-dirs
create-dirs:
	@for repo in $(REPOS); do \
		sudo mkdir -p "$(BASE_DIR)/$$repo"; \
		sudo chmod -R 0777 "$(BASE_DIR)/$$repo"; \
	done

# 6. Clonar repositórios
.PHONY: clone
clone:
	@git clone -b main https://github.com/barretodsp/fhir-collector.git $(BASE_DIR)/fhir-collector || (cd $(BASE_DIR)/fhir-collector && git fetch && git reset --hard origin/main)
	@git clone -b main https://github.com/barretodsp/fhir-worker.git $(BASE_DIR)/fhir-worker || (cd $(BASE_DIR)/fhir-worker && git fetch && git reset --hard origin/main)
	@git clone -b main https://github.com/barretodsp/fhir-api.git $(BASE_DIR)/fhir-api || (cd $(BASE_DIR)/fhir-api && git fetch && git reset --hard origin/main)

# 7. Garantir permissão de execução para script init-sqs.sh
.PHONY: script-permissions
script-permissions:
	chmod 0755 $(BASE_DIR)/fhir-collector/localstack/init-sqs.sh

# 8. Criar diretórios persistentes adicionais
.PHONY: persistent-dirs
persistent-dirs:
	@for dir in $(DIRS_fhir-collector); do \
		mkdir -p "$(BASE_DIR)/fhir-collector/$$dir"; \
		chmod -R 0777 "$(BASE_DIR)/fhir-collector/$$dir"; \
	done
	@for dir in $(DIRS_fhir-worker); do \
		mkdir -p "$(BASE_DIR)/fhir-worker/$$dir"; \
		chmod -R 0777 "$(BASE_DIR)/fhir-worker/$$dir"; \
	done
	@for dir in $(DIRS_fhir-api); do \
		mkdir -p "$(BASE_DIR)/fhir-api/$$dir"; \
		chmod -R 0777 "$(BASE_DIR)/fhir-api/$$dir"; \
	done

# 9. Subir containers via docker-compose
.PHONY: up
up:
	@for repo in $(REPOS); do \
		(cd "$(BASE_DIR)/$$repo" && docker compose up -d); \
	done

# -----------------------------
# Target completo (orquestra todas etapas)
.PHONY: all
all: stop-containers docker-network clean-dirs create-dirs clone script-permissions persistent-dirs up
	@echo "Setup completo!"
