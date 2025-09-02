"""
Единые обработчики ошибок для Neuro Store API
"""

import uuid
from typing import Any, Dict

from fastapi import HTTPException, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from jose import JWTError
from sqlalchemy.exc import IntegrityError, OperationalError

from app.core.logging_config import log_error


class NeuroStoreException(Exception):
    """Базовое исключение для Neuro Store"""
    def __init__(self, message: str, details: Dict[str, Any] = None):
        self.message = message
        self.details = details or {}
        super().__init__(self.message)


class AuthenticationError(NeuroStoreException):
    """Ошибка аутентификации"""
    pass


class AuthorizationError(NeuroStoreException):
    """Ошибка авторизации"""
    pass


class ValidationError(NeuroStoreException):
    """Ошибка валидации данных"""
    pass


class BusinessLogicError(NeuroStoreException):
    """Ошибка бизнес-логики"""
    pass


def create_error_response(
    error_type: str,
    message: str,
    status_code: int = 500,
    details: Dict[str, Any] = None,
    request_id: str = None
) -> JSONResponse:
    """Создание единообразного ответа об ошибке"""
    
    if not request_id:
        request_id = str(uuid.uuid4())
    
    error_response = {
        "error": {
            "type": error_type,
            "message": message,
            "details": details or {},
            "request_id": request_id
        }
    }
    
    return JSONResponse(
        status_code=status_code,
        content=error_response
    )


async def http_exception_handler(request: Request, exc: HTTPException) -> JSONResponse:
    """Обработчик HTTP исключений"""
    request_id = str(uuid.uuid4())
    
    # Логируем ошибку
    log_error(
        error_type="HTTPException",
        error_message=exc.detail,
        request_id=request_id,
        details={
            "status_code": exc.status_code,
            "url": str(request.url),
            "method": request.method
        }
    )
    
    return create_error_response(
        error_type="HTTPException",
        message=exc.detail,
        status_code=exc.status_code,
        request_id=request_id
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    """Обработчик ошибок валидации данных"""
    request_id = str(uuid.uuid4())
    
    # Преобразуем ошибки валидации в читаемый формат
    validation_errors = []
    for error in exc.errors():
        field_path = " -> ".join(str(loc) for loc in error["loc"])
        validation_errors.append({
            "field": field_path,
            "message": error["msg"],
            "type": error["type"]
        })
    
    error_message = "Ошибка валидации входных данных"
    
    # Логируем ошибку
    log_error(
        error_type="ValidationError",
        error_message=error_message,
        request_id=request_id,
        details={
            "validation_errors": validation_errors,
            "url": str(request.url),
            "method": request.method
        }
    )
    
    return create_error_response(
        error_type="ValidationError",
        message=error_message,
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        details={"validation_errors": validation_errors},
        request_id=request_id
    )


async def jwt_exception_handler(request: Request, exc: JWTError) -> JSONResponse:
    """Обработчик ошибок JWT"""
    request_id = str(uuid.uuid4())
    
    error_message = "Недействительный или истекший токен аутентификации"
    
    # Логируем ошибку
    log_error(
        error_type="JWTError",
        error_message=error_message,
        request_id=request_id,
        details={
            "jwt_error": str(exc),
            "url": str(request.url),
            "method": request.method
        }
    )
    
    return create_error_response(
        error_type="JWTError",
        message=error_message,
        status_code=status.HTTP_401_UNAUTHORIZED,
        request_id=request_id
    )


async def integrity_exception_handler(request: Request, exc: IntegrityError) -> JSONResponse:
    """Обработчик ошибок целостности БД"""
    request_id = str(uuid.uuid4())
    
    error_message = "Нарушение ограничений целостности данных"
    
    # Пытаемся определить тип ошибки
    if "unique" in str(exc).lower():
        error_message = "Запись с такими данными уже существует"
    elif "foreign key" in str(exc).lower():
        error_message = "Ссылка на несуществующую запись"
    
    # Логируем ошибку
    log_error(
        error_type="IntegrityError",
        error_message=error_message,
        request_id=request_id,
        details={
            "db_error": str(exc.orig) if hasattr(exc, 'orig') else str(exc),
            "url": str(request.url),
            "method": request.method
        }
    )
    
    return create_error_response(
        error_type="IntegrityError",
        message=error_message,
        status_code=status.HTTP_400_BAD_REQUEST,
        request_id=request_id
    )


async def operational_exception_handler(request: Request, exc: OperationalError) -> JSONResponse:
    """Обработчик операционных ошибок БД"""
    request_id = str(uuid.uuid4())
    
    error_message = "Ошибка подключения к базе данных"
    
    # Логируем ошибку
    log_error(
        error_type="OperationalError",
        error_message=error_message,
        request_id=request_id,
        details={
            "db_error": str(exc.orig) if hasattr(exc, 'orig') else str(exc),
            "url": str(request.url),
            "method": request.method
        }
    )
    
    return create_error_response(
        error_type="OperationalError",
        message=error_message,
        status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
        request_id=request_id
    )


async def generic_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Общий обработчик всех остальных исключений"""
    request_id = str(uuid.uuid4())
    
    error_message = "Внутренняя ошибка сервера"
    
    # Логируем ошибку
    log_error(
        error_type=type(exc).__name__,
        error_message=str(exc),
        request_id=request_id,
        details={
            "exception_type": type(exc).__name__,
            "url": str(request.url),
            "method": request.method,
            "traceback": str(exc)
        }
    )
    
    return create_error_response(
        error_type="InternalServerError",
        message=error_message,
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        request_id=request_id
    )


async def neuro_store_exception_handler(request: Request, exc: NeuroStoreException) -> JSONResponse:
    """Обработчик кастомных исключений Neuro Store"""
    request_id = str(uuid.uuid4())
    
    # Определяем статус код по типу исключения
    status_code = status.HTTP_400_BAD_REQUEST
    if isinstance(exc, AuthenticationError):
        status_code = status.HTTP_401_UNAUTHORIZED
    elif isinstance(exc, AuthorizationError):
        status_code = status.HTTP_403_FORBIDDEN
    elif isinstance(exc, ValidationError):
        status_code = status.HTTP_422_UNPROCESSABLE_ENTITY
    
    # Логируем ошибку
    log_error(
        error_type=type(exc).__name__,
        error_message=exc.message,
        request_id=request_id,
        details=exc.details
    )
    
    return create_error_response(
        error_type=type(exc).__name__,
        message=exc.message,
        status_code=status_code,
        details=exc.details,
        request_id=request_id
    )
