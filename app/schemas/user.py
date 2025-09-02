"""
Pydantic схемы для пользователей
"""

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, EmailStr, Field


class UserBase(BaseModel):
    """Базовая схема пользователя"""

    email: EmailStr = Field(..., description="Email пользователя")
    first_name: str = Field(
        ..., min_length=1, max_length=100, description="Имя пользователя"
    )
    last_name: str = Field(
        ..., min_length=1, max_length=100, description="Фамилия пользователя"
    )
    phone: Optional[str] = Field(
        None, max_length=20, description="Телефон пользователя"
    )


class UserCreate(UserBase):
    """Схема создания пользователя"""

    password: str = Field(
        ..., min_length=6, max_length=100, description="Пароль (минимум 6 символов)"
    )


class UserUpdate(BaseModel):
    """Схема обновления пользователя"""

    first_name: Optional[str] = Field(None, min_length=1, max_length=100)
    last_name: Optional[str] = Field(None, min_length=1, max_length=100)
    phone: Optional[str] = Field(None, max_length=20)
    is_active: Optional[bool] = None


class UserResponse(UserBase):
    """Схема ответа с данными пользователя"""

    id: int
    balance: float
    is_active: bool
    is_verified: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class UserWithRoles(UserResponse):
    """Схема пользователя с ролями"""

    roles: List[str] = Field(
        default_factory=list, description="Список ролей пользователя"
    )


class RoleBase(BaseModel):
    """Базовая схема роли"""

    name: str = Field(..., min_length=1, max_length=50, description="Название роли")
    description: Optional[str] = Field(None, description="Описание роли")


class RoleCreate(RoleBase):
    """Схема создания роли"""

    pass


class RoleResponse(RoleBase):
    """Схема ответа с данными роли"""

    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class UserRoleAssign(BaseModel):
    """Схема назначения роли пользователю"""

    user_id: int = Field(..., gt=0, description="ID пользователя")
    role_id: int = Field(..., gt=0, description="ID роли")
