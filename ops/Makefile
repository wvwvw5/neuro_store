# Makefile для управления Neuro Store

# Переменные
COMPOSE_FILE = ops/docker-compose.yml
ENV_FILE = ops/.env

# Цвета для вывода
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help up down logs restart clean build migrate seed backup restore test lint format check-env

# Помощь
help:
	@echo "$(GREEN)Neuro Store - Команды управления$(NC)"
	@echo ""
	@echo "$(YELLOW)Основные команды:$(NC)"
	@echo "  up          Запуск всех сервисов"
	@echo "  down        Остановка всех сервисов"
	@echo "  restart     Перезапуск всех сервисов"
	@echo "  logs        Просмотр логов"
	@echo "  clean       Очистка volumes и containers"
	@echo ""
	@echo "$(YELLOW)База данных:$(NC)"
	@echo "  migrate     Применение миграций"
	@echo "  seed        Загрузка тестовых данных"
	@echo "  backup      Создание бэкапа БД"
	@echo "  restore     Восстановление БД из бэкапа"
	@echo ""
	@echo "$(YELLOW)Разработка:$(NC)"
	@echo "  test        Запуск тестов"
	@echo "  lint        Проверка кода линтерами"
	@echo "  format      Форматирование кода"
	@echo "  check-env   Проверка переменных окружения"
	@echo ""
	@echo "$(YELLOW)Примеры:$(NC)"
	@echo "  make up                    # Запуск в development режиме"
	@echo "  make up ENV=production     # Запуск в production режиме"
	@echo "  make logs SERVICE=backend  # Логи конкретного сервиса"
	@echo "  make users                 # Показать всех пользователей"
	@echo "  make admin                 # Создать админа"

# Проверка переменных окружения
check-env:
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(RED)Файл .env не найден. Скопируйте ops/.env.example в ops/.env$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✅ Файл .env найден$(NC)"

# Запуск сервисов
up: check-env
	@echo "$(GREEN)🚀 Запуск Neuro Store...$(NC)"
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up --build -d
	@echo "$(GREEN)✅ Сервисы запущены!$(NC)"
	@echo ""
	@echo "$(YELLOW)📱 Доступные сервисы:$(NC)"
	@echo "  Frontend:    http://localhost:3000"
	@echo "  Backend API: http://localhost:8000"
	@echo "  Swagger UI:  http://localhost:8000/docs"
	@echo "  pgAdmin:     http://localhost:5050"
	@echo "  Redis UI:    http://localhost:8081 (если включен)"

# Остановка сервисов
down:
	@echo "$(YELLOW)🛑 Остановка сервисов...$(NC)"
	docker compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✅ Сервисы остановлены$(NC)"

# Остановка с удалением volumes
down-volumes:
	@echo "$(RED)🗑️ Остановка с удалением данных...$(NC)"
	docker compose -f $(COMPOSE_FILE) down -v
	@echo "$(GREEN)✅ Сервисы остановлены, данные удалены$(NC)"

# Перезапуск сервисов
restart:
	@echo "$(YELLOW)🔄 Перезапуск сервисов...$(NC)"
	docker compose -f $(COMPOSE_FILE) restart
	@echo "$(GREEN)✅ Сервисы перезапущены$(NC)"

# Перезапуск конкретного сервиса
restart-service:
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)Укажите SERVICE. Пример: make restart-service SERVICE=backend$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)🔄 Перезапуск $(SERVICE)...$(NC)"
	docker compose -f $(COMPOSE_FILE) restart $(SERVICE)
	@echo "$(GREEN)✅ $(SERVICE) перезапущен$(NC)"

# Просмотр логов
logs:
	@if [ -n "$(SERVICE)" ]; then \
		echo "$(YELLOW)📋 Логи сервиса $(SERVICE):$(NC)"; \
		docker compose -f $(COMPOSE_FILE) logs -f $(SERVICE); \
	else \
		echo "$(YELLOW)📋 Логи всех сервисов:$(NC)"; \
		docker compose -f $(COMPOSE_FILE) logs -f; \
	fi

# Сборка образов
build:
	@echo "$(YELLOW)🔨 Сборка образов...$(NC)"
	docker compose -f $(COMPOSE_FILE) build
	@echo "$(GREEN)✅ Образы собраны$(NC)"

# Очистка
clean:
	@echo "$(RED)🧹 Очистка контейнеров и образов...$(NC)"
	docker compose -f $(COMPOSE_FILE) down -v --rmi all --remove-orphans
	docker system prune -f
	@echo "$(GREEN)✅ Очистка завершена$(NC)"

# Миграции БД
migrate:
	@echo "$(YELLOW)🗄️ Применение миграций...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec backend alembic upgrade head
	@echo "$(GREEN)✅ Миграции применены$(NC)"

# Создание миграции
migration:
	@if [ -z "$(MESSAGE)" ]; then \
		echo "$(RED)Укажите MESSAGE. Пример: make migration MESSAGE='add user table'$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)📝 Создание миграции: $(MESSAGE)$(NC)"
	docker compose -f $(COMPOSE_FILE) exec backend alembic revision --autogenerate -m "$(MESSAGE)"
	@echo "$(GREEN)✅ Миграция создана$(NC)"

# Загрузка тестовых данных
seed:
	@echo "$(YELLOW)🌱 Загрузка тестовых данных...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec db psql -U $${POSTGRES_USER:-postgres} -d $${POSTGRES_DB:-neuro_store} -f /docker-entrypoint-initdb.d/02_init_data.sql
	@echo "$(GREEN)✅ Тестовые данные загружены$(NC)"

# Бэкап БД
backup:
	@echo "$(YELLOW)💾 Создание бэкапа БД...$(NC)"
	@mkdir -p db/backup
	docker compose -f $(COMPOSE_FILE) exec db pg_dump -U $${POSTGRES_USER:-postgres} -d $${POSTGRES_DB:-neuro_store} > db/backup/backup_`date +%Y%m%d_%H%M%S`.sql
	@echo "$(GREEN)✅ Бэкап создан в db/backup/$(NC)"

# Восстановление БД
restore:
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Укажите FILE. Пример: make restore FILE=db/backup/backup_20240101.sql$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)♻️ Восстановление БД из $(FILE)...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec -T db psql -U $${POSTGRES_USER:-postgres} -d $${POSTGRES_DB:-neuro_store} < $(FILE)
	@echo "$(GREEN)✅ БД восстановлена$(NC)"

# Запуск тестов
test:
	@echo "$(YELLOW)🧪 Запуск тестов...$(NC)"
	pytest -v --cov=app --cov-report=term-missing
	@echo "$(GREEN)✅ Тесты завершены$(NC)"

# Запуск тестов в Docker
test-docker:
	@echo "$(YELLOW)🧪 Запуск тестов в Docker...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec backend pytest -v
	@echo "$(GREEN)✅ Тесты в Docker завершены$(NC)"

# Линтинг кода
lint:
	@echo "$(YELLOW)🔍 Проверка кода линтерами...$(NC)"
	ruff check app/ tests/
	black --check app/ tests/
	isort --check-only app/ tests/
	mypy app/
	@echo "$(GREEN)✅ Линтинг завершен$(NC)"

# Форматирование кода
format:
	@echo "$(YELLOW)✨ Форматирование кода...$(NC)"
	black app/ tests/
	isort app/ tests/
	ruff --fix app/ tests/
	@echo "$(GREEN)✅ Код отформатирован$(NC)"

# Статус сервисов
status:
	@echo "$(YELLOW)📊 Статус сервисов:$(NC)"
	docker compose -f $(COMPOSE_FILE) ps

# Мониторинг ресурсов
stats:
	@echo "$(YELLOW)📈 Статистика использования ресурсов:$(NC)"
	docker stats --no-stream

# Подключение к БД
db-shell:
	@echo "$(YELLOW)🗄️ Подключение к PostgreSQL...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec db psql -U $${POSTGRES_USER:-postgres} -d $${POSTGRES_DB:-neuro_store}

# Подключение к Redis
redis-shell:
	@echo "$(YELLOW)📦 Подключение к Redis...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec redis redis-cli

# Подключение к backend контейнеру
backend-shell:
	@echo "$(YELLOW)🐍 Подключение к backend...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec backend bash

# Подключение к frontend контейнеру
frontend-shell:
	@echo "$(YELLOW)⚛️ Подключение к frontend...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec frontend sh

# Проверка здоровья сервисов
health:
	@echo "$(YELLOW)🏥 Проверка здоровья сервисов...$(NC)"
	@curl -s http://localhost:8000/health | jq . || echo "Backend недоступен"
	@curl -s http://localhost:3000 > /dev/null && echo "Frontend: ✅ OK" || echo "Frontend: ❌ Недоступен"

# Production команды
prod-up:
	@echo "$(GREEN)🚀 Запуск в PRODUCTION режиме...$(NC)"
	docker compose -f $(COMPOSE_FILE) --profile production up --build -d
	@echo "$(GREEN)✅ Production сервисы запущены$(NC)"

prod-down:
	@echo "$(YELLOW)🛑 Остановка production сервисов...$(NC)"
	docker compose -f $(COMPOSE_FILE) --profile production down
	@echo "$(GREEN)✅ Production сервисы остановлены$(NC)"

# Инструменты разработчика
tools-up:
	@echo "$(YELLOW)🛠️ Запуск инструментов разработчика...$(NC)"
	docker compose -f $(COMPOSE_FILE) --profile tools up -d
	@echo "$(GREEN)✅ Инструменты запущены$(NC)"
	@echo "  Redis Commander: http://localhost:8081"

tools-down:
	@echo "$(YELLOW)🛠️ Остановка инструментов...$(NC)"
	docker compose -f $(COMPOSE_FILE) --profile tools down
	@echo "$(GREEN)✅ Инструменты остановлены$(NC)"

# Показать всех пользователей
users:
	@echo "$(YELLOW)👥 Пользователи в системе:$(NC)"
	docker compose -f $(COMPOSE_FILE) exec db psql -U postgres -d neuro_store -c "SELECT id, email, first_name, last_name, is_active, created_at FROM users ORDER BY id;"

# Создать админа
admin:
	@echo "$(YELLOW)🛡️ Создание администратора...$(NC)"
	@read -p "Email: " email; \
	read -s -p "Пароль: " password; \
	echo; \
	read -p "Имя: " first_name; \
	read -p "Фамилия: " last_name; \
	echo "$(GREEN)Создание пользователя...$(NC)"; \
	curl -s -X POST http://localhost:8000/api/v1/auth/register -H "Content-Type: application/json" -d "{\"email\":\"$$email\",\"password\":\"$$password\",\"first_name\":\"$$first_name\",\"last_name\":\"$$last_name\"}" | python3 -m json.tool; \
	echo "$(GREEN)✅ Пользователь создан!$(NC)"
