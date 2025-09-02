"""
Административные эндпоинты (только для админов)
"""

from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.dependencies.roles import require_admin, require_moderator_or_admin
from app.models.user import User
from app.models.role import Role
from app.models.subscription import Subscription
from app.models.order import Order
from app.schemas.auth import UserResponse

router = APIRouter(prefix="/admin", tags=["Администрирование"])


@router.get("/protected-route")
def protected_admin_route(
    current_user: User = Depends(require_admin)
) -> Any:
    """Защищенный маршрут только для администраторов"""
    return {
        "message": "Добро пожаловать в админ-панель!",
        "user": {
            "id": current_user.id,
            "email": current_user.email,
            "name": f"{current_user.first_name} {current_user.last_name}"
        },
        "access_level": "admin"
    }


@router.get("/users", response_model=List[UserResponse])
def get_all_users(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
) -> Any:
    """Получение списка всех пользователей (только для админов)"""
    users = db.query(User).offset(skip).limit(limit).all()
    return users


@router.get("/users/{user_id}", response_model=UserResponse)
def get_user_by_id(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
) -> Any:
    """Получение пользователя по ID (только для админов)"""
    user = db.query(User).filter(User.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Пользователь не найден"
        )
    
    return user


@router.put("/users/{user_id}/activate")
def activate_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
) -> Any:
    """Активация пользователя (только для админов)"""
    user = db.query(User).filter(User.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Пользователь не найден"
        )
    
    user.is_active = True
    db.commit()
    
    return {"message": f"Пользователь {user.email} успешно активирован"}


@router.put("/users/{user_id}/deactivate")
def deactivate_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
) -> Any:
    """Деактивация пользователя (только для админов)"""
    user = db.query(User).filter(User.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Пользователь не найден"
        )
    
    if user.id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Нельзя деактивировать самого себя"
        )
    
    user.is_active = False
    db.commit()
    
    return {"message": f"Пользователь {user.email} успешно деактивирован"}


@router.get("/statistics")
def get_admin_statistics(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_moderator_or_admin)
) -> Any:
    """Получение статистики для админов и модераторов"""
    total_users = db.query(User).count()
    active_users = db.query(User).filter(User.is_active == True).count()
    total_subscriptions = db.query(Subscription).count()
    active_subscriptions = db.query(Subscription).filter(Subscription.status == "active").count()
    total_orders = db.query(Order).count()
    completed_orders = db.query(Order).filter(Order.status == "completed").count()
    
    return {
        "users": {
            "total": total_users,
            "active": active_users,
            "inactive": total_users - active_users
        },
        "subscriptions": {
            "total": total_subscriptions,
            "active": active_subscriptions,
            "inactive": total_subscriptions - active_subscriptions
        },
        "orders": {
            "total": total_orders,
            "completed": completed_orders,
            "pending": total_orders - completed_orders
        }
    }
