"""
Тесты управления продуктами Neuro Store
"""

import pytest
from fastapi.testclient import TestClient

from app.models.product import Product
from app.models.product_plan import ProductPlan
from tests.conftest import create_test_product_data


class TestProducts:
    """Тесты управления продуктами"""

    @pytest.mark.products
    def test_get_products_success(self, client: TestClient, test_product: Product):
        """Тест получения списка продуктов"""
        response = client.get("/api/v1/products/")
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) >= 1
        
        # Проверяем структуру продукта
        product = data[0]
        assert "id" in product
        assert "name" in product
        assert "description" in product
        assert "category" in product
        assert "is_active" in product

    @pytest.mark.products
    def test_get_product_by_id_success(self, client: TestClient, test_product: Product):
        """Тест получения продукта по ID"""
        response = client.get(f"/api/v1/products/{test_product.id}")
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == test_product.id
        assert data["name"] == test_product.name
        assert data["category"] == test_product.category

    @pytest.mark.products
    def test_get_product_by_id_not_found(self, client: TestClient):
        """Тест получения несуществующего продукта"""
        response = client.get("/api/v1/products/99999")
        
        assert response.status_code == 404
        error_data = response.json()
        assert "error" in error_data
        assert "не найден" in error_data["error"]["message"]

    @pytest.mark.products
    def test_get_product_plans_success(self, client: TestClient, test_product_plan: ProductPlan):
        """Тест получения планов для продукта"""
        response = client.get(f"/api/v1/products/{test_product_plan.product_id}/plans")
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) >= 1
        
        # Проверяем структуру плана
        plan = data[0]
        assert "id" in plan
        assert "name" in plan
        assert "price" in plan
        assert "duration_days" in plan

    @pytest.mark.products
    def test_get_product_plans_not_found(self, client: TestClient):
        """Тест получения планов для несуществующего продукта"""
        response = client.get("/api/v1/products/99999/plans")
        
        assert response.status_code == 404
        error_data = response.json()
        assert "error" in error_data

    @pytest.mark.products
    def test_create_product_admin_success(self, client: TestClient, admin_headers: dict):
        """Тест создания продукта админом"""
        product_data = create_test_product_data("New AI Product")
        
        response = client.post("/api/v1/products/", json=product_data, headers=admin_headers)
        
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == product_data["name"]
        assert data["description"] == product_data["description"]
        assert data["is_active"] is True

    @pytest.mark.products
    def test_create_product_user_forbidden(self, client: TestClient, auth_headers: dict):
        """Тест запрета создания продукта обычным пользователем"""
        product_data = create_test_product_data("Forbidden Product")
        
        response = client.post("/api/v1/products/", json=product_data, headers=auth_headers)
        
        assert response.status_code == 403
        error_data = response.json()
        assert "error" in error_data
        assert "Недостаточно прав" in error_data["error"]["message"]

    @pytest.mark.products
    def test_create_product_no_auth(self, client: TestClient):
        """Тест создания продукта без аутентификации"""
        product_data = create_test_product_data("Unauthorized Product")
        
        response = client.post("/api/v1/products/", json=product_data)
        
        assert response.status_code == 401
        error_data = response.json()
        assert "error" in error_data

    @pytest.mark.products
    def test_update_product_admin_success(self, client: TestClient, test_product: Product, admin_headers: dict):
        """Тест обновления продукта админом"""
        update_data = {
            "name": "Updated Product Name",
            "description": "Updated description"
        }
        
        response = client.put(f"/api/v1/products/{test_product.id}", json=update_data, headers=admin_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == update_data["name"]
        assert data["description"] == update_data["description"]

    @pytest.mark.products
    def test_update_product_user_forbidden(self, client: TestClient, test_product: Product, auth_headers: dict):
        """Тест запрета обновления продукта обычным пользователем"""
        update_data = {"name": "Forbidden Update"}
        
        response = client.put(f"/api/v1/products/{test_product.id}", json=update_data, headers=auth_headers)
        
        assert response.status_code == 403
        error_data = response.json()
        assert "error" in error_data

    @pytest.mark.products
    def test_delete_product_admin_success(self, client: TestClient, test_product: Product, admin_headers: dict):
        """Тест удаления (деактивации) продукта админом"""
        response = client.delete(f"/api/v1/products/{test_product.id}", headers=admin_headers)
        
        assert response.status_code == 204

    @pytest.mark.products
    def test_delete_product_user_forbidden(self, client: TestClient, test_product: Product, auth_headers: dict):
        """Тест запрета удаления продукта обычным пользователем"""
        response = client.delete(f"/api/v1/products/{test_product.id}", headers=auth_headers)
        
        assert response.status_code == 403
        error_data = response.json()
        assert "error" in error_data


class TestProductsCaching:
    """Тесты кэширования продуктов"""

    @pytest.mark.products
    @pytest.mark.integration
    def test_products_caching(self, client: TestClient, test_product: Product):
        """Тест кэширования списка продуктов"""
        # Первый запрос - данные загружаются из БД
        response1 = client.get("/api/v1/products/")
        assert response1.status_code == 200
        
        # Второй запрос - данные должны браться из кэша
        response2 = client.get("/api/v1/products/")
        assert response2.status_code == 200
        
        # Данные должны быть одинаковыми
        assert response1.json() == response2.json()

    @pytest.mark.products
    @pytest.mark.integration  
    def test_product_plans_caching(self, client: TestClient, test_product_plan: ProductPlan):
        """Тест кэширования планов продукта"""
        product_id = test_product_plan.product_id
        
        # Первый запрос
        response1 = client.get(f"/api/v1/products/{product_id}/plans")
        assert response1.status_code == 200
        
        # Второй запрос (из кэша)
        response2 = client.get(f"/api/v1/products/{product_id}/plans")
        assert response2.status_code == 200
        
        # Данные должны быть одинаковыми
        assert response1.json() == response2.json()


class TestProductsRateLimiting:
    """Тесты rate limiting для продуктов"""

    @pytest.mark.products
    @pytest.mark.slow
    def test_products_rate_limiting(self, client: TestClient, test_product: Product):
        """Тест rate limiting для эндпоинта продуктов"""
        # Делаем много запросов подряд
        responses = []
        for i in range(35):  # Больше лимита в 30 запросов
            response = client.get("/api/v1/products/")
            responses.append(response)
        
        # Проверяем, что некоторые запросы были заблокированы
        blocked_responses = [r for r in responses if r.status_code == 429]
        assert len(blocked_responses) > 0, "Rate limiting должен сработать"

    @pytest.mark.products
    def test_products_rate_limiting_different_endpoints(self, client: TestClient, test_product: Product):
        """Тест что rate limiting работает независимо для разных эндпоинтов"""
        # Запросы к разным эндпоинтам не должны влиять друг на друга
        response1 = client.get("/api/v1/products/")
        response2 = client.get(f"/api/v1/products/{test_product.id}")
        
        assert response1.status_code == 200
        assert response2.status_code == 200
