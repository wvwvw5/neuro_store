from datetime import datetime

from pydantic import BaseModel, Field


class SubscriptionBase(BaseModel):
    """Базовая схема подписки"""

    product_id: int = Field(..., gt=0, description="ID продукта")
    plan_id: int = Field(..., gt=0, description="ID плана")


class SubscriptionCreate(SubscriptionBase):
    """Схема создания подписки"""

    pass


class SubscriptionResponse(SubscriptionBase):
    """Схема ответа с данными подписки"""

    id: int
    user_id: int
    status: str
    start_date: datetime
    end_date: datetime
    auto_renew: bool
    requests_used: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class SubscriptionStatus(BaseModel):
    """Схема статуса подписки"""

    id: int
    status: str
    start_date: datetime
    end_date: datetime
    days_left: int
    requests_used: int
    auto_renew: bool
