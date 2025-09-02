from sqlalchemy import BigInteger, Column, DateTime, ForeignKey, Numeric, String
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class Payment(Base):
    """Модель платежей"""

    __tablename__ = "payments"

    id = Column(BigInteger, primary_key=True, index=True)
    order_id = Column(
        BigInteger,
        ForeignKey("orders.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
        unique=True,
        comment="ID заказа",
    )
    user_id = Column(
        BigInteger,
        ForeignKey("users.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
        comment="ID пользователя",
    )
    amount = Column(Numeric(12, 2), nullable=False, comment="Сумма платежа")
    currency = Column(String(3), default="RUB", comment="Валюта платежа")
    payment_method = Column(String(100), nullable=False, comment="Способ оплаты")
    status = Column(
        String(50), nullable=False, default="pending", comment="Статус платежа"
    )
    transaction_id = Column(String(255), comment="ID транзакции в платежной системе")
    payment_date = Column(DateTime(timezone=True), comment="Дата платежа")
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), comment="Дата создания"
    )
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        comment="Дата обновления",
    )

    # Связи
    order = relationship("Order", back_populates="payment")
    user = relationship("User", back_populates="payments")

    def __repr__(self):
        return f"<Payment(id={self.id}, order_id={self.order_id}, amount={self.amount}, status='{self.status}')>"
