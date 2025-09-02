"""
Эндпоинты для управления пользователями
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db


router = APIRouter()


@router.get("/me")
async def get_current_user():
    """Получение информации о текущем пользователе"""
    # TODO: Реализовать получение текущего пользователя
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Получение пользователя пока не реализовано"
    )


@router.get("/{user_id}")
async def get_user(user_id: int, db: Session = Depends(get_db)):
    """Получение пользователя по ID"""
    # TODO: Реализовать получение пользователя
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Получение пользователя пока не реализовано"
    )


@router.put("/{user_id}")
async def update_user(user_id: int, db: Session = Depends(get_db)):
    """Обновление пользователя"""
    # TODO: Реализовать обновление пользователя
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Обновление пользователя пока не реализовано"
    )
