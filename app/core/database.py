"""
Настройки базы данных для Neuro Store
"""

from typing import Generator
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool

from app.core.config import settings

# Создание движка базы данных
if settings.APP_ENV == "test":
    # Для тестов используем SQLite в памяти
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
else:
    # Для production/development используем PostgreSQL
    engine = create_engine(
        settings.DATABASE_URL,
        pool_pre_ping=True,
        pool_recycle=300,
        pool_size=10,
        max_overflow=20,
    )

# Создание фабрики сессий
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Базовый класс для моделей
Base = declarative_base()


def get_db() -> Generator[Session, None, None]:
    """
    Dependency для получения сессии базы данных
    
    Yields:
        Session: Сессия базы данных
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def create_tables() -> None:
    """Создание всех таблиц в базе данных"""
    Base.metadata.create_all(bind=engine)


def drop_tables() -> None:
    """Удаление всех таблиц из базы данных"""
    Base.metadata.drop_all(bind=engine)
