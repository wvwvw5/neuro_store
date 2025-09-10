"""
Кастомные исключения для Neuro Store
"""

from fastapi import HTTPException, Request, status
from fastapi.responses import JSONResponse
from typing import Any, Dict, Optional
from pydantic import ValidationError
from jose import JWTError
from sqlalchemy.exc import IntegrityError, OperationalError

from app.core.logging_config import get_logger

logger = get_logger("neuro_store.exceptions")


class NeuroStoreException(Exception):
    """Базовое исключение для Neuro Store"""
    
    def __init__(
        self,
        message: str,
        status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR,
        details: Optional[Dict[str, Any]] = None
    ):
        self.message = message
        self.status_code = status_code
        self.details = details or {}
        super().__init__(self.message)


class AuthenticationError(NeuroStoreException):
    """Ошибка аутентификации"""
    
    def __init__(self, message: str = "Ошибка аутентификации", details: Optional[Dict[str, Any]] = None):
        super().__init__(message, status.HTTP_401_UNAUTHORIZED, details)


class AuthorizationError(NeuroStoreException):
    """Ошибка авторизации"""
    
    def __init__(self, message: str = "Недостаточно прав", details: Optional[Dict[str, Any]] = None):
        super().__init__(message, status.HTTP_403_FORBIDDEN, details)


class ValidationError(NeuroStoreException):
    """Ошибка валидации данных"""
    
    def __init__(self, message: str = "Ошибка валидации", details: Optional[Dict[str, Any]] = None):
        super().__init__(message, status.HTTP_422_UNPROCESSABLE_ENTITY, details)


class NotFoundError(NeuroStoreException):
    """Ресурс не найден"""
    
    def __init__(self, message: str = "Ресурс не найден", details: Optional[Dict[str, Any]] = None):
        super().__init__(message, status.HTTP_404_NOT_FOUND, details)


class ConflictError(NeuroStoreException):
    """Конфликт данных"""
    
    def __init__(self, message: str = "Конфликт данных", details: Optional[Dict[str, Any]] = None):
        super().__init__(message, status.HTTP_409_CONFLICT, details)


class RateLimitError(NeuroStoreException):
    """Превышен лимит запросов"""
    
    def __init__(self, message: str = "Превышен лимит запросов", details: Optional[Dict[str, Any]] = None):
        super().__init__(message, status.HTTP_429_TOO_MANY_REQUESTS, details)


class DatabaseError(NeuroStoreException):
    """Ошибка базы данных"""
    
    def __init__(self, message: str = "Ошибка базы данных", details: Optional[Dict[str, Any]] = None):
        super().__init__(message, status.HTTP_500_INTERNAL_SERVER_ERROR, details)


class CacheError(NeuroStoreException):
    """Ошибка кэширования"""
    
    def __init__(self, message: str = "Ошибка кэширования", details: Optional[Dict[str, Any]] = None):
        super().__init__(message, status.HTTP_500_INTERNAL_SERVER_ERROR, details)


class ExternalServiceError(NeuroStoreException):
    """Ошибка внешнего сервиса"""
    
    def __init__(self, message: str = "Ошибка внешнего сервиса", details: Optional[Dict[str, Any]] = None):
        super().__init__(message, status.HTTP_502_BAD_GATEWAY, details)


def handle_neuro_store_exception(exc: NeuroStoreException) -> HTTPException:
    """Преобразование кастомного исключения в HTTPException для FastAPI"""
    return HTTPException(
        status_code=exc.status_code,
        detail={
            "error": exc.message,
            "details": exc.details
        }
    )


# Exception handlers for FastAPI
async def neuro_store_exception_handler(request: Request, exc: NeuroStoreException) -> JSONResponse:
    """Обработчик кастомных исключений NeuroStore"""
    logger.error(
        "NeuroStore exception occurred",
        error_type=type(exc).__name__,
        message=exc.message,
        status_code=exc.status_code,
        details=exc.details,
        path=str(request.url.path),
        method=request.method
    )
    
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": exc.message,
            "details": exc.details,
            "type": type(exc).__name__
        }
    )


async def validation_exception_handler(request: Request, exc: ValidationError) -> JSONResponse:
    """Обработчик ошибок валидации Pydantic"""
    logger.warning(
        "Validation error occurred",
        path=str(request.url.path),
        method=request.method,
        errors=str(exc)
    )
    
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "error": "Ошибка валидации данных",
            "details": {"validation_errors": str(exc)}
        }
    )


async def jwt_exception_handler(request: Request, exc: JWTError) -> JSONResponse:
    """Обработчик ошибок JWT"""
    logger.warning(
        "JWT error occurred",
        path=str(request.url.path),
        method=request.method,
        error=str(exc)
    )
    
    return JSONResponse(
        status_code=status.HTTP_401_UNAUTHORIZED,
        content={
            "error": "Ошибка аутентификации",
            "details": {"jwt_error": "Недействительный токен"}
        }
    )


async def integrity_exception_handler(request: Request, exc: IntegrityError) -> JSONResponse:
    """Обработчик ошибок целостности БД"""
    logger.error(
        "Database integrity error occurred",
        path=str(request.url.path),
        method=request.method,
        error=str(exc)
    )
    
    return JSONResponse(
        status_code=status.HTTP_409_CONFLICT,
        content={
            "error": "Нарушение целостности данных",
            "details": {"database_error": "Дублирование или связанные данные"}
        }
    )


async def operational_exception_handler(request: Request, exc: OperationalError) -> JSONResponse:
    """Обработчик операционных ошибок БД"""
    logger.error(
        "Database operational error occurred",
        path=str(request.url.path),
        method=request.method,
        error=str(exc)
    )
    
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": "Ошибка базы данных",
            "details": {"database_error": "Проблема с подключением или выполнением запроса"}
        }
    )


async def generic_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Обработчик всех остальных исключений"""
    logger.error(
        "Unhandled exception occurred",
        path=str(request.url.path),
        method=request.method,
        error_type=type(exc).__name__,
        error=str(exc)
    )
    
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": "Внутренняя ошибка сервера",
            "details": {"error_type": type(exc).__name__}
        }
    )
