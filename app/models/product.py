from sqlalchemy import Column, BigInteger, String, Text, Boolean, DateTime, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class Product(Base):
    """Модель нейросетевых продуктов"""
    __tablename__ = "products"

    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255), nullable=False, comment="Название продукта")
    description = Column(Text, comment="Описание продукта")
    category = Column(String(100), nullable=False, comment="Категория продукта")
    api_endpoint = Column(String(500), comment="API endpoint продукта")
    is_active = Column(Boolean, default=True, comment="Активен ли продукт")
    created_at = Column(DateTime(timezone=True), server_default=func.now(), comment="Дата создания")
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), comment="Дата обновления")

    # Связи
    product_plans = relationship("ProductPlan", back_populates="product")
    plans = relationship("Plan", secondary="product_plans", back_populates="products")
    subscriptions = relationship("Subscription", back_populates="product")
    usage_events = relationship("UsageEvent", back_populates="product")

    def __repr__(self):
        return f"<Product(id={self.id}, name='{self.name}', category='{self.category}')>"
