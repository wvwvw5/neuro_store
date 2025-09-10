"""
Конфигурация приложения Neuro Store
"""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Настройки приложения Neuro Store"""

    # Настройки приложения
    APP_ENV: str = "development"
    DEBUG: bool = True

    # Настройки API
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Neuro Store API"
    PROJECT_VERSION: str = "1.0.0"
    PROJECT_DESCRIPTION: str = "API для магазина подписок на нейросетевые сервисы"

    # Настройки CORS
    CORS_ORIGINS: str = "http://localhost:3000,http://127.0.0.1:3000"

    # Настройки базы данных
    DATABASE_URL: str = (
        "postgresql+psycopg2://postgres:postgres@localhost:5433/neuro_store"
    )
    DATABASE_URL_ASYNC: str = (
        "postgresql+asyncpg://postgres:postgres@localhost:5433/neuro_store"
    )
    TEST_DATABASE_URL: str = (
        "postgresql+psycopg2://postgres:postgres@localhost:5433/neuro_store_test"
    )

    # Настройки безопасности
    SECRET_KEY: str = "your-secret-key-change-in-production-min-32-chars"
    JWT_SECRET: str = "your-jwt-secret-change-in-production-min-32-chars"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    JWT_EXPIRE_MINUTES: int = 60

    # Настройки логирования
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"
    LOG_FILENAME: str = "app.log"
    LOG_ROTATION: str = "10MB"
    LOG_RETENTION: str = "30"

    # Настройки Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_DB: int = 0

    # Rate Limiting
    RATE_LIMIT_DEFAULT: str = "20/minute"
    RATE_LIMIT_LOGIN: str = "5/minute"
    RATE_LIMIT_REGISTER: str = "3/minute"
    RATE_LIMIT_PRODUCTS: str = "30/minute"
    RATE_LIMIT_SUBSCRIPTIONS: str = "10/minute"

    # Кэширование
    CACHE_TTL_SECONDS: int = 120
    CACHE_TTL_PRODUCTS: int = 300
    CACHE_TTL_PLANS: int = 600

    # Внешние API
    OPENAI_API_KEY: str = ""
    ANTHROPIC_API_KEY: str = ""
    STABILITY_API_KEY: str = ""
    MIDJOURNEY_API_KEY: str = ""

    # Платежные системы
    STRIPE_SECRET_KEY: str = ""
    STRIPE_PUBLISHABLE_KEY: str = ""
    YOOKASSA_SHOP_ID: str = ""
    YOOKASSA_SECRET_KEY: str = ""

    model_config = {"extra": "ignore", "env_file": ".env", "case_sensitive": True}


# Создание экземпляра настроек
settings = Settings()
