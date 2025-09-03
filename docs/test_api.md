# Примеры вызовов API

## Навигация
- [Аутентификация](#аутентификация)
- [Продукты](#продукты)
- [Подписки](#подписки)
- [Администрирование](#администрирование)
- [Обработка ошибок](#обработка-ошибок)

## Аутентификация

### Регистрация пользователя

**Запрос:**
```bash
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "username": "testuser",
    "password": "securepass123",
    "full_name": "Тестовый Пользователь"
  }'
```

**Ответ:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "testuser",
  "full_name": "Тестовый Пользователь",
  "is_active": true,
  "created_at": "2024-01-15T10:30:00Z"
}
```

### Вход в систему

**Запрос:**
```bash
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=user@example.com&password=securepass123"
```

**Ответ:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Обновление токена

**Запрос:**
```bash
curl -X POST "http://localhost:8000/api/v1/auth/refresh" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Ответ:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

### Получение профиля пользователя

**Запрос:**
```bash
curl -X GET "http://localhost:8000/api/v1/auth/me" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Ответ:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "testuser",
  "full_name": "Тестовый Пользователь",
  "is_active": true,
  "roles": ["user"],
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

## Продукты

### Получение списка продуктов

**Запрос:**
```bash
curl -X GET "http://localhost:8000/api/v1/products/?skip=0&limit=10"
```

**Ответ:**
```json
{
  "items": [
    {
      "id": 1,
      "name": "ChatGPT Pro",
      "description": "Продвинутый ИИ-ассистент для общения и решения задач",
      "category": "AI Chat",
      "price": 20.00,
      "is_active": true,
      "created_at": "2024-01-15T10:30:00Z"
    },
    {
      "id": 2,
      "name": "Midjourney",
      "description": "Генерация изображений на основе текстового описания",
      "category": "Image Generation",
      "price": 30.00,
      "is_active": true,
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 2,
  "skip": 0,
  "limit": 10
}
```

### Получение продукта по ID

**Запрос:**
```bash
curl -X GET "http://localhost:8000/api/v1/products/1"
```

**Ответ:**
```json
{
  "id": 1,
  "name": "ChatGPT Pro",
  "description": "Продвинутый ИИ-ассистент для общения и решения задач",
  "category": "AI Chat",
  "price": 20.00,
  "is_active": true,
  "plans": [
    {
      "id": 1,
      "name": "Месячный",
      "description": "Доступ на 30 дней",
      "price": 20.00,
      "duration_days": 30
    },
    {
      "id": 2,
      "name": "Годовой",
      "description": "Доступ на 365 дней со скидкой",
      "price": 200.00,
      "duration_days": 365
    }
  ],
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

### Создание продукта (требует роль admin/moderator)

**Запрос:**
```bash
curl -X POST "http://localhost:8000/api/v1/products/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "DALL-E 3",
    "description": "Новейшая модель генерации изображений от OpenAI",
    "category": "Image Generation",
    "price": 25.00
  }'
```

**Ответ:**
```json
{
  "id": 3,
  "name": "DALL-E 3",
  "description": "Новейшая модель генерации изображений от OpenAI",
  "category": "Image Generation",
  "price": 25.00,
  "is_active": true,
  "created_at": "2024-01-15T11:00:00Z",
  "updated_at": "2024-01-15T11:00:00Z"
}
```

### Обновление продукта

**Запрос:**
```bash
curl -X PUT "http://localhost:8000/api/v1/products/3" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "price": 30.00,
    "description": "Обновленное описание DALL-E 3"
  }'
```

**Ответ:**
```json
{
  "id": 3,
  "name": "DALL-E 3",
  "description": "Обновленное описание DALL-E 3",
  "category": "Image Generation",
  "price": 30.00,
  "is_active": true,
  "created_at": "2024-01-15T11:00:00Z",
  "updated_at": "2024-01-15T11:15:00Z"
}
```

## Подписки

### Получение списка подписок пользователя

**Запрос:**
```bash
curl -X GET "http://localhost:8000/api/v1/subscriptions/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Ответ:**
```json
{
  "items": [
    {
      "id": 1,
      "product": {
        "id": 1,
        "name": "ChatGPT Pro",
        "category": "AI Chat"
      },
      "plan": {
        "id": 1,
        "name": "Месячный",
        "price": 20.00
      },
      "status": "active",
      "start_date": "2024-01-01T00:00:00Z",
      "end_date": "2024-01-31T23:59:59Z",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 1,
  "skip": 0,
  "limit": 10
}
```

### Создание подписки

**Запрос:**
```bash
curl -X POST "http://localhost:8000/api/v1/subscriptions/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 2,
    "plan_id": 1
  }'
```

**Ответ:**
```json
{
  "id": 2,
  "product": {
    "id": 2,
    "name": "Midjourney",
    "category": "Image Generation"
  },
  "plan": {
    "id": 1,
    "name": "Месячный",
    "price": 30.00
  },
  "status": "active",
  "start_date": "2024-01-15T12:00:00Z",
  "end_date": "2024-02-15T11:59:59Z",
  "created_at": "2024-01-15T12:00:00Z"
}
```

### Отмена подписки

**Запрос:**
```bash
curl -X DELETE "http://localhost:8000/api/v1/subscriptions/2" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Ответ:**
```json
{
  "id": 2,
  "status": "cancelled",
  "cancelled_at": "2024-01-15T12:30:00Z",
  "message": "Подписка успешно отменена"
}
```

### Проверка статуса подписки

**Запрос:**
```bash
curl -X GET "http://localhost:8000/api/v1/subscriptions/1/status" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Ответ:**
```json
{
  "subscription_id": 1,
  "status": "active",
  "days_remaining": 16,
  "is_expired": false,
  "can_renew": true,
  "next_billing_date": "2024-02-01T00:00:00Z"
}
```

## Администрирование

### Получение списка пользователей (требует роль admin/moderator)

**Запрос:**
```bash
curl -X GET "http://localhost:8000/api/v1/admin/users/?skip=0&limit=10" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Ответ:**
```json
{
  "items": [
    {
      "id": 1,
      "email": "user@example.com",
      "username": "testuser",
      "full_name": "Тестовый Пользователь",
      "is_active": true,
      "roles": ["user"],
      "created_at": "2024-01-15T10:30:00Z",
      "subscriptions_count": 1
    },
    {
      "id": 2,
      "email": "admin@example.com",
      "username": "admin",
      "full_name": "Администратор",
      "is_active": true,
      "roles": ["admin"],
      "created_at": "2024-01-01T00:00:00Z",
      "subscriptions_count": 0
    }
  ],
  "total": 2,
  "skip": 0,
  "limit": 10
}
```

### Назначение роли пользователю (только admin)

**Запрос:**
```bash
curl -X POST "http://localhost:8000/api/v1/admin/users/1/roles" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "role_name": "moderator"
  }'
```

**Ответ:**
```json
{
  "user_id": 1,
  "role_name": "moderator",
  "assigned_by": 2,
  "assigned_at": "2024-01-15T13:00:00Z",
  "message": "Роль moderator успешно назначена пользователю"
}
```

### Получение статистики системы (только admin)

**Запрос:**
```bash
curl -X GET "http://localhost:8000/api/v1/admin/stats" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Ответ:**
```json
{
  "users": {
    "total": 150,
    "active": 142,
    "new_this_month": 23
  },
  "subscriptions": {
    "total": 89,
    "active": 67,
    "expired": 22,
    "revenue_this_month": 2340.50
  },
  "products": {
    "total": 12,
    "active": 10
  },
  "system": {
    "uptime": "15 days, 8 hours",
    "database_size": "2.3 GB",
    "last_backup": "2024-01-15T02:00:00Z"
  }
}
```

## Обработка ошибок

### Ошибка аутентификации (401)

**Запрос:**
```bash
curl -X GET "http://localhost:8000/api/v1/auth/me"
```

**Ответ:**
```json
{
  "detail": "Not authenticated"
}
```

### Ошибка авторизации (403)

**Запрос:**
```bash
curl -X DELETE "http://localhost:8000/api/v1/products/1" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Ответ:**
```json
{
  "detail": "Недостаточно прав для выполнения операции"
}
```

### Ошибка валидации (422)

**Запрос:**
```bash
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invalid-email",
    "password": "123"
  }'
```

**Ответ:**
```json
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "value is not a valid email address",
      "type": "value_error.email"
    },
    {
      "loc": ["body", "password"],
      "msg": "ensure this value has at least 6 characters",
      "type": "value_error.any_str.min_length",
      "ctx": {"limit_value": 6}
    }
  ]
}
```

### Ошибка "не найдено" (404)

**Запрос:**
```bash
curl -X GET "http://localhost:8000/api/v1/products/999"
```

**Ответ:**
```json
{
  "detail": "Продукт с ID 999 не найден"
}
```

### Rate Limiting (429)

**Запрос:**
```bash
# Множественные запросы к одному эндпоинту
for i in {1..10}; do
  curl -X POST "http://localhost:8000/api/v1/auth/login" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=test&password=test"
done
```

**Ответ:**
```json
{
  "detail": "Too many requests. Please try again later."
}
```

## Переменные окружения

### Базовый URL

```bash
# Для локальной разработки
export API_BASE_URL="http://localhost:8000"

# Для продакшна
export API_BASE_URL="https://api.neurostore.com"
```

### Аутентификация

```bash
# Получение токена для использования в других запросах
TOKEN=$(curl -s -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=user@example.com&password=securepass123" \
  | jq -r '.access_token')

# Использование токена
curl -X GET "http://localhost:8000/api/v1/auth/me" \
  -H "Authorization: Bearer $TOKEN"
```

## Тестирование API

### Проверка доступности

```bash
# Health check
curl -X GET "http://localhost:8000/health"

# API версия
curl -X GET "http://localhost:8000/api/v1/version"
```

### Автоматизированное тестирование

```bash
# Запуск тестов API
pytest tests/test_api/ -v

# Тестирование конкретного эндпоинта
pytest tests/test_api/test_auth.py::test_login_success -v

# Тестирование с покрытием
pytest --cov=app --cov-report=html tests/
```
