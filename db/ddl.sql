-- =====================================================
-- DDL скрипт для создания базы данных магазина подписок на нейросети
-- PostgreSQL 14+
-- =====================================================

-- Создание базы данных (выполнить отдельно)
-- CREATE DATABASE neuro_store;

-- Подключение к базе данных
-- \c neuro_store;

-- Расширение для UUID (если потребуется)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- Создание таблиц
-- =====================================================

-- 1. Таблица пользователей
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE users IS 'Пользователи системы';
COMMENT ON COLUMN users.email IS 'Email пользователя для входа';
COMMENT ON COLUMN users.password_hash IS 'Хеш пароля пользователя';
COMMENT ON COLUMN users.first_name IS 'Имя пользователя';
COMMENT ON COLUMN users.last_name IS 'Фамилия пользователя';
COMMENT ON COLUMN users.is_active IS 'Статус активности пользователя';

-- 2. Таблица ролей
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE roles IS 'Роли пользователей в системе';
COMMENT ON COLUMN roles.name IS 'Название роли';
COMMENT ON COLUMN roles.description IS 'Описание роли';

-- 3. Таблица связи пользователей и ролей (M:M)
CREATE TABLE user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT fk_user_roles_user_id FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_user_roles_role_id FOREIGN KEY (role_id) 
        REFERENCES roles(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uk_user_role UNIQUE (user_id, role_id)
);

COMMENT ON TABLE user_roles IS 'Связь пользователей и ролей (многие ко многим)';
COMMENT ON COLUMN user_roles.user_id IS 'Ссылка на пользователя';
COMMENT ON COLUMN user_roles.role_id IS 'Ссылка на роль';
COMMENT ON COLUMN user_roles.assigned_at IS 'Дата назначения роли';

-- 4. Таблица продуктов (нейросети)
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE products IS 'Продукты (нейросети)';
COMMENT ON COLUMN products.name IS 'Название нейросети';
COMMENT ON COLUMN products.description IS 'Описание возможностей нейросети';
COMMENT ON COLUMN products.category IS 'Категория нейросети';
COMMENT ON COLUMN products.is_active IS 'Статус активности продукта';

-- 5. Таблица тарифных планов
CREATE TABLE plans (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL CHECK (price > 0),
    duration_days INTEGER NOT NULL CHECK (duration_days > 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE plans IS 'Тарифные планы подписок';
COMMENT ON COLUMN plans.name IS 'Название тарифного плана';
COMMENT ON COLUMN plans.description IS 'Описание плана';
COMMENT ON COLUMN plans.price IS 'Стоимость плана';
COMMENT ON COLUMN plans.duration_days IS 'Продолжительность в днях';

-- 6. Таблица связи продуктов и планов (M:M)
CREATE TABLE product_plans (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    plan_id BIGINT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT fk_product_plans_product_id FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_product_plans_plan_id FOREIGN KEY (plan_id) 
        REFERENCES plans(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uk_product_plan UNIQUE (product_id, plan_id)
);

COMMENT ON TABLE product_plans IS 'Связь продуктов и планов (многие ко многим)';
COMMENT ON COLUMN product_plans.product_id IS 'Ссылка на продукт';
COMMENT ON COLUMN product_plans.plan_id IS 'Ссылка на план';
COMMENT ON COLUMN product_plans.is_active IS 'Статус активности связи';

-- 7. Таблица подписок
CREATE TABLE subscriptions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_plan_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'expired', 'cancelled')),
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT fk_subscriptions_user_id FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_subscriptions_product_plan_id FOREIGN KEY (product_plan_id) 
        REFERENCES product_plans(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_subscription_dates CHECK (end_date > start_date)
);

COMMENT ON TABLE subscriptions IS 'Подписки пользователей на нейросети';
COMMENT ON COLUMN subscriptions.user_id IS 'Ссылка на пользователя';
COMMENT ON COLUMN subscriptions.product_plan_id IS 'Ссылка на связь продукт-план';
COMMENT ON COLUMN subscriptions.status IS 'Статус подписки';
COMMENT ON COLUMN subscriptions.start_date IS 'Дата начала подписки';
COMMENT ON COLUMN subscriptions.end_date IS 'Дата окончания подписки';

-- 8. Таблица заказов
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_plan_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT fk_orders_user_id FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_orders_product_plan_id FOREIGN KEY (product_plan_id) 
        REFERENCES product_plans(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMENT ON TABLE orders IS 'Заказы пользователей';
COMMENT ON COLUMN orders.user_id IS 'Ссылка на пользователя';
COMMENT ON COLUMN orders.product_plan_id IS 'Ссылка на связь продукт-план';
COMMENT ON COLUMN orders.status IS 'Статус заказа';
COMMENT ON COLUMN orders.amount IS 'Сумма заказа';

-- 9. Таблица платежей
CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    transaction_id VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT fk_payments_order_id FOREIGN KEY (order_id) 
        REFERENCES orders(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMENT ON TABLE payments IS 'Платежи по заказам';
COMMENT ON COLUMN payments.order_id IS 'Ссылка на заказ (1:1)';
COMMENT ON COLUMN payments.amount IS 'Сумма платежа';
COMMENT ON COLUMN payments.payment_method IS 'Способ оплаты';
COMMENT ON COLUMN payments.status IS 'Статус платежа';
COMMENT ON COLUMN payments.transaction_id IS 'Внешний идентификатор транзакции';

-- 10. Таблица событий использования
CREATE TABLE usage_events (
    id BIGSERIAL PRIMARY KEY,
    subscription_id BIGINT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT fk_usage_events_subscription_id FOREIGN KEY (subscription_id) 
        REFERENCES subscriptions(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMENT ON TABLE usage_events IS 'События использования нейросетей';
COMMENT ON COLUMN usage_events.subscription_id IS 'Ссылка на подписку';
COMMENT ON COLUMN usage_events.event_type IS 'Тип события использования';
COMMENT ON COLUMN usage_events.metadata IS 'Дополнительные данные события';

-- 11. Таблица журнала аудита
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    user_id BIGINT,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT fk_audit_log_user_id FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);

COMMENT ON TABLE audit_log IS 'Журнал аудита изменений в системе';
COMMENT ON COLUMN audit_log.table_name IS 'Название таблицы';
COMMENT ON COLUMN audit_log.operation IS 'Тип операции';
COMMENT ON COLUMN audit_log.old_values IS 'Предыдущие значения записи';
COMMENT ON COLUMN audit_log.new_values IS 'Новые значения записи';
COMMENT ON COLUMN audit_log.user_id IS 'Ссылка на пользователя, выполнившего операцию';

-- =====================================================
-- Создание индексов
-- =====================================================

-- Индексы для таблицы users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Индексы для таблицы user_roles
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);

-- Индексы для таблицы products
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_is_active ON products(is_active);
CREATE INDEX idx_products_created_at ON products(created_at);

-- Индексы для таблицы plans
CREATE INDEX idx_plans_price ON plans(price);
CREATE INDEX idx_plans_is_active ON plans(is_active);

-- Индексы для таблицы product_plans
CREATE INDEX idx_product_plans_product_id ON product_plans(product_id);
CREATE INDEX idx_product_plans_plan_id ON product_plans(plan_id);
CREATE INDEX idx_product_plans_is_active ON product_plans(is_active);

-- Индексы для таблицы subscriptions
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_start_date ON subscriptions(start_date);
CREATE INDEX idx_subscriptions_end_date ON subscriptions(end_date);
CREATE INDEX idx_subscriptions_product_plan_id ON subscriptions(product_plan_id);

-- Индексы для таблицы orders
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_product_plan_id ON orders(product_plan_id);

-- Индексы для таблицы payments
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);

-- Индексы для таблицы usage_events
CREATE INDEX idx_usage_events_subscription_id ON usage_events(subscription_id);
CREATE INDEX idx_usage_events_event_type ON usage_events(event_type);
CREATE INDEX idx_usage_events_created_at ON usage_events(created_at);

-- Индексы для таблицы audit_log
CREATE INDEX idx_audit_log_table_name ON audit_log(table_name);
CREATE INDEX idx_audit_log_operation ON audit_log(operation);
CREATE INDEX idx_audit_log_timestamp ON audit_log(timestamp);
CREATE INDEX idx_audit_log_user_id ON audit_log(user_id);

-- =====================================================
-- Создание представлений (VIEW)
-- =====================================================

-- Представление для отчета по активным подпискам
CREATE VIEW active_subscriptions_report AS
SELECT 
    s.id as subscription_id,
    u.email as user_email,
    u.first_name,
    u.last_name,
    p.name as product_name,
    pl.name as plan_name,
    pl.price,
    s.start_date,
    s.end_date,
    s.status,
    CASE 
        WHEN s.end_date < NOW() THEN 'expired'
        WHEN s.end_date - NOW() < INTERVAL '7 days' THEN 'expiring_soon'
        ELSE 'active'
    END as subscription_status
FROM subscriptions s
JOIN users u ON s.user_id = u.id
JOIN product_plans pp ON s.product_plan_id = pp.id
JOIN products p ON pp.product_id = p.id
JOIN plans pl ON pp.plan_id = pl.id
WHERE s.status = 'active'
ORDER BY s.end_date;

COMMENT ON VIEW active_subscriptions_report IS 'Отчет по активным подпискам с информацией о пользователях и продуктах';

-- Представление для отчета по выручке
CREATE VIEW revenue_report AS
SELECT 
    DATE_TRUNC('month', o.created_at) as month,
    p.name as product_name,
    pl.name as plan_name,
    COUNT(o.id) as orders_count,
    SUM(o.amount) as total_revenue,
    AVG(o.amount) as avg_order_value,
    COUNT(CASE WHEN o.status = 'completed' THEN 1 END) as completed_orders,
    COUNT(CASE WHEN o.status = 'cancelled' THEN 1 END) as cancelled_orders
FROM orders o
JOIN product_plans pp ON o.product_plan_id = pp.id
JOIN products p ON pp.product_id = p.id
JOIN plans pl ON pp.plan_id = pl.id
GROUP BY DATE_TRUNC('month', o.created_at), p.name, pl.name
ORDER BY month DESC, total_revenue DESC;

COMMENT ON VIEW revenue_report IS 'Отчет по выручке по месяцам, продуктам и планам';

-- Представление для статистики использования
CREATE VIEW usage_statistics AS
SELECT 
    p.name as product_name,
    pl.name as plan_name,
    COUNT(DISTINCT s.id) as active_subscriptions,
    COUNT(ue.id) as usage_events_count,
    COUNT(DISTINCT s.user_id) as unique_users,
    AVG(EXTRACT(EPOCH FROM (s.end_date - s.start_date))/86400) as avg_subscription_days
FROM products p
JOIN product_plans pp ON p.id = pp.product_id
JOIN plans pl ON pp.plan_id = pl.id
LEFT JOIN subscriptions s ON pp.id = s.product_plan_id AND s.status = 'active'
LEFT JOIN usage_events ue ON s.id = ue.subscription_id
WHERE pp.is_active = true
GROUP BY p.name, pl.name
ORDER BY active_subscriptions DESC;

COMMENT ON VIEW usage_statistics IS 'Статистика использования нейросетей по продуктам и планам';

-- =====================================================
-- Создание последовательностей для автоинкремента
-- =====================================================

-- Последовательности уже созданы автоматически через BIGSERIAL
-- Но можно создать дополнительные последовательности если потребуется

-- =====================================================
-- Создание функций для автоматического обновления updated_at
-- =====================================================

-- Функция для обновления поля updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

COMMENT ON FUNCTION update_updated_at_column() IS 'Функция для автоматического обновления поля updated_at';

-- Триггеры для автоматического обновления updated_at
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at 
    BEFORE UPDATE ON products 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at 
    BEFORE UPDATE ON subscriptions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at 
    BEFORE UPDATE ON orders 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Вставка базовых данных
-- =====================================================

-- Вставка базовых ролей
INSERT INTO roles (name, description) VALUES
('admin', 'Администратор системы'),
('user', 'Обычный пользователь'),
('moderator', 'Модератор контента');

-- Вставка базовых продуктов (нейросетей)
INSERT INTO products (name, description, category) VALUES
('ChatGPT', 'Мощная языковая модель для генерации текста и диалогов', 'Языковые модели'),
('DALL-E', 'Нейросеть для генерации изображений по текстовому описанию', 'Генерация изображений'),
('Midjourney', 'Продвинутая нейросеть для создания художественных изображений', 'Генерация изображений'),
('Stable Diffusion', 'Открытая нейросеть для генерации изображений', 'Генерация изображений'),
('Whisper', 'Нейросеть для распознавания и транскрипции речи', 'Обработка аудио');

-- Вставка базовых тарифных планов
INSERT INTO plans (name, description, price, duration_days) VALUES
('Базовый', 'Базовый доступ к нейросети', 299.00, 30),
('Стандарт', 'Расширенный доступ с приоритетом', 599.00, 30),
('Премиум', 'Полный доступ с максимальным приоритетом', 999.00, 30),
('Годовой', 'Годовая подписка со скидкой', 9999.00, 365);

-- Связывание продуктов и планов
INSERT INTO product_plans (product_id, plan_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), -- ChatGPT
(2, 1), (2, 2), (2, 3), (2, 4), -- DALL-E
(3, 1), (3, 2), (3, 3), (3, 4), -- Midjourney
(4, 1), (4, 2), (4, 3), (4, 4), -- Stable Diffusion
(5, 1), (5, 2), (5, 3), (5, 4); -- Whisper

COMMIT;
