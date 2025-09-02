# Магазин подписок на нейросети (Neuro Store)

> Учебный курсовой проект: защищённая клиент-серверная система для продажи подписок на нейросетевые сервисы.  
> Backend: **FastAPI + PostgreSQL + SQLAlchemy/Alembic**, Frontend: **Next.js (React)**, DevOps: **Docker Compose**.

---

## Содержание
- [Описание](#описание)
- [Стек технологий](#стек-технологий)
- [Требования курсового проекта (чек-лист)](#требования-курсового-проекта-чек-лист)
- [Быстрый старт](#быстрый-старт)
  - [Запуск через Docker Compose (рекомендуется)](#запуск-через-docker-compose-рекомендуется)
- [Локальный запуск без Docker](#локальный-запуск-без-docker)
  - [Backend](#backend)
  - [Frontend](#frontend)
- [Миграции БД (Alembic)](#миграции-бд-alembic)
- [Скрипты бэкапа/восстановления](#скрипты-бэкаповосстановления)
- [Дорожная карта](#дорожная-карта)
- [Стандарты разработки](#стандарты-разработки)
- [Лицензия](#лицензия)

---

## Описание

**Neuro Store** — магазин подписок на модели/сервисы ИИ.  
Основные возможности:
- Регистрация/авторизация (JWT).
- Ролевая модель доступа (RBAC): `admin`, `user`, `viewer`.
- Управление продуктами, тарифами и подписками.
- Учёт оплат и потребления сервисов.
- Аудит изменений в БД (триггеры + `audit_log`).
- Отчётность и аналитика.
- Бэкап и восстановление данных.

---

## Стек технологий

- **Backend:** FastAPI, SQLAlchemy, Alembic, Pydantic  
- **DB:** PostgreSQL (>=14), pgAdmin  
- **Auth & Security:** JWT (`python-jose`), `passlib[bcrypt]`, `cryptography`  
- **Frontend:** Next.js (React)  
- **DevOps:** Docker, Docker Compose, Makefile, pre-commit, linters (ruff/black/isort/mypy)  
- **Инструменты БД:** `pg_dump`/`pg_restore`

---

## Требования курсового проекта (чек-лист)

- [ ] 8+ таблиц в 3НФ  
- [ ] Связи 1:1, 1:М, М:М  
- [ ] Ограничения целостности (NOT NULL, UNIQUE, CHECK)  
- [ ] Процедуры/функции, триггеры, транзакции  
- [ ] Аудит изменений (логирование в `audit_log`)  
- [ ] Ролевая модель (3+ роли)  
- [ ] Бэкап и восстановление данных  
- [ ] Клиентская часть (UI)  
- [ ] REST API со спецификацией OpenAPI  
- [ ] Отчётность/аналитика  
- [ ] Тестирование (unit/интеграционные)  
- [x] Инструкция по запуску

---


## Быстрый старт

### Запуск через Docker Compose (рекомендуется)

1. Поднимите сервисы:

   docker compose -f ops/docker-compose.yml up --build


2. Доступные сервисы:

   * **Backend (FastAPI):** [http://localhost:8000](http://localhost:8000)
   * **Swagger UI:** [http://localhost:8000/docs](http://localhost:8000/docs)
   * **PostgreSQL:** localhost:5432
   * **pgAdmin:** [http://localhost:5050](http://localhost:5050)
   * **Frontend (Next.js):** [http://localhost:3000](http://localhost:3000)

3. Примените миграции:

   docker compose exec backend alembic upgrade head

---

## Локальный запуск без Docker

### Backend

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
# Swagger: http://127.0.0.1:8000/docs
```

### Frontend

cd client
npm install
npm run dev
# http://localhost:3000

---

## Миграции БД (Alembic)

# Создать ревизию
alembic revision -m "init schema"

# Применить миграции
alembic upgrade head

# Откатить миграцию
alembic downgrade -1

---

## Скрипты бэкапа/восстановления

### Бэкап:

# В Docker
docker compose exec db pg_dump -U $POSTGRES_USER -d $POSTGRES_DB > db/backup/backup_$(date +%F).sql


### Восстановление:

# В Docker
docker compose exec -T db psql -U $POSTGRES_USER -d $POSTGRES_DB < db/restore/dump.sql

---

## Дорожная карта

| Этап             | Подзадачи                                                            | Статус |
| ---------------- | -------------------------------------------------------------------- | ------ |
| 1. Инициализация | README, структура, Docker, pgAdmin                                   | ✅      |
| 2. БД            | ERD, DDL (`ddl.sql`), триггеры/процедуры, Alembic                    | ⏳      |
| 3. Backend API   | Auth (JWT), RBAC, CRUD: products/plans/subscriptions/orders/payments | ⏳      |
| 4. Клиент        | UI: личный кабинет, подписки, аналитика                              | ⏳      |
| 5. Тестирование  | Pytest, интеграционные тесты, линтеры                                | ⏳      |
| 6. Документация  | OpenAPI, инструкции, отчёт                                           | ⏳      |

---

## Стандарты разработки

* **Коммиты:** Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:` …)
* **Ветки:** `main`, `develop`, фичи — `feature/<task>`
* **Код-стайл:** `ruff`, `black`, `isort`, `mypy`
* **PR:** шаблон с чек-листом (линтеры, тесты, обновление docs)

---

## Лицензия

Этот проект распространяется под лицензией MIT.

```text
MIT License

Copyright (c) 2025 Neuro Store

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights  
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      
copies of the Software, and to permit persons to whom the Software is         
furnished to do so, subject to the following conditions:                      

The above copyright notice and this permission notice shall be included in    
all copies or substantial portions of the Software.                           

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN     
THE SOFTWARE.
