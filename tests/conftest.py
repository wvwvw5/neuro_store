"""
Конфигурация тестов для Neuro Store
"""

import asyncio
from typing import AsyncGenerator, Generator

import fakeredis.aioredis as fakeredis
import pytest
import pytest_asyncio
from fastapi import FastAPI
from fastapi.testclient import TestClient
from httpx import AsyncClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.database import Base, get_db
from app.core.security import get_password_hash
from app.main import app
from app.models.plan import Plan
from app.models.product import Product
from app.models.product_plan import ProductPlan
from app.models.role import Role
from app.models.user import User
from app.models.user_role import UserRole

# Настройка тестовой базы данных в памяти
SQLALCHEMY_TEST_DATABASE_URL = "sqlite:///:memory:"

test_engine = create_engine(
    SQLALCHEMY_TEST_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
    echo=False,  # Отключаем SQL логи для тестов
)

TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


@pytest.fixture(scope="session")
def event_loop():
    """Создание event loop для всей сессии тестов"""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="function")
def db_session() -> Generator[Session, None, None]:
    """Создание тестовой сессии БД с откатом после каждого теста"""
    try:
        # Создаем таблицы
        Base.metadata.create_all(bind=test_engine)

        # Создаем сессию
        session = TestingSessionLocal()

        yield session
    except Exception as e:
        print(f"Error in db_session fixture: {e}")
        raise
    finally:
        try:
            session.close()
            # Очищаем таблицы после теста
            Base.metadata.drop_all(bind=test_engine)
        except Exception as e:
            print(f"Error cleaning up db_session fixture: {e}")
            # Не блокируем тесты при ошибках очистки


@pytest.fixture(scope="function")
def override_get_db(db_session: Session):
    """Переопределение зависимости get_db для тестов"""

    def _override_get_db():
        try:
            yield db_session
        except Exception as e:
            print(f"Error in override_get_db: {e}")
            raise
        finally:
            pass

    return _override_get_db


@pytest.fixture(scope="function")
def test_app(override_get_db, override_get_redis, override_get_limiter):
    """Создание тестового приложения"""
    from app.services.cache import get_redis
    from app.core.limiter import get_limiter
    from app.main import create_application
    
    # Создаем новое приложение для тестов без инициализации внешних сервисов
    test_app = create_application()
    
    # Переопределяем зависимости
    test_app.dependency_overrides[get_db] = override_get_db
    test_app.dependency_overrides[get_redis] = override_get_redis
    test_app.dependency_overrides[get_limiter] = override_get_limiter
    
    yield test_app
    test_app.dependency_overrides.clear()


@pytest.fixture(scope="function")
def client(test_app: FastAPI) -> Generator[TestClient, None, None]:
    """Создание синхронного тестового клиента"""
    with TestClient(test_app) as test_client:
        yield test_client


@pytest_asyncio.fixture(scope="function")
async def async_client(test_app: FastAPI) -> AsyncGenerator[AsyncClient, None]:
    """Создание асинхронного тестового клиента"""
    async with AsyncClient(app=test_app, base_url="http://test") as ac:
        yield ac


@pytest.fixture(scope="function")
def fake_redis():
    """Создание fake Redis для тестов"""
    return fakeredis.FakeRedis()

@pytest.fixture(scope="function")
def override_get_redis(fake_redis):
    """Переопределение зависимости get_redis для тестов"""
    from app.services.cache import get_redis
    
    async def _override_get_redis():
        return fake_redis
    
    return _override_get_redis

@pytest.fixture(scope="function")
def override_get_limiter():
    """Переопределение зависимости get_limiter для тестов"""
    
    async def _override_get_limiter():
        # Возвращаем заглушку вместо rate limiter
        class MockRateLimiter:
            def __init__(self):
                pass
            
            async def __call__(self, request):
                return True  # Всегда разрешаем
        
        return MockRateLimiter()
    
    return _override_get_limiter


@pytest.fixture(scope="function")
def test_user(db_session: Session) -> User:
    """Создание тестового пользователя"""
    try:
        user = User(
            email="test@example.com",
            password_hash=get_password_hash("testpass123"),
            first_name="Тест",
            last_name="Пользователь",
            balance=1000.00,
            is_active=True,
            is_verified=True,
        )
        db_session.add(user)
        db_session.commit()
        db_session.refresh(user)
        return user
    except Exception as e:
        print(f"Error creating test_user: {e}")
        db_session.rollback()
        raise


@pytest.fixture(scope="function")
def test_admin(db_session: Session) -> User:
    """Создание тестового администратора"""
    try:
        # Создаем роль админа
        admin_role = Role(name="admin", description="Администратор системы", is_active=True)
        db_session.add(admin_role)
        db_session.flush()

        # Создаем пользователя-админа
        admin_user = User(
            email="admin@example.com",
            password_hash=get_password_hash("adminpass123"),
            first_name="Админ",
            last_name="Тестовый",
            balance=10000.00,
            is_active=True,
            is_verified=True,
        )
        db_session.add(admin_user)
        db_session.flush()

        # Назначаем роль
        user_role = UserRole(user_id=admin_user.id, role_id=admin_role.id)
        db_session.add(user_role)
        db_session.commit()

        db_session.refresh(admin_user)
        return admin_user
    except Exception as e:
        print(f"Error creating test_admin: {e}")
        db_session.rollback()
        raise


@pytest.fixture(scope="function")
def test_product(db_session: Session) -> Product:
    """Создание тестового продукта"""
    try:
        product = Product(
            name="Test AI",
            description="Тестовая нейросеть",
            category="Тестирование",
            api_endpoint="https://api.test.com/v1/test",
            is_active=True,
        )
        db_session.add(product)
        db_session.commit()
        db_session.refresh(product)
        return product
    except Exception as e:
        print(f"Error creating test_product: {e}")
        db_session.rollback()
        raise


@pytest.fixture(scope="function")
def test_plan(db_session: Session) -> Plan:
    """Создание тестового плана"""
    plan = Plan(
        name="Тестовый план",
        description="План для тестирования",
        price=99.99,
        duration_days=30,
        max_requests_per_month=100,
        features="Тестовые функции",
        is_active=True,
    )
    db_session.add(plan)
    db_session.commit()
    db_session.refresh(plan)
    return plan


@pytest.fixture(scope="function")
def test_product_plan(
    db_session: Session, test_product: Product, test_plan: Plan
) -> ProductPlan:
    """Создание связи продукт-план для тестов"""
    product_plan = ProductPlan(
        product_id=test_product.id, plan_id=test_plan.id, is_available=True
    )
    db_session.add(product_plan)
    db_session.commit()
    db_session.refresh(product_plan)
    return product_plan


@pytest.fixture(scope="function")
def auth_token(client: TestClient, test_user: User) -> str:
    """Получение токена аутентификации для тестового пользователя"""
    response = client.post(
        "/api/v1/auth/login",
        data={"username": test_user.email, "password": "testpass123"},
    )
    assert response.status_code == 200
    token_data = response.json()
    return token_data["access_token"]


@pytest.fixture(scope="function")
def admin_token(client: TestClient, test_admin: User) -> str:
    """Получение токена аутентификации для тестового админа"""
    response = client.post(
        "/api/v1/auth/login",
        data={"username": test_admin.email, "password": "adminpass123"},
    )
    assert response.status_code == 200
    token_data = response.json()
    return token_data["access_token"]


@pytest.fixture(scope="function")
def auth_headers(auth_token: str) -> dict:
    """Заголовки аутентификации для тестов"""
    return {"Authorization": f"bearer {auth_token}"}


@pytest.fixture(scope="function")
def admin_headers(admin_token: str) -> dict:
    """Заголовки аутентификации для админа"""
    return {"Authorization": f"bearer {admin_token}"}


# Хелперы для создания тестовых данных


def create_test_user_data(email: str = "newuser@example.com") -> dict:
    """Создание данных для тестового пользователя"""
    return {
        "email": email,
        "password": "newpass123",
        "first_name": "Новый",
        "last_name": "Пользователь",
        "phone": "+7 (999) 123-45-67",
    }


def create_test_product_data(name: str = "Test Product") -> dict:
    """Создание данных для тестового продукта"""
    return {
        "name": name,
        "description": "Описание тестового продукта",
        "category": "Тестирование",
        "api_endpoint": "https://api.test.com/v1/endpoint",
    }


def create_test_subscription_data(product_id: int, plan_id: int) -> dict:
    """Создание данных для тестовой подписки"""
    return {"product_id": product_id, "plan_id": plan_id}
