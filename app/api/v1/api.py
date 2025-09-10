"""
Системные API эндпоинты
"""

import time
from fastapi import APIRouter
from app.core.config import settings

router = APIRouter()


@router.get(
    "/health",
    summary="Проверка здоровья API v1",
    description="Проверка состояния API версии 1",
    tags=["Мониторинг"],
)
async def api_health_check():
    """Проверка здоровья API v1"""
    return {
        "status": "healthy",
        "api_version": "v1",
        "timestamp": time.time(),
        "endpoints": {
            "auth": "✅ Доступна",
            "products": "✅ Доступна",
            "subscriptions": "✅ Доступна",
            "admin": "✅ Доступна",
            "roles": "✅ Доступна",
            "payments": "✅ Доступна",
        },
    }
