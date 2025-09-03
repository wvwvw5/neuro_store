from sqlalchemy import BigInteger, Boolean, Column, DateTime, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class Role(Base):
    """Модель ролей пользователей"""

    __tablename__ = "roles"

    id = Column(BigInteger, primary_key=True, index=True, autoincrement=True)
    name = Column(String(50), unique=True, nullable=False, comment="Название роли")
    description = Column(Text, comment="Описание роли")
    is_active = Column(Boolean, default=True, comment="Активна ли роль")
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
    user_roles = relationship("UserRole", back_populates="role")
    users = relationship("User", secondary="user_roles", back_populates="roles")

    def __repr__(self):
        return f"<Role(id={self.id}, name='{self.name}')>"
