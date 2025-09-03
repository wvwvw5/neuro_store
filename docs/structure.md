# Структура проекта Neuro Store

## Навигация
- [Дерево каталогов](#дерево-каталогов)
- [Описание компонентов](#описание-компонентов)
- [Ветвление и коммиты](#ветвление-и-коммиты)
- [Архитектурные решения](#архитектурные-решения)

## Дерево каталогов

```
neuro_store/
├── app/                          # Backend приложение (FastAPI)
│   ├── api/                      # API эндпоинты
│   │   ├── v1/                   # API версия 1.0
│   │   │   ├── auth.py           # Аутентификация
│   │   │   ├── products.py       # Управление продуктами
│   │   │   ├── subscriptions.py  # Управление подписками
│   │   │   └── admin.py          # Административные функции
│   │   └── deps.py               # Зависимости и middleware
│   ├── core/                     # Основные настройки
│   │   ├── config.py             # Конфигурация приложения
│   │   ├── security.py           # JWT и безопасность
│   │   ├── rbac.py               # Ролевая модель
│   │   ├── limiter.py            # Rate limiting
│   │   └── logging.py            # Логирование
│   ├── db/                       # Работа с базой данных
│   │   ├── base.py               # Базовые классы
│   │   └── session.py            # Сессии БД
│   ├── models/                   # SQLAlchemy модели
│   │   ├── user.py               # Пользователи
│   │   ├── role.py               # Роли
│   │   ├── product.py            # Продукты
│   │   ├── subscription.py       # Подписки
│   │   └── audit.py              # Аудит
│   ├── schemas/                  # Pydantic схемы
│   │   ├── user.py               # Схемы пользователей
│   │   ├── product.py            # Схемы продуктов
│   │   └── subscription.py       # Схемы подписок
│   ├── services/                 # Бизнес-логика
│   │   ├── auth.py               # Сервис аутентификации
│   │   ├── cache.py              # Redis кэширование
│   │   └── subscription.py       # Сервис подписок
│   └── main.py                   # Точка входа приложения
├── client/                       # Frontend приложение (Next.js)
│   ├── components/               # React компоненты
│   ├── pages/                    # Страницы приложения
│   ├── styles/                   # CSS стили
│   └── package.json              # Зависимости Node.js
├── db/                           # База данных
│   ├── migrations/               # Alembic миграции
│   ├── procedures/               # SQL процедуры
│   ├── triggers/                 # SQL триггеры
│   └── views/                    # SQL представления
├── ops/                          # Операционные скрипты
│   ├── backup/                   # Скрипты резервного копирования
│   ├── deploy/                   # Скрипты развертывания
│   └── monitoring/               # Мониторинг
├── tests/                        # Тесты
│   ├── conftest.py               # Конфигурация pytest
│   ├── test_basic.py             # Базовые тесты
│   ├── test_auth.py              # Тесты аутентификации
│   └── test_api/                 # Тесты API
├── docs/                         # Документация
│   ├── requirements_checklist.md  # Чек-лист требований
│   ├── structure.md              # Структура проекта
│   ├── architecture.md           # Архитектура
│   ├── rbac.md                   # Ролевая модель
│   ├── test_api.md               # Примеры API
│   └── start.md                  # Инструкции запуска
├── .github/                      # GitHub конфигурация
│   └── workflows/                # CI/CD пайплайны
├── docker-compose.yml            # Docker Compose конфигурация
├── requirements.txt              # Python зависимости
├── pytest.ini                   # Конфигурация pytest
└── README.md                     # Основная документация
```

## Описание компонентов

### Backend (`app/`)

**`app/api/`** - REST API эндпоинты, организованные по версиям
- **`v1/`** - текущая версия API с полным функционалом
- **`deps.py`** - зависимости для dependency injection (аутентификация, роли)

**`app/core/`** - основные настройки и конфигурация
- **`config.py`** - настройки из переменных окружения
- **`security.py`** - JWT токены, хеширование паролей
- **`rbac.py`** - проверка ролей и разрешений
- **`limiter.py`** - ограничение частоты запросов

**`app/models/`** - SQLAlchemy ORM модели
- Все модели наследуются от `Base` класса
- Автоматическое создание таблиц при запуске
- Поддержка soft delete и аудита

**`app/schemas/`** - Pydantic схемы для валидации
- Входящие данные (Create, Update)
- Исходящие данные (Response)
- Автоматическая валидация типов

**`app/services/`** - бизнес-логика приложения
- Разделение ответственности между слоями
- Кэширование через Redis
- Транзакционность операций

### Frontend (`client/`)

**Next.js приложение** с современной архитектурой
- **`components/`** - переиспользуемые React компоненты
- **`pages/`** - страницы с роутингом
- **`styles/`** - CSS модули и глобальные стили

### База данных (`db/`)

**PostgreSQL 14+** с расширенными возможностями
- **`migrations/`** - Alembic миграции для версионирования схемы
- **`procedures/`** - SQL процедуры для сложной логики
- **`triggers/`** - автоматические действия при изменениях
- **`views/`** - виртуализированные таблицы для отчетности

### Тестирование (`tests/`)

**pytest** с полным покрытием функционала
- **`conftest.py`** - общие фикстуры и настройки
- **`test_basic.py`** - базовые тесты приложения
- **`test_auth.py`** - тесты аутентификации и авторизации
- **`test_api/`** - интеграционные тесты API

## Ветвление и коммиты

### Стратегия ветвления

```
main                    # Продакшн версия
├── develop            # Основная ветка разработки
├── feature/auth       # Функциональные ветки
├── feature/products   # (feature/*)
├── bugfix/login       # Исправления багов
└── hotfix/security    # Критические исправления
```

**Правила ветвления:**
- `main` - только через Pull Request из `develop`
- `develop` - основная ветка для интеграции
- `feature/*` - новая функциональность
- `bugfix/*` - исправления багов
- `hotfix/*` - критические исправления для продакшна

### Conventional Commits

**Формат коммитов:**
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Типы коммитов:**
- `feat:` - новая функциональность
- `fix:` - исправление бага
- `docs:` - изменения в документации
- `style:` - форматирование кода
- `refactor:` - рефакторинг
- `test:` - добавление тестов
- `chore:` - обновление зависимостей

**Примеры:**
```bash
feat(auth): add JWT refresh token support
fix(api): resolve rate limiting issue in tests
docs: update API documentation with examples
test(auth): add integration tests for login
```

## Архитектурные решения

### Принципы проектирования

1. **Разделение ответственности** - каждый модуль имеет четкую зону ответственности
2. **Dependency Injection** - использование FastAPI Depends для внедрения зависимостей
3. **Слоистая архитектура** - API → Services → Models → Database
4. **Конфигурация через переменные окружения** - гибкость развертывания

### Технологический стек

- **Backend:** FastAPI + SQLAlchemy + PostgreSQL + Redis
- **Frontend:** Next.js + React + TypeScript
- **База данных:** PostgreSQL 14+ с расширениями
- **Кэширование:** Redis 7+ для сессий и кэша
- **Тестирование:** pytest + SQLite (тесты) + PostgreSQL (разработка)
- **Контейнеризация:** Docker + Docker Compose
- **CI/CD:** GitHub Actions с автоматическим тестированием
