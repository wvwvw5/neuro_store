"""
Neuro Store - FastAPI приложение для магазина подписок на нейросети
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.core.config import settings
from app.api.v1.api import api_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Управление жизненным циклом приложения"""
    # Startup
    print("🚀 Запуск Neuro Store API...")
    
    yield
    
    # Shutdown
    print("🛑 Остановка Neuro Store API...")


def create_application() -> FastAPI:
    """Создание экземпляра FastAPI приложения"""
    
    app = FastAPI(
        title=settings.PROJECT_NAME,
        openapi_url=f"{settings.API_V1_STR}/openapi.json",
        lifespan=lifespan,
        docs_url="/docs",
        redoc_url="/redoc"
    )

    # Настройка CORS
    if settings.BACKEND_CORS_ORIGINS:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

    # Подключение роутеров
    app.include_router(api_router, prefix=settings.API_V1_STR)

    return app


app = create_application()


@app.get("/")
async def root():
    """Корневой endpoint"""
    return {
        "message": "Добро пожаловать в Neuro Store API!",
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc"
    }


@app.get("/health")
async def health_check():
    """Проверка состояния API"""
    return {"status": "healthy", "service": "neuro-store-api"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
