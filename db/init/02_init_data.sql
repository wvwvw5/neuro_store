-- Инициализация базы данных Neuro Store
-- Выполняется автоматически при первом запуске Docker контейнера

-- Вставка ролей пользователей
INSERT INTO roles (name, description, is_active) VALUES
('admin', 'Администратор системы', true),
('moderator', 'Модератор контента', true),
('user', 'Обычный пользователь', true)
ON CONFLICT (name) DO NOTHING;

-- Вставка продуктов (нейросетей)
INSERT INTO products (name, description, category, api_endpoint, is_active) VALUES
('ChatGPT', 'Мощная языковая модель для генерации текста, ответов на вопросы и творческих задач', 'Языковые модели', 'https://api.openai.com/v1/chat/completions', true),
('DALL-E', 'Создание уникальных изображений по текстовому описанию', 'Генерация изображений', 'https://api.openai.com/v1/images/generations', true),
('Midjourney', 'Создание художественных изображений высокого качества', 'Генерация изображений', 'https://api.midjourney.com/v1/generate', true),
('Claude', 'AI-ассистент от Anthropic для анализа текста и генерации контента', 'Языковые модели', 'https://api.anthropic.com/v1/messages', true),
('Stable Diffusion', 'Открытая модель для генерации изображений с высокой степенью контроля', 'Генерация изображений', 'https://api.stability.ai/v1/generation', true),
('Jasper', 'AI-помощник для создания маркетингового контента', 'Маркетинг', 'https://api.jasper.ai/v1/content', true)
ON CONFLICT (name) DO NOTHING;

-- Вставка тарифных планов
INSERT INTO plans (name, description, price, duration_days, max_requests_per_month, features, is_active) VALUES
('Базовый', 'Для начинающих пользователей', 299.00, 30, 100, 'Базовый доступ к API, поддержка по email', true),
('Стандарт', 'Для активных пользователей', 599.00, 30, 500, 'Расширенный доступ, приоритетная поддержка, аналитика', true),
('Премиум', 'Для профессионалов', 1299.00, 30, 2000, 'Максимальный доступ, персональный менеджер, API ключи', true),
('Годовой', 'Выгодная годовая подписка', 9999.00, 365, 25000, 'Все возможности Премиум + скидка 23%', true),
('Пробный', 'Пробный доступ на 7 дней', 0.00, 7, 10, 'Ограниченный функционал для тестирования', true)
ON CONFLICT (name) DO NOTHING;

-- Связывание продуктов и планов
INSERT INTO product_plans (product_id, plan_id, is_available) VALUES
-- ChatGPT
(1, 1, true), (1, 2, true), (1, 3, true), (1, 4, true), (1, 5, true),
-- DALL-E
(2, 1, true), (2, 2, true), (2, 3, true), (2, 4, true), (2, 5, true),
-- Midjourney
(3, 1, true), (3, 2, true), (3, 3, true), (3, 4, true), (3, 5, true),
-- Claude
(4, 1, true), (4, 2, true), (4, 3, true), (4, 4, true), (4, 5, true),
-- Stable Diffusion
(5, 1, true), (5, 2, true), (5, 3, true), (5, 4, true), (5, 5, true),
-- Jasper
(6, 1, true), (6, 2, true), (6, 3, true), (6, 4, true), (6, 5, true)
ON CONFLICT (product_id, plan_id) DO NOTHING;

-- Создание тестового пользователя (пароль: test123)
INSERT INTO users (email, password_hash, first_name, last_name, phone, balance, is_active, is_verified) VALUES
('test@neurostore.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/HS.iK8i', 'Тест', 'Пользователь', '+7 (999) 123-45-67', 1000.00, true, true)
ON CONFLICT (email) DO NOTHING;

-- Назначение роли пользователю
INSERT INTO user_roles (user_id, role_id) VALUES
(1, 3)  -- Роль "user" для тестового пользователя
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Создание тестовой подписки
INSERT INTO subscriptions (user_id, product_id, plan_id, status, start_date, end_date, auto_renew, requests_used) VALUES
(1, 1, 2, 'active', NOW(), NOW() + INTERVAL '30 days', true, 25)
ON CONFLICT DO NOTHING;

-- Создание тестового заказа
INSERT INTO orders (user_id, product_id, plan_id, status, amount, currency, notes) VALUES
(1, 1, 2, 'completed', 599.00, 'RUB', 'Тестовый заказ для ChatGPT Стандарт')
ON CONFLICT DO NOTHING;

-- Создание тестового платежа
INSERT INTO payments (order_id, user_id, amount, currency, payment_method, status, payment_date) VALUES
(1, 1, 599.00, 'RUB', 'balance', 'completed', NOW())
ON CONFLICT (order_id) DO NOTHING;

-- Создание тестовых событий использования
INSERT INTO usage_events (user_id, subscription_id, product_id, event_type, request_data, response_data, tokens_used, cost, duration_ms, status) VALUES
(1, 1, 1, 'chat_completion', '{"prompt": "Привет, как дела?"}', '{"response": "Привет! У меня все хорошо, спасибо что спросили!"}', 15, 0.0003, 1200, 'success'),
(1, 1, 1, 'chat_completion', '{"prompt": "Расскажи о нейросетях"}', '{"response": "Нейросети - это..."}', 45, 0.0009, 2100, 'success')
ON CONFLICT DO NOTHING;

-- Обновление баланса пользователя после покупки
UPDATE users SET balance = balance - 599.00 WHERE id = 1;

COMMIT;
