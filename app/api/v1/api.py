"""
Основной API роутер для версии v1
"""

from fastapi import APIRouter

from app.api.v1.endpoints import auth, users, products, subscriptions, orders

api_router = APIRouter()

# Подключение эндпоинтов
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(products.router, prefix="/products", tags=["products"])
api_router.include_router(
    subscriptions.router, prefix="/subscriptions", tags=["subscriptions"]
)
api_router.include_router(orders.router, prefix="/orders", tags=["orders"])
