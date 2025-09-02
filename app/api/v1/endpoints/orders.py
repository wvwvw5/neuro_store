"""
Эндпоинты для управления заказами
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db

router = APIRouter()


@router.get("/")
async def get_orders(db: Session = Depends(get_db)):
    """Получение списка заказов пользователя"""
    # TODO: Реализовать получение заказов
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Получение заказов пока не реализовано"
    )


@router.get("/{order_id}")
async def get_order(order_id: int, db: Session = Depends(get_db)):
    """Получение заказа по ID"""
    # TODO: Реализовать получение заказа
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Получение заказа пока не реализовано"
    )


@router.post("/")
async def create_order(db: Session = Depends(get_db)):
    """Создание нового заказа"""
    # TODO: Реализовать создание заказа
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Создание заказа пока не реализовано"
    )


@router.put("/{order_id}/confirm")
async def confirm_order(order_id: int, db: Session = Depends(get_db)):
    """Подтверждение заказа"""
    # TODO: Реализовать подтверждение заказа
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Подтверждение заказа пока не реализовано"
    )


@router.put("/{order_id}/cancel")
async def cancel_order(order_id: int, db: Session = Depends(get_db)):
    """Отмена заказа"""
    # TODO: Реализовать отмену заказа
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Отмена заказа пока не реализована"
    )
