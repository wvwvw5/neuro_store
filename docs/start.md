# Инструкция по запуску и эксплуатации Neuro Store

## Навигация
- [Быстрый старт](#быстрый-старт)
- [Требования к окружению](#требования-к-окружению)
- [Локальный запуск](#локальный-запуск)
- [Docker запуск](#docker-запуск)
- [Миграции базы данных](#миграции-базы-данных)
- [Резервное копирование](#резервное-копирование)
- [Мониторинг и логи](#мониторинг-и-логи)
- [FAQ и устранение неполадок](#faq-и-устранение-неполадок)

## Быстрый старт

### 1. Клонирование репозитория

```bash
git clone https://github.com/wvwvw5/neuro_store.git
cd neuro_store
```

### 2. Запуск через Docker Compose

```bash
# Поднятие всех сервисов
docker-compose up -d

# Проверка статуса
docker-compose ps

# Просмотр логов
docker-compose logs -f
```

### 3. Доступные сервисы

| Сервис | URL | Описание |
|--------|-----|----------|
| Backend API | http://localhost:8000 | FastAPI приложение |
| Swagger UI | http://localhost:8000/docs | API документация |
| ReDoc | http://localhost:8000/redoc | Альтернативная документация |
| Frontend | http://localhost:3000 | Next.js клиент |
| pgAdmin | http://localhost:5050 | Управление базой данных |
| Redis Commander | http://localhost:8081 | Управление Redis |

### 4. Применение миграций

```bash
# Автоматическое применение миграций при запуске
docker-compose exec backend alembic upgrade head

# Проверка статуса миграций
docker-compose exec backend alembic current
```

### 5. Создание первого пользователя

```bash
# Создание администратора
docker-compose exec backend python -m app.scripts.create_admin

# Или через API
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@neurostore.com",
    "username": "admin",
    "password": "admin123",
    "full_name": "Администратор"
  }'
```

## Требования к окружению

### Системные требования

- **ОС:** Linux (Ubuntu 20.04+), macOS 12+, Windows 10+ (WSL2)
- **RAM:** Минимум 4 GB, рекомендуется 8 GB
- **Диск:** Минимум 10 GB свободного места
- **CPU:** 2+ ядра

### Программное обеспечение

| Компонент | Версия | Примечание |
|------------|--------|------------|
| **Python** | 3.11+ | Основной язык backend |
| **Node.js** | 20+ | Для frontend и инструментов |
| **PostgreSQL** | 14+ | Основная база данных |
| **Redis** | 7+ | Кэширование и сессии |
| **Docker** | 20.10+ | Контейнеризация |
| **Docker Compose** | 2.0+ | Оркестрация сервисов |

### Проверка установки

```bash
# Python
python3 --version  # Должно быть 3.11+

# Node.js
node --version     # Должно быть 20+

# Docker
docker --version   # Должно быть 20.10+

# Docker Compose
docker-compose --version  # Должно быть 2.0+

# PostgreSQL
psql --version     # Должно быть 14+

# Redis
redis-server --version  # Должно быть 7+
```

## Локальный запуск

### 1. Настройка виртуального окружения

```bash
# Создание виртуального окружения
python3 -m venv venv

# Активация (Linux/macOS)
source venv/bin/activate

# Активация (Windows)
venv\Scripts\activate

# Установка зависимостей
pip install -r requirements.txt
```

### 2. Настройка переменных окружения

```bash
# Копирование примера конфигурации
cp .env.example .env

# Редактирование конфигурации
nano .env
```

**Основные переменные (.env):**
```bash
# База данных
DATABASE_URL=postgresql://user:password@localhost:5432/neuro_store
TEST_DATABASE_URL=sqlite:///./test.db

# Redis
REDIS_URL=redis://localhost:6379

# JWT
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Приложение
PROJECT_NAME=Neuro Store
VERSION=1.0.0
DEBUG=true
```

### 3. Запуск PostgreSQL

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# macOS
brew install postgresql
brew services start postgresql

# Создание базы данных
sudo -u postgres createdb neuro_store
sudo -u postgres createuser neuro_user
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE neuro_store TO neuro_user;"
```

### 4. Запуск Redis

```bash
# Ubuntu/Debian
sudo apt install redis-server
sudo systemctl start redis-server

# macOS
brew install redis
brew services start redis

# Проверка
redis-cli ping  # Должен ответить PONG
```

### 5. Запуск backend

```bash
# Применение миграций
alembic upgrade head

# Запуск приложения
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 6. Запуск frontend

```bash
# Переход в папку клиента
cd client

# Установка зависимостей
npm install

# Запуск в режиме разработки
npm run dev
```

## Docker запуск

### 1. Конфигурация Docker Compose

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: neuro_store
      POSTGRES_USER: neuro_user
      POSTGRES_PASSWORD: neuro_pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./db/init:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U neuro_user -d neuro_store"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build: .
    environment:
      - DATABASE_URL=postgresql://neuro_user:neuro_pass@postgres:5432/neuro_store
      - REDIS_URL=redis://redis:6379
    ports:
      - "8000:8000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./app:/app/app
      - ./logs:/app/logs

  frontend:
    build: ./client
    ports:
      - "3000:3000"
    volumes:
      - ./client:/app
      - /app/node_modules
    environment:
      - NEXT_PUBLIC_API_BASE=http://localhost:8000

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@neurostore.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    depends_on:
      - postgres

volumes:
  postgres_data:
  redis_data:
```

### 2. Команды управления

```bash
# Запуск всех сервисов
docker-compose up -d

# Остановка всех сервисов
docker-compose down

# Перезапуск конкретного сервиса
docker-compose restart backend

# Просмотр логов
docker-compose logs -f backend

# Просмотр статуса
docker-compose ps

# Очистка данных (осторожно!)
docker-compose down -v
```

### 3. Сборка образов

```bash
# Сборка всех образов
docker-compose build

# Сборка конкретного сервиса
docker-compose build backend

# Принудительная пересборка
docker-compose build --no-cache
```

## Миграции базы данных

### 1. Создание миграции

```bash
# Создание новой миграции
alembic revision --autogenerate -m "Add new table"

# Создание пустой миграции
alembic revision -m "Custom migration"
```

### 2. Применение миграций

```bash
# Применение всех миграций
alembic upgrade head

# Применение до конкретной версии
alembic upgrade 001

# Откат на одну версию назад
alembic downgrade -1

# Откат до конкретной версии
alembic downgrade 001
```

### 3. Проверка статуса

```bash
# Текущая версия
alembic current

# История миграций
alembic history

# Просмотр SQL для миграции
alembic upgrade head --sql
```

### 4. Автоматические миграции

```bash
# В Docker Compose
docker-compose exec backend alembic upgrade head

# В CI/CD пайплайне
- name: Run migrations
  run: |
    alembic upgrade head
```

## Резервное копирование

### 1. Автоматическое резервное копирование

**Скрипт backup.sh:**
```bash
#!/bin/bash

# Настройки
BACKUP_DIR="/backups"
DB_NAME="neuro_store"
DB_USER="neuro_user"
DB_HOST="localhost"
DATE=$(date +%Y%m%d_%H%M%S)

# Создание директории для бэкапов
mkdir -p $BACKUP_DIR

# Резервное копирование PostgreSQL
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > $BACKUP_DIR/db_backup_$DATE.sql

# Сжатие бэкапа
gzip $BACKUP_DIR/db_backup_$DATE.sql

# Удаление старых бэкапов (старше 30 дней)
find $BACKUP_DIR -name "db_backup_*.sql.gz" -mtime +30 -delete

echo "Backup completed: db_backup_$DATE.sql.gz"
```

### 2. Восстановление из бэкапа

```bash
# Распаковка бэкапа
gunzip db_backup_20240115_120000.sql.gz

# Восстановление
psql -h localhost -U neuro_user -d neuro_store < db_backup_20240115_120000.sql

# Или через Docker
docker-compose exec -T postgres psql -U neuro_user -d neuro_store < db_backup_20240115_120000.sql
```

### 3. Настройка cron для автоматических бэкапов

```bash
# Редактирование crontab
crontab -e

# Добавление задачи (бэкап каждый день в 2:00)
0 2 * * * /path/to/neuro_store/ops/backup/backup.sh >> /var/log/backup.log 2>&1
```

### 4. Бэкап через Docker

```bash
# Создание бэкапа
docker-compose exec postgres pg_dump -U neuro_user neuro_store > backup.sql

# Восстановление
docker-compose exec -T postgres psql -U neuro_user neuro_store < backup.sql
```

## Мониторинг и логи

### 1. Логи приложения

```bash
# Просмотр логов backend
docker-compose logs -f backend

# Просмотр логов конкретного сервиса
docker-compose logs -f postgres

# Поиск по логам
docker-compose logs backend | grep ERROR
```

### 2. Логи базы данных

```bash
# Подключение к PostgreSQL
docker-compose exec postgres psql -U neuro_user -d neuro_store

# Включение логирования
ALTER SYSTEM SET log_statement = 'all';
ALTER SYSTEM SET log_min_duration_statement = 1000;
SELECT pg_reload_conf();

# Просмотр логов
docker-compose exec postgres tail -f /var/log/postgresql/postgresql-15-main.log
```

### 3. Мониторинг производительности

```bash
# Проверка использования ресурсов
docker stats

# Проверка дискового пространства
docker system df

# Очистка неиспользуемых ресурсов
docker system prune -a
```

### 4. Health checks

```bash
# Проверка здоровья API
curl http://localhost:8000/health

# Проверка подключения к БД
docker-compose exec postgres pg_isready -U neuro_user

# Проверка Redis
docker-compose exec redis redis-cli ping
```

## FAQ и устранение неполадок

### Частые проблемы

#### 1. Порт уже занят

```bash
# Поиск процесса, использующего порт
sudo lsof -i :8000

# Завершение процесса
sudo kill -9 <PID>

# Или изменение порта в docker-compose.yml
ports:
  - "8001:8000"  # Внешний порт 8001
```

#### 2. Проблемы с подключением к БД

```bash
# Проверка статуса PostgreSQL
sudo systemctl status postgresql

# Проверка подключения
psql -h localhost -U neuro_user -d neuro_store

# Проверка логов
sudo tail -f /var/log/postgresql/postgresql-15-main.log
```

#### 3. Проблемы с Redis

```bash
# Проверка статуса Redis
sudo systemctl status redis-server

# Проверка подключения
redis-cli ping

# Очистка кэша
redis-cli FLUSHALL
```

#### 4. Проблемы с Docker

```bash
# Перезапуск Docker
sudo systemctl restart docker

# Очистка Docker
docker system prune -a

# Проверка дискового пространства
df -h
```

### Отладка

#### 1. Включение debug режима

```bash
# В .env файле
DEBUG=true
LOG_LEVEL=DEBUG

# В Docker Compose
environment:
  - DEBUG=true
  - LOG_LEVEL=DEBUG
```

#### 2. Просмотр переменных окружения

```bash
# В контейнере
docker-compose exec backend env

# Проверка конфигурации
docker-compose exec backend python -c "from app.core.config import settings; print(settings.dict())"
```

#### 3. Тестирование подключений

```bash
# Тест подключения к БД
docker-compose exec backend python -c "
from app.db.session import engine
from sqlalchemy import text
with engine.connect() as conn:
    result = conn.execute(text('SELECT 1'))
    print('Database connection OK')
"

# Тест подключения к Redis
docker-compose exec backend python -c "
import redis
r = redis.Redis.from_url('redis://redis:6379')
print('Redis connection OK:', r.ping())
"
```

### Производительность

#### 1. Оптимизация PostgreSQL

```sql
-- Проверка медленных запросов
SELECT query, mean_time, calls, total_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- Анализ индексов
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

#### 2. Оптимизация Redis

```bash
# Проверка использования памяти
docker-compose exec redis redis-cli info memory

# Мониторинг команд
docker-compose exec redis redis-cli monitor
```

#### 3. Мониторинг ресурсов

```bash
# Использование CPU и памяти
htop

# Дисковые операции
iotop

# Сетевая активность
iftop
```

### Безопасность

#### 1. Обновление зависимостей

```bash
# Проверка уязвимостей
pip-audit

# Обновление зависимостей
pip install --upgrade -r requirements.txt

# Проверка безопасности Docker образов
docker scout cves postgres:15
```

#### 2. Настройка файрвола

```bash
# Ubuntu/Debian
sudo ufw allow 8000/tcp  # Backend API
sudo ufw allow 3000/tcp  # Frontend
sudo ufw allow 5432/tcp  # PostgreSQL (только локально)
sudo ufw enable
```

#### 3. SSL/TLS настройка

```bash
# Генерация самоподписанного сертификата
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

# Настройка в FastAPI
uvicorn app.main:app --ssl-keyfile=key.pem --ssl-certfile=cert.pem
```

## Полезные команды

### Управление сервисами

```bash
# Запуск в фоновом режиме
docker-compose up -d

# Остановка
docker-compose down

# Перезапуск
docker-compose restart

# Просмотр логов
docker-compose logs -f
```

### Управление базой данных

```bash
# Подключение к БД
docker-compose exec postgres psql -U neuro_user -d neuro_store

# Применение миграций
docker-compose exec backend alembic upgrade head

# Создание бэкапа
docker-compose exec postgres pg_dump -U neuro_user neuro_store > backup.sql
```

### Управление приложением

```bash
# Перезапуск backend
docker-compose restart backend

# Просмотр переменных окружения
docker-compose exec backend env

# Выполнение команд в контейнере
docker-compose exec backend python -c "print('Hello from container')"
```

### Мониторинг

```bash
# Статус сервисов
docker-compose ps

# Использование ресурсов
docker stats

# Проверка здоровья
curl http://localhost:8000/health
```
