from sqlalchemy import Column, BigInteger, ForeignKey, String, DateTime, Numeric, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class Order(Base):
    """Модель заказов"""

    __tablename__ = "orders"

    id = Column(BigInteger, primary_key=True, index=True)
    user_id = Column(
        BigInteger,
        ForeignKey("users.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
        comment="ID пользователя",
    )
    product_id = Column(
        BigInteger,
        ForeignKey("products.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=True,
        comment="ID продукта (NULL для пополнения баланса)",
    )
    plan_id = Column(
        BigInteger,
        ForeignKey("plans.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=True,
        comment="ID плана (NULL для пополнения баланса)",
    )
    status = Column(
        String(50), nullable=False, default="pending", comment="Статус заказа"
    )
    amount = Column(Numeric(12, 2), nullable=False, comment="Сумма заказа")
    currency = Column(String(3), default="RUB", comment="Валюта заказа")
    notes = Column(Text, comment="Примечания к заказу")
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
    user = relationship("User", back_populates="orders")
    product = relationship("Product")
    plan = relationship("Plan")
    payment = relationship("Payment", back_populates="order", uselist=False)

    def __repr__(self):
        return f"<Order(id={self.id}, user_id={self.user_id}, amount={self.amount}, status='{self.status}')>"
