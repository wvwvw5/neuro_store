# Системная архитектура Neuro Store

## Навигация
- [Общая схема](#общая-схема)
- [Пакетная структура backend](#пакетная-структура-backend)
- [Схема базы данных](#схема-базы-данных)
- [Компоненты системы](#компоненты-системы)
- [Нефункциональные требования](#нефункциональные-требования)

## Общая схема

```mermaid
graph TB
    subgraph "Client Layer"
        C[Next.js Client]
        M[Mobile App]
    end
    
    subgraph "API Gateway"
        LB[Load Balancer]
        API[FastAPI Backend]
    end
    
    subgraph "Data Layer"
        PG[(PostgreSQL)]
        RD[(Redis)]
    end
    
    subgraph "Infrastructure"
        DC[Docker Compose]
        PGADMIN[pgAdmin]
        CI[GitHub Actions]
    end
    
    C --> LB
    M --> LB
    LB --> API
    API --> PG
    API --> RD
    API --> PGADMIN
    DC --> PG
    DC --> RD
    DC --> PGADMIN
    CI --> API
    
    style C fill:#61dafb
    style API fill:#00d4aa
    style PG fill:#336791
    style RD fill:#dc382d
    style PGADMIN fill:#fca326
```

## Пакетная структура backend

```mermaid
classDiagram
    class FastAPI {
        +main.py
        +create_application()
        +include_router()
    }
    
    class Core {
        +config.py
        +security.py
        +rbac.py
        +limiter.py
        +logging.py
    }
    
    class API {
        +v1/
        +deps.py
        +auth.py
        +products.py
        +subscriptions.py
        +admin.py
    }
    
    class Services {
        +auth_service.py
        +product_service.py
        +subscription_service.py
        +cache_service.py
    }
    
    class Models {
        +user.py
        +role.py
        +product.py
        +subscription.py
        +audit.py
    }
    
    class Schemas {
        +user.py
        +product.py
        +subscription.py
        +response.py
    }
    
    class Database {
        +base.py
        +session.py
        +migrations/
    }
    
    FastAPI --> Core
    FastAPI --> API
    API --> Services
    Services --> Models
    Services --> Schemas
    Models --> Database
    Core --> Database
```

## Схема базы данных

```mermaid
erDiagram
    users {
        bigint id PK
        varchar email UK
        varchar username UK
        varchar hashed_password
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }
    
    roles {
        bigint id PK
        varchar name UK
        text description
        jsonb permissions
        timestamp created_at
    }
    
    user_roles {
        bigint id PK
        bigint user_id FK
        bigint role_id FK
        bigint assigned_by FK
        timestamp assigned_at
        timestamp expires_at
    }
    
    products {
        bigint id PK
        varchar name
        text description
        decimal price
        varchar category
        boolean is_active
        bigint owner_id FK
        timestamp created_at
        timestamp updated_at
    }
    
    plans {
        bigint id PK
        varchar name
        text description
        decimal price
        integer duration_days
        boolean is_active
        timestamp created_at
    }
    
    product_plans {
        bigint id PK
        bigint product_id FK
        bigint plan_id FK
        boolean is_active
        timestamp created_at
    }
    
    subscriptions {
        bigint id PK
        bigint user_id FK
        bigint product_id FK
        bigint plan_id FK
        varchar status
        timestamp start_date
        timestamp end_date
        timestamp created_at
        timestamp updated_at
    }
    
    orders {
        bigint id PK
        bigint user_id FK
        bigint subscription_id FK
        decimal amount
        varchar status
        timestamp created_at
        timestamp paid_at
    }
    
    payments {
        bigint id PK
        bigint order_id FK
        varchar payment_method
        decimal amount
        varchar status
        timestamp created_at
        timestamp processed_at
    }
    
    usage_events {
        bigint id PK
        bigint user_id FK
        bigint product_id FK
        varchar event_type
        jsonb event_data
        timestamp created_at
    }
    
    audit_log {
        bigint id PK
        varchar action
        varchar table_name
        bigint record_id
        bigint user_id FK
        jsonb old_values
        jsonb new_values
        timestamp created_at
    }
    
    users ||--o{ user_roles : has
    roles ||--o{ user_roles : assigned_to
    users ||--o{ user_roles : assigned_by
    users ||--o{ products : owns
    users ||--o{ subscriptions : subscribes
    products ||--o{ product_plans : offers
    plans ||--o{ product_plans : included_in
    products ||--o{ subscriptions : subscribed_to
    plans ||--o{ subscriptions : uses
    users ||--o{ orders : places
    subscriptions ||--o{ orders : generates
    orders ||--o{ payments : pays_for
    users ||--o{ usage_events : generates
    products ||--o{ usage_events : tracks
    users ||--o{ audit_log : performs
```

## Компоненты системы

### Аутентификация и безопасность

**JWT токены**
- **Реализация:** `app/core/security.py`
- **Функции:** Создание, валидация, обновление токенов
- **Безопасность:** RSA ключи, короткое время жизни access токенов

**RBAC система**
- **Реализация:** `app/core/rbac.py`
- **Роли:** admin, moderator, user, viewer
- **Проверка:** Dependency injection в FastAPI эндпоинтах

**Rate Limiting**
- **Реализация:** `app/core/limiter.py`
- **Стратегия:** По IP адресу и пользователю
- **Лимиты:** Настраиваемые по эндпоинтам

### Кэширование и производительность

**Redis кэш**
- **Реализация:** `app/services/cache.py`
- **Назначение:** Сессии, кэш продуктов, rate limiting
- **Стратегия:** TTL с автоматическим обновлением

**Оптимизация БД**
- **Индексы:** По часто используемым полям
- **Представления:** Агрегированные данные для отчетности
- **Процедуры:** Сложная бизнес-логика

### Миграции и версионирование

**Alembic миграции**
- **Конфигурация:** `alembic.ini`
- **Структура:** `db/migrations/`
- **Команды:** upgrade, downgrade, revision

**Backup и Restore**
- **Скрипты:** `ops/backup/`
- **Автоматизация:** Cron jobs для регулярного резервного копирования
- **Хранение:** Локальные файлы + облачное хранилище

## Нефункциональные требования

### Логирование

**Структурированное логирование**
- **Библиотека:** structlog
- **Формат:** JSON для машинного чтения
- **Уровни:** DEBUG, INFO, WARNING, ERROR, CRITICAL
- **Контекст:** User ID, Request ID, Endpoint

```python
# app/core/logging.py
import structlog

logger = structlog.get_logger()

# Пример использования
logger.info(
    "User action",
    user_id=user.id,
    action="product_created",
    product_id=product.id
)
```

### Обработка ошибок

**Глобальные обработчики**
- **HTTP ошибки:** Стандартные коды состояния
- **Валидация:** Pydantic ValidationError
- **Бизнес-логика:** Кастомные исключения
- **Логирование:** Автоматическое логирование ошибок

```python
# app/core/exceptions.py
from fastapi import HTTPException, status

class InsufficientPermissionsError(HTTPException):
    def __init__(self, detail: str = "Недостаточно прав"):
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=detail
        )

class ResourceNotFoundError(HTTPException):
    def __init__(self, resource: str, resource_id: int):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"{resource} с ID {resource_id} не найден"
        )
```

### Тестирование

**Стратегия тестирования**
- **Unit тесты:** pytest для всех модулей
- **Интеграционные тесты:** API эндпоинты
- **Тестовая БД:** SQLite in-memory для изоляции
- **Mock объекты:** Заглушки для внешних сервисов

**Покрытие кода**
- **Инструмент:** pytest-cov
- **Цель:** Минимум 80% покрытия
- **Отчеты:** HTML и XML форматы

### CI/CD

**GitHub Actions**
- **Триггеры:** Push в main/develop, Pull Request
- **Этапы:** Lint, Test, Build, Deploy
- **Окружения:** Development, Staging, Production

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run tests
        run: pytest --cov=app --cov-report=xml
```

### Мониторинг и метрики

**Метрики приложения**
- **Время ответа:** FastAPI middleware
- **Количество запросов:** Prometheus метрики
- **Ошибки:** Автоматический сбор и алерты

**Здоровье системы**
- **Health checks:** `/health` эндпоинт
- **Readiness probe:** Проверка подключения к БД
- **Liveness probe:** Проверка работоспособности приложения

### Масштабируемость

**Горизонтальное масштабирование**
- **Load Balancer:** Распределение нагрузки между инстансами
- **Stateless API:** Без состояния для горизонтального масштабирования
- **Кэш:** Redis для разделения состояния между инстансами

**Вертикальное масштабирование**
- **Ресурсы БД:** Увеличение CPU/RAM по необходимости
- **Connection Pool:** Оптимизация количества соединений
- **Индексы:** Анализ и оптимизация запросов
