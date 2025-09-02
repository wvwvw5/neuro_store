"""
Конфигурация приложения Neuro Store
"""

from typing import List, Union
from pydantic import AnyHttpUrl, BaseSettings, validator


class Settings(BaseSettings):
    """Настройки приложения"""
    
    # Настройки API
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Neuro Store API"
    
    # Настройки CORS
    BACKEND_CORS_ORIGINS: List[AnyHttpUrl] = []

    @validator("BACKEND_CORS_ORIGINS", pre=True)
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    # Настройки базы данных
    DATABASE_URL: str = "postgresql://postgres:password@localhost:5432/neuro_store"
    DATABASE_URL_ASYNC: str = "postgresql+asyncpg://postgres:password@localhost:5432/neuro_store"
    
    # Настройки безопасности
    SECRET_KEY: str = "your-secret-key-here-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Настройки логирования
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"
    
    # Настройки Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # Настройки внешних API
    PAYMENT_API_KEY: str = ""
    PAYMENT_API_URL: str = "https://api.payment-provider.com"

    class Config:
        env_file = ".env"
        case_sensitive = True


# Создание экземпляра настроек
settings = Settings()
