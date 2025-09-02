"""
Neuro Store - FastAPI приложение для магазина подписок на нейросети
"""

import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from jose import JWTError
from sqlalchemy.exc import IntegrityError, OperationalError

from app.core.config import settings
from app.core.logging_config import configure_logging, get_logger, log_request
from app.core.exceptions import (
    validation_exception_handler,
    jwt_exception_handler,
    integrity_exception_handler,
    operational_exception_handler,
    generic_exception_handler,
    neuro_store_exception_handler,
    NeuroStoreException
)
from app.core.limiter import init_limiter, close_limiter
from app.services.cache import init_cache, close_cache
from app.api.v1 import auth, products, subscriptions, admin, roles, payments

# Настройка логирования
configure_logging()
logger = get_logger("neuro_store.main")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Управление жизненным циклом приложения"""
    # Startup
    logger.info("🚀 Запуск Neuro Store API", 
                version=settings.PROJECT_VERSION,
                environment=settings.APP_ENV)
    
    try:
        # Инициализация Redis для кэширования
        await init_cache()
        
        # Инициализация rate limiter
        await init_limiter()
        
        logger.info("✅ Все сервисы инициализированы успешно")
        
    except Exception as e:
        logger.error("❌ Ошибка инициализации сервисов", error=str(e))
        raise
    
    yield
    
    # Shutdown
    logger.info("🛑 Остановка Neuro Store API")
    
    try:
        await close_cache()
        await close_limiter()
        logger.info("✅ Все сервисы остановлены корректно")
    except Exception as e:
        logger.error("❌ Ошибка при остановке сервисов", error=str(e))


def create_application() -> FastAPI:
    """Создание экземпляра FastAPI приложения"""
    
    app = FastAPI(
        title=settings.PROJECT_NAME,
        description=settings.PROJECT_DESCRIPTION,
        version=settings.PROJECT_VERSION,
        lifespan=lifespan,
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
        contact={
            "name": "Neuro Store Support",
            "email": "support@neurostore.com",
            "url": "https://github.com/wvwvw5/neuro_store"
        },
        license_info={
            "name": "MIT License",
            "url": "https://opensource.org/licenses/MIT"
        },
        openapi_tags=[
            {
                "name": "Аутентификация",
                "description": "Регистрация, вход в систему, управление токенами"
            },
            {
                "name": "Продукты",
                "description": "Управление нейросетевыми продуктами и тарифными планами"
            },
            {
                "name": "Подписки",
                "description": "Создание и управление подписками пользователей"
            },
            {
                "name": "Администрирование",
                "description": "Административные функции (только для админов)"
            },
            {
                "name": "Роли",
                "description": "Управление ролями и правами доступа"
            }
        ]
    )

    # Middleware для логирования запросов
    @app.middleware("http")
    async def log_requests(request: Request, call_next):
        start_time = time.time()
        
        # Выполняем запрос
        response = await call_next(request)
        
        # Логируем запрос
        process_time = time.time() - start_time
        log_request(
            method=request.method,
            url=str(request.url),
            status_code=response.status_code,
            response_time=process_time
        )
        
        return response

    # Настройка CORS
    cors_origins = settings.CORS_ORIGINS.split(",") if settings.CORS_ORIGINS else ["*"]
    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_credentials=True,
        allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allow_headers=["*"],
        expose_headers=["*"],
    )

    # Регистрация обработчиков ошибок
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
    app.add_exception_handler(JWTError, jwt_exception_handler)
    app.add_exception_handler(IntegrityError, integrity_exception_handler)
    app.add_exception_handler(OperationalError, operational_exception_handler)
    app.add_exception_handler(NeuroStoreException, neuro_store_exception_handler)
    app.add_exception_handler(Exception, generic_exception_handler)

    # Подключение API роутеров
    app.include_router(auth.router, prefix=settings.API_V1_STR)
    app.include_router(products.router, prefix=settings.API_V1_STR)
    app.include_router(subscriptions.router, prefix=settings.API_V1_STR)
    app.include_router(admin.router, prefix=settings.API_V1_STR)
    app.include_router(roles.router, prefix=settings.API_V1_STR)
    app.include_router(payments.router, prefix=settings.API_V1_STR)

    return app


# Создание приложения
app = create_application()


@app.get("/", 
         summary="Корневой эндпоинт",
         description="Информация о API и доступных эндпоинтах",
         tags=["Общие"])
async def root():
    """Корневой эндпоинт с информацией о API"""
    return {
        "message": "Добро пожаловать в Neuro Store API!",
        "version": settings.PROJECT_VERSION,
        "environment": settings.APP_ENV,
        "docs": "/docs",
        "redoc": "/redoc",
        "status": "healthy"
    }


@app.get("/health",
         summary="Проверка здоровья",
         description="Проверка состояния API и подключенных сервисов",
         tags=["Мониторинг"])
async def health_check():
    """Проверка здоровья приложения"""
    health_status = {
        "status": "healthy",
        "timestamp": time.time(),
        "version": settings.PROJECT_VERSION,
        "environment": settings.APP_ENV
    }
    
    # Проверяем Redis
    try:
        from app.services.cache import redis_client
        if redis_client:
            await redis_client.ping()
            health_status["redis"] = "connected"
        else:
            health_status["redis"] = "not_initialized"
    except Exception:
        health_status["redis"] = "disconnected"
    
    return health_status


@app.get("/api/v1/health",
         summary="Проверка здоровья API v1",
         description="Проверка состояния API версии 1",
         tags=["Мониторинг"])
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
            "payments": "✅ Доступна"
        }
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.APP_ENV == "development",
        log_level=settings.LOG_LEVEL.lower()
    )