from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.core.limiter import get_limiter
from app.core.logging_config import get_logger
from app.dependencies.roles import require_admin
from app.models.plan import Plan
from app.models.product import Product
from app.models.product_plan import ProductPlan
from app.models.user import User
from app.schemas.product import (
    PlanResponse,
    ProductCreate,
    ProductResponse,
    ProductUpdate,
)
from app.services.cache import cache, invalidate_products_cache

logger = get_logger("neuro_store.products")

router = APIRouter(
    prefix="/products",
    tags=["Продукты"],
    responses={
        404: {"description": "Продукт не найден"},
        429: {"description": "Превышен лимит запросов"},
    },
)


@router.get(
    "/",
    response_model=List[ProductResponse],
    summary="Список продуктов",
    description="Получение списка всех активных нейросетевых продуктов с возможностью фильтрации по категории",
)
@cache(ttl=settings.CACHE_TTL_PRODUCTS, key_prefix="products")
async def get_products(
    skip: int = 0,
    limit: int = 100,
    category: str = None,
    db: Session = Depends(get_db),
    limiter = Depends(get_limiter),
) -> Any:
    """Получение списка всех продуктов с кэшированием"""
    try:
        logger.info("Fetching products", skip=skip, limit=limit, category=category)

        query = db.query(Product).filter(Product.is_active)

        if category:
            query = query.filter(Product.category == category)

        products = query.offset(skip).limit(limit).all()

        logger.info("Products fetched successfully", count=len(products))
        return products

    except Exception as e:
        logger.error("Error fetching products", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ошибка получения списка продуктов",
        )


@router.get("/{product_id}", response_model=ProductResponse)
def get_product(product_id: int, db: Session = Depends(get_db)) -> Any:
    """Получение продукта по ID"""
    product = db.query(Product).filter(Product.id == product_id).first()

    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Продукт не найден"
        )

    return product


@router.get(
    "/{product_id}/plans",
    response_model=List[PlanResponse],
    summary="Планы продукта",
    description="Получение всех доступных тарифных планов для конкретного продукта",
)
@cache(ttl=settings.CACHE_TTL_PLANS, key_prefix="product_plans")
async def get_product_plans(
    product_id: int,
    db: Session = Depends(get_db),
    limiter = Depends(get_limiter),
) -> Any:
    """Получение планов для конкретного продукта с кэшированием"""
    try:
        logger.info("Fetching product plans", product_id=product_id)

        # Проверяем существование продукта
        product = db.query(Product).filter(Product.id == product_id).first()
        if not product:
            logger.warning("Product not found", product_id=product_id)
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Продукт не найден"
            )

        # Получаем планы через связующую таблицу
        product_plans = (
            db.query(ProductPlan)
            .filter(ProductPlan.product_id == product_id, ProductPlan.is_available)
            .all()
        )

        plans = []
        for pp in product_plans:
            plan = db.query(Plan).filter(Plan.id == pp.plan_id).first()
            if plan and plan.is_active:
                plans.append(plan)

        logger.info(
            "Product plans fetched successfully",
            product_id=product_id,
            plans_count=len(plans),
        )
        return plans

    except HTTPException:
        raise
    except Exception as e:
        logger.error(
            "Error fetching product plans", product_id=product_id, error=str(e)
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ошибка получения планов продукта",
        )


@router.post(
    "/",
    response_model=ProductResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Создание продукта",
    description="Создание нового нейросетевого продукта (только для администраторов)",
)
async def create_product(
    product_data: ProductCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
) -> Any:
    """Создание нового продукта (только для админов)"""
    try:
        logger.info(
            "Creating new product",
            user_id=current_user.id,
            product_name=product_data.name,
        )

        product = Product(**product_data.dict())
        db.add(product)
        db.commit()
        db.refresh(product)

        # Инвалидируем кэш продуктов
        await invalidate_products_cache()

        logger.info(
            "Product created successfully",
            product_id=product.id,
            product_name=product.name,
            created_by=current_user.id,
        )

        return product

    except Exception as e:
        logger.error("Error creating product", user_id=current_user.id, error=str(e))
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ошибка создания продукта",
        )


@router.put("/{product_id}", response_model=ProductResponse)
def update_product(
    product_id: int,
    product_data: ProductUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin),
) -> Any:
    """Обновление продукта (только для админов)"""

    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Продукт не найден"
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
    current_user: User = Depends(require_admin),
):
    """Удаление продукта (только для админов)"""

    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Продукт не найден"
        )

    # Мягкое удаление - просто деактивируем
    product.is_active = False
    db.commit()
