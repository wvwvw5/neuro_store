"""
Схемы для аутентификации
"""

from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr


class UserLogin(BaseModel):
    """Схема входа пользователя"""

    email: EmailStr
    password: str


class UserCreate(BaseModel):
    """Схема создания пользователя"""

    email: EmailStr
    password: str
    first_name: str
    last_name: str
    phone: Optional[str] = None


class UserResponse(BaseModel):
    """Схема ответа с данными пользователя"""

    id: int
    email: str
    first_name: str
    last_name: str
    phone: Optional[str] = None
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class Token(BaseModel):
    """Схема токена доступа"""

    access_token: str
    token_type: str


class TokenData(BaseModel):
    """Схема данных токена"""

    email: Optional[str] = None
