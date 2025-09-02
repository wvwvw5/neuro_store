from datetime import datetime
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.api.v1.auth import get_current_user_from_token
from app.models.user import User
from app.models.payment import Payment
from app.models.order import Order
from app.models.user_role import UserRole
from sqlalchemy import func
from app.schemas.payment import (
    BalanceTopUpRequest,
    BalanceTopUpResponse,
    CardVerificationRequest,
    CardVerificationResponse,
    PaymentStatus
)
from app.core.logging_config import get_logger

logger = get_logger(__name__)
router = APIRouter()


@router.post("/topup-balance", response_model=BalanceTopUpResponse)
def topup_balance(
    request: BalanceTopUpRequest,
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db)
) -> Any:
    """Пополнение баланса пользователя"""
    try:
        logger.info(f"Попытка пополнения баланса для пользователя {current_user.email}, сумма: {request.amount}")
        
        # Проверяем данные карты (заглушка для демо)
        if not request.card_number or len(request.card_number) < 16:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Неверный номер карты"
            )
        
        if not request.expiry_month or not request.expiry_year:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Неверная дата истечения карты"
            )
        
        if not request.cvv or len(request.cvv) != 3:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Неверный CVV код"
            )
        
        # Создаем заказ на пополнение баланса
        order = Order(
            user_id=current_user.id,
            product_id=None,  # Для пополнения баланса
            plan_id=None,     # Для пополнения баланса
            amount=request.amount,
            status="pending"
        )
        db.add(order)
        db.flush()
        
        # Создаем платеж
        payment = Payment(
            order_id=order.id,
            user_id=current_user.id,
            amount=request.amount,
            payment_method="card",
            status="pending",
            payment_date=datetime.utcnow(),
            transaction_id=f"TXN_{order.id}_{int(datetime.utcnow().timestamp())}"
        )
        db.add(payment)
        
        # Генерируем код верификации (заглушка)
        verification_code = "1111"  # В реальности будет отправляться SMS
        
        # Сохраняем код верификации в сессии (в реальности в Redis)
        # Пока просто логируем
        logger.info(f"Код верификации для пользователя {current_user.email}: {verification_code}")
        
        db.commit()
        
        return BalanceTopUpResponse(
            success=True,
            message="Введите код верификации, отправленный на ваш телефон",
            verification_required=True,
            payment_id=payment.id,
            amount=request.amount
        )
        
    except Exception as e:
        logger.error(f"Ошибка при пополнении баланса: {str(e)}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ошибка при пополнении баланса"
        )


@router.post("/verify-payment", response_model=PaymentStatus)
def verify_payment(
    request: CardVerificationRequest,
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db)
) -> Any:
    """Верификация платежа по SMS коду"""
    try:
        logger.info(f"Попытка верификации платежа для пользователя {current_user.email}")
        
        # Проверяем код верификации (заглушка)
        if request.verification_code != "1111":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Неверный код верификации"
            )
        
        # Находим платеж
        payment = db.query(Payment).filter(
            Payment.id == request.payment_id,
            Payment.user_id == current_user.id,
            Payment.status == "pending"
        ).first()
        
        if not payment:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Платеж не найден"
            )
        
        # Обновляем статус платежа
        payment.status = "completed"
        
        # Обновляем статус заказа
        order = db.query(Order).filter(Order.id == payment.order_id).first()
        if order:
            order.status = "completed"
        
        # Пополняем баланс пользователя
        current_user.balance += payment.amount
        
        db.commit()
        
        logger.info(f"Баланс пользователя {current_user.email} пополнен на {payment.amount}")
        
        return PaymentStatus(
            success=True,
            message=f"Баланс успешно пополнен на {payment.amount} ₽",
            new_balance=current_user.balance,
            payment_id=payment.id
        )
        
    except Exception as e:
        logger.error(f"Ошибка при верификации платежа: {str(e)}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ошибка при верификации платежа"
        )


@router.get("/balance", response_model=dict)
def get_balance(
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db)
) -> Any:
    """Получение текущего баланса пользователя"""
    return {
        "balance": current_user.balance,
        "currency": "RUB"
    }


@router.get("/topup-statistics", response_model=dict)
def get_topup_statistics(
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db)
) -> Any:
    """Получение статистики пополнений (только для админов)"""
    # Проверяем, является ли пользователь админом
    admin_role = db.query(UserRole).filter(
        UserRole.user_id == current_user.id,
        UserRole.role_id == 1  # ID роли admin
    ).first()
    
    if not admin_role:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Доступ запрещен. Требуются права администратора"
        )
    
    # Получаем общую статистику пополнений
    total_topups = db.query(func.sum(Payment.amount)).filter(
        Payment.status == "completed",
        Payment.payment_method == "card"
    ).scalar() or 0
    
    # Количество успешных пополнений
    topup_count = db.query(func.count(Payment.id)).filter(
        Payment.status == "completed",
        Payment.payment_method == "card"
    ).scalar() or 0
    
    # Статистика по месяцам
    monthly_stats = db.query(
        func.date_trunc('month', Payment.payment_date).label('month'),
        func.sum(Payment.amount).label('total'),
        func.count(Payment.id).label('count')
    ).filter(
        Payment.status == "completed",
        Payment.payment_method == "card"
    ).group_by(
        func.date_trunc('month', Payment.payment_date)
    ).order_by(
        func.date_trunc('month', Payment.payment_date).desc()
    ).limit(12).all()
    
    return {
        "total_topups": float(total_topups),
        "topup_count": topup_count,
        "currency": "RUB",
        "monthly_statistics": [
            {
                "month": stat.month.strftime("%Y-%m"),
                "total": float(stat.total),
                "count": stat.count
            }
            for stat in monthly_stats
        ]
    }
