"""
Тесты системы подписок Neuro Store
"""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.models.user import User
from app.models.product import Product
from app.models.plan import Plan
from app.models.product_plan import ProductPlan
from app.models.subscription import Subscription
from tests.conftest import create_test_subscription_data


class TestSubscriptions:
    """Тесты управления подписками"""

    @pytest.mark.subscriptions
    def test_get_subscriptions_success(self, client: TestClient, auth_headers: dict):
        """Тест получения списка подписок пользователя"""
        response = client.get("/api/v1/subscriptions/", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    @pytest.mark.subscriptions
    def test_get_subscriptions_no_auth(self, client: TestClient):
        """Тест получения подписок без аутентификации"""
        response = client.get("/api/v1/subscriptions/")
        
        assert response.status_code == 401
        error_data = response.json()
        assert "error" in error_data

    @pytest.mark.subscriptions
    def test_create_subscription_success(self, 
                                       client: TestClient, 
                                       auth_headers: dict,
                                       test_user: User,
                                       test_product_plan: ProductPlan,
                                       db_session: Session):
        """Тест создания подписки"""
        # Убеждаемся, что у пользователя достаточно средств
        test_user.balance = 1000.00
        db_session.commit()
        
        subscription_data = create_test_subscription_data(
            test_product_plan.product_id,
            test_product_plan.plan_id
        )
        
        response = client.post("/api/v1/subscriptions/", json=subscription_data, headers=auth_headers)
        
        assert response.status_code == 201
        data = response.json()
        assert data["product_id"] == subscription_data["product_id"]
        assert data["plan_id"] == subscription_data["plan_id"]
        assert data["status"] == "active"
        assert "start_date" in data
        assert "end_date" in data

    @pytest.mark.subscriptions
    def test_create_subscription_insufficient_balance(self,
                                                    client: TestClient,
                                                    auth_headers: dict,
                                                    test_user: User,
                                                    test_product_plan: ProductPlan,
                                                    db_session: Session):
        """Тест создания подписки с недостаточным балансом"""
        # Устанавливаем недостаточный баланс
        test_user.balance = 0.00
        db_session.commit()
        
        subscription_data = create_test_subscription_data(
            test_product_plan.product_id,
            test_product_plan.plan_id
        )
        
        response = client.post("/api/v1/subscriptions/", json=subscription_data, headers=auth_headers)
        
        assert response.status_code == 400
        error_data = response.json()
        assert "error" in error_data
        assert "Недостаточно средств" in error_data["error"]["message"]

    @pytest.mark.subscriptions
    def test_create_subscription_invalid_product(self, client: TestClient, auth_headers: dict):
        """Тест создания подписки с несуществующим продуктом"""
        subscription_data = {
            "product_id": 99999,
            "plan_id": 1
        }
        
        response = client.post("/api/v1/subscriptions/", json=subscription_data, headers=auth_headers)
        
        assert response.status_code == 404
        error_data = response.json()
        assert "error" in error_data

    @pytest.mark.subscriptions
    def test_create_subscription_no_auth(self, client: TestClient, test_product_plan: ProductPlan):
        """Тест создания подписки без аутентификации"""
        subscription_data = create_test_subscription_data(
            test_product_plan.product_id,
            test_product_plan.plan_id
        )
        
        response = client.post("/api/v1/subscriptions/", json=subscription_data)
        
        assert response.status_code == 401
        error_data = response.json()
        assert "error" in error_data

    @pytest.mark.subscriptions
    def test_get_subscription_by_id_success(self,
                                          client: TestClient,
                                          auth_headers: dict,
                                          test_user: User,
                                          test_product_plan: ProductPlan,
                                          db_session: Session):
        """Тест получения подписки по ID"""
        # Создаем тестовую подписку
        subscription = Subscription(
            user_id=test_user.id,
            product_id=test_product_plan.product_id,
            plan_id=test_product_plan.plan_id,
            status="active",
            start_date="2025-01-01T00:00:00Z",
            end_date="2025-02-01T00:00:00Z",
            auto_renew=True,
            requests_used=0
        )
        db_session.add(subscription)
        db_session.commit()
        db_session.refresh(subscription)
        
        response = client.get(f"/api/v1/subscriptions/{subscription.id}", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == subscription.id
        assert data["user_id"] == test_user.id
        assert data["status"] == "active"

    @pytest.mark.subscriptions
    def test_get_subscription_other_user_forbidden(self,
                                                 client: TestClient,
                                                 auth_headers: dict,
                                                 test_product_plan: ProductPlan,
                                                 db_session: Session):
        """Тест запрета доступа к чужой подписке"""
        # Создаем подписку для другого пользователя
        other_user = User(
            email="other@example.com",
            password_hash="hash",
            first_name="Другой",
            last_name="Пользователь"
        )
        db_session.add(other_user)
        db_session.flush()
        
        subscription = Subscription(
            user_id=other_user.id,
            product_id=test_product_plan.product_id,
            plan_id=test_product_plan.plan_id,
            status="active",
            start_date="2025-01-01T00:00:00Z",
            end_date="2025-02-01T00:00:00Z"
        )
        db_session.add(subscription)
        db_session.commit()
        
        response = client.get(f"/api/v1/subscriptions/{subscription.id}", headers=auth_headers)
        
        assert response.status_code == 404  # Не найдена для текущего пользователя
        error_data = response.json()
        assert "error" in error_data

    @pytest.mark.subscriptions
    def test_cancel_subscription_success(self,
                                       client: TestClient,
                                       auth_headers: dict,
                                       test_user: User,
                                       test_product_plan: ProductPlan,
                                       db_session: Session):
        """Тест отмены подписки"""
        # Создаем активную подписку
        subscription = Subscription(
            user_id=test_user.id,
            product_id=test_product_plan.product_id,
            plan_id=test_product_plan.plan_id,
            status="active",
            start_date="2025-01-01T00:00:00Z",
            end_date="2025-02-01T00:00:00Z",
            auto_renew=True
        )
        db_session.add(subscription)
        db_session.commit()
        db_session.refresh(subscription)
        
        response = client.put(f"/api/v1/subscriptions/{subscription.id}/cancel", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "cancelled"
        assert data["auto_renew"] is False

    @pytest.mark.subscriptions
    def test_cancel_subscription_already_cancelled(self,
                                                 client: TestClient,
                                                 auth_headers: dict,
                                                 test_user: User,
                                                 test_product_plan: ProductPlan,
                                                 db_session: Session):
        """Тест отмены уже отмененной подписки"""
        # Создаем отмененную подписку
        subscription = Subscription(
            user_id=test_user.id,
            product_id=test_product_plan.product_id,
            plan_id=test_product_plan.plan_id,
            status="cancelled",
            start_date="2025-01-01T00:00:00Z",
            end_date="2025-02-01T00:00:00Z"
        )
        db_session.add(subscription)
        db_session.commit()
        
        response = client.put(f"/api/v1/subscriptions/{subscription.id}/cancel", headers=auth_headers)
        
        assert response.status_code == 400
        error_data = response.json()
        assert "error" in error_data
        assert "неактивна" in error_data["error"]["message"]

    @pytest.mark.subscriptions
    def test_get_subscription_status_success(self,
                                           client: TestClient,
                                           auth_headers: dict,
                                           test_user: User,
                                           test_product_plan: ProductPlan,
                                           db_session: Session):
        """Тест получения статуса подписки"""
        subscription = Subscription(
            user_id=test_user.id,
            product_id=test_product_plan.product_id,
            plan_id=test_product_plan.plan_id,
            status="active",
            start_date="2025-01-01T00:00:00Z",
            end_date="2025-02-01T00:00:00Z",
            requests_used=25
        )
        db_session.add(subscription)
        db_session.commit()
        
        response = client.get(f"/api/v1/subscriptions/{subscription.id}/status", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == subscription.id
        assert data["status"] == "active"
        assert "days_left" in data
        assert data["requests_used"] == 25


class TestSubscriptionsRateLimiting:
    """Тесты rate limiting для подписок"""

    @pytest.mark.subscriptions
    @pytest.mark.slow
    def test_subscriptions_rate_limiting(self, client: TestClient, auth_headers: dict):
        """Тест rate limiting для эндпоинта подписок (10 запросов в минуту)"""
        # Делаем много запросов подряд
        responses = []
        for i in range(12):  # Больше лимита в 10 запросов
            response = client.get("/api/v1/subscriptions/", headers=auth_headers)
            responses.append(response)
        
        # Проверяем, что некоторые запросы были заблокированы
        blocked_responses = [r for r in responses if r.status_code == 429]
        success_responses = [r for r in responses if r.status_code == 200]
        
        assert len(success_responses) <= 10, "Не более 10 успешных запросов"
        assert len(blocked_responses) >= 1, "Должны быть заблокированные запросы"
