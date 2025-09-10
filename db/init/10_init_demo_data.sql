-- ========================================
-- Инициализация демонстрационных данных
-- ========================================

-- Вставка дополнительных демонстрационных данных для полноценного тестирования

-- Дополнительные категории продуктов
INSERT INTO categories (name, description, slug, icon, color, sort_order) VALUES
('Мультимодальные AI', 'AI модели, работающие с несколькими типами данных одновременно', 'multimodal-ai', 'layers', '#8B5CF6', 9),
('Специализированные AI', 'AI инструменты для конкретных задач и отраслей', 'specialized-ai', 'target', '#F59E0B', 10),
('AI для бизнеса', 'Корпоративные AI решения для автоматизации и аналитики', 'business-ai', 'briefcase', '#10B981', 11)
ON CONFLICT (slug) DO NOTHING;

-- Дополнительные продукты
INSERT INTO products (name, description, short_description, slug, category_id, logo_url, website_url, api_documentation_url, features, tags, sort_order) VALUES
-- Мультимодальные AI
('GPT-4 Vision', 'Мультимодальная модель OpenAI, работающая с текстом и изображениями', 'AI модель для анализа текста и изображений', 'gpt-4-vision', 9, 'https://example.com/gpt4v-logo.png', 'https://openai.com/research/gpt-4', 'https://platform.openai.com/docs/guides/vision', '["text_generation", "image_analysis", "multimodal", "vision", "reasoning"]', ARRAY['AI', 'openai', 'multimodal', 'vision'], 16),
('Claude 3 Vision', 'Мультимодальная модель Anthropic с улучшенным зрением', 'AI модель для анализа изображений и текста', 'claude-3-vision', 9, 'https://example.com/claude3v-logo.png', 'https://claude.ai', 'https://docs.anthropic.com/claude/docs/vision', '["text_analysis", "image_analysis", "multimodal", "vision", "safety"]', ARRAY['AI', 'anthropic', 'multimodal', 'vision'], 17),

-- Специализированные AI
('CodeWhisperer', 'AI помощник для программирования от Amazon', 'AI ассистент для разработчиков AWS', 'codewhisperer', 10, 'https://example.com/codewhisperer-logo.png', 'https://aws.amazon.com/codewhisperer/', 'https://docs.aws.amazon.com/codewhisperer/', '["code_completion", "aws_integration", "security_scanning", "multi_language"]', ARRAY['AI', 'aws', 'coding', 'security'], 18),
('GitHub Copilot X', 'Продвинутая версия GitHub Copilot с дополнительными возможностями', 'AI ассистент для разработчиков с расширенными функциями', 'github-copilot-x', 10, 'https://example.com/copilot-x-logo.png', 'https://github.com/features/copilot-x', 'https://docs.github.com/copilot-x', '["code_completion", "chat", "pull_requests", "documentation", "testing"]', ARRAY['AI', 'github', 'coding', 'advanced'], 19),

-- AI для бизнеса
('Salesforce Einstein', 'AI платформа для CRM и бизнес-аналитики', 'AI для автоматизации продаж и аналитики', 'salesforce-einstein', 11, 'https://example.com/einstein-logo.png', 'https://www.salesforce.com/products/einstein/', 'https://developer.salesforce.com/docs/einstein', '["sales_automation", "predictive_analytics", "customer_insights", "business_intelligence"]', ARRAY['AI', 'salesforce', 'business', 'crm'], 20),
('Microsoft Copilot', 'AI помощник для Microsoft 365 и бизнес-приложений', 'AI ассистент для Microsoft продуктов', 'microsoft-copilot', 11, 'https://example.com/ms-copilot-logo.png', 'https://copilot.microsoft.com', 'https://docs.microsoft.com/copilot', '["office_automation", "document_creation", "data_analysis", "business_processes"]', ARRAY['AI', 'microsoft', 'business', 'office'], 21)
ON CONFLICT (slug) DO NOTHING;

-- Дополнительные планы для новых продуктов
INSERT INTO plans (product_id, name, description, price, currency, billing_cycle, features, limits, is_popular, sort_order) VALUES
-- GPT-4 Vision планы
(16, 'Базовый', 'Базовый доступ к GPT-4 Vision', 29.99, 'USD', 'monthly', '["text_generation", "image_analysis", "basic_vision"]', '{"requests_per_month": 1000, "image_analysis": 500}', false, 1),
(16, 'Профессиональный', 'Профессиональный доступ к GPT-4 Vision', 59.99, 'USD', 'monthly', '["text_generation", "image_analysis", "advanced_vision", "priority_access"]', '{"requests_per_month": 5000, "image_analysis": 2500}', true, 2),
(16, 'Enterprise', 'Корпоративный доступ к GPT-4 Vision', 199.99, 'USD', 'monthly', '["text_generation", "image_analysis", "enterprise_features", "dedicated_support"]', '{"requests_per_month": 20000, "image_analysis": 10000}', false, 3),

-- Claude 3 Vision планы
(17, 'Стартовый', 'Стартовый доступ к Claude 3 Vision', 24.99, 'USD', 'monthly', '["text_analysis", "image_analysis", "basic_vision"]', '{"requests_per_month": 800, "image_analysis": 400}', false, 1),
(17, 'Профессиональный', 'Профессиональный доступ к Claude 3 Vision', 49.99, 'USD', 'monthly', '["text_analysis", "image_analysis", "advanced_vision", "priority_access"]', '{"requests_per_month": 3000, "image_analysis": 1500}', true, 2),

-- CodeWhisperer планы
(18, 'Индивидуальный', 'Персональный доступ к CodeWhisperer', 19.99, 'USD', 'monthly', '["code_completion", "aws_integration", "security_scanning"]', '{"code_suggestions": "unlimited", "languages": "all"}', false, 1),
(18, 'Команда', 'Доступ для команд разработчиков', 39.99, 'USD', 'monthly', '["code_completion", "aws_integration", "security_scanning", "team_features"]', '{"code_suggestions": "unlimited", "languages": "all", "team_size": 10}', true, 2),
(18, 'Enterprise', 'Корпоративный доступ', 99.99, 'USD', 'monthly', '["code_completion", "aws_integration", "security_scanning", "enterprise_features", "support"]', '{"code_suggestions": "unlimited", "languages": "all", "team_size": "unlimited"}', false, 3),

-- GitHub Copilot X планы
(19, 'Индивидуальный', 'Персональный доступ к Copilot X', 29.99, 'USD', 'monthly', '["code_completion", "chat", "pull_requests", "documentation"]', '{"repositories": "unlimited", "languages": "all"}', false, 1),
(19, 'Команда', 'Доступ для команд', 59.99, 'USD', 'monthly', '["code_completion", "chat", "pull_requests", "documentation", "team_features"]', '{"repositories": "unlimited", "languages": "all", "team_size": 10}', true, 2),
(19, 'Enterprise', 'Корпоративный доступ', 149.99, 'USD', 'monthly', '["code_completion", "chat", "pull_requests", "documentation", "enterprise_features", "support"]', '{"repositories": "unlimited", "languages": "all", "team_size": "unlimited"}', false, 3),

-- Salesforce Einstein планы
(20, 'Стартовый', 'Базовый доступ к Einstein', 49.99, 'USD', 'monthly', '["sales_automation", "basic_analytics", "customer_insights"]', '{"users": 5, "predictions_per_month": 1000}', false, 1),
(20, 'Профессиональный', 'Профессиональный доступ к Einstein', 99.99, 'USD', 'monthly', '["sales_automation", "advanced_analytics", "customer_insights", "predictive_models"]', '{"users": 25, "predictions_per_month": 10000}', true, 2),
(20, 'Enterprise', 'Корпоративный доступ к Einstein', 299.99, 'USD', 'monthly', '["sales_automation", "enterprise_analytics", "custom_models", "dedicated_support"]', '{"users": "unlimited", "predictions_per_month": "unlimited"}', false, 3),

-- Microsoft Copilot планы
(21, 'Бизнес', 'Доступ для бизнеса', 22.99, 'USD', 'monthly', '["office_automation", "document_creation", "data_analysis"]', '{"users": 1, "office_apps": "all"}', false, 1),
(21, 'Enterprise', 'Корпоративный доступ', 44.99, 'USD', 'monthly', '["office_automation", "document_creation", "data_analysis", "business_processes"]', '{"users": "unlimited", "office_apps": "all", "enterprise_features": true}', true, 2)
ON CONFLICT (product_id, name) DO NOTHING;

-- Дополнительные тестовые пользователи
INSERT INTO users (email, username, full_name, hashed_password, role_id, is_active, is_verified) VALUES
('developer@example.com', 'developer', 'Разработчик Тестовый', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 3, true, true),
('designer@example.com', 'designer', 'Дизайнер Тестовый', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 3, true, true),
('marketer@example.com', 'marketer', 'Маркетолог Тестовый', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 3, true, true),
('analyst@example.com', 'analyst', 'Аналитик Тестовый', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 3, true, true),
('student@example.com', 'student', 'Студент Тестовый', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 4, true, true)
ON CONFLICT (email) DO NOTHING;

-- Дополнительные тестовые подписки
INSERT INTO subscriptions (user_id, product_id, plan_id, status, start_date, end_date, auto_renew, payment_method, payment_status, amount_paid, currency, api_key, usage_limits, usage_current) VALUES
-- Подписки для новых пользователей
(9, 16, 22, 'active', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP + INTERVAL '25 days', true, 'card', 'completed', 29.99, 'USD', 'sk-test-gpt4v-dev-123', '{"requests_per_month": 1000, "image_analysis": 500}', '{"requests_per_month": 150, "image_analysis": 75}'),
(10, 17, 25, 'active', CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP + INTERVAL '27 days', true, 'card', 'completed', 24.99, 'USD', 'sk-test-claude3v-designer-123', '{"requests_per_month": 800, "image_analysis": 400}', '{"requests_per_month": 120, "image_analysis": 60}'),
(11, 18, 28, 'active', CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP + INTERVAL '23 days', true, 'card', 'completed', 19.99, 'USD', 'sk-test-codewhisperer-marketer-123', '{"code_suggestions": "unlimited", "languages": "all"}', '{"code_suggestions": 250, "languages": 3}'),
(12, 19, 31, 'active', CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP + INTERVAL '28 days', true, 'card', 'completed', 29.99, 'USD', 'sk-test-copilot-x-analyst-123', '{"repositories": "unlimited", "languages": "all"}', '{"repositories": 8, "languages": 5}'),
(13, 20, 34, 'active', CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP + INTERVAL '20 days', true, 'card', 'completed', 49.99, 'USD', 'sk-test-einstein-student-123', '{"users": 5, "predictions_per_month": 1000}', '{"users": 2, "predictions_per_month": 300}')
ON CONFLICT (user_id, product_id) DO NOTHING;

-- Дополнительные платежи
INSERT INTO payments (subscription_id, user_id, amount, currency, payment_method, payment_provider, transaction_id, status, description, metadata) VALUES
(12, 9, 29.99, 'USD', 'card', 'stripe', 'txn_gpt4v_dev_001', 'completed', 'Оплата подписки GPT-4 Vision Базовый', '{"product": "GPT-4 Vision", "plan": "Базовый", "billing_cycle": "monthly"}'),
(13, 10, 24.99, 'USD', 'card', 'stripe', 'txn_claude3v_designer_001', 'completed', 'Оплата подписки Claude 3 Vision Стартовый', '{"product": "Claude 3 Vision", "plan": "Стартовый", "billing_cycle": "monthly"}'),
(14, 11, 19.99, 'USD', 'card', 'stripe', 'txn_codewhisperer_marketer_001', 'completed', 'Оплата подписки CodeWhisperer Индивидуальный', '{"product": "CodeWhisperer", "plan": "Индивидуальный", "billing_cycle": "monthly"}'),
(15, 12, 29.99, 'USD', 'card', 'stripe', 'txn_copilot_x_analyst_001', 'completed', 'Оплата подписки GitHub Copilot X Индивидуальный', '{"product": "GitHub Copilot X", "plan": "Индивидуальный", "billing_cycle": "monthly"}'),
(16, 13, 49.99, 'USD', 'card', 'stripe', 'txn_einstein_student_001', 'completed', 'Оплата подписки Salesforce Einstein Стартовый', '{"product": "Salesforce Einstein", "plan": "Стартовый", "billing_cycle": "monthly"}')
ON CONFLICT (subscription_id) DO NOTHING;

-- Дополнительные API ключи
INSERT INTO api_keys (user_id, subscription_id, name, key_hash, permissions, is_active, last_used, expires_at) VALUES
(9, 12, 'GPT-4 Vision API Key', 'sk-gpt4v-dev-123-hash', '["text_generation", "image_analysis", "basic_vision"]', true, CURRENT_TIMESTAMP - INTERVAL '4 hours', CURRENT_TIMESTAMP + INTERVAL '25 days'),
(10, 13, 'Claude 3 Vision API Key', 'sk-claude3v-designer-123-hash', '["text_analysis", "image_analysis", "basic_vision"]', true, CURRENT_TIMESTAMP - INTERVAL '6 hours', CURRENT_TIMESTAMP + INTERVAL '27 days'),
(11, 14, 'CodeWhisperer API Key', 'sk-codewhisperer-marketer-123-hash', '["code_completion", "aws_integration", "security_scanning"]', true, CURRENT_TIMESTAMP - INTERVAL '8 hours', CURRENT_TIMESTAMP + INTERVAL '23 days'),
(12, 15, 'Copilot X API Key', 'sk-copilot-x-analyst-123-hash', '["code_completion", "chat", "pull_requests", "documentation"]', true, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP + INTERVAL '28 days'),
(13, 16, 'Einstein API Key', 'sk-einstein-student-123-hash', '["sales_automation", "basic_analytics", "customer_insights"]', true, CURRENT_TIMESTAMP - INTERVAL '10 hours', CURRENT_TIMESTAMP + INTERVAL '20 days')
ON CONFLICT (key_hash) DO NOTHING;

-- Дополнительные API логи
INSERT INTO api_logs (user_id, subscription_id, api_key_id, endpoint, method, status_code, response_time_ms, request_size, response_size, ip_address, user_agent, request_headers, response_headers, error_message, created_at) VALUES
-- Логи для GPT-4 Vision
(9, 12, 15, '/api/v1/chat/completions', 'POST', 200, 1800, 1024, 3072, '192.168.1.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-gpt4v-dev-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-027"}', NULL, CURRENT_TIMESTAMP - INTERVAL '4 hours'),
(9, 12, 15, '/api/v1/chat/completions', 'POST', 200, 2200, 2048, 4096, '192.168.1.107', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-gpt4v-dev-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-028"}', NULL, CURRENT_TIMESTAMP - INTERVAL '5 hours'),

-- Логи для Claude 3 Vision
(10, 13, 16, '/api/v1/chat/completions', 'POST', 200, 1600, 512, 2048, '192.168.1.108', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', '{"Authorization": "Bearer sk-claude3v-designer-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-029"}', NULL, CURRENT_TIMESTAMP - INTERVAL '6 hours'),
(10, 13, 16, '/api/v1/chat/completions', 'POST', 200, 1400, 256, 1024, '192.168.1.108', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', '{"Authorization": "Bearer sk-claude3v-designer-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-030"}', NULL, CURRENT_TIMESTAMP - INTERVAL '7 hours'),

-- Логи для CodeWhisperer
(11, 14, 17, '/api/v1/code/suggestions', 'POST', 200, 120, 2048, 1024, '192.168.1.109', 'Mozilla/5.0 (Linux; Ubuntu 22.04) AppleWebKit/537.36', '{"Authorization": "Bearer sk-codewhisperer-marketer-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-031"}', NULL, CURRENT_TIMESTAMP - INTERVAL '8 hours'),
(11, 14, 17, '/api/v1/code/suggestions', 'POST', 200, 95, 1024, 512, '192.168.1.109', 'Mozilla/5.0 (Linux; Ubuntu 22.04) AppleWebKit/537.36', '{"Authorization": "Bearer sk-codewhisperer-marketer-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-032"}', NULL, CURRENT_TIMESTAMP - INTERVAL '9 hours'),

-- Логи для Copilot X
(12, 15, 18, '/api/v1/copilot/chat', 'POST', 200, 200, 1536, 768, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-copilot-x-analyst-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-033"}', NULL, CURRENT_TIMESTAMP - INTERVAL '2 hours'),
(12, 15, 18, '/api/v1/copilot/suggestions', 'POST', 200, 180, 2048, 1024, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-copilot-x-analyst-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-034"}', NULL, CURRENT_TIMESTAMP - INTERVAL '3 hours'),

-- Логи для Einstein
(13, 16, 19, '/api/v1/einstein/predictions', 'POST', 200, 800, 512, 2048, '192.168.1.111', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', '{"Authorization": "Bearer sk-einstein-student-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-035"}', NULL, CURRENT_TIMESTAMP - INTERVAL '10 hours'),
(13, 16, 19, '/api/v1/einstein/insights', 'GET', 200, 150, 0, 1024, '192.168.1.111', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', '{"Authorization": "Bearer sk-einstein-student-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-036"}', NULL, CURRENT_TIMESTAMP - INTERVAL '11 hours')
ON CONFLICT (id) DO NOTHING;

-- Комментарии к демонстрационным данным
COMMENT ON TABLE products IS 'Дополнительные демонстрационные продукты для полноценного тестирования';
COMMENT ON TABLE plans IS 'Дополнительные тарифные планы для новых продуктов';
COMMENT ON TABLE users IS 'Дополнительные тестовые пользователи с разными ролями';
COMMENT ON TABLE subscriptions IS 'Дополнительные тестовые подписки для новых пользователей';
COMMENT ON TABLE payments IS 'Дополнительные тестовые платежи для новых подписок';
COMMENT ON TABLE api_keys IS 'Дополнительные тестовые API ключи для новых подписок';
COMMENT ON TABLE api_logs IS 'Дополнительные тестовые API логи для новых пользователей';

-- Информация о демонстрационных данных
COMMENT ON TABLE products IS 'Демонстрационные данные включают 21 продукт в 11 категориях';
COMMENT ON TABLE plans IS 'Демонстрационные данные включают 37 тарифных планов';
COMMENT ON TABLE users IS 'Демонстрационные данные включают 13 пользователей с разными ролями';
COMMENT ON TABLE subscriptions IS 'Демонстрационные данные включают 16 подписок в разных статусах';
COMMENT ON TABLE payments IS 'Демонстрационные данные включают 16 платежей';
COMMENT ON TABLE api_keys IS 'Демонстрационные данные включают 19 API ключей';
COMMENT ON TABLE api_logs IS 'Демонстрационные данные включают 36 API логов';





