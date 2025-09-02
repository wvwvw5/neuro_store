-- Создание таблиц базы данных Neuro Store
-- Выполняется автоматически при первом запуске Docker контейнера

-- Создание таблицы ролей
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Создание таблицы пользователей
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    balance NUMERIC(12,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Создание таблицы связей пользователей и ролей
CREATE TABLE IF NOT EXISTS user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, role_id)
);

-- Создание таблицы продуктов
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(100),
    api_endpoint TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Создание таблицы тарифных планов
CREATE TABLE IF NOT EXISTS plans (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL,
    duration_days INTEGER NOT NULL,
    max_requests_per_month INTEGER,
    features TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Создание таблицы связей продуктов и планов
CREATE TABLE IF NOT EXISTS product_plans (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    plan_id BIGINT NOT NULL REFERENCES plans(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(product_id, plan_id)
);

-- Создание таблицы подписок
CREATE TABLE IF NOT EXISTS subscriptions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    plan_id BIGINT NOT NULL REFERENCES plans(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    auto_renew BOOLEAN DEFAULT false,
    requests_used INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Создание таблицы заказов
CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    plan_id BIGINT NOT NULL REFERENCES plans(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    amount NUMERIC(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RUB',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Создание таблицы платежей
CREATE TABLE IF NOT EXISTS payments (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    amount NUMERIC(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RUB',
    payment_method VARCHAR(50),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    payment_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Создание таблицы событий использования
CREATE TABLE IF NOT EXISTS usage_events (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    subscription_id BIGINT REFERENCES subscriptions(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    request_data JSONB,
    response_data JSONB,
    tokens_used INTEGER,
    cost NUMERIC(12,6),
    duration_ms INTEGER,
    status VARCHAR(50) DEFAULT 'success',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Создание таблицы аудита
CREATE TABLE IF NOT EXISTS audit_log (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT,
    action VARCHAR(20) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Создание индексов для улучшения производительности
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_usage_events_user_id ON usage_events(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_table_record ON audit_log(table_name, record_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_timestamp ON audit_log(timestamp);

-- Создание функции для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Создание триггеров для автоматического обновления updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_plans_updated_at BEFORE UPDATE ON plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Создание представлений для аналитики
CREATE OR REPLACE VIEW subscription_summary AS
SELECT 
    p.name as product_name,
    pl.name as plan_name,
    COUNT(s.id) as total_subscriptions,
    COUNT(CASE WHEN s.status = 'active' THEN 1 END) as active_subscriptions,
    AVG(pl.price) as avg_price,
    SUM(pl.price) as total_revenue
FROM products p
JOIN product_plans pp ON p.id = pp.product_id
JOIN plans pl ON pp.plan_id = pl.id
LEFT JOIN subscriptions s ON p.id = s.product_id AND pl.id = s.plan_id
WHERE p.is_active = true AND pl.is_active = true
GROUP BY p.id, p.name, pl.id, pl.name;

CREATE OR REPLACE VIEW user_activity AS
SELECT 
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    COUNT(s.id) as total_subscriptions,
    COUNT(CASE WHEN s.status = 'active' THEN 1 END) as active_subscriptions,
    SUM(o.amount) as total_spent,
    COUNT(ue.id) as total_requests
FROM users u
LEFT JOIN subscriptions s ON u.id = s.user_id
LEFT JOIN orders o ON u.id = o.user_id
LEFT JOIN usage_events ue ON u.id = ue.user_id
GROUP BY u.id, u.email, u.first_name, u.last_name;

CREATE OR REPLACE VIEW revenue_analytics AS
SELECT 
    DATE_TRUNC('month', o.created_at) as month,
    p.name as product_name,
    pl.name as plan_name,
    COUNT(o.id) as orders_count,
    SUM(o.amount) as total_revenue,
    AVG(o.amount) as avg_order_value
FROM orders o
JOIN products p ON o.product_id = p.id
JOIN plans pl ON o.plan_id = pl.id
WHERE o.status = 'completed'
GROUP BY DATE_TRUNC('month', o.created_at), p.id, p.name, pl.id, pl.name
ORDER BY month DESC, total_revenue DESC;
