from datetime import timedelta
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi_limiter.depends import RateLimiter
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.core.security import (
    verify_password,
    create_access_token,
    get_password_hash,
    verify_token,
)
from app.core.logging_config import get_logger, log_auth_event
from app.models.user import User
from app.models.role import Role
from app.models.user_role import UserRole
from app.schemas.auth import Token, UserCreate, UserResponse

logger = get_logger("neuro_store.auth")

router = APIRouter(
    prefix="/auth",
    tags=["Аутентификация"],
    responses={
        401: {"description": "Ошибка аутентификации"},
        429: {"description": "Превышен лимит запросов"},
    },
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


async def get_current_user_from_token(
    token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)
) -> User:
    """Получение текущего пользователя из токена"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Не удалось проверить учетные данные",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = verify_token(token)
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except Exception:
        raise credentials_exception

    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception

    return user


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Регистрация пользователя",
    description="Создание нового аккаунта пользователя с хэшированием пароля",
)
async def register(
    user_data: UserCreate,
    db: Session = Depends(get_db),
    _: None = Depends(RateLimiter(times=3, seconds=60)),
) -> Any:
    """Регистрация нового пользователя с rate limiting"""
    try:
        logger.info("User registration attempt", email=user_data.email)

        # Проверяем, что email не занят
        existing_user = db.query(User).filter(User.email == user_data.email).first()
        if existing_user:
            log_auth_event(
                "register", user_data.email, False, {"reason": "email_exists"}
            )
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Пользователь с таким email уже существует",
            )

        # Создаем пользователя
        user = User(
            email=user_data.email,
            password_hash=get_password_hash(user_data.password),
            first_name=user_data.first_name,
            last_name=user_data.last_name,
            phone=user_data.phone,
        )

        db.add(user)
        db.commit()
        db.refresh(user)

        log_auth_event("register", user.email, True, {"user_id": user.id})
        logger.info("User registered successfully", user_id=user.id, email=user.email)

        return UserResponse(
            id=user.id,
            email=user.email,
            first_name=user.first_name,
            last_name=user.last_name,
            phone=user.phone,
            balance=float(user.balance),
            is_active=user.is_active,
            is_verified=user.is_verified,
            created_at=user.created_at,
            updated_at=user.updated_at,
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Registration error", email=user_data.email, error=str(e))
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ошибка регистрации пользователя",
        )


@router.post(
    "/login",
    response_model=Token,
    summary="Вход в систему",
    description="Аутентификация пользователя и получение JWT токена",
)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
    _: None = Depends(RateLimiter(times=5, seconds=60)),
) -> Any:
    """Вход в систему с rate limiting"""
    try:
        logger.info("Login attempt", email=form_data.username)

        # Ищем пользователя по email
        user = db.query(User).filter(User.email == form_data.username).first()

        if not user or not verify_password(form_data.password, user.password_hash):
            log_auth_event(
                "login", form_data.username, False, {"reason": "invalid_credentials"}
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Неверный email или пароль",
                headers={"WWW-Authenticate": "Bearer"},
            )

        if not user.is_active:
            log_auth_event("login", user.email, False, {"reason": "user_inactive"})
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, detail="Пользователь неактивен"
            )

        # Создаем токен доступа (1 час)
        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user.email}, expires_delta=access_token_expires
        )

        log_auth_event("login", user.email, True, {"user_id": user.id})
        logger.info("User logged in successfully", user_id=user.id, email=user.email)

        return Token(access_token=access_token, token_type="bearer")

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Login error", email=form_data.username, error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ошибка входа в систему",
        )


@router.get("/me", response_model=UserResponse)
def get_current_user(current_user: User = Depends(get_current_user_from_token)) -> Any:
    """Получение информации о текущем пользователе"""
    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        first_name=current_user.first_name,
        last_name=current_user.last_name,
        phone=current_user.phone,
        is_active=current_user.is_active,
        created_at=current_user.created_at,
    )


@router.get("/me/roles")
def get_current_user_roles(
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db),
) -> Any:
    """Получение ролей текущего пользователя"""
    user_roles = db.query(UserRole).filter(UserRole.user_id == current_user.id).all()
    roles = []

    for user_role in user_roles:
        role = db.query(Role).filter(Role.id == user_role.role_id).first()
        if role and role.is_active:
            roles.append(role.name)

    return {
        "user_id": current_user.id,
        "email": current_user.email,
        "roles": roles,
        "is_admin": "admin" in roles,
        "is_moderator": "moderator" in roles,
    }
