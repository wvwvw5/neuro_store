"""
Инициализация API для Neuro Store
"""

from fastapi import APIRouter
from app.api.v1 import auth, products, subscriptions, admin, payments, roles, api

# Создание основного роутера API
api_router = APIRouter()

# Подключение всех версий API
api_router.include_router(api.router, tags=["system"])
api_router.include_router(auth.router, tags=["authentication"])
api_router.include_router(products.router, tags=["products"])
api_router.include_router(subscriptions.router, tags=["subscriptions"])
api_router.include_router(admin.router, tags=["admin"])
api_router.include_router(payments.router, tags=["payments"])
api_router.include_router(roles.router, prefix="/roles", tags=["roles"])

# Экспорт основного роутера
__all__ = ["api_router"]
