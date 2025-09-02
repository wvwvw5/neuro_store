"""
Конфигурация структурированного логирования для Neuro Store
"""

import logging
import sys
from typing import Any, Dict

import structlog
from structlog.types import FilteringBoundLogger

from app.core.config import settings


def configure_logging() -> None:
    """Настройка структурированного логирования"""

    # Определяем уровень логирования
    log_level = getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO)

    # Настройка для production (JSON) или development (читаемый формат)
    if settings.APP_ENV == "production":
        # Production: структурированные JSON логи
        processors = [
            structlog.stdlib.filter_by_level,
            structlog.stdlib.add_logger_name,
            structlog.stdlib.add_log_level,
            structlog.stdlib.PositionalArgumentsFormatter(),
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.UnicodeDecoder(),
            structlog.processors.JSONRenderer(),
        ]

        # Настройка для записи в файл и stdout
        logging.basicConfig(
            format="%(message)s",
            stream=sys.stdout,
            level=log_level,
        )

    else:
        # Development: читаемые цветные логи
        processors = [
            structlog.stdlib.filter_by_level,
            structlog.stdlib.add_logger_name,
            structlog.stdlib.add_log_level,
            structlog.stdlib.PositionalArgumentsFormatter(),
            structlog.processors.TimeStamper(fmt="%Y-%m-%d %H:%M:%S"),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.UnicodeDecoder(),
            structlog.dev.ConsoleRenderer(colors=True),
        ]

        logging.basicConfig(
            format="%(message)s",
            stream=sys.stdout,
            level=log_level,
        )

    # Конфигурация structlog
    structlog.configure(
        processors=processors,
        wrapper_class=structlog.stdlib.BoundLogger,
        logger_factory=structlog.stdlib.LoggerFactory(),
        context_class=dict,
        cache_logger_on_first_use=True,
    )


def get_logger(name: str = None) -> FilteringBoundLogger:
    """Получение структурированного логгера"""
    return structlog.get_logger(name)


def log_request(
    method: str,
    url: str,
    status_code: int,
    response_time: float,
    user_id: int = None,
    user_email: str = None,
) -> None:
    """Логирование HTTP запросов"""
    logger = get_logger("neuro_store.requests")

    log_data = {
        "method": method,
        "url": url,
        "status_code": status_code,
        "response_time_ms": round(response_time * 1000, 2),
    }

    if user_id:
        log_data["user_id"] = user_id
    if user_email:
        log_data["user_email"] = user_email

    if status_code >= 400:
        logger.warning("HTTP request failed", **log_data)
    else:
        logger.info("HTTP request completed", **log_data)


def log_auth_event(
    event_type: str, user_email: str, success: bool, details: Dict[str, Any] = None
) -> None:
    """Логирование событий аутентификации"""
    logger = get_logger("neuro_store.auth")

    log_data = {
        "event_type": event_type,
        "user_email": user_email,
        "success": success,
    }

    if details:
        log_data.update(details)

    if success:
        logger.info("Authentication event", **log_data)
    else:
        logger.warning("Authentication failed", **log_data)


def log_subscription_event(
    event_type: str,
    user_id: int,
    subscription_id: int = None,
    product_id: int = None,
    plan_id: int = None,
    details: Dict[str, Any] = None,
) -> None:
    """Логирование событий подписок"""
    logger = get_logger("neuro_store.subscriptions")

    log_data = {
        "event_type": event_type,
        "user_id": user_id,
    }

    if subscription_id:
        log_data["subscription_id"] = subscription_id
    if product_id:
        log_data["product_id"] = product_id
    if plan_id:
        log_data["plan_id"] = plan_id
    if details:
        log_data.update(details)

    logger.info("Subscription event", **log_data)


def log_error(
    error_type: str,
    error_message: str,
    user_id: int = None,
    request_id: str = None,
    details: Dict[str, Any] = None,
) -> None:
    """Логирование ошибок"""
    logger = get_logger("neuro_store.errors")

    log_data = {
        "error_type": error_type,
        "error_message": error_message,
    }

    if user_id:
        log_data["user_id"] = user_id
    if request_id:
        log_data["request_id"] = request_id
    if details:
        log_data.update(details)

    logger.error("Application error", **log_data)
