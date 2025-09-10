-- ========================================
-- DDL для базы данных Neuro Store
-- Создание таблиц и индексов
-- ========================================

-- Создание базы данных
CREATE DATABASE IF NOT EXISTS neuro_store
    WITH 
    OWNER = neuro_user
    ENCODING = 'UTF8'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Подключение к базе данных
\c neuro_store;

-- Создание расширений
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ========================================
-- ТАБЛИЦЫ
-- ========================================

-- Таблица ролей пользователей
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    permissions JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица пользователей
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    role_id INTEGER NOT NULL REFERENCES roles(id),
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255),
    password_reset_token VARCHAR(255),
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица категорий продуктов
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    slug VARCHAR(100) NOT NULL UNIQUE,
    icon VARCHAR(100),
    color VARCHAR(7),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица продуктов (нейросетей)
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    slug VARCHAR(255) NOT NULL UNIQUE,
    category_id INTEGER NOT NULL REFERENCES categories(id),
    logo_url VARCHAR(500),
    website_url VARCHAR(500),
    api_documentation_url VARCHAR(500),
    features JSONB DEFAULT '[]',
    tags TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица тарифных планов
CREATE TABLE IF NOT EXISTS plans (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    billing_cycle VARCHAR(20) NOT NULL, -- monthly, yearly, lifetime
    features JSONB DEFAULT '[]',
    limits JSONB DEFAULT '{}',
    is_popular BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица подписок пользователей
CREATE TABLE IF NOT EXISTS subscriptions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    plan_id INTEGER NOT NULL REFERENCES plans(id),
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- active, expired, cancelled, suspended
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    auto_renew BOOLEAN DEFAULT TRUE,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending', -- pending, completed, failed, refunded
    amount_paid DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    api_key VARCHAR(255),
    usage_limits JSONB DEFAULT '{}',
    usage_current JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица платежей
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    subscription_id INTEGER NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    payment_method VARCHAR(50) NOT NULL,
    payment_provider VARCHAR(50) NOT NULL, -- stripe, yookassa, etc.
    transaction_id VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending, completed, failed, refunded
    description TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица API ключей
CREATE TABLE IF NOT EXISTS api_keys (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subscription_id INTEGER REFERENCES subscriptions(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    key_hash VARCHAR(255) NOT NULL UNIQUE,
    permissions JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT TRUE,
    last_used TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица логов API запросов
CREATE TABLE IF NOT EXISTS api_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    subscription_id INTEGER REFERENCES subscriptions(id),
    api_key_id INTEGER REFERENCES api_keys(id),
    endpoint VARCHAR(255) NOT NULL,
    method VARCHAR(10) NOT NULL,
    status_code INTEGER NOT NULL,
    response_time_ms INTEGER,
    request_size INTEGER,
    response_size INTEGER,
    ip_address INET,
    user_agent TEXT,
    request_headers JSONB,
    response_headers JSONB,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица уведомлений
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- email, push, sms
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- ИНДЕКСЫ
-- ========================================

-- Индексы для таблицы users
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- Индексы для таблицы products
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_slug ON products(slug);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_tags ON products USING GIN(tags);

-- Индексы для таблицы plans
CREATE INDEX IF NOT EXISTS idx_plans_product_id ON plans(product_id);
CREATE INDEX IF NOT EXISTS idx_plans_is_active ON plans(is_active);
CREATE INDEX IF NOT EXISTS idx_plans_price ON plans(price);

-- Индексы для таблицы subscriptions
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_product_id ON subscriptions(product_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_plan_id ON subscriptions(plan_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_end_date ON subscriptions(end_date);

-- Индексы для таблицы payments
CREATE INDEX IF NOT EXISTS idx_payments_subscription_id ON payments(subscription_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at);

-- Индексы для таблицы api_keys
CREATE INDEX IF NOT EXISTS idx_api_keys_user_id ON api_keys(user_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_subscription_id ON api_keys(subscription_id);
CREATE INDEX IF NOT EXISTS idx_api_keys_is_active ON api_keys(is_active);

-- Индексы для таблицы api_logs
CREATE INDEX IF NOT EXISTS idx_api_logs_user_id ON api_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_api_logs_subscription_id ON api_logs(subscription_id);
CREATE INDEX IF NOT EXISTS idx_api_logs_created_at ON api_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_api_logs_endpoint ON api_logs(endpoint);
CREATE INDEX IF NOT EXISTS idx_api_logs_status_code ON api_logs(status_code);

-- Индексы для таблицы notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);

-- ========================================
-- ОГРАНИЧЕНИЯ
-- ========================================

-- Ограничения для таблицы users
ALTER TABLE users ADD CONSTRAINT chk_users_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
ALTER TABLE users ADD CONSTRAINT chk_users_username CHECK (username ~* '^[a-zA-Z0-9_-]{3,50}$');

-- Ограничения для таблицы products
ALTER TABLE products ADD CONSTRAINT chk_products_price_positive CHECK (id > 0);

-- Ограничения для таблицы plans
ALTER TABLE plans ADD CONSTRAINT chk_plans_price_positive CHECK (price >= 0);
ALTER TABLE plans ADD CONSTRAINT chk_plans_billing_cycle CHECK (billing_cycle IN ('monthly', 'yearly', 'lifetime'));

-- Ограничения для таблицы subscriptions
ALTER TABLE subscriptions ADD CONSTRAINT chk_subscriptions_status CHECK (status IN ('active', 'expired', 'cancelled', 'suspended'));
ALTER TABLE subscriptions ADD CONSTRAINT chk_subscriptions_dates CHECK (start_date < end_date OR end_date IS NULL);

-- Ограничения для таблицы payments
ALTER TABLE payments ADD CONSTRAINT chk_payments_amount_positive CHECK (amount > 0);
ALTER TABLE payments ADD CONSTRAINT chk_payments_status CHECK (status IN ('pending', 'completed', 'failed', 'refunded'));

-- Ограничения для таблицы api_logs
ALTER TABLE api_logs ADD CONSTRAINT chk_api_logs_method CHECK (method IN ('GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'));
ALTER TABLE api_logs ADD CONSTRAINT chk_api_logs_status_code CHECK (status_code >= 100 AND status_code < 600);

-- ========================================
-- КОММЕНТАРИИ
-- ========================================

COMMENT ON TABLE roles IS 'Роли пользователей в системе';
COMMENT ON TABLE users IS 'Пользователи системы';
COMMENT ON TABLE categories IS 'Категории продуктов (нейросетей)';
COMMENT ON TABLE products IS 'Продукты (нейросети)';
COMMENT ON TABLE plans IS 'Тарифные планы для продуктов';
COMMENT ON TABLE subscriptions IS 'Подписки пользователей на продукты';
COMMENT ON TABLE payments IS 'Платежи за подписки';
COMMENT ON TABLE api_keys IS 'API ключи для доступа к нейросетям';
COMMENT ON TABLE api_logs IS 'Логи API запросов';
COMMENT ON TABLE notifications IS 'Уведомления пользователей';
