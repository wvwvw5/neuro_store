"""
Тесты системы аутентификации Neuro Store
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.models.user import User
from tests.conftest import create_test_user_data


class TestAuthentication:
    """Тесты аутентификации"""

    @pytest.mark.auth
    def test_register_success(self, client: TestClient, db_session: Session):
        """Тест успешной регистрации"""
        user_data = create_test_user_data("register@example.com")
        
        response = client.post("/api/v1/auth/register", json=user_data)
        
        assert response.status_code == 201
        data = response.json()
        assert data["email"] == user_data["email"]
        assert data["first_name"] == user_data["first_name"]
        assert data["last_name"] == user_data["last_name"]
        assert data["is_active"] is True
        assert "id" in data
        assert "password" not in data  # Пароль не должен возвращаться

    @pytest.mark.auth
    def test_register_duplicate_email(self, client: TestClient, test_user: User):
        """Тест регистрации с существующим email"""
        user_data = create_test_user_data(test_user.email)
        
        response = client.post("/api/v1/auth/register", json=user_data)
        
        assert response.status_code == 400
        error_data = response.json()
        assert "error" in error_data
        assert "уже существует" in error_data["error"]["message"]

    @pytest.mark.auth
    def test_register_invalid_email(self, client: TestClient):
        """Тест регистрации с невалидным email"""
        user_data = create_test_user_data("invalid-email")
        
        response = client.post("/api/v1/auth/register", json=user_data)
        
        assert response.status_code == 422
        error_data = response.json()
        assert "error" in error_data
        assert error_data["error"]["type"] == "ValidationError"

    @pytest.mark.auth
    def test_register_weak_password(self, client: TestClient):
        """Тест регистрации со слабым паролем"""
        user_data = create_test_user_data()
        user_data["password"] = "123"  # Слишком короткий
        
        response = client.post("/api/v1/auth/register", json=user_data)
        
        assert response.status_code == 422
        error_data = response.json()
        assert "error" in error_data

    @pytest.mark.auth
    def test_login_success(self, client: TestClient, test_user: User):
        """Тест успешного входа"""
        response = client.post(
            "/api/v1/auth/login",
            data={
                "username": test_user.email,
                "password": "testpass123"
            }
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"
        assert len(data["access_token"]) > 50  # JWT токен должен быть длинным

    @pytest.mark.auth
    def test_login_invalid_password(self, client: TestClient, test_user: User):
        """Тест входа с неверным паролем"""
        response = client.post(
            "/api/v1/auth/login",
            data={
                "username": test_user.email,
                "password": "wrongpassword"
            }
        )
        
        assert response.status_code == 401
        error_data = response.json()
        assert "error" in error_data
        assert "Неверный email или пароль" in error_data["error"]["message"]

    @pytest.mark.auth
    def test_login_nonexistent_user(self, client: TestClient):
        """Тест входа с несуществующим пользователем"""
        response = client.post(
            "/api/v1/auth/login",
            data={
                "username": "nonexistent@example.com",
                "password": "somepassword"
            }
        )
        
        assert response.status_code == 401
        error_data = response.json()
        assert "error" in error_data

    @pytest.mark.auth
    def test_get_current_user_success(self, client: TestClient, test_user: User, auth_headers: dict):
        """Тест получения информации о текущем пользователе"""
        response = client.get("/api/v1/auth/me", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["email"] == test_user.email
        assert data["first_name"] == test_user.first_name
        assert data["id"] == test_user.id

    @pytest.mark.auth
    def test_get_current_user_no_token(self, client: TestClient):
        """Тест получения пользователя без токена"""
        response = client.get("/api/v1/auth/me")
        
        assert response.status_code == 401
        error_data = response.json()
        assert "error" in error_data

    @pytest.mark.auth
    def test_get_current_user_invalid_token(self, client: TestClient):
        """Тест получения пользователя с невалидным токеном"""
        headers = {"Authorization": "bearer invalid_token"}
        response = client.get("/api/v1/auth/me", headers=headers)
        
        assert response.status_code == 401
        error_data = response.json()
        assert "error" in error_data

    @pytest.mark.auth
    def test_get_user_roles(self, client: TestClient, test_user: User, auth_headers: dict):
        """Тест получения ролей пользователя"""
        response = client.get("/api/v1/auth/me/roles", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert "roles" in data
        assert "is_admin" in data
        assert "is_moderator" in data
        assert data["user_id"] == test_user.id

    @pytest.mark.auth
    @pytest.mark.slow
    def test_rate_limiting_login(self, client: TestClient, test_user: User):
        """Тест rate limiting для входа (5 запросов в минуту)"""
        # Делаем несколько быстрых запросов
        for i in range(6):  # Больше лимита
            response = client.post(
                "/api/v1/auth/login",
                data={
                    "username": test_user.email,
                    "password": "wrongpassword"  # Неверный пароль
                }
            )
            
            if i < 5:
                # Первые 5 запросов должны проходить (но с ошибкой 401)
                assert response.status_code == 401
            else:
                # 6-й запрос должен быть заблокирован rate limiter
                assert response.status_code == 429  # Too Many Requests


class TestRoleBasedAccess:
    """Тесты ролевого доступа"""

    @pytest.mark.admin
    def test_admin_protected_route_success(self, client: TestClient, admin_headers: dict):
        """Тест доступа админа к защищенному эндпоинту"""
        response = client.get("/api/v1/admin/protected-route", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert "access_level" in data
        assert data["access_level"] == "admin"

    @pytest.mark.admin
    def test_admin_protected_route_forbidden(self, client: TestClient, auth_headers: dict):
        """Тест запрета доступа обычного пользователя к админ эндпоинту"""
        response = client.get("/api/v1/admin/protected-route", headers=auth_headers)
        
        assert response.status_code == 403
        error_data = response.json()
        assert "error" in error_data
        assert "Недостаточно прав" in error_data["error"]["message"]

    @pytest.mark.admin
    def test_admin_statistics(self, client: TestClient, admin_headers: dict):
        """Тест получения статистики админом"""
        response = client.get("/api/v1/admin/statistics", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert "users" in data
        assert "subscriptions" in data
        assert "orders" in data
        assert isinstance(data["users"]["total"], int)

    @pytest.mark.admin
    def test_admin_users_list(self, client: TestClient, admin_headers: dict, test_user: User):
        """Тест получения списка пользователей админом"""
        response = client.get("/api/v1/admin/users", headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) >= 1  # Должен быть хотя бы тестовый пользователь
