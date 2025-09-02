from sqlalchemy import Column, BigInteger, ForeignKey, String, DateTime, Boolean, Integer
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class Subscription(Base):
    """Модель подписок пользователей"""
    __tablename__ = "subscriptions"

    id = Column(BigInteger, primary_key=True, index=True)
    user_id = Column(BigInteger, ForeignKey("users.id", ondelete="RESTRICT", onupdate="CASCADE"), nullable=False, comment="ID пользователя")
    product_id = Column(BigInteger, ForeignKey("products.id", ondelete="RESTRICT", onupdate="CASCADE"), nullable=False, comment="ID продукта")
    plan_id = Column(BigInteger, ForeignKey("plans.id", ondelete="RESTRICT", onupdate="CASCADE"), nullable=False, comment="ID плана")
    status = Column(String(50), nullable=False, default="active", comment="Статус подписки")
    start_date = Column(DateTime(timezone=True), nullable=False, comment="Дата начала подписки")
    end_date = Column(DateTime(timezone=True), nullable=False, comment="Дата окончания подписки")
    auto_renew = Column(Boolean, default=True, comment="Автопродление подписки")
    requests_used = Column(Integer, default=0, comment="Использовано запросов")
    created_at = Column(DateTime(timezone=True), server_default=func.now(), comment="Дата создания")
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), comment="Дата обновления")

    # Связи
    user = relationship("User", back_populates="subscriptions")
    product = relationship("Product", back_populates="subscriptions")
    plan = relationship("Plan", back_populates="subscriptions")
    usage_events = relationship("UsageEvent", back_populates="subscription")

    def __repr__(self):
        return f"<Subscription(id={self.id}, user_id={self.user_id}, product_id={self.product_id}, status='{self.status}')>"
