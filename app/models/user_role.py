from sqlalchemy import BigInteger, Column, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class UserRole(Base):
    """Модель связи пользователей и ролей (M:M)"""

    __tablename__ = "user_roles"

    id = Column(BigInteger, primary_key=True, index=True)
    user_id = Column(
        BigInteger,
        ForeignKey("users.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
        comment="ID пользователя",
    )
    role_id = Column(
        BigInteger,
        ForeignKey("roles.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
        comment="ID роли",
    )
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        comment="Дата назначения роли",
    )

    # Связи
    user = relationship("User", back_populates="user_roles")
    role = relationship("Role", back_populates="user_roles")

    # Уникальное ограничение
    __table_args__ = (UniqueConstraint("user_id", "role_id", name="uq_user_role"),)

    def __repr__(self):
        return f"<UserRole(user_id={self.user_id}, role_id={self.role_id})>"
