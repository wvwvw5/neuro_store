from decimal import Decimal
from typing import Optional

from pydantic import BaseModel, Field, validator


class BalanceTopUpRequest(BaseModel):
    """Запрос на пополнение баланса"""

    amount: Decimal = Field(..., gt=0, description="Сумма пополнения")
    card_number: str = Field(
        ..., min_length=16, max_length=19, description="Номер карты"
    )
    card_holder: str = Field(..., min_length=2, description="Имя владельца карты")
    expiry_month: int = Field(..., ge=1, le=12, description="Месяц истечения карты")
    expiry_year: int = Field(..., ge=2024, le=2030, description="Год истечения карты")
    cvv: str = Field(..., min_length=3, max_length=4, description="CVV код")
    phone: Optional[str] = Field(
        None, description="Телефон для SMS (если отличается от профиля)"
    )

    @validator("card_number")
    def validate_card_number(cls, v):
        # Убираем пробелы и дефисы
        v = v.replace(" ", "").replace("-", "")
        if not v.isdigit():
            raise ValueError("Номер карты должен содержать только цифры")
        return v

    @validator("cvv")
    def validate_cvv(cls, v):
        if not v.isdigit():
            raise ValueError("CVV должен содержать только цифры")
        return v


class BalanceTopUpResponse(BaseModel):
    """Ответ на пополнение баланса"""

    success: bool
    message: str
    verification_required: bool
    payment_id: int
    amount: Decimal


class CardVerificationRequest(BaseModel):
    """Запрос на верификацию карты"""

    payment_id: int = Field(..., description="ID платежа")
    verification_code: str = Field(
        ..., min_length=4, max_length=6, description="Код верификации из SMS"
    )


class CardVerificationResponse(BaseModel):
    """Ответ на верификацию карты"""

    success: bool
    message: str
    verification_code: str


class PaymentStatus(BaseModel):
    """Статус платежа"""

    success: bool
    message: str
    new_balance: Decimal
    payment_id: int


class PaymentHistory(BaseModel):
    """История платежей"""

    id: int
    amount: Decimal
    currency: str
    payment_method: str
    status: str
    payment_date: str
    transaction_id: Optional[str]
    created_at: str
