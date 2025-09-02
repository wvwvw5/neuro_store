from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.user import User
from app.models.product import Product
from app.models.plan import Plan
from app.models.product_plan import ProductPlan
from app.api.v1.auth import get_current_user_from_token
from app.schemas.product import ProductCreate, ProductUpdate, ProductResponse, PlanResponse

router = APIRouter(prefix="/products", tags=["Продукты"])


@router.get("/", response_model=List[ProductResponse])
def get_products(
    skip: int = 0,
    limit: int = 100,
    category: str = None,
    db: Session = Depends(get_db)
) -> Any:
    """Получение списка всех продуктов"""
    query = db.query(Product).filter(Product.is_active == True)
    
    if category:
        query = query.filter(Product.category == category)
    
    products = query.offset(skip).limit(limit).all()
    return products


@router.get("/{product_id}", response_model=ProductResponse)
def get_product(product_id: int, db: Session = Depends(get_db)) -> Any:
    """Получение продукта по ID"""
    product = db.query(Product).filter(Product.id == product_id).first()
    
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Продукт не найден"
        )
    
    return product


@router.get("/{product_id}/plans", response_model=List[PlanResponse])
def get_product_plans(product_id: int, db: Session = Depends(get_db)) -> Any:
    """Получение планов для конкретного продукта"""
    # Проверяем существование продукта
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Продукт не найден"
        )
    
    # Получаем планы через связующую таблицу
    product_plans = db.query(ProductPlan).filter(
        ProductPlan.product_id == product_id,
        ProductPlan.is_available == True
    ).all()
    
    plans = []
    for pp in product_plans:
        plan = db.query(Plan).filter(Plan.id == pp.plan_id).first()
        if plan and plan.is_active:
            plans.append(plan)
    
    return plans


@router.post("/", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def create_product(
    product_data: ProductCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
) -> Any:
    """Создание нового продукта (только для админов)"""
    # TODO: Проверка прав доступа (админ)
    
    product = Product(**product_data.dict())
    db.add(product)
    db.commit()
    db.refresh(product)
    
    return product


@router.put("/{product_id}", response_model=ProductResponse)
def update_product(
    product_id: int,
    product_data: ProductUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
) -> Any:
    """Обновление продукта (только для админов)"""
    # TODO: Проверка прав доступа (админ)
    
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Продукт не найден"
        )
    
    for field, value in product_data.dict(exclude_unset=True).items():
        setattr(product, field, value)
    
    db.commit()
    db.refresh(product)
    
    return product


@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(
    product_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
) -> Any:
    """Удаление продукта (только для админов)"""
    # TODO: Проверка прав доступа (админ)
    
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Продукт не найден"
        )
    
    # Мягкое удаление - просто деактивируем
    product.is_active = False
    db.commit()
    
    return None
