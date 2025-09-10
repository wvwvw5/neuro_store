-- ========================================
-- Инициализация тарифных планов
-- ========================================

-- Вставка базовых тарифных планов для разных продуктов
INSERT INTO plans (product_id, name, description, price, currency, billing_cycle, features, limits, is_popular, sort_order) VALUES
-- ChatGPT планы
(1, 'Базовый', 'Базовый доступ к ChatGPT с ограниченным количеством запросов', 9.99, 'USD', 'monthly', '["chat", "text_generation", "basic_support"]', '{"requests_per_month": 1000, "conversation_length": 1000}', false, 1),
(1, 'Стандарт', 'Расширенный доступ с приоритетом и дополнительными возможностями', 19.99, 'USD', 'monthly', '["chat", "text_generation", "priority_access", "advanced_features", "email_support"]', '{"requests_per_month": 5000, "conversation_length": 4000}', true, 2),
(1, 'Премиум', 'Полный доступ с максимальным приоритетом и всеми функциями', 39.99, 'USD', 'monthly', '["chat", "text_generation", "priority_access", "advanced_features", "custom_models", "phone_support"]', '{"requests_per_month": 10000, "conversation_length": 8000}', false, 3),
(1, 'Годовой', 'Годовая подписка со скидкой 20%', 399.99, 'USD', 'yearly', '["chat", "text_generation", "priority_access", "advanced_features", "custom_models", "phone_support", "annual_discount"]', '{"requests_per_month": 10000, "conversation_length": 8000}', false, 4),

-- Claude планы
(2, 'Базовый', 'Базовый доступ к Claude AI', 14.99, 'USD', 'monthly', '["text_analysis", "content_writing", "basic_support"]', '{"requests_per_month": 800, "context_length": 100000}', false, 1),
(2, 'Профессиональный', 'Профессиональный доступ с расширенными возможностями', 29.99, 'USD', 'monthly', '["text_analysis", "content_writing", "advanced_features", "priority_access", "email_support"]', '{"requests_per_month": 3000, "context_length": 200000}', true, 2),
(2, 'Годовой', 'Годовая подписка со скидкой', 299.99, 'USD', 'yearly', '["text_analysis", "content_writing", "advanced_features", "priority_access", "email_support", "annual_discount"]', '{"requests_per_month": 3000, "context_length": 200000}', false, 3),

-- DALL-E планы
(4, 'Стартовый', 'Базовый доступ к генерации изображений', 12.99, 'USD', 'monthly', '["image_generation", "basic_models", "standard_resolution"]', '{"images_per_month": 50, "resolution": "1024x1024"}', false, 1),
(4, 'Стандарт', 'Расширенный доступ с высоким разрешением', 24.99, 'USD', 'monthly', '["image_generation", "advanced_models", "high_resolution", "variations"]', '{"images_per_month": 200, "resolution": "1024x1024"}', true, 2),
(4, 'Профессиональный', 'Профессиональный доступ с максимальным качеством', 49.99, 'USD', 'monthly', '["image_generation", "all_models", "maximum_resolution", "variations", "priority_processing"]', '{"images_per_month": 500, "resolution": "1792x1024"}', false, 3),

-- Midjourney планы
(5, 'Базовый', 'Базовый доступ к Midjourney', 9.99, 'USD', 'monthly', '["image_generation", "basic_models", "community_access"]', '{"images_per_month": 200, "fast_mode": false}', false, 1),
(5, 'Стандарт', 'Стандартный доступ с быстрым режимом', 29.99, 'USD', 'monthly', '["image_generation", "advanced_models", "fast_mode", "priority_access"]', '{"images_per_month": 1000, "fast_mode": true}', true, 2),
(5, 'Премиум', 'Премиум доступ с максимальными возможностями', 59.99, 'USD', 'monthly', '["image_generation", "all_models", "fast_mode", "priority_access", "private_mode"]', '{"images_per_month": 3000, "fast_mode": true}', false, 3),

-- Stable Diffusion планы
(6, 'Облачный', 'Облачный доступ к Stable Diffusion', 19.99, 'USD', 'monthly', '["image_generation", "cloud_processing", "model_access"]', '{"images_per_month": 100, "processing_time": "standard"}', false, 1),
(6, 'Профессиональный', 'Профессиональный доступ с быстрой обработкой', 39.99, 'USD', 'monthly', '["image_generation", "cloud_processing", "fast_processing", "custom_models"]', '{"images_per_month": 500, "processing_time": "fast"}', true, 2),
(6, 'Enterprise', 'Корпоративный доступ с выделенными ресурсами', 99.99, 'USD', 'monthly', '["image_generation", "dedicated_resources", "custom_models", "api_access", "support"]', '{"images_per_month": 2000, "processing_time": "instant"}', false, 3),

-- Whisper планы
(7, 'Базовый', 'Базовый доступ к распознаванию речи', 4.99, 'USD', 'monthly', '["speech_recognition", "basic_models", "standard_accuracy"]', '{"audio_hours_per_month": 10, "languages": 5}', false, 1),
(7, 'Стандарт', 'Стандартный доступ с высокой точностью', 14.99, 'USD', 'monthly', '["speech_recognition", "advanced_models", "high_accuracy", "custom_vocabulary"]', '{"audio_hours_per_month": 50, "languages": 20}', true, 2),
(7, 'Профессиональный', 'Профессиональный доступ с максимальной точностью', 29.99, 'USD', 'monthly', '["speech_recognition", "all_models", "maximum_accuracy", "custom_vocabulary", "api_access"]', '{"audio_hours_per_month": 200, "languages": 50}', false, 3),

-- ElevenLabs планы
(8, 'Стартовый', 'Базовый доступ к генерации голоса', 7.99, 'USD', 'monthly', '["voice_generation", "basic_voices", "standard_quality"]', '{"characters_per_month": 10000, "voices": 5}', false, 1),
(8, 'Создатель', 'Доступ для создателей контента', 19.99, 'USD', 'monthly', '["voice_generation", "premium_voices", "high_quality", "voice_cloning"]', '{"characters_per_month": 50000, "voices": 15}', true, 2),
(8, 'Профессиональный', 'Профессиональный доступ с максимальными возможностями', 39.99, 'USD', 'monthly', '["voice_generation", "all_voices", "maximum_quality", "voice_cloning", "api_access"]', '{"characters_per_month": 200000, "voices": 30}', false, 3),

-- GitHub Copilot планы
(12, 'Индивидуальный', 'Персональный доступ для разработчиков', 9.99, 'USD', 'monthly', '["code_completion", "github_integration", "personal_use"]', '{"repositories": "unlimited", "languages": "all"}', false, 1),
(12, 'Команда', 'Доступ для команд разработчиков', 19.99, 'USD', 'USD', 'monthly', '["code_completion", "github_integration", "team_features", "admin_controls"]', '{"repositories": "unlimited", "languages": "all", "team_size": 10}', true, 2),
(12, 'Enterprise', 'Корпоративный доступ с расширенными возможностями', 39.99, 'USD', 'monthly', '["code_completion", "github_integration", "enterprise_features", "security", "support"]', '{"repositories": "unlimited", "languages": "all", "team_size": "unlimited"}', false, 3),

-- Jasper планы
(14, 'Стартовый', 'Базовый доступ для создания контента', 24.99, 'USD', 'monthly', '["content_creation", "basic_templates", "standard_models"]', '{"words_per_month": 20000, "templates": 50}', false, 1),
(14, 'Профессиональный', 'Профессиональный доступ с расширенными возможностями', 49.99, 'USD', 'monthly', '["content_creation", "all_templates", "advanced_models", "team_collaboration"]', '{"words_per_month": 100000, "templates": 100}', true, 2),
(14, 'Business', 'Бизнес доступ с корпоративными функциями', 99.99, 'USD', 'monthly', '["content_creation", "all_templates", "all_models", "team_collaboration", "api_access", "support"]', '{"words_per_month": 500000, "templates": "unlimited"}', false, 3)
ON CONFLICT (product_id, name) DO NOTHING;

-- Комментарии к планам
COMMENT ON TABLE plans IS 'Тарифные планы для нейросетевых сервисов';
COMMENT ON COLUMN plans.product_id IS 'Ссылка на продукт';
COMMENT ON COLUMN plans.name IS 'Название тарифного плана';
COMMENT ON COLUMN plans.description IS 'Описание возможностей плана';
COMMENT ON COLUMN plans.price IS 'Стоимость плана';
COMMENT ON COLUMN plans.currency IS 'Валюта цены';
COMMENT ON COLUMN plans.billing_cycle IS 'Цикл оплаты (monthly, yearly, lifetime)';
COMMENT ON COLUMN plans.features IS 'JSON массив доступных функций';
COMMENT ON COLUMN plans.limits IS 'JSON объект с ограничениями плана';
COMMENT ON COLUMN plans.is_popular IS 'Флаг популярного плана';
COMMENT ON COLUMN plans.sort_order IS 'Порядок сортировки планов';





