.PHONY: help up down restart logs \
	postgres-up postgres-down pgadmin-up pgadmin-down data-loader-up data-loader-down dbt-up dbt-down \
	postgres-logs pgadmin-logs data-loader-logs dbt-logs \
	load load-small dbt-run dbt-test dbt-docs dbt-freshness psql clean pipeline

# ═══════════════════════════════════════════════
# ShopFlow BI Platform — Makefile
# ═══════════════════════════════════════════════

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ──────────── Core ────────────

up: ## Start core services (PG + pgAdmin + dbt)
	docker compose up -d

down: ## Stop all services
	docker compose down

restart: down up ## Restart

logs: ## Show logs
	docker compose logs -f

postgres-up: ## Start PostgreSQL and pgAdmin together
	docker compose up -d postgres pgadmin

postgres-down: ## Stop PostgreSQL and pgAdmin together
	docker compose stop postgres pgadmin

pgadmin-up: postgres-up ## Alias: start PostgreSQL and pgAdmin together

pgadmin-down: postgres-down ## Alias: stop PostgreSQL and pgAdmin together

data-loader-up: ## Build and run only data-loader
	docker compose up --build data-loader

data-loader-down: ## Remove stopped data-loader container
	docker compose rm -sf data-loader

dbt-up: ## Start only dbt container
	docker compose up -d dbt

dbt-down: ## Stop only dbt container
	docker compose stop dbt

postgres-logs: ## Show PostgreSQL logs
	docker compose logs -f postgres

pgadmin-logs: ## Show pgAdmin logs
	docker compose logs -f pgadmin

data-loader-logs: ## Show data-loader logs
	docker compose logs -f data-loader

dbt-logs: ## Show dbt logs
	docker compose logs -f dbt

# ──────────── Data ────────────

load: ## Generate and load data
	docker compose run --rm data-loader python -m src.main

load-small: ## Load small amount of data (for testing)
	docker compose run --rm \
		-e NUM_USERS=1000 \
		-e NUM_PRODUCTS=100 \
		-e NUM_CAMPAIGNS=5 \
		-e EVENTS_PER_DAY=5000 \
		data-loader python -m src.main

# ──────────── dbt ────────────

dbt-run: ## Run dbt

	docker compose exec dbt dbt run --profiles-dir .

dbt-test: ## Run dbt test
	docker compose exec dbt dbt test --profiles-dir .

dbt-docs: ## Generate dbt docs
	docker compose exec dbt dbt docs generate --profiles-dir .
	docker compose exec dbt dbt docs serve --profiles-dir . --host 0.0.0.0 --port 8081

dbt-freshness: ## Check data freshness
	docker compose exec dbt dbt source freshness --profiles-dir .

# ──────────── Utils ────────────

psql: ## Connect to PostgreSQL
	docker compose exec postgres psql -U shopflow_user -d shopflow

clean: ## Remove all data and volumes
	docker compose down -v
	docker compose -f docker-compose.airflow.yml down -v 2>/dev/null || true
	docker compose -f docker-compose.metabase.yml down -v 2>/dev/null || true

# ──────────── Full Pipeline ────────────

pipeline: up load dbt-run dbt-test ## Full run: up → load → dbt run → dbt test
	@echo "Pipeline complete! Connect Power BI to localhost:5432"