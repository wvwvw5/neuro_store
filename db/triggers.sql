-- ========================================
-- Триггеры и процедуры для Neuro Store
-- ========================================

-- Подключение к базе данных
\c neuro_store;

-- ========================================
-- ФУНКЦИИ
-- ========================================

-- Функция для автоматического обновления поля updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

COMMENT ON FUNCTION update_updated_at_column() IS 'Функция для автоматического обновления поля updated_at';

-- Функция для логирования изменений в таблицах
CREATE OR REPLACE FUNCTION log_table_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO api_logs (
            endpoint,
            method,
            status_code,
            ip_address,
            user_agent,
            request_headers,
            response_headers,
            created_at
        ) VALUES (
            'table_change',
            'INSERT',
            200,
            '127.0.0.1',
            'system_trigger',
            jsonb_build_object('table', TG_TABLE_NAME, 'operation', TG_OP),
            jsonb_build_object('new_record', to_jsonb(NEW)),
            CURRENT_TIMESTAMP
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO api_logs (
            endpoint,
            method,
            status_code,
            ip_address,
            user_agent,
            request_headers,
            response_headers,
            created_at
        ) VALUES (
            'table_change',
            'UPDATE',
            200,
            '127.0.0.1',
            'system_trigger',
            jsonb_build_object('table', TG_TABLE_NAME, 'operation', TG_OP),
            jsonb_build_object('old_record', to_jsonb(OLD), 'new_record', to_jsonb(NEW)),
            CURRENT_TIMESTAMP
        );
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO api_logs (
            endpoint,
            method,
            status_code,
            ip_address,
            user_agent,
            request_headers,
            response_headers,
            created_at
        ) VALUES (
            'table_change',
            'DELETE',
            200,
            '127.0.0.1',
            'system_trigger',
            jsonb_build_object('table', TG_TABLE_NAME, 'operation', TG_OP),
            jsonb_build_object('old_record', to_jsonb(OLD)),
            CURRENT_TIMESTAMP
        );
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

COMMENT ON FUNCTION log_table_changes() IS 'Функция для логирования изменений в таблицах';

-- Функция для проверки лимитов подписки
CREATE OR REPLACE FUNCTION check_subscription_limits(
    p_subscription_id INTEGER,
    p_usage_type VARCHAR(50),
    p_usage_amount INTEGER DEFAULT 1
)
RETURNS BOOLEAN AS $$
DECLARE
    v_plan_limits JSONB;
    v_current_usage JSONB;
    v_limit_value INTEGER;
    v_usage_value INTEGER;
BEGIN
    -- Получаем лимиты плана
    SELECT limits INTO v_plan_limits
    FROM plans p
    JOIN subscriptions s ON p.id = s.plan_id
    WHERE s.id = p_subscription_id;
    
    -- Получаем текущее использование
    SELECT usage_current INTO v_current_usage
    FROM subscriptions
    WHERE id = p_subscription_id;
    
    -- Проверяем лимит для конкретного типа использования
    v_limit_value := COALESCE((v_plan_limits->>p_usage_type)::INTEGER, 0);
    v_usage_value := COALESCE((v_current_usage->>p_usage_type)::INTEGER, 0);
    
    -- Если лимит не установлен, разрешаем
    IF v_limit_value = 0 THEN
        RETURN TRUE;
    END IF;
    
    -- Проверяем, не превышен ли лимит
    IF v_usage_value + p_usage_amount > v_limit_value THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
$$ language 'plpgsql';

COMMENT ON FUNCTION check_subscription_limits(INTEGER, VARCHAR, INTEGER) IS 'Функция для проверки лимитов подписки';

-- Функция для обновления использования подписки
CREATE OR REPLACE FUNCTION update_subscription_usage(
    p_subscription_id INTEGER,
    p_usage_type VARCHAR(50),
    p_usage_amount INTEGER DEFAULT 1
)
RETURNS BOOLEAN AS $$
DECLARE
    v_plan_limits JSONB;
    v_current_usage JSONB;
    v_limit_value INTEGER;
    v_usage_value INTEGER;
BEGIN
    -- Проверяем лимиты
    IF NOT check_subscription_limits(p_subscription_id, p_usage_type, p_usage_amount) THEN
        RETURN FALSE;
    END IF;
    
    -- Получаем текущее использование
    SELECT usage_current INTO v_current_usage
    FROM subscriptions
    WHERE id = p_subscription_id;
    
    -- Обновляем использование
    v_usage_value := COALESCE((v_current_usage->>p_usage_type)::INTEGER, 0);
    v_current_usage := jsonb_set(
        COALESCE(v_current_usage, '{}'::jsonb),
        ARRAY[p_usage_type],
        to_jsonb(v_usage_value + p_usage_amount)
    );
    
    -- Сохраняем обновленное использование
    UPDATE subscriptions
    SET usage_current = v_current_usage,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_subscription_id;
    
    RETURN TRUE;
END;
$$ language 'plpgsql';

COMMENT ON FUNCTION update_subscription_usage(INTEGER, VARCHAR, INTEGER) IS 'Функция для обновления использования подписки';

-- Функция для проверки активности подписки
CREATE OR REPLACE FUNCTION is_subscription_active(p_subscription_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    v_status VARCHAR(20);
    v_end_date TIMESTAMP WITH TIME ZONE;
BEGIN
    SELECT status, end_date INTO v_status, v_end_date
    FROM subscriptions
    WHERE id = p_subscription_id;
    
    -- Проверяем статус и дату окончания
    IF v_status = 'active' AND (v_end_date IS NULL OR v_end_date > CURRENT_TIMESTAMP) THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ language 'plpgsql';

COMMENT ON FUNCTION is_subscription_active(INTEGER) IS 'Функция для проверки активности подписки';

-- Функция для получения статистики по продуктам
CREATE OR REPLACE FUNCTION get_product_statistics(
    p_product_id INTEGER DEFAULT NULL,
    p_date_from DATE DEFAULT NULL,
    p_date_to DATE DEFAULT NULL
)
RETURNS TABLE(
    product_id INTEGER,
    product_name VARCHAR(255),
    total_subscriptions INTEGER,
    active_subscriptions INTEGER,
    total_revenue DECIMAL(10,2),
    avg_subscription_duration INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as product_id,
        p.name as product_name,
        COUNT(s.id)::INTEGER as total_subscriptions,
        COUNT(CASE WHEN s.status = 'active' THEN 1 END)::INTEGER as active_subscriptions,
        COALESCE(SUM(py.amount), 0) as total_revenue,
        COALESCE(AVG(EXTRACT(EPOCH FROM (s.end_date - s.start_date))/86400), 0)::INTEGER as avg_subscription_duration
    FROM products p
    LEFT JOIN subscriptions s ON p.id = s.product_id
    LEFT JOIN payments py ON s.id = py.subscription_id AND py.status = 'completed'
    WHERE (p_product_id IS NULL OR p.id = p_product_id)
        AND (p_date_from IS NULL OR s.created_at >= p_date_from)
        AND (p_date_to IS NULL OR s.created_at <= p_date_to)
    GROUP BY p.id, p.name
    ORDER BY total_subscriptions DESC;
END;
$$ language 'plpgsql';

COMMENT ON FUNCTION get_product_statistics(INTEGER, DATE, DATE) IS 'Функция для получения статистики по продуктам';

-- ========================================
-- ТРИГГЕРЫ
-- ========================================

-- Триггеры для автоматического обновления updated_at
CREATE TRIGGER update_roles_updated_at 
    BEFORE UPDATE ON roles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at 
    BEFORE UPDATE ON categories 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at 
    BEFORE UPDATE ON products 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plans_updated_at 
    BEFORE UPDATE ON plans 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at 
    BEFORE UPDATE ON subscriptions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at 
    BEFORE UPDATE ON payments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_api_keys_updated_at 
    BEFORE UPDATE ON api_keys 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Триггеры для логирования изменений в критических таблицах
CREATE TRIGGER log_users_changes
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION log_table_changes();

CREATE TRIGGER log_subscriptions_changes
    AFTER INSERT OR UPDATE OR DELETE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION log_table_changes();

CREATE TRIGGER log_payments_changes
    AFTER INSERT OR UPDATE OR DELETE ON payments
    FOR EACH ROW EXECUTE FUNCTION log_table_changes();

-- Триггер для автоматического обновления статуса подписки
CREATE OR REPLACE FUNCTION update_subscription_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Если подписка истекла, меняем статус на expired
    IF NEW.end_date IS NOT NULL AND NEW.end_date < CURRENT_TIMESTAMP AND NEW.status = 'active' THEN
        NEW.status := 'expired';
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER check_subscription_expiration
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_subscription_status();

-- Триггер для проверки уникальности email при регистрации
CREATE OR REPLACE FUNCTION check_unique_email()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверяем, что email уникален
    IF EXISTS(SELECT 1 FROM users WHERE email = NEW.email AND id != NEW.id) THEN
        RAISE EXCEPTION 'Email % уже используется', NEW.email;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER ensure_unique_email
    BEFORE INSERT OR UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION check_unique_email();

-- ========================================
-- ПРЕДСТАВЛЕНИЯ (VIEWS)
-- ========================================

-- Представление для отчета по активным подпискам
CREATE OR REPLACE VIEW active_subscriptions_report AS
SELECT 
    s.id as subscription_id,
    u.email as user_email,
    u.username,
    u.full_name,
    p.name as product_name,
    pl.name as plan_name,
    pl.price,
    pl.currency,
    s.start_date,
    s.end_date,
    s.status,
    CASE 
        WHEN s.end_date < CURRENT_TIMESTAMP THEN 'expired'
        WHEN s.end_date - CURRENT_TIMESTAMP < INTERVAL '7 days' THEN 'expiring_soon'
        ELSE 'active'
    END as subscription_status
FROM subscriptions s
JOIN users u ON s.user_id = u.id
JOIN products p ON s.product_id = p.id
JOIN plans pl ON s.plan_id = pl.id
WHERE s.status = 'active'
ORDER BY s.end_date;

COMMENT ON VIEW active_subscriptions_report IS 'Отчет по активным подпискам с информацией о пользователях и продуктах';

-- Представление для отчета по выручке
CREATE OR REPLACE VIEW revenue_report AS
SELECT 
    DATE_TRUNC('month', py.created_at) as month,
    p.name as product_name,
    pl.name as plan_name,
    COUNT(py.id) as payments_count,
    SUM(py.amount) as total_revenue,
    AVG(py.amount) as avg_payment_value,
    COUNT(CASE WHEN py.status = 'completed' THEN 1 END) as completed_payments,
    COUNT(CASE WHEN py.status = 'failed' THEN 1 END) as failed_payments
FROM payments py
JOIN subscriptions s ON py.subscription_id = s.id
JOIN products p ON s.product_id = p.id
JOIN plans pl ON s.plan_id = pl.id
GROUP BY DATE_TRUNC('month', py.created_at), p.name, pl.name
ORDER BY month DESC, total_revenue DESC;

COMMENT ON VIEW revenue_report IS 'Отчет по выручке по месяцам, продуктам и планам';

-- Представление для статистики использования API
CREATE OR REPLACE VIEW api_usage_statistics AS
SELECT 
    p.name as product_name,
    COUNT(DISTINCT s.id) as active_subscriptions,
    COUNT(al.id) as api_requests_count,
    AVG(al.response_time_ms) as avg_response_time,
    COUNT(CASE WHEN al.status_code >= 400 THEN 1 END) as error_requests_count
FROM products p
LEFT JOIN subscriptions s ON p.id = s.product_id AND s.status = 'active'
LEFT JOIN api_logs al ON s.id = al.subscription_id
WHERE al.endpoint != 'table_change'
GROUP BY p.name
ORDER BY active_subscriptions DESC;

COMMENT ON VIEW api_usage_statistics IS 'Статистика использования API по продуктам';

-- ========================================
-- ИНДЕКСЫ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ
-- ========================================

-- Составные индексы для часто используемых запросов
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_product 
ON subscriptions(user_id, product_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_status_dates 
ON subscriptions(status, start_date, end_date);

CREATE INDEX IF NOT EXISTS idx_payments_subscription_status 
ON payments(subscription_id, status);

CREATE INDEX IF NOT EXISTS idx_api_logs_subscription_created 
ON api_logs(subscription_id, created_at);

-- Индексы для полнотекстового поиска
CREATE INDEX IF NOT EXISTS idx_products_search 
ON products USING GIN(to_tsvector('russian', name || ' ' || COALESCE(description, '')));

CREATE INDEX IF NOT EXISTS idx_users_search 
ON users USING GIN(to_tsvector('russian', full_name || ' ' || COALESCE(username, '')));

-- ========================================
-- ПРАВА ДОСТУПА
-- ========================================

-- Предоставление прав на чтение для роли viewer
GRANT SELECT ON ALL TABLES IN SCHEMA public TO neuro_user;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO neuro_user;

-- Предоставление прав на запись для роли user
GRANT INSERT, UPDATE ON subscriptions, payments, api_logs TO neuro_user;

-- Предоставление всех прав для роли admin
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO neuro_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO neuro_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO neuro_user;
