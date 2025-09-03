"""
Конфигурация rate limiting для Neuro Store API
"""

import redis.asyncio as redis
from fastapi import Request
from fastapi_limiter import FastAPILimiter
from fastapi_limiter.depends import RateLimiter

from app.core.config import settings
from app.core.logging_config import get_logger

logger = get_logger("neuro_store.limiter")


async def init_limiter() -> None:
    """Инициализация rate limiter с Redis"""
    try:
        # Подключаемся к Redis
        redis_client = redis.from_url(
            settings.REDIS_URL, encoding="utf-8", decode_responses=True
        )

        # Проверяем подключение
        await redis_client.ping()

        # Инициализируем FastAPILimiter
        await FastAPILimiter.init(redis_client)

        logger.info(
            "Rate limiter initialized successfully", redis_url=settings.REDIS_URL
        )

    except Exception as e:
        logger.error("Failed to initialize rate limiter", error=str(e))
        raise


async def close_limiter() -> None:
    """Закрытие rate limiter"""
    try:
        await FastAPILimiter.close()
        logger.info("Rate limiter closed successfully")
    except Exception as e:
        logger.error("Failed to close rate limiter", error=str(e))


def get_client_ip(request: Request) -> str:
    """Получение IP адреса клиента для rate limiting"""
    # Проверяем заголовки прокси
    forwarded_for = request.headers.get("X-Forwarded-For")
    if forwarded_for:
        return forwarded_for.split(",")[0].strip()

    real_ip = request.headers.get("X-Real-IP")
    if real_ip:
        return real_ip

    # Возвращаем IP из соединения
    if hasattr(request.client, "host"):
        return request.client.host

    return "unknown"


def create_rate_limiter(times: int, seconds: int, identifier_func=None):
    """Создание rate limiter с кастомными параметрами"""
    if identifier_func is None:
        identifier_func = get_client_ip

    return RateLimiter(times=times, seconds=seconds, identifier=identifier_func)


# Предустановленные лимитеры для разных эндпоинтов
def get_default_limiter():
    """Стандартный лимитер (20 запросов в минуту)"""
    return create_rate_limiter(times=20, seconds=60)


def get_auth_limiter():
    """Лимитер для аутентификации (5 запросов в минуту)"""
    return create_rate_limiter(times=5, seconds=60)


def get_register_limiter():
    """Лимитер для регистрации (3 запроса в минуту)"""
    return create_rate_limiter(times=3, seconds=60)


def get_products_limiter():
    """Лимитер для продуктов (30 запросов в минуту)"""
    return create_rate_limiter(times=30, seconds=60)


def get_subscriptions_limiter():
    """Лимитер для подписок (10 запросов в минуту)"""
    return create_rate_limiter(times=10, seconds=60)


def parse_rate_limit(rate_limit_str: str) -> tuple[int, int]:
    """Парсинг строки rate limit в формате '20/minute' или '5/hour'"""
    try:
        times_str, period_str = rate_limit_str.split("/")
        times = int(times_str)

        if period_str == "second":
            seconds = 1
        elif period_str == "minute":
            seconds = 60
        elif period_str == "hour":
            seconds = 3600
        elif period_str == "day":
            seconds = 86400
        else:
            # По умолчанию считаем минуты
            seconds = 60

        return times, seconds
    except (ValueError, AttributeError):
        # Возвращаем значения по умолчанию
        return 20, 60


def get_limiter_from_settings(setting_name: str, default: str = "20/minute"):
    """Создание лимитера из настроек"""
    rate_limit_str = getattr(settings, setting_name, default)
    times, seconds = parse_rate_limit(rate_limit_str)
    return create_rate_limiter(times=times, seconds=seconds)


async def get_limiter():
    """Получение rate limiter для dependency injection"""
    # Возвращаем стандартный лимитер
    return get_default_limiter()
