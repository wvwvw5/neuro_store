"""
Сервис кэширования для Neuro Store API
"""

import json
import functools
from typing import Optional, Callable

import redis.asyncio as redis

from app.core.config import settings
from app.core.logging_config import get_logger

logger = get_logger("neuro_store.cache")

# Глобальная переменная для Redis клиента
redis_client: Optional[redis.Redis] = None


async def init_cache() -> None:
    """Инициализация подключения к Redis для кэширования"""
    global redis_client

    try:
        redis_client = redis.from_url(
            settings.REDIS_URL, encoding="utf-8", decode_responses=True
        )

        # Проверяем подключение
        await redis_client.ping()

        logger.info(
            "Cache service initialized successfully", redis_url=settings.REDIS_URL
        )

    except Exception as e:
        logger.error("Failed to initialize cache service", error=str(e))
        redis_client = None
        raise


async def close_cache() -> None:
    """Закрытие подключения к Redis"""
    global redis_client

    if redis_client:
        try:
            await redis_client.close()
            logger.info("Cache service closed successfully")
        except Exception as e:
            logger.error("Failed to close cache service", error=str(e))
        finally:
            redis_client = None


async def get_cache(key: str) -> Optional[str]:
    """Получение значения из кэша"""
    if not redis_client:
        return None

    try:
        value = await redis_client.get(key)
        if value:
            logger.debug("Cache hit", key=key)
            return value
        else:
            logger.debug("Cache miss", key=key)
            return None
    except Exception as e:
        logger.error("Cache get error", key=key, error=str(e))
        return None


async def set_cache(key: str, value: str, ttl: int = None) -> bool:
    """Сохранение значения в кэш"""
    if not redis_client:
        return False

    try:
        if ttl:
            await redis_client.setex(key, ttl, value)
        else:
            await redis_client.set(key, value)

        logger.debug("Cache set", key=key, ttl=ttl)
        return True
    except Exception as e:
        logger.error("Cache set error", key=key, error=str(e))
        return False


async def delete_cache(key: str) -> bool:
    """Удаление значения из кэша"""
    if not redis_client:
        return False

    try:
        result = await redis_client.delete(key)
        logger.debug("Cache delete", key=key, deleted=bool(result))
        return bool(result)
    except Exception as e:
        logger.error("Cache delete error", key=key, error=str(e))
        return False


async def delete_cache_pattern(pattern: str) -> int:
    """Удаление всех ключей по паттерну"""
    if not redis_client:
        return 0

    try:
        keys = await redis_client.keys(pattern)
        if keys:
            result = await redis_client.delete(*keys)
            logger.info("Cache pattern delete", pattern=pattern, deleted_count=result)
            return result
        return 0
    except Exception as e:
        logger.error("Cache pattern delete error", pattern=pattern, error=str(e))
        return 0


def generate_cache_key(prefix: str, *args, **kwargs) -> str:
    """Генерация ключа кэша"""
    key_parts = [prefix]

    # Добавляем аргументы
    for arg in args:
        key_parts.append(str(arg))

    # Добавляем именованные аргументы
    for k, v in sorted(kwargs.items()):
        if v is not None:
            key_parts.append(f"{k}={v}")

    return ":".join(key_parts)


def cache(ttl: int = None, key_prefix: str = None):
    """Декоратор для кэширования результатов функций"""

    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            # Генерируем ключ кэша
            prefix = key_prefix or f"{func.__module__}.{func.__name__}"
            cache_key = generate_cache_key(prefix, *args, **kwargs)

            # Пытаемся получить из кэша
            cached_value = await get_cache(cache_key)
            if cached_value:
                try:
                    return json.loads(cached_value)
                except json.JSONDecodeError:
                    logger.warning("Invalid JSON in cache", key=cache_key)

            # Выполняем функцию
            result = await func(*args, **kwargs)

            # Сохраняем в кэш
            if result is not None:
                try:
                    cache_ttl = ttl or settings.CACHE_TTL_SECONDS
                    await set_cache(
                        cache_key, json.dumps(result, default=str), cache_ttl
                    )
                except (TypeError, ValueError) as e:
                    logger.warning(
                        "Failed to cache result", key=cache_key, error=str(e)
                    )

            return result

        return wrapper

    return decorator


# Специализированные функции для инвалидации кэша


async def invalidate_products_cache() -> None:
    """Инвалидация кэша продуктов"""
    patterns = ["products:*", "product_plans:*", "*products*"]

    total_deleted = 0
    for pattern in patterns:
        deleted = await delete_cache_pattern(pattern)
        total_deleted += deleted

    logger.info("Products cache invalidated", total_deleted=total_deleted)


async def invalidate_plans_cache(product_id: int = None) -> None:
    """Инвалидация кэша планов"""
    if product_id:
        pattern = f"*plans*{product_id}*"
    else:
        pattern = "*plans*"

    deleted = await delete_cache_pattern(pattern)
    logger.info("Plans cache invalidated", pattern=pattern, deleted_count=deleted)


async def invalidate_user_cache(user_id: int) -> None:
    """Инвалидация кэша пользователя"""
    patterns = [f"*user*{user_id}*", f"*subscriptions*{user_id}*"]

    total_deleted = 0
    for pattern in patterns:
        deleted = await delete_cache_pattern(pattern)
        total_deleted += deleted

    logger.info("User cache invalidated", user_id=user_id, total_deleted=total_deleted)
