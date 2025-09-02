-- =====================================================
-- Триггеры, функции и процедуры для магазина подписок на нейросети
-- PostgreSQL 14+
-- =====================================================

-- =====================================================
-- Функция для триггера аудита
-- =====================================================

CREATE OR REPLACE FUNCTION audit_log_trigger()
RETURNS TRIGGER AS $$
DECLARE
    old_data JSONB;
    new_data JSONB;
    current_user_id BIGINT;
BEGIN
    -- Получаем ID текущего пользователя из контекста
    -- В реальном приложении это должно передаваться через SET SESSION
    current_user_id := COALESCE(current_setting('app.current_user_id', true)::BIGINT, NULL);
    
    -- Подготавливаем данные для аудита
    IF TG_OP = 'DELETE' THEN
        old_data = to_jsonb(OLD);
        new_data = NULL;
    ELSIF TG_OP = 'UPDATE' THEN
        old_data = to_jsonb(OLD);
        new_data = to_jsonb(NEW);
    ELSIF TG_OP = 'INSERT' THEN
        old_data = NULL;
        new_data = to_jsonb(NEW);
    END IF;
    
    -- Вставляем запись в журнал аудита
    INSERT INTO audit_log (
        table_name,
        operation,
        old_values,
        new_values,
        user_id,
        timestamp
    ) VALUES (
        TG_TABLE_NAME,
        TG_OP,
        old_data,
        new_data,
        current_user_id,
        NOW()
    );
    
    -- Возвращаем результат для триггера
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION audit_log_trigger() IS 'Функция для автоматического логирования изменений в таблицах';

-- =====================================================
-- Создание триггеров аудита для основных таблиц
-- =====================================================

-- Триггер для таблицы subscriptions
CREATE TRIGGER audit_subscriptions_trigger
    AFTER INSERT OR UPDATE OR DELETE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION audit_log_trigger();

COMMENT ON TRIGGER audit_subscriptions_trigger ON subscriptions IS 'Триггер аудита для таблицы подписок';

-- Триггер для таблицы orders
CREATE TRIGGER audit_orders_trigger
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW EXECUTE FUNCTION audit_log_trigger();

COMMENT ON TRIGGER audit_orders_trigger ON orders IS 'Триггер аудита для таблицы заказов';

-- Триггер для таблицы payments
CREATE TRIGGER audit_payments_trigger
    AFTER INSERT OR UPDATE OR DELETE ON payments
    FOR EACH ROW EXECUTE FUNCTION audit_log_trigger();

COMMENT ON TRIGGER audit_payments_trigger ON payments IS 'Триггер аудита для таблицы платежей';

-- Триггер для таблицы users
CREATE TRIGGER audit_users_trigger
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION audit_log_trigger();

COMMENT ON TRIGGER audit_users_trigger ON users IS 'Триггер аудита для таблицы пользователей';

-- Триггер для таблицы products
CREATE TRIGGER audit_products_trigger
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW EXECUTE FUNCTION audit_log_trigger();

COMMENT ON TRIGGER audit_products_trigger ON products IS 'Триггер аудита для таблицы продуктов';

-- =====================================================
-- Функция для установки ID текущего пользователя
-- =====================================================

CREATE OR REPLACE FUNCTION set_current_user(user_id BIGINT)
RETURNS VOID AS $$
BEGIN
    PERFORM set_config('app.current_user_id', user_id::TEXT, true);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION set_current_user(BIGINT) IS 'Функция для установки ID текущего пользователя в контексте сессии';

-- =====================================================
-- Процедура активации подписки
-- =====================================================

CREATE OR REPLACE PROCEDURE activate_subscription(order_id BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
    order_record RECORD;
    subscription_id BIGINT;
    start_date TIMESTAMPTZ;
    end_date TIMESTAMPTZ;
    product_plan_record RECORD;
BEGIN
    -- Начинаем транзакцию
    BEGIN
        -- Получаем информацию о заказе
        SELECT o.*, pp.product_id, pp.plan_id, p.duration_days
        INTO order_record
        FROM orders o
        JOIN product_plans pp ON o.product_plan_id = pp.id
        JOIN plans p ON pp.plan_id = p.id
        WHERE o.id = order_id AND o.status = 'confirmed';
        
        -- Проверяем, что заказ существует и подтвержден
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Заказ с ID % не найден или не подтвержден', order_id;
        END IF;
        
        -- Проверяем, что у пользователя нет активной подписки на этот продукт
        IF EXISTS (
            SELECT 1 FROM subscriptions s
            WHERE s.user_id = order_record.user_id
            AND s.product_plan_id = order_record.product_plan_id
            AND s.status = 'active'
        ) THEN
            RAISE EXCEPTION 'У пользователя уже есть активная подписка на этот продукт';
        END IF;
        
        -- Вычисляем даты подписки
        start_date := NOW();
        end_date := start_date + (order_record.duration_days || ' days')::INTERVAL;
        
        -- Создаем подписку
        INSERT INTO subscriptions (
            user_id,
            product_plan_id,
            status,
            start_date,
            end_date
        ) VALUES (
            order_record.user_id,
            order_record.product_plan_id,
            'active',
            start_date,
            end_date
        ) RETURNING id INTO subscription_id;
        
        -- Обновляем статус заказа
        UPDATE orders 
        SET status = 'completed', updated_at = NOW()
        WHERE id = order_id;
        
        -- Создаем событие использования
        INSERT INTO usage_events (
            subscription_id,
            event_type,
            metadata
        ) VALUES (
            subscription_id,
            'subscription_activated',
            jsonb_build_object(
                'order_id', order_id,
                'activation_date', start_date,
                'duration_days', order_record.duration_days
            )
        );
        
        -- Логируем успешную активацию
        RAISE NOTICE 'Подписка успешно активирована. ID: %, Пользователь: %, Продукт: %, План: %, Действует до: %',
            subscription_id, order_record.user_id, order_record.product_id, order_record.plan_id, end_date;
            
        -- Фиксируем транзакцию
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Откатываем транзакцию в случае ошибки
            ROLLBACK;
            RAISE;
    END;
END;
$$;

COMMENT ON PROCEDURE activate_subscription(BIGINT) IS 'Процедура для активации подписки после подтверждения заказа';

-- =====================================================
-- Функция для проверки статуса подписки
-- =====================================================

CREATE OR REPLACE FUNCTION check_subscription_status(subscription_id BIGINT)
RETURNS TABLE(
    subscription_id BIGINT,
    user_id BIGINT,
    product_name VARCHAR,
    plan_name VARCHAR,
    status VARCHAR,
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    days_remaining INTEGER,
    is_active BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.user_id,
        p.name as product_name,
        pl.name as plan_name,
        s.status,
        s.start_date,
        s.end_date,
        EXTRACT(DAY FROM (s.end_date - NOW()))::INTEGER as days_remaining,
        CASE 
            WHEN s.status = 'active' AND s.end_date > NOW() THEN true
            ELSE false
        END as is_active
    FROM subscriptions s
    JOIN product_plans pp ON s.product_plan_id = pp.id
    JOIN products p ON pp.product_id = p.id
    JOIN plans pl ON pp.plan_id = pl.id
    WHERE s.id = subscription_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_subscription_status(BIGINT) IS 'Функция для проверки статуса и деталей подписки';

-- =====================================================
-- Функция для получения статистики пользователя
-- =====================================================

CREATE OR REPLACE FUNCTION get_user_statistics(user_id BIGINT)
RETURNS TABLE(
    total_subscriptions BIGINT,
    active_subscriptions BIGINT,
    total_spent NUMERIC,
    favorite_product VARCHAR,
    subscription_history JSONB
) AS $$
BEGIN
    RETURN QUERY
    WITH user_stats AS (
        SELECT 
            COUNT(s.id) as total_subs,
            COUNT(CASE WHEN s.status = 'active' AND s.end_date > NOW() THEN 1 END) as active_subs,
            COALESCE(SUM(o.amount), 0) as total_amount,
            p.name as product_name,
            COUNT(s.id) as product_usage_count
        FROM users u
        LEFT JOIN subscriptions s ON u.id = s.user_id
        LEFT JOIN product_plans pp ON s.product_plan_id = pp.id
        LEFT JOIN products p ON pp.product_id = p.id
        LEFT JOIN orders o ON u.id = o.user_id AND o.status = 'completed'
        WHERE u.id = user_id
        GROUP BY p.name
    ),
    subscription_history AS (
        SELECT jsonb_agg(
            jsonb_build_object(
                'subscription_id', s.id,
                'product_name', p.name,
                'plan_name', pl.name,
                'status', s.status,
                'start_date', s.start_date,
                'end_date', s.end_date,
                'amount', o.amount
            )
        ) as history
        FROM subscriptions s
        JOIN product_plans pp ON s.product_plan_id = pp.id
        JOIN products p ON pp.product_id = p.id
        JOIN plans pl ON pp.plan_id = pl.id
        LEFT JOIN orders o ON s.user_id = o.user_id AND o.product_plan_id = s.product_plan_id
        WHERE s.user_id = user_id
    )
    SELECT 
        us.total_subs,
        us.active_subs,
        us.total_amount,
        us.product_name as favorite_product,
        sh.history as subscription_history
    FROM user_stats us
    CROSS JOIN subscription_history sh
    ORDER BY us.product_usage_count DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_user_statistics(BIGINT) IS 'Функция для получения статистики пользователя по подпискам';

-- =====================================================
-- Функция для автоматического обновления статуса подписок
-- =====================================================

CREATE OR REPLACE FUNCTION update_expired_subscriptions()
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    -- Обновляем статус истекших подписок
    UPDATE subscriptions 
    SET status = 'expired', updated_at = NOW()
    WHERE status = 'active' AND end_date < NOW();
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    
    -- Логируем обновление
    RAISE NOTICE 'Обновлено % истекших подписок', updated_count;
    
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_expired_subscriptions() IS 'Функция для автоматического обновления статуса истекших подписок';

-- =====================================================
-- Создание индексов для оптимизации триггеров
-- =====================================================

-- Индекс для оптимизации поиска по таблице и операции в audit_log
CREATE INDEX IF NOT EXISTS idx_audit_log_table_operation ON audit_log(table_name, operation);

-- Индекс для оптимизации поиска по времени в audit_log
CREATE INDEX IF NOT EXISTS idx_audit_log_timestamp_operation ON audit_log(timestamp, operation);

-- =====================================================
-- Функция для очистки старых записей аудита
-- =====================================================

CREATE OR REPLACE FUNCTION cleanup_old_audit_logs(months_to_keep INTEGER DEFAULT 12)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Удаляем записи аудита старше указанного количества месяцев
    DELETE FROM audit_log 
    WHERE timestamp < NOW() - (months_to_keep || ' months')::INTERVAL;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    RAISE NOTICE 'Удалено % старых записей аудита (старше % месяцев)', deleted_count, months_to_keep;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cleanup_old_audit_logs(INTEGER) IS 'Функция для очистки старых записей аудита';

-- =====================================================
-- Создание планировщика для автоматических задач
-- =====================================================

-- Примечание: Для использования планировщика необходимо установить расширение pg_cron
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Пример настройки автоматического обновления статуса подписок (если pg_cron установлен)
-- SELECT cron.schedule('update-expired-subscriptions', '0 2 * * *', 'SELECT update_expired_subscriptions();');

-- Пример настройки автоматической очистки старых записей аудита
-- SELECT cron.schedule('cleanup-audit-logs', '0 3 1 * *', 'SELECT cleanup_old_audit_logs(12);');

-- =====================================================
-- Функция для получения отчета по аудиту
-- =====================================================

CREATE OR REPLACE FUNCTION get_audit_report(
    table_name_filter VARCHAR DEFAULT NULL,
    operation_filter VARCHAR DEFAULT NULL,
    date_from TIMESTAMPTZ DEFAULT NULL,
    date_to TIMESTAMPTZ DEFAULT NULL,
    user_id_filter BIGINT DEFAULT NULL
)
RETURNS TABLE(
    table_name VARCHAR,
    operation VARCHAR,
    operation_count BIGINT,
    last_operation TIMESTAMPTZ,
    affected_user_id BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.table_name,
        al.operation,
        COUNT(*) as operation_count,
        MAX(al.timestamp) as last_operation,
        al.user_id as affected_user_id
    FROM audit_log al
    WHERE (table_name_filter IS NULL OR al.table_name = table_name_filter)
        AND (operation_filter IS NULL OR al.operation = operation_filter)
        AND (date_from IS NULL OR al.timestamp >= date_from)
        AND (date_to IS NULL OR al.timestamp <= date_to)
        AND (user_id_filter IS NULL OR al.user_id = user_id_filter)
    GROUP BY al.table_name, al.operation, al.user_id
    ORDER BY operation_count DESC, last_operation DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_audit_report(VARCHAR, VARCHAR, TIMESTAMPTZ, TIMESTAMPTZ, BIGINT) IS 'Функция для получения отчета по аудиту с фильтрацией';

-- =====================================================
-- Создание представления для мониторинга аудита
-- =====================================================

CREATE OR REPLACE VIEW audit_monitoring AS
SELECT 
    DATE_TRUNC('hour', timestamp) as hour_bucket,
    table_name,
    operation,
    COUNT(*) as operation_count,
    COUNT(DISTINCT user_id) as unique_users
FROM audit_log
WHERE timestamp >= NOW() - INTERVAL '24 hours'
GROUP BY DATE_TRUNC('hour', timestamp), table_name, operation
ORDER BY hour_bucket DESC, operation_count DESC;

COMMENT ON VIEW audit_monitoring IS 'Представление для мониторинга активности аудита по часам';

-- =====================================================
-- Функция для проверки целостности данных
-- =====================================================

CREATE OR REPLACE FUNCTION check_data_integrity()
RETURNS TABLE(
    check_name VARCHAR,
    status VARCHAR,
    details TEXT
) AS $$
BEGIN
    -- Проверка 1: Подписки с несуществующими пользователями
    RETURN QUERY
    SELECT 
        'Проверка подписок'::VARCHAR as check_name,
        CASE 
            WHEN COUNT(*) = 0 THEN 'OK'::VARCHAR
            ELSE 'ERROR'::VARCHAR
        END as status,
        CASE 
            WHEN COUNT(*) = 0 THEN 'Все подписки имеют корректные ссылки на пользователей'
            ELSE 'Найдено ' || COUNT(*) || ' подписок с несуществующими пользователями'
        END::TEXT as details
    FROM subscriptions s
    LEFT JOIN users u ON s.user_id = u.id
    WHERE u.id IS NULL;
    
    -- Проверка 2: Заказы с несуществующими пользователями
    RETURN QUERY
    SELECT 
        'Проверка заказов'::VARCHAR as check_name,
        CASE 
            WHEN COUNT(*) = 0 THEN 'OK'::VARCHAR
            ELSE 'ERROR'::VARCHAR
        END as status,
        CASE 
            WHEN COUNT(*) = 0 THEN 'Все заказы имеют корректные ссылки на пользователей'
            ELSE 'Найдено ' || COUNT(*) || ' заказов с несуществующими пользователями'
        END::TEXT as details
    FROM orders o
    LEFT JOIN users u ON o.user_id = u.id
    WHERE u.id IS NULL;
    
    -- Проверка 3: Подписки с несуществующими продуктами/планами
    RETURN QUERY
    SELECT 
        'Проверка связей подписок'::VARCHAR as check_name,
        CASE 
            WHEN COUNT(*) = 0 THEN 'OK'::VARCHAR
            ELSE 'ERROR'::VARCHAR
        END as status,
        CASE 
            WHEN COUNT(*) = 0 THEN 'Все подписки имеют корректные ссылки на продукты/планы'
            ELSE 'Найдено ' || COUNT(*) || ' подписок с несуществующими продуктами/планами'
        END::TEXT as details
    FROM subscriptions s
    LEFT JOIN product_plans pp ON s.product_plan_id = pp.id
    WHERE pp.id IS NULL;
    
    -- Проверка 4: Заказы с несуществующими продуктами/планами
    RETURN QUERY
    SELECT 
        'Проверка связей заказов'::VARCHAR as check_name,
        CASE 
            WHEN COUNT(*) = 0 THEN 'OK'::VARCHAR
            ELSE 'ERROR'::VARCHAR
        END as status,
        CASE 
            WHEN COUNT(*) = 0 THEN 'Все заказы имеют корректные ссылки на продукты/планы'
            ELSE 'Найдено ' || COUNT(*) || ' заказов с несуществующими продуктами/планами'
        END::TEXT as details
    FROM orders o
    LEFT JOIN product_plans pp ON o.product_plan_id = pp.id
    WHERE pp.id IS NULL;
    
    -- Проверка 5: Платежи с несуществующими заказами
    RETURN QUERY
    SELECT 
        'Проверка платежей'::VARCHAR as check_name,
        CASE 
            WHEN COUNT(*) = 0 THEN 'OK'::VARCHAR
            ELSE 'ERROR'::VARCHAR
        END as status,
        CASE 
            WHEN COUNT(*) = 0 THEN 'Все платежи имеют корректные ссылки на заказы'
            ELSE 'Найдено ' || COUNT(*) || ' платежей с несуществующими заказами'
        END::TEXT as details
    FROM payments p
    LEFT JOIN orders o ON p.order_id = o.id
    WHERE o.id IS NULL;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_data_integrity() IS 'Функция для проверки целостности данных в базе';

COMMIT;
