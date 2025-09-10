-- ========================================
-- Инициализация тестовых подписок
-- ========================================

-- Вставка тестовых подписок для демонстрации системы
INSERT INTO subscriptions (user_id, product_id, plan_id, status, start_date, end_date, auto_renew, payment_method, payment_status, amount_paid, currency, api_key, usage_limits, usage_current) VALUES
-- Активные подписки
(3, 1, 2, 'active', CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP + INTERVAL '30 days', true, 'card', 'completed', 19.99, 'USD', 'sk-test-chatgpt-user-123', '{"requests_per_month": 5000, "conversation_length": 4000}', '{"requests_per_month": 1200, "conversation_length": 800}'),
(3, 4, 2, 'active', CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_TIMESTAMP + INTERVAL '45 days', true, 'card', 'completed', 24.99, 'USD', 'sk-test-dalle-user-123', '{"images_per_month": 200, "resolution": "1024x1024"}', '{"images_per_month": 45, "resolution": "1024x1024"}'),
(5, 1, 1, 'active', CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP + INTERVAL '23 days', true, 'card', 'completed', 9.99, 'USD', 'sk-test-chatgpt-john-123', '{"requests_per_month": 1000, "conversation_length": 1000}', '{"requests_per_month": 300, "conversation_length": 400}'),
(6, 5, 2, 'active', CURRENT_TIMESTAMP - INTERVAL '20 days', CURRENT_TIMESTAMP + INTERVAL '40 days', true, 'card', 'completed', 29.99, 'USD', 'sk-test-midjourney-jane-123', '{"images_per_month": 1000, "fast_mode": true}', '{"images_per_month": 650, "fast_mode": true}'),
(7, 12, 1, 'active', CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP + INTERVAL '20 days', true, 'card', 'completed', 9.99, 'USD', 'sk-test-copilot-bob-123', '{"repositories": "unlimited", "languages": "all"}', '{"repositories": 5, "languages": 3}'),
(8, 7, 2, 'active', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP + INTERVAL '25 days', true, 'card', 'completed', 14.99, 'USD', 'sk-test-whisper-alice-123', '{"audio_hours_per_month": 50, "languages": 20}', '{"audio_hours_per_month": 12, "languages": 8}'),

-- Истекшие подписки
(3, 8, 1, 'expired', CURRENT_TIMESTAMP - INTERVAL '90 days', CURRENT_TIMESTAMP - INTERVAL '30 days', false, 'card', 'completed', 7.99, 'USD', 'sk-expired-elevenlabs-user-123', '{"characters_per_month": 10000, "voices": 5}', '{"characters_per_month": 8500, "voices": 5}'),
(5, 6, 1, 'expired', CURRENT_TIMESTAMP - INTERVAL '120 days', CURRENT_TIMESTAMP - INTERVAL '60 days', false, 'card', 'completed', 19.99, 'USD', 'sk-expired-stable-diffusion-john-123', '{"images_per_month": 100, "processing_time": "standard"}', '{"images_per_month": 87, "processing_time": "standard"}'),

-- Отмененные подписки
(6, 14, 1, 'cancelled', CURRENT_TIMESTAMP - INTERVAL '45 days', CURRENT_TIMESTAMP - INTERVAL '15 days', false, 'card', 'completed', 24.99, 'USD', 'sk-cancelled-jasper-jane-123', '{"words_per_month": 20000, "templates": 50}', '{"words_per_month": 12500, "templates": 50}'),
(7, 2, 1, 'cancelled', CURRENT_TIMESTAMP - INTERVAL '60 days', CURRENT_TIMESTAMP - INTERVAL '30 days', false, 'card', 'completed', 14.99, 'USD', 'sk-cancelled-claude-bob-123', '{"requests_per_month": 800, "context_length": 100000}', '{"requests_per_month": 420, "context_length": 100000}'),

-- Приостановленные подписки
(8, 9, 2, 'suspended', CURRENT_TIMESTAMP - INTERVAL '80 days', CURRENT_TIMESTAMP + INTERVAL '10 days', false, 'card', 'completed', 39.99, 'USD', 'sk-suspended-runway-alice-123', '{"video_generation": true, "video_editing": true, "animation": true}', '{"video_generation": 15, "video_editing": 8, "animation": 12}')
ON CONFLICT (user_id, product_id) DO NOTHING;

-- Вставка тестовых платежей
INSERT INTO payments (subscription_id, user_id, amount, currency, payment_method, payment_provider, transaction_id, status, description, metadata) VALUES
-- Успешные платежи
(1, 3, 19.99, 'USD', 'card', 'stripe', 'txn_chatgpt_user_001', 'completed', 'Оплата подписки ChatGPT Стандарт', '{"product": "ChatGPT", "plan": "Стандарт", "billing_cycle": "monthly"}'),
(2, 3, 24.99, 'USD', 'card', 'stripe', 'txn_dalle_user_001', 'completed', 'Оплата подписки DALL-E Стандарт', '{"product": "DALL-E", "plan": "Стандарт", "billing_cycle": "monthly"}'),
(3, 5, 9.99, 'USD', 'card', 'stripe', 'txn_chatgpt_john_001', 'completed', 'Оплата подписки ChatGPT Базовый', '{"product": "ChatGPT", "plan": "Базовый", "billing_cycle": "monthly"}'),
(4, 6, 29.99, 'USD', 'card', 'stripe', 'txn_midjourney_jane_001', 'completed', 'Оплата подписки Midjourney Стандарт', '{"product": "Midjourney", "plan": "Стандарт", "billing_cycle": "monthly"}'),
(5, 7, 9.99, 'USD', 'card', 'stripe', 'txn_copilot_bob_001', 'completed', 'Оплата подписки GitHub Copilot Индивидуальный', '{"product": "GitHub Copilot", "plan": "Индивидуальный", "billing_cycle": "monthly"}'),
(6, 8, 14.99, 'USD', 'card', 'stripe', 'txn_whisper_alice_001', 'completed', 'Оплата подписки Whisper Стандарт', '{"product": "Whisper", "plan": "Стандарт", "billing_cycle": "monthly"}'),

-- Истекшие подписки
(7, 3, 7.99, 'USD', 'card', 'stripe', 'txn_elevenlabs_user_expired', 'completed', 'Оплата подписки ElevenLabs Стартовый', '{"product": "ElevenLabs", "plan": "Стартовый", "billing_cycle": "monthly"}'),
(8, 5, 19.99, 'USD', 'card', 'stripe', 'txn_stable_diffusion_john_expired', 'completed', 'Оплата подписки Stable Diffusion Облачный', '{"product": "Stable Diffusion", "plan": "Облачный", "billing_cycle": "monthly"}'),

-- Отмененные подписки
(9, 6, 24.99, 'USD', 'card', 'stripe', 'txn_jasper_jane_cancelled', 'completed', 'Оплата подписки Jasper Стартовый', '{"product": "Jasper", "plan": "Стартовый", "billing_cycle": "monthly"}'),
(10, 7, 14.99, 'USD', 'card', 'stripe', 'txn_claude_bob_cancelled', 'completed', 'Оплата подписки Claude Базовый', '{"product": "Claude", "plan": "Базовый", "billing_cycle": "monthly"}'),

-- Приостановленные подписки
(11, 8, 39.99, 'USD', 'card', 'stripe', 'txn_runway_alice_suspended', 'completed', 'Оплата подписки Runway Профессиональный', '{"product": "Runway", "plan": "Профессиональный", "billing_cycle": "monthly"}')
ON CONFLICT (subscription_id) DO NOTHING;

-- Комментарии к подпискам
COMMENT ON TABLE subscriptions IS 'Подписки пользователей на нейросетевые сервисы';
COMMENT ON COLUMN subscriptions.user_id IS 'Ссылка на пользователя';
COMMENT ON COLUMN subscriptions.product_id IS 'Ссылка на продукт (нейросеть)';
COMMENT ON COLUMN subscriptions.plan_id IS 'Ссылка на тарифный план';
COMMENT ON COLUMN subscriptions.status IS 'Статус подписки: active, expired, cancelled, suspended';
COMMENT ON COLUMN subscriptions.start_date IS 'Дата начала подписки';
COMMENT ON COLUMN subscriptions.end_date IS 'Дата окончания подписки';
COMMENT ON COLUMN subscriptions.auto_renew IS 'Автоматическое продление';
COMMENT ON COLUMN subscriptions.payment_method IS 'Способ оплаты';
COMMENT ON COLUMN subscriptions.payment_status IS 'Статус платежа';
COMMENT ON COLUMN subscriptions.amount_paid IS 'Сумма оплаты';
COMMENT ON COLUMN subscriptions.currency IS 'Валюта платежа';
COMMENT ON COLUMN subscriptions.api_key IS 'API ключ для доступа к сервису';
COMMENT ON COLUMN subscriptions.usage_limits IS 'Лимиты использования в JSON формате';
COMMENT ON COLUMN subscriptions.usage_current IS 'Текущее использование в JSON формате';

-- Комментарии к платежам
COMMENT ON TABLE payments IS 'Платежи за подписки на нейросетевые сервисы';
COMMENT ON COLUMN payments.subscription_id IS 'Ссылка на подписку';
COMMENT ON COLUMN payments.user_id IS 'Ссылка на пользователя';
COMMENT ON COLUMN payments.amount IS 'Сумма платежа';
COMMENT ON COLUMN payments.currency IS 'Валюта платежа';
COMMENT ON COLUMN payments.payment_method IS 'Способ оплаты';
COMMENT ON COLUMN payments.payment_provider IS 'Платежный провайдер';
COMMENT ON COLUMN payments.transaction_id IS 'Внешний идентификатор транзакции';
COMMENT ON COLUMN payments.status IS 'Статус платежа';
COMMENT ON COLUMN payments.description IS 'Описание платежа';
COMMENT ON COLUMN payments.metadata IS 'Дополнительные данные в JSON формате';





