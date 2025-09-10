# Ролевая модель и разграничение доступа (RBAC)

## Навигация
- [Обзор ролей](#обзор-ролей)
- [Матрица доступа](#матрица-доступа)
- [Реализация в коде](#реализация-в-коде)
- [Модель данных](#модель-данных)
- [Примеры использования](#примеры-использования)

## Обзор ролей

### Роли пользователей

| Роль | Описание | Уровень доступа |
|------|----------|-----------------|
| `admin` | Администратор системы | Полный доступ ко всем функциям |
| `moderator` | Модератор контента | Управление продуктами, модерация пользователей |
| `user` | Обычный пользователь | Просмотр продуктов, управление подписками |
| `viewer` | Просмотрщик | Только чтение публичной информации |

### Иерархия ролей

```
admin (высший уровень)
├── moderator (управление контентом)
├── user (полный функционал)
└── viewer (только чтение)
```

## Матрица доступа

### Эндпоинты API

| Эндпоинт | Метод | admin | moderator | user | viewer | Гость |
|-----------|-------|-------|-----------|------|--------|-------|
| `/api/v1/auth/register` | POST | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/api/v1/auth/login` | POST | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/api/v1/auth/me` | GET | ✅ | ✅ | ✅ | ✅ | ❌ |
| `/api/v1/auth/refresh` | POST | ✅ | ✅ | ✅ | ✅ | ❌ |
| `/api/v1/products/` | GET | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/api/v1/products/{id}` | GET | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/api/v1/products/` | POST | ✅ | ✅ | ❌ | ❌ | ❌ |
| `/api/v1/products/{id}` | PUT | ✅ | ✅ | ❌ | ❌ | ❌ |
| `/api/v1/products/{id}` | DELETE | ✅ | ❌ | ❌ | ❌ | ❌ |
| `/api/v1/subscriptions/` | GET | ✅ | ✅ | ✅ | ❌ | ❌ |
| `/api/v1/subscriptions/` | POST | ✅ | ✅ | ✅ | ❌ | ❌ |
| `/api/v1/subscriptions/{id}` | PUT | ✅ | ✅ | ✅* | ❌ | ❌ |
| `/api/v1/subscriptions/{id}` | DELETE | ✅ | ✅ | ✅* | ❌ | ❌ |
| `/api/v1/admin/users/` | GET | ✅ | ✅ | ❌ | ❌ | ❌ |
| `/api/v1/admin/users/{id}` | PUT | ✅ | ✅ | ❌ | ❌ | ❌ |
| `/api/v1/admin/roles/` | GET | ✅ | ❌ | ❌ | ❌ | ❌ |
| `/api/v1/admin/roles/` | POST | ✅ | ❌ | ❌ | ❌ | ❌ |

*Только для собственных подписок

### Операции с данными

| Операция | admin | moderator | user | viewer |
|----------|-------|-----------|------|--------|
| **Пользователи** | | | | |
| Создание | ✅ | ✅ | ❌ | ❌ |
| Чтение | ✅ | ✅ | Свой профиль | ❌ |
| Обновление | ✅ | ✅ | Свой профиль | ❌ |
| Удаление | ✅ | ❌ | ❌ | ❌ |
| **Продукты** | | | | |
| Создание | ✅ | ✅ | ❌ | ❌ |
| Чтение | ✅ | ✅ | ✅ | ✅ |
| Обновление | ✅ | ✅ | ❌ | ❌ |
| Удаление | ✅ | ❌ | ❌ | ❌ |
| **Подписки** | | | | |
| Создание | ✅ | ✅ | ✅ | ❌ |
| Чтение | ✅ | ✅ | Свои | ❌ |
| Обновление | ✅ | ✅ | Свои | ❌ |
| Отмена | ✅ | ✅ | Свои | ❌ |
| **Роли** | | | | |
| Назначение | ✅ | ✅ | ❌ | ❌ |
| Управление | ✅ | ❌ | ❌ | ❌ |

## Реализация в коде

### Проверка ролей на уровне FastAPI

#### 1. Dependency для проверки аутентификации

```python
# app/api/deps.py
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer
from app.core.security import decode_access_token
from app.models.user import User

security = HTTPBearer()

async def get_current_user(token: str = Depends(security)) -> User:
    """Получение текущего пользователя из JWT токена"""
    try:
        payload = decode_access_token(token)
        user_id: int = payload.get("sub")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Неверный токен аутентификации"
            )
        user = get_user_by_id(user_id)
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Пользователь не найден"
            )
        return user
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Неверный токен аутентификации"
        )
```

#### 2. Dependency для проверки ролей

```python
# app/api/deps.py
from app.dependencies.roles import require_role
from app.models.role import Role

def require_role(required_role: str):
    """Декоратор для проверки роли пользователя"""
    async def role_checker(current_user: User = Depends(get_current_user)):
        if not check_role_permission(current_user, required_role):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Недостаточно прав для выполнения операции"
            )
        return current_user
    return role_checker

def require_any_role(required_roles: List[str]):
    """Декоратор для проверки любой из ролей"""
    async def role_checker(current_user: User = Depends(get_current_user)):
        for role in required_roles:
            if check_role_permission(current_user, role):
                return current_user
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Недостаточно прав для выполнения операции"
        )
    return role_checker
```

#### 3. Использование в эндпоинтах

```python
# app/api/v1/products.py
from app.api.deps import require_role, require_any_role

@router.post("/", response_model=ProductResponse)
async def create_product(
    product: ProductCreate,
    current_user: User = Depends(require_any_role(["admin", "moderator"]))
):
    """Создание нового продукта (только admin/moderator)"""
    return await product_service.create_product(product, current_user.id)

@router.delete("/{product_id}")
async def delete_product(
    product_id: int,
    current_user: User = Depends(require_role("admin"))
):
    """Удаление продукта (только admin)"""
    return await product_service.delete_product(product_id)

@router.get("/", response_model=List[ProductResponse])
async def get_products(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_user)  # Любой аутентифицированный
):
    """Получение списка продуктов"""
    return await product_service.get_products(skip=skip, limit=limit)
```

### Проверка разрешений в сервисах

```python
# app/services/product_service.py
from app.dependencies.roles import check_user_permissions

class ProductService:
    async def update_product(
        self, 
        product_id: int, 
        product_data: ProductUpdate, 
        current_user: User
    ) -> Product:
        """Обновление продукта с проверкой прав"""
        product = await self.get_product(product_id)
        
        # Проверяем права на обновление
        if not self._can_update_product(current_user, product):
            raise PermissionError("Недостаточно прав для обновления продукта")
        
        return await self._update_product(product_id, product_data)
    
    def _can_update_product(self, user: User, product: Product) -> bool:
        """Проверка прав на обновление продукта"""
        # Admin может обновлять все
        if user.has_role("admin"):
            return True
        
        # Moderator может обновлять все
        if user.has_role("moderator"):
            return True
        
        # User может обновлять только свои продукты
        if user.has_role("user") and product.owner_id == user.id:
            return True
        
        return False
```

## Модель данных для ролей

### Структура таблиц

```sql
-- Таблица ролей
CREATE TABLE roles (
    id BIGINT PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permissions JSONB,  -- Детальные разрешения
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица связи пользователей и ролей (М:М)
CREATE TABLE user_roles (
    id BIGINT PRIMARY KEY AUTOINCREMENT,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    role_id BIGINT REFERENCES roles(id) ON DELETE CASCADE,
    assigned_by BIGINT REFERENCES users(id),  -- Кем назначена роль
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,  -- Время истечения роли
    UNIQUE(user_id, role_id)
);

-- Таблица пользователей
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTOINCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Назначение ролей

```python
# app/services/role_service.py
class RoleService:
    async def assign_role(
        self, 
        user_id: int, 
        role_name: str, 
        assigned_by: User
    ) -> UserRole:
        """Назначение роли пользователю"""
        # Проверяем права на назначение ролей
        if not assigned_by.has_role("admin") and not assigned_by.has_role("moderator"):
            raise PermissionError("Недостаточно прав для назначения ролей")
        
        # Проверяем, что роль существует
        role = await self.get_role_by_name(role_name)
        if not role:
            raise ValueError(f"Роль '{role_name}' не найдена")
        
        # Проверяем ограничения на назначение ролей
        if role_name == "admin" and not assigned_by.has_role("admin"):
            raise PermissionError("Только admin может назначать роль admin")
        
        # Создаем связь пользователь-роль
        user_role = UserRole(
            user_id=user_id,
            role_id=role.id,
            assigned_by=assigned_by.id
        )
        
        return await self.create_user_role(user_role)
    
    async def revoke_role(
        self, 
        user_id: int, 
        role_name: str, 
        revoked_by: User
    ) -> bool:
        """Отзыв роли у пользователя"""
        # Проверяем права на отзыв ролей
        if not revoked_by.has_role("admin"):
            raise PermissionError("Только admin может отзывать роли")
        
        # Проверяем, что пользователь имеет эту роль
        user_role = await self.get_user_role(user_id, role_name)
        if not user_role:
            raise ValueError(f"Пользователь не имеет роль '{role_name}'")
        
        # Отзываем роль
        return await self.delete_user_role(user_role.id)
```

## Примеры использования

### Проверка ролей в шаблонах

```python
# В FastAPI эндпоинтах
@router.get("/admin/dashboard")
async def admin_dashboard(
    current_user: User = Depends(require_role("admin"))
):
    """Панель администратора"""
    return {"message": "Добро пожаловать в панель администратора"}

@router.post("/moderate/content")
async def moderate_content(
    content_id: int,
    action: str,
    current_user: User = Depends(require_any_role(["admin", "moderator"]))
):
    """Модерация контента"""
    return await moderation_service.moderate_content(content_id, action, current_user)
```

### Проверка прав в бизнес-логике

```python
# В сервисах
async def process_subscription_cancellation(
    subscription_id: int, 
    user: User
) -> bool:
    """Отмена подписки с проверкой прав"""
    subscription = await subscription_service.get_subscription(subscription_id)
    
    # Проверяем права на отмену
    if not can_cancel_subscription(user, subscription):
        raise PermissionError("Недостаточно прав для отмены подписки")
    
    return await subscription_service.cancel_subscription(subscription_id)
```

### Логирование действий с ролями

```python
# Аудит действий с ролями
async def log_role_assignment(
    user_id: int, 
    role_name: str, 
    assigned_by: int
):
    """Логирование назначения роли"""
    await audit_service.log_action(
        action="role_assigned",
        user_id=assigned_by,
        target_user_id=user_id,
        details={
            "role": role_name,
            "timestamp": datetime.utcnow().isoformat()
        }
    )
```
