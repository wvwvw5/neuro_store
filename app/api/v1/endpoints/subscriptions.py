"""
Эндпоинты для управления подписками
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db

router = APIRouter()


@router.get("/")
async def get_subscriptions(db: Session = Depends(get_db)):
    """Получение списка подписок пользователя"""
    # TODO: Реализовать получение подписок
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Получение подписок пока не реализовано",
    )


@router.get("/{subscription_id}")
async def get_subscription(subscription_id: int, db: Session = Depends(get_db)):
    """Получение подписки по ID"""
    # TODO: Реализовать получение подписки
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Получение подписки пока не реализовано",
    )


@router.post("/")
async def create_subscription(db: Session = Depends(get_db)):
    """Создание новой подписки"""
    # TODO: Реализовать создание подписки
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Создание подписки пока не реализовано",
    )


@router.put("/{subscription_id}/cancel")
async def cancel_subscription(subscription_id: int, db: Session = Depends(get_db)):
    """Отмена подписки"""
    # TODO: Реализовать отмену подписки
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Отмена подписки пока не реализована",
    )
