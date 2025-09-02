"""
Эндпоинты для управления ролями
"""

from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.dependencies.roles import require_admin
from app.models.user import User
from app.models.role import Role
from app.models.user_role import UserRole
from app.schemas.user import RoleCreate, RoleResponse, UserRoleAssign

router = APIRouter(prefix="/roles", tags=["Роли"])


@router.get("/", response_model=List[RoleResponse])
def get_roles(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
) -> Any:
    """Получение списка всех ролей (только для админов)"""
    roles = db.query(Role).filter(Role.is_active).all()
    return roles


@router.post("/", response_model=RoleResponse, status_code=status.HTTP_201_CREATED)
def create_role(
    role_data: RoleCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
) -> Any:
    """Создание новой роли (только для админов)"""
    # Проверяем, что роль с таким именем не существует
    existing_role = db.query(Role).filter(Role.name == role_data.name).first()
    if existing_role:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Роль с таким именем уже существует"
        )
    
    role = Role(**role_data.dict())
    db.add(role)
    db.commit()
    db.refresh(role)
    
    return role


@router.post("/assign", status_code=status.HTTP_201_CREATED)
def assign_role_to_user(
    assignment: UserRoleAssign,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
) -> Any:
    """Назначение роли пользователю (только для админов)"""
    # Проверяем существование пользователя
    user = db.query(User).filter(User.id == assignment.user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Пользователь не найден"
        )
    
    # Проверяем существование роли
    role = db.query(Role).filter(Role.id == assignment.role_id).first()
    if not role:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Роль не найдена"
        )
    
    # Проверяем, что роль еще не назначена
    existing_assignment = db.query(UserRole).filter(
        UserRole.user_id == assignment.user_id,
        UserRole.role_id == assignment.role_id
    ).first()
    
    if existing_assignment:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Роль уже назначена этому пользователю"
        )
    
    # Создаем назначение роли
    user_role = UserRole(
        user_id=assignment.user_id,
        role_id=assignment.role_id
    )
    
    db.add(user_role)
    db.commit()
    
    return {
        "message": f"Роль '{role.name}' успешно назначена пользователю {user.email}"
    }


@router.delete("/revoke", status_code=status.HTTP_204_NO_CONTENT)
def revoke_role_from_user(
    assignment: UserRoleAssign,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
):
    """Отзыв роли у пользователя (только для админов)"""
    user_role = db.query(UserRole).filter(
        UserRole.user_id == assignment.user_id,
        UserRole.role_id == assignment.role_id
    ).first()
    
    if not user_role:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Назначение роли не найдено"
        )
    
    db.delete(user_role)
    db.commit()


@router.get("/user/{user_id}", response_model=List[RoleResponse])
def get_user_roles(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
) -> Any:
    """Получение ролей пользователя (только для админов)"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Пользователь не найден"
        )
    
    user_roles = db.query(UserRole).filter(UserRole.user_id == user_id).all()
    roles = []
    
    for user_role in user_roles:
        role = db.query(Role).filter(Role.id == user_role.role_id).first()
        if role and role.is_active:
            roles.append(role)
    
    return roles
