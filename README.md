# Магазин подписок на нейросети (Neuro Store)

> Учебный курсовой проект: защищённая клиент-серверная система для продажи подписок на нейросетевые сервисы.
> Backend: **FastAPI + PostgreSQL + Redis + SQLAlchemy/Alembic**, Frontend: **Next.js (React)**, DevOps: **Docker Compose**.

---

## Содержание

- [Быстрый старт](#быстрый-старт)
- [Локальный запуск без Docker](#локальный-запуск-без-docker)
  - [Backend](#backend)
  - [Frontend](#frontend)
- [Архитектура базы данных](#архитектура-базы-данных)
- [Миграции БД (Alembic)](#миграции-бд-alembic)
- [Скрипты бэкапа/восстановления](#скрипты-бэкапавосстановления)
- [Дорожная карта](#дорожная-карта)
- [Стандарты разработки](#стандарты-разработки)

---

## Быстрый старт

### 🚀 Автоматический запуск (рекомендуется)

Используйте готовый скрипт для быстрого запуска:

```bash
./start.sh
```

Этот скрипт автоматически:
- Проверит наличие Docker и Docker Compose
- Создаст необходимые директории
- Скопирует .env.example в .env
- Запустит все сервисы
- Покажет статус и доступные URL

### Запуск через Docker Compose

1. Поднимите сервисы:

```bash
docker compose -f ops/docker-compose.yml up --build
```

2. Доступные сервисы:

- **Backend (FastAPI):** [http://localhost:8000](http://localhost:8000/)
- **Swagger UI:** <http://localhost:8000/docs>
- **PostgreSQL:** localhost:5433
- **Redis:** localhost:6379
- **pgAdmin:** [http://localhost:5050](http://localhost:5050/)
- **Frontend (Next.js):** [http://localhost:3000](http://localhost:3000/)

3. Примените миграции:

```bash
docker compose -f ops/docker-compose.yml exec backend alembic upgrade head
```

---

## Локальный запуск без Docker

### Backend

```bash
# 1. Виртуальное окружение и зависимости
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 2. Переменные окружения
cp ops/.env.example .env

# 3. Миграции
alembic upgrade head

# 4. Запуск сервера
uvicorn app.main:app --reload
# Swagger UI: http://127.0.0.1:8000/docs
```

### Frontend

```bash
cd client
npm install
npm run dev
# http://localhost:3000
```

---

## Архитектура базы данных

### Основные сущности (11 таблиц)

1. **roles** - Роли пользователей (admin, moderator, user, viewer)
2. **users** - Пользователи системы
3. **categories** - Категории продуктов
4. **products** - Продукты (нейросети)
5. **plans** - Тарифные планы
6. **subscriptions** - Подписки пользователей
7. **payments** - Платежи
8. **api_keys** - API ключи для доступа
9. **api_logs** - Логи использования API
10. **notifications** - Уведомления пользователей

### Типы связей

- **1:1** - Подписка ↔ Платеж
- **1:M** - Пользователь → Подписки, Продукт → Планы, Категория → Продукты
- **M:M** - Пользователи ↔ Роли (через поле role_id в users)

### Нормализация

Все таблицы находятся в 3НФ (третьей нормальной форме) с устранением транзитивных зависимостей.

## Структура файлов

```
neuro_store/
├── docs/                        # Документация проекта
│   ├── requirements_checklist.md # Чек-лист требований
│   ├── structure.md             # Структура проекта
│   ├── rbac.md                  # Роли и права доступа
│   ├── architecture.md          # Архитектура системы
│   ├── test_api.md              # Примеры API
│   ├── start.md                 # Инструкции по запуску
│   └── erd.md                   # ER-диаграмма и словарь данных
├── db/                          # База данных
│   ├── ddl.sql                  # SQL-скрипт создания таблиц
│   ├── triggers.sql             # Триггеры, функции и процедуры
│   ├── backup/                  # Резервное копирование
│   │   └── README.md            # Документация по бэкапам
│   └── init/                    # Инициализация данных
│       ├── 01_init_roles.sql   # Роли пользователей
│       ├── 02_init_categories.sql # Категории продуктов
│       ├── 03_init_products.sql # Продукты
│       ├── 04_init_plans.sql   # Тарифные планы
│       ├── 05_init_test_users.sql # Тестовые пользователи
│       ├── 06_init_test_subscriptions.sql # Тестовые подписки
│       ├── 07_init_api_keys.sql # API ключи
│       ├── 08_init_api_logs.sql # Логи API
│       ├── 09_init_notifications.sql # Уведомления
│       ├── 10_init_demo_data.sql # Демо данные
│       └── README.md            # Документация инициализации
├── ops/                         # DevOps и развертывание
│   ├── docker-compose.yml       # Docker Compose конфигурация
│   ├── Dockerfile.backend       # Dockerfile для FastAPI
│   ├── Dockerfile.frontend      # Dockerfile для Next.js
│   └── .env.example             # Пример переменных окружения
├── app/                         # FastAPI приложение
│   ├── api/                     # API роутеры
│   │   ├── __init__.py          # Основной API роутер
│   │   └── v1/                  # API версии 1
│   │       ├── auth.py          # Аутентификация
│   │       ├── products.py      # Управление продуктами
│   │       ├── subscriptions.py # Управление подписками
│   │       └── admin.py         # Административные функции
│   ├── core/                    # Основные настройки
│   │   ├── config.py            # Конфигурация
│   │   ├── database.py          # База данных
│   │   ├── exceptions.py        # Кастомные исключения
│   │   ├── logging_config.py    # Настройка логирования
│   │   ├── limiter.py           # Rate limiting
│   │   └── security.py          # Безопасность
│   ├── dependencies/            # FastAPI зависимости
│   │   └── roles.py             # RBAC зависимости
│   ├── models/                  # SQLAlchemy модели
│   │   ├── user.py              # Модель пользователя
│   │   ├── role.py              # Модель роли
│   │   ├── product.py           # Модель продукта
│   │   ├── plan.py              # Модель плана
│   │   ├── subscription.py      # Модель подписки
│   │   ├── payment.py           # Модель платежа
│   │   ├── api_key.py           # Модель API ключа
│   │   ├── api_log.py           # Модель лога API
│   │   └── notification.py      # Модель уведомления
│   ├── schemas/                 # Pydantic схемы
│   └── services/                # Бизнес-логика
│       └── cache.py             # Redis кэширование
├── client/                      # Next.js frontend
│   ├── components/              # React компоненты
│   ├── types/                   # TypeScript типы
│   └── pages/                   # Страницы приложения
├── tests/                       # Тесты
│   ├── conftest.py              # Конфигурация pytest
│   ├── test_basic.py            # Базовые тесты
│   └── test_auth.py             # Тесты аутентификации
├── requirements.txt              # Python зависимости
├── pytest.ini                   # Конфигурация pytest
├── alembic.ini                  # Конфигурация Alembic
├── start.sh                     # Скрипт автоматического запуска
└── README.md                    # Документация проекта
```

## Установка и настройка

### 🔑 Тестовые данные

После запуска системы доступны тестовые данные:

- **Администратор:** admin@neurostore.com / 123
- **Модератор:** moderator@neurostore.com / 123
- **Пользователь:** user@neurostore.com / 123
- **Продукты:** ChatGPT, DALL-E, Midjourney, Claude, Stable Diffusion, Jasper
- **Планы:** Базовый (299₽), Стандарт (599₽), Премиум (1299₽), Годовой (9999₽), Пробный (0₽)
- **Готовые подписки:** Различные подписки для тестовых пользователей

### Требования

- **Backend:** Python 3.8+, FastAPI, PostgreSQL 14+, Redis 6+
- **Frontend:** Node.js 16+, Next.js
- **DevOps:** Docker, Docker Compose
- **База данных:** PostgreSQL с расширениями

### Шаги установки

1. **Создание базы данных:**
```sql
CREATE DATABASE neuro_store;
\c neuro_store;
```

2. **Выполнение DDL скрипта:**
```bash
psql -d neuro_store -f db/ddl.sql
```

3. **Выполнение скрипта с триггерами:**
```bash
psql -d neuro_store -f db/triggers.sql
```

4. **Инициализация данных:**
```bash
# Выполнение всех скриптов инициализации
for file in db/init/*.sql; do
    psql -d neuro_store -f "$file"
done
```

5. **Проверка установки:**
```sql
-- Проверка таблиц
\dt

-- Проверка функций
\df

-- Проверка представлений
\dv

-- Проверка данных
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM subscriptions;
```

## Основной функционал

### 🚀 API Endpoints

- **POST /api/v1/auth/register** - Регистрация пользователя
- **POST /api/v1/auth/login** - Вход в систему (JWT)
- **GET /api/v1/auth/me** - Информация о текущем пользователе
- **GET /api/v1/products/** - Список всех продуктов
- **GET /api/v1/products/{id}** - Детали продукта
- **GET /api/v1/products/{id}/plans** - Планы для продукта
- **POST /api/v1/subscriptions/** - Создание подписки
- **GET /api/v1/subscriptions/** - Подписки пользователя
- **PUT /api/v1/subscriptions/{id}/cancel** - Отмена подписки
- **GET /api/v1/admin/users** - Управление пользователями (admin)
- **GET /api/v1/admin/statistics** - Статистика системы (admin)

### Аудит и логирование

- **Структурированное логирование** через structlog
- **Логирование запросов** и ответов API
- **Логирование ошибок** и исключений
- **Логирование безопасности** (аутентификация, авторизация)
- **Логирование операций** с базой данных и кэшем

### Управление подписками

- **JWT аутентификация** с refresh токенами
- **RBAC система** с ролями admin, moderator, user, viewer
- **Rate limiting** для защиты от злоупотреблений
- **Валидация данных** через Pydantic схемы
- **Обработка исключений** с кастомными классами

### Аналитика и отчеты

- **VIEW для активных подписок** с детальной информацией
- **Отчет по выручке** по месяцам, продуктам и планам
- **Статистика использования** нейросетей
- **Мониторинг API** через логи и метрики

### Безопасность и целостность

- **Ограничения целостности** (CHECK, FOREIGN KEY)
- **ON DELETE RESTRICT** для защиты от случайного удаления
- **ON UPDATE CASCADE** для синхронизации изменений
- **Проверка целостности данных** через функции
- **Хеширование паролей** с bcrypt
- **JWT токены** с настраиваемым временем жизни

## Примеры использования

### Создание администратора

```bash
# Создание администратора через API
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@neurostore.com",
    "password": "admin123",
    "full_name": "Администратор",
    "role": "admin"
  }'
```

### Аутентификация и получение токена

```bash
# Вход в систему
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@neurostore.com",
    "password": "admin123"
  }'

# Использование токена для доступа к защищенным эндпоинтам
curl -X GET "http://localhost:8000/api/v1/auth/me" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Управление продуктами

```bash
# Получение списка продуктов
curl -X GET "http://localhost:8000/api/v1/products/"

# Получение деталей продукта
curl -X GET "http://localhost:8000/api/v1/products/1"

# Получение планов для продукта
curl -X GET "http://localhost:8000/api/v1/products/1/plans"
```

### Управление подписками

```bash
# Создание подписки
curl -X POST "http://localhost:8000/api/v1/subscriptions/" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 1,
    "plan_id": 2
  }'

# Получение подписок пользователя
curl -X GET "http://localhost:8000/api/v1/subscriptions/" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Автоматические задачи

### Обновление статуса подписок

```sql
-- Ручной запуск
SELECT update_expired_subscriptions();

-- Автоматический запуск (если pg_cron установлен)
SELECT cron.schedule('update-expired-subscriptions', '0 2 * * *', 
    'SELECT update_expired_subscriptions();');
```

### Очистка старых записей

```sql
-- Очистка старых логов API
SELECT cleanup_old_api_logs(30);

-- Очистка старых уведомлений
SELECT cleanup_old_notifications(90);
```

## Миграции БД (Alembic)

```bash
# Создать ревизию
alembic revision -m "init schema"

# Применить миграции
alembic upgrade head

# Откатить миграцию
alembic downgrade -1

# Проверить текущую версию
alembic current
```

## Скрипты бэкапа/восстановления

### Бэкап:

```bash
# В Docker
docker compose -f ops/docker-compose.yml exec postgres pg_dump -U neuro_user -d neuro_store > db/backup/backup_$(date +%F).sql

# Локально
pg_dump -U neuro_user -d neuro_store > db/backup/backup_$(date +%F).sql
```

### Восстановление:

```bash
# В Docker
docker compose -f ops/docker-compose.yml exec -T postgres psql -U neuro_user -d neuro_store < db/backup/backup_2024-01-30.sql

# Локально
psql -U neuro_user -d neuro_store < db/backup/backup_2024-01-30.sql
```

## Индексы и производительность

### Созданные индексы

- **Первичные ключи** (автоматически)
- **Внешние ключи** для быстрого JOIN
- **Часто используемые поля** (статусы, даты, email)
- **Составные индексы** для сложных запросов
- **Индексы для поиска** по текстовым полям

### Оптимизация запросов

- **VIEW для сложных отчетов**
- **Индексы по условиям WHERE**
- **Оптимизированные JOIN** через промежуточные таблицы
- **Кэширование** часто запрашиваемых данных в Redis

## Безопасность

### Роли и права доступа

- **admin** - Полный доступ к системе, управление пользователями
- **moderator** - Модерация контента, просмотр статистики
- **user** - Обычный пользователь, управление своими подписками
- **viewer** - Только просмотр продуктов и планов

### Аудит операций

- **Логирование всех изменений** через триггеры
- **Отслеживание пользователей** выполняющих операции
- **Сохранение истории изменений** в audit_log
- **Мониторинг безопасности** через логи

## Расширение функционала

### Добавление новых нейросетей

```sql
-- Добавление нового продукта
INSERT INTO products (name, description, category_id, features, website_url) VALUES 
('Claude', 'AI-ассистент от Anthropic', 1, '["Языковая модель", "Код", "Анализ"]', 'https://claude.ai');

-- Связывание с планами
INSERT INTO plans (name, description, price, billing_cycle, features, usage_limits) VALUES 
('Пробный', 'Пробный доступ на 7 дней', 0.00, 'monthly', '["Базовый доступ"]', '{"requests_per_day": 100}');
```

### Создание новых тарифных планов

```sql
-- Добавление нового плана
INSERT INTO plans (name, description, price, billing_cycle, features, usage_limits) VALUES 
('Enterprise', 'Корпоративный план', 9999.00, 'yearly', '["Приоритетная поддержка", "API доступ", "Аналитика"]', '{"requests_per_day": 10000}');
```

## Мониторинг и обслуживание

### Регулярные задачи

1. **Ежедневно в 2:00** - Обновление статуса истекших подписок
2. **Ежемесячно в 3:00** - Очистка старых записей логов
3. **Еженедельно** - Проверка целостности данных
4. **По требованию** - Создание резервных копий

### Рекомендации по производительности

- **Мониторинг размера таблиц** (особенно api_logs)
- **Анализ медленных запросов** через pg_stat_statements
- **Регулярная очистка** старых записей логов
- **Партиционирование** больших таблиц при необходимости
- **Мониторинг Redis** кэша и его производительности

## Дорожная карта

| Этап              | Подзадачи                                                            | Статус |
| ----------------- | -------------------------------------------------------------------- | ------ |
| 1. Инициализация | README, структура проекта, Docker, pgAdmin                           | ✅      |
| 2. БД            | ERD, DDL (ddl.sql), триггеры/процедуры, Alembic                      | ✅      |
| 3. Backend API   | Аутентификация (JWT), RBAC, CRUD: products, plans, subscriptions ... | ✅      |
| 4. Клиент        | UI: личный кабинет, подписки, аналитика                              | ✅      |
| 5. Тестирование  | Pytest, интеграционные тесты, линтеры                                | ✅      |
| 6. Документация  | OpenAPI, инструкции, отчёт по КП                                     | ✅      |

## Стандарты разработки

- **Коммиты:** Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:` ...)
- **Ветки:** `main`, `develop`, фичи --- `feature/<task>`
- **Код-стайл:** `ruff`, `black`, `isort`, `mypy`
- **PR:** использование шаблона с чек-листом (линтеры, тесты, обновление docs)

## Поддержка и развитие

### Реализованные возможности

- **✅ API endpoints** для аутентификации, продуктов, планов и подписок
- **✅ Полная модель данных** с SQLAlchemy ORM
- **✅ JWT аутентификация** с защищенными эндпоинтами
- **✅ RBAC система** с ролями и правами доступа
- **✅ Rate limiting** для защиты API
- **✅ Структурированное логирование** через structlog
- **✅ Redis кэширование** для производительности
- **✅ Красивый UI** на Next.js с Tailwind CSS
- **✅ Docker Compose** для простого развертывания
- **✅ Полная документация** проекта на русском языке
- **✅ Тестирование** с pytest и фикстурами

### Возможные улучшения

- **Микросервисная архитектура** для масштабирования
- **Асинхронная обработка** платежей и уведомлений
- **WebSocket** для real-time уведомлений
- **Метрики и мониторинг** через Prometheus/Grafana
- **CI/CD pipeline** с автоматическим тестированием

### Тестирование

- **Unit тесты** для функций и процедур
- **Интеграционные тесты** для API эндпоинтов
- **Тесты аутентификации** и авторизации
- **Тесты rate limiting** и кэширования

## 🆕 Новые возможности

### 🎯 **Улучшенный UI с кнопками**
- **Главная страница**: Кнопки быстрых действий (Регистрация, Вход, Личный кабинет, Админ панель)
- **Dashboard**: Улучшенный интерфейс с кнопками действий для подписок
- **Admin панель**: Расширенное управление пользователями с кнопками действий

### 💾 **Сохранение данных**
- **Docker volumes**: Все данные сохраняются в `ops_postgres_data` volume
- **Автоматическое сохранение**: Данные не теряются при перезапуске контейнеров
- **Резервное копирование**: Скрипты в `db/backup/` для автоматизации

### 🛠️ **Удобное управление**
- **Makefile команды**: `make -f ops/Makefile users`, `make -f ops/Makefile admin`
- **Быстрые действия**: Создание пользователей, управление ролями
- **Мониторинг**: Проверка статуса сервисов и пользователей

## Заключение

Данная система предоставляет полнофункциональный backend для магазина подписок на нейросети, соответствующий всем требованиям курсового проекта:

✅ **11 таблиц в 3НФ**  
✅ **Связи 1:1, 1:M, M:M**  
✅ **Ограничения целостности**  
✅ **Процедуры и функции**  
✅ **Триггеры аудита**  
✅ **Транзакции**  
✅ **Аналитика через VIEW**  
✅ **FastAPI + Next.js архитектура**  
✅ **Docker Compose развертывание**  
✅ **Полная документация**  
✅ **🎯 Улучшенный UI с кнопками**  
✅ **💾 Сохранение данных после перезапуска**  
✅ **🛠️ Удобное управление через Makefile**  
✅ **🔐 RBAC система безопасности**  
✅ **📊 Структурированное логирование**  
✅ **⚡ Redis кэширование**  
✅ **🧪 Полное тестирование**  

Система готова к использованию и дальнейшему развитию!

---

## About

Проект создан в рамках курсовой работы по разработке защищённой клиент-серверной системы для продажи подписок на нейросетевые сервисы.

