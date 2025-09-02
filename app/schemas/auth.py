"""
Схемы для аутентификации
"""

from pydantic import BaseModel, EmailStr
from typing import Optional


class UserLogin(BaseModel):
    """Схема для входа пользователя"""
    email: EmailStr
    password: str


class Token(BaseModel):
    """Схема токена"""
    access_token: str
    token_type: str


class TokenData(BaseModel):
    """Данные токена"""
    email: Optional[str] = None
