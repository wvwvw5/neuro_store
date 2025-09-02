from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class ProductBase(BaseModel):
    """Базовая схема продукта"""

    name: str = Field(
        ..., min_length=1, max_length=255, description="Название продукта"
    )
    description: Optional[str] = Field(None, description="Описание продукта")
    category: str = Field(
        ..., min_length=1, max_length=100, description="Категория продукта"
    )
    api_endpoint: Optional[str] = Field(
        None, max_length=500, description="API endpoint продукта"
    )


class ProductCreate(ProductBase):
    """Схема создания продукта"""

    pass


class ProductUpdate(BaseModel):
    """Схема обновления продукта"""

    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    category: Optional[str] = Field(None, min_length=1, max_length=100)
    api_endpoint: Optional[str] = Field(None, max_length=500)
    is_active: Optional[bool] = None


class ProductResponse(ProductBase):
    """Схема ответа с данными продукта"""

    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class PlanBase(BaseModel):
    """Базовая схема плана"""

    name: str = Field(..., min_length=1, max_length=255, description="Название плана")
    description: Optional[str] = Field(None, description="Описание плана")
    price: float = Field(..., ge=0, description="Цена плана")
    duration_days: int = Field(..., gt=0, description="Длительность в днях")
    max_requests_per_month: Optional[int] = Field(
        None, gt=0, description="Максимум запросов в месяц"
    )
    features: Optional[str] = Field(None, description="Особенности плана")


class PlanCreate(PlanBase):
    """Схема создания плана"""

    pass


class PlanUpdate(BaseModel):
    """Схема обновления плана"""

    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    price: Optional[float] = Field(None, ge=0)
    duration_days: Optional[int] = Field(None, gt=0)
    max_requests_per_month: Optional[int] = Field(None, gt=0)
    features: Optional[str] = None
    is_active: Optional[bool] = None


class PlanResponse(PlanBase):
    """Схема ответа с данными плана"""

    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
