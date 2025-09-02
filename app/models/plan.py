from sqlalchemy import (
    BigInteger,
    Boolean,
    Column,
    DateTime,
    Integer,
    Numeric,
    String,
    Text,
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class Plan(Base):
    """Модель тарифных планов"""

    __tablename__ = "plans"

    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255), nullable=False, comment="Название плана")
    description = Column(Text, comment="Описание плана")
    price = Column(Numeric(12, 2), nullable=False, comment="Цена плана")
    duration_days = Column(Integer, nullable=False, comment="Длительность в днях")
    max_requests_per_month = Column(Integer, comment="Максимум запросов в месяц")
    features = Column(Text, comment="Особенности плана (JSON)")
    is_active = Column(Boolean, default=True, comment="Активен ли план")
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
    product_plans = relationship("ProductPlan", back_populates="plan")
    products = relationship(
        "Product", secondary="product_plans", back_populates="plans"
    )
    subscriptions = relationship("Subscription", back_populates="plan")

    def __repr__(self):
        return f"<Plan(id={self.id}, name='{self.name}', price={self.price}, duration={self.duration_days}дн)>"
