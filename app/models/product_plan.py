from sqlalchemy import BigInteger, Column, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class ProductPlan(Base):
    """Модель связи продуктов и планов (M:M)"""

    __tablename__ = "product_plans"

    id = Column(BigInteger, primary_key=True, index=True)
    product_id = Column(
        BigInteger,
        ForeignKey("products.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
        comment="ID продукта",
    )
    plan_id = Column(
        BigInteger,
        ForeignKey("plans.id", ondelete="RESTRICT", onupdate="CASCADE"),
        nullable=False,
        comment="ID плана",
    )
    is_available = Column(
        BigInteger, default=True, comment="Доступен ли план для продукта"
    )
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        comment="Дата создания связи",
    )

    # Связи
    product = relationship("Product", back_populates="product_plans")
    plan = relationship("Plan", back_populates="product_plans")

    # Уникальное ограничение
    __table_args__ = (
        UniqueConstraint("product_id", "plan_id", name="uq_product_plan"),
    )

    def __repr__(self):
        return f"<ProductPlan(product_id={self.product_id}, plan_id={self.plan_id})>"
