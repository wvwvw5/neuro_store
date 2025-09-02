from datetime import datetime, timedelta
from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.user import User
from app.models.subscription import Subscription
from app.models.product import Product
from app.models.plan import Plan
from app.models.order import Order
from app.models.payment import Payment
from app.api.v1.auth import get_current_user_from_token
from app.schemas.subscription import (
    SubscriptionCreate,
    SubscriptionResponse,
    SubscriptionStatus,
)

router = APIRouter(prefix="/subscriptions", tags=["Подписки"])


@router.get("/", response_model=List[SubscriptionResponse])
def get_user_subscriptions(
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db),
) -> Any:
    """Получение подписок текущего пользователя"""
    subscriptions = (
        db.query(Subscription).filter(Subscription.user_id == current_user.id).all()
    )

    return subscriptions


@router.get("/{subscription_id}", response_model=SubscriptionResponse)
def get_subscription(
    subscription_id: int,
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db),
) -> Any:
    """Получение конкретной подписки пользователя"""
    subscription = (
        db.query(Subscription)
        .filter(
            Subscription.id == subscription_id, Subscription.user_id == current_user.id
        )
        .first()
    )

    if not subscription:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Подписка не найдена"
        )

    return subscription


@router.post(
    "/", response_model=SubscriptionResponse, status_code=status.HTTP_201_CREATED
)
def create_subscription(
    subscription_data: SubscriptionCreate,
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db),
) -> Any:
    """Создание новой подписки"""
    # Проверяем существование продукта и плана
    product = (
        db.query(Product)
        .filter(Product.id == subscription_data.product_id, Product.is_active)
        .first()
    )

    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Продукт не найден или неактивен",
        )

    plan = (
        db.query(Plan)
        .filter(Plan.id == subscription_data.plan_id, Plan.is_active)
        .first()
    )

    if not plan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="План не найден или неактивен"
        )

    # Проверяем, что у пользователя достаточно средств
    if current_user.balance < plan.price:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Недостаточно средств на балансе",
        )

    # Создаем подписку
    start_date = datetime.utcnow()
    end_date = start_date + timedelta(days=plan.duration_days)

    subscription = Subscription(
        user_id=current_user.id,
        product_id=subscription_data.product_id,
        plan_id=subscription_data.plan_id,
        start_date=start_date,
        end_date=end_date,
        status="active",
    )

    # Списываем средства с баланса
    current_user.balance -= plan.price

    # Создаем заказ
    order = Order(
        user_id=current_user.id,
        product_id=subscription_data.product_id,
        plan_id=subscription_data.plan_id,
        amount=plan.price,
        status="completed",
    )

    # Сначала сохраняем заказ, чтобы получить его ID
    db.add(order)
    db.flush()  # Получаем ID без коммита

    # Теперь создаем платеж с правильным order_id
    payment = Payment(
        order_id=order.id,
        user_id=current_user.id,
        amount=plan.price,
        payment_method="balance",
        status="completed",
        payment_date=datetime.utcnow(),
    )

    # Добавляем все остальное
    db.add(subscription)
    db.add(payment)
    db.commit()

    db.refresh(subscription)
    return subscription


@router.put("/{subscription_id}/cancel", response_model=SubscriptionResponse)
def cancel_subscription(
    subscription_id: int,
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db),
) -> Any:
    """Отмена подписки"""
    subscription = (
        db.query(Subscription)
        .filter(
            Subscription.id == subscription_id, Subscription.user_id == current_user.id
        )
        .first()
    )

    if not subscription:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Подписка не найдена"
        )

    if subscription.status != "active":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Подписка уже неактивна"
        )

    subscription.status = "cancelled"
    subscription.auto_renew = False

    db.commit()
    db.refresh(subscription)

    return subscription


@router.get("/{subscription_id}/status", response_model=SubscriptionStatus)
def get_subscription_status(
    subscription_id: int,
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db),
) -> Any:
    """Получение статуса подписки"""
    subscription = (
        db.query(Subscription)
        .filter(
            Subscription.id == subscription_id, Subscription.user_id == current_user.id
        )
        .first()
    )

    if not subscription:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Подписка не найдена"
        )

    # Проверяем, не истекла ли подписка
    if subscription.status == "active" and datetime.utcnow() > subscription.end_date:
        subscription.status = "expired"
        db.commit()

    return SubscriptionStatus(
        id=subscription.id,
        status=subscription.status,
        start_date=subscription.start_date,
        end_date=subscription.end_date,
        days_left=(subscription.end_date - datetime.utcnow()).days
        if subscription.status == "active"
        else 0,
        requests_used=subscription.requests_used,
        auto_renew=subscription.auto_renew,
    )
