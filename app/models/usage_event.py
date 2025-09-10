from sqlalchemy import Integer, Column, DateTime, ForeignKey, Numeric, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class UsageEvent(Base):
    """Модель событий использования нейросетей"""

    __tablename__ = "usage_events"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
        comment="ID пользователя"
    )
    subscription_id = Column(
        Integer,
        ForeignKey("subscriptions.id", ondelete="RESTRICT", onupdate="CASCADE"),
        comment="ID подписки"
    )
    product_id = Column(
        Integer,
        ForeignKey("products.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
        comment="ID продукта"
    )
    event_type = Column(String(100), nullable=False, comment="Тип события")
    request_data = Column(Text, comment="Данные запроса (JSON)")
    response_data = Column(Text, comment="Данные ответа (JSON)")
    tokens_used = Column(Integer, comment="Использовано токенов")
    cost = Column(Numeric(12, 4), comment="Стоимость запроса")
    duration_ms = Column(Integer, comment="Время выполнения в мс")
    status = Column(String(50), default="success", comment="Статус выполнения")
    error_message = Column(Text, comment="Сообщение об ошибке")
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), comment="Дата создания"
    )

    # Связи
    user = relationship("User", back_populates="usage_events")
    subscription = relationship("Subscription", back_populates="usage_events")
    product = relationship("Product", back_populates="usage_events")

    def __repr__(self):
        return f"<UsageEvent(id={self.id}, user_id={self.user_id}, event_type='{self.event_type}', status='{self.status}')>"
