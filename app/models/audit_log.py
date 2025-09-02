from sqlalchemy import Column, BigInteger, String, DateTime, Text, JSON
from sqlalchemy.sql import func
from app.core.database import Base


class AuditLog(Base):
    """Модель журнала аудита"""

    __tablename__ = "audit_log"

    id = Column(BigInteger, primary_key=True, index=True)
    table_name = Column(String(100), nullable=False, comment="Название таблицы")
    record_id = Column(BigInteger, comment="ID записи")
    operation = Column(
        String(20), nullable=False, comment="Тип операции (INSERT/UPDATE/DELETE)"
    )
    user_id = Column(BigInteger, comment="ID пользователя, выполнившего операцию")
    old_values = Column(JSON, comment="Старые значения (JSON)")
    new_values = Column(JSON, comment="Новые значения (JSON)")
    timestamp = Column(
        DateTime(timezone=True), server_default=func.now(), comment="Время операции"
    )
    ip_address = Column(String(45), comment="IP адрес")
    user_agent = Column(Text, comment="User Agent")

    def __repr__(self):
        return f"<AuditLog(id={self.id}, table='{self.table_name}', operation='{self.operation}', user_id={self.user_id})>"
