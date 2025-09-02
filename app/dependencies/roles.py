"""
Зависимости для проверки ролей пользователей
"""

from typing import List

from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.v1.auth import get_current_user_from_token
from app.core.database import get_db
from app.models.role import Role
from app.models.user import User
from app.models.user_role import UserRole


def get_current_user_roles(
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db),
) -> List[str]:
    """Получение списка ролей текущего пользователя"""
    user_roles = db.query(UserRole).filter(UserRole.user_id == current_user.id).all()
    roles = []

    for user_role in user_roles:
        role = db.query(Role).filter(Role.id == user_role.role_id).first()
        if role and role.is_active:
            roles.append(role.name)

    return roles


def require_role(required_role: str):
    """Декоратор для проверки конкретной роли"""

    def role_checker(
        current_user: User = Depends(get_current_user_from_token),
        db: Session = Depends(get_db),
    ) -> User:
        # Получаем роли пользователя
        user_roles = get_current_user_roles(current_user, db)

        if required_role not in user_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Недостаточно прав. Требуется роль: {required_role}",
            )

        return current_user

    return role_checker


def require_admin(
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db),
) -> User:
    """Проверка роли администратора"""
    user_roles = get_current_user_roles(current_user, db)

    if "admin" not in user_roles:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Недостаточно прав. Требуется роль администратора.",
        )

    return current_user


def require_moderator_or_admin(
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db),
) -> User:
    """Проверка роли модератора или администратора"""
    user_roles = get_current_user_roles(current_user, db)

    if not any(role in user_roles for role in ["admin", "moderator"]):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Недостаточно прав. Требуется роль модератора или администратора.",
        )

    return current_user


def check_user_permissions(
    resource_user_id: int,
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db),
) -> User:
    """Проверка, что пользователь может работать с ресурсом (свой ресурс или админ)"""
    user_roles = get_current_user_roles(current_user, db)

    # Админ может работать с любыми ресурсами
    if "admin" in user_roles:
        return current_user

    # Пользователь может работать только со своими ресурсами
    if current_user.id != resource_user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Недостаточно прав для доступа к этому ресурсу",
        )

    return current_user
