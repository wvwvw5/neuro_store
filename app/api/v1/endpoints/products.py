"""
Эндпоинты для управления продуктами (нейросетями)
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db

router = APIRouter()


@router.get("/")
async def get_products(db: Session = Depends(get_db)):
    """Получение списка всех продуктов"""
    # TODO: Реализовать получение продуктов
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Получение продуктов пока не реализовано"
    )


@router.get("/{product_id}")
async def get_product(product_id: int, db: Session = Depends(get_db)):
    """Получение продукта по ID"""
    # TODO: Реализовать получение продукта
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Получение продукта пока не реализовано"
    )


@router.get("/{product_id}/plans")
async def get_product_plans(product_id: int, db: Session = Depends(get_db)):
    """Получение планов для продукта"""
    # TODO: Реализовать получение планов
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Получение планов пока не реализовано"
    )
