"""
Эндпоинты для аутентификации
"""

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.core.database import get_db

from app.schemas.auth import Token, UserLogin

router = APIRouter()


@router.post("/login", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    """Вход пользователя в систему"""
    # TODO: Реализовать логику аутентификации
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Аутентификация пока не реализована"
    )


@router.post("/register", response_model=Token)
async def register(
    user_data: UserLogin,
    db: Session = Depends(get_db)
):
    """Регистрация нового пользователя"""
    # TODO: Реализовать логику регистрации
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Регистрация пока не реализована"
    )


@router.post("/refresh", response_model=Token)
async def refresh_token():
    """Обновление токена доступа"""
    # TODO: Реализовать обновление токена
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Обновление токена пока не реализовано"
    )
