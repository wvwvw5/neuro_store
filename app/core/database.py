"""
Настройка базы данных
"""

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession

from app.core.config import settings

# Синхронный движок для миграций
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    echo=False
)

# Асинхронный движок для API
async_engine = create_async_engine(
    settings.DATABASE_URL_ASYNC,
    pool_pre_ping=True,
    echo=False
)

# Синхронная сессия
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Асинхронная сессия
AsyncSessionLocal = sessionmaker(
    async_engine, class_=AsyncSession, expire_on_commit=False
)

# Базовый класс для моделей
Base = declarative_base()


def get_db():
    """Получение синхронной сессии БД"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


async def get_async_db():
    """Получение асинхронной сессии БД"""
    async with AsyncSessionLocal() as session:
        yield session
