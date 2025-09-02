"""
Модель пользователя
"""

from sqlalchemy import BigInteger, Boolean, Column, DateTime, Numeric, String
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class User(Base):
    """Модель пользователей системы"""

    __tablename__ = "users"

    id = Column(BigInteger, primary_key=True, index=True)
    email = Column(
        String(255),
        unique=True,
        nullable=False,
        index=True,
        comment="Email пользователя",
    )
    password_hash = Column(String(255), nullable=False, comment="Хеш пароля")
    first_name = Column(String(100), nullable=False, comment="Имя пользователя")
    last_name = Column(String(100), nullable=False, comment="Фамилия пользователя")
    phone = Column(String(20), comment="Телефон пользователя")
    balance = Column(Numeric(12, 2), default=0.00, comment="Баланс пользователя")
    is_active = Column(Boolean, default=True, comment="Активен ли пользователь")
    is_verified = Column(Boolean, default=False, comment="Подтвержден ли email")
    created_at = Column(
        DateTime(timezone=True), server_default=func.now(), comment="Дата регистрации"
    )
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        comment="Дата обновления",
    )

    # Связи
    user_roles = relationship("UserRole", back_populates="user")
    roles = relationship("Role", secondary="user_roles", back_populates="users")
    subscriptions = relationship("Subscription", back_populates="user")
    orders = relationship("Order", back_populates="user")
    payments = relationship("Payment", back_populates="user")
    usage_events = relationship("UsageEvent", back_populates="user")

    def __repr__(self):
        return f"<User(id={self.id}, email='{self.email}', name='{self.first_name} {self.last_name}')>"
