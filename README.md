
# Магазин подписок на нейросети (Neuro Store)

> Учебный курсовой проект: защищённая клиент-серверная система для продажи подписок на нейросетевые сервисы.
> Backend: **FastAPI + PostgreSQL + SQLAlchemy/Alembic**, Frontend: **Next.js (React)**, DevOps: **Docker Compose**.

---

## Содержание
- [Быстрый старт](#быстрый-старт)
- [Локальный запуск без Docker](#локальный-запуск-без-docker)
  - [Backend](#backend)
  - [Frontend](#frontend)
- [Миграции БД (Alembic)](#миграции-бд-alembic)
- [Скрипты бэкапа/восстановления](#скрипты-бэкаповосстановления)
- [Дорожная карта](#дорожная-карта)
- [Стандарты разработки](#стандарты-разработки)

---

## Быстрый старт

### Запуск через Docker Compose (рекомендуется)

1. Поднимите сервисы:

```bash
docker compose -f ops/docker-compose.yml up --build

```

1.  Доступные сервисы:

-   **Backend (FastAPI):** [http://localhost:8000](http://localhost:8000/)

-   **Swagger UI:** <http://localhost:8000/docs>

-   **PostgreSQL:** localhost:5432

-   **pgAdmin:** [http://localhost:5050](http://localhost:5050/)

-   **Frontend (Next.js):** [http://localhost:3000](http://localhost:3000/)

1.  Примените миграции:

```
docker compose exec backend alembic upgrade head

```

* * * * *

Локальный запуск без Docker
---------------------------

### Backend

```
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

```
cd client
npm install
npm run dev
# http://localhost:3000

```

* * * * *

Миграции БД (Alembic)
---------------------

```
# Создать ревизию
alembic revision -m "init schema"

# Применить миграции
alembic upgrade head

# Откатить миграцию
alembic downgrade -1

```

* * * * *

Скрипты бэкапа/восстановления
-----------------------------

### Бэкап:

```
# В Docker
docker compose exec db pg_dump -U $POSTGRES_USER -d $POSTGRES_DB > db/backup/backup_$(date +%F).sql

```

### Восстановление:

```
# В Docker
docker compose exec -T db psql -U $POSTGRES_USER -d $POSTGRES_DB < db/restore/dump.sql

```

* * * * *

Дорожная карта
--------------

| Этап | Подзадачи | Статус |
| --- | --- | --- |
| 1\. Инициализация | README, структура проекта, Docker, pgAdmin | ✅ |
| 2\. БД | ERD, DDL (`ddl.sql`), триггеры/процедуры, Alembic | ⏳ |
| 3\. Backend API | Аутентификация (JWT), RBAC, CRUD: products, plans, subscriptions ... | ⏳ |
| 4\. Клиент | UI: личный кабинет, подписки, аналитика | ⏳ |
| 5\. Тестирование | Pytest, интеграционные тесты, линтеры | ⏳ |
| 6\. Документация | OpenAPI, инструкции, отчёт по КП | ⏳ |

* * * * *

Стандарты разработки
--------------------

-   **Коммиты:** Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:` ...)

-   **Ветки:** `main`, `develop`, фичи --- `feature/<task>`

-   **Код-стайл:** `ruff`, `black`, `isort`, `mypy`

-   **PR:** использование шаблона с чек-листом (линтеры, тесты, обновление docs)

* * * * *
