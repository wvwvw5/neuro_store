"""
Базовые тесты для проверки работоспособности системы
"""

import pytest
from fastapi.testclient import TestClient

from app.main import app


def test_app_creation():
    """Тест создания приложения"""
    assert app is not None

    assert app.title == "Neuro Store"


def test_health_check(client: TestClient):
    """Тест проверки здоровья приложения"""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_docs_available(client: TestClient):
    """Тест доступности документации"""
    response = client.get("/docs")
    assert response.status_code == 200


def test_openapi_schema(client: TestClient):
    """Тест доступности OpenAPI схемы"""
    response = client.get("/openapi.json")
    assert response.status_code == 200
    assert "openapi" in response.json()


@pytest.mark.asyncio
async def test_fake_redis(fake_redis):
    """Тест fake Redis"""
    # Проверяем, что fake Redis работает
    await fake_redis.set("test_key", "test_value")
    value = await fake_redis.get("test_key")
    assert value == b"test_value"


def test_database_connection(db_session):
    """Тест подключения к тестовой базе данных"""
    # Простая проверка, что сессия работает
    assert db_session is not None
    # Проверяем, что можем выполнить простой запрос
    from sqlalchemy import text
    result = db_session.execute(text("SELECT 1"))
    assert result.scalar() == 1
