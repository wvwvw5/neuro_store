-- ========================================
-- Инициализация API логов
-- ========================================

-- Вставка тестовых API логов для демонстрации системы
INSERT INTO api_logs (user_id, subscription_id, api_key_id, endpoint, method, status_code, response_time_ms, request_size, response_size, ip_address, user_agent, request_headers, response_headers, error_message, created_at) VALUES
-- Успешные запросы к ChatGPT
(3, 1, 1, '/api/v1/chat/completions', 'POST', 200, 1250, 512, 2048, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-chatgpt-user-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-001"}', NULL, CURRENT_TIMESTAMP - INTERVAL '2 hours'),
(3, 1, 1, '/api/v1/chat/completions', 'POST', 200, 980, 256, 1024, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-chatgpt-user-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-002"}', NULL, CURRENT_TIMESTAMP - INTERVAL '3 hours'),
(5, 3, 3, '/api/v1/chat/completions', 'POST', 200, 1100, 384, 1536, '192.168.1.101', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', '{"Authorization": "Bearer sk-chatgpt-john-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-003"}', NULL, CURRENT_TIMESTAMP - INTERVAL '6 hours'),

-- Успешные запросы к DALL-E
(3, 2, 2, '/api/v1/images/generations', 'POST', 200, 4500, 128, 2048, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-dalle-user-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-004"}', NULL, CURRENT_TIMESTAMP - INTERVAL '1 day'),
(3, 2, 2, '/api/v1/images/generations', 'POST', 200, 5200, 256, 2048, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-dalle-user-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-005"}', NULL, CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- Успешные запросы к Midjourney
(6, 4, 4, '/api/v1/imagine', 'POST', 200, 8000, 512, 1024, '192.168.1.102', 'Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36', '{"Authorization": "Bearer sk-midjourney-jane-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-006"}', NULL, CURRENT_TIMESTAMP - INTERVAL '12 hours'),
(6, 4, 4, '/api/v1/imagine', 'POST', 200, 7500, 256, 1024, '192.168.1.102', 'Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36', '{"Authorization": "Bearer sk-midjourney-jane-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-007"}', NULL, CURRENT_TIMESTAMP - INTERVAL '13 hours'),

-- Успешные запросы к GitHub Copilot
(7, 5, 5, '/api/v1/copilot/suggestions', 'POST', 200, 150, 1024, 512, '192.168.1.103', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-copilot-bob-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-008"}', NULL, CURRENT_TIMESTAMP - INTERVAL '3 hours'),
(7, 5, 5, '/api/v1/copilot/suggestions', 'POST', 200, 180, 2048, 1024, '192.168.1.103', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-copilot-bob-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-009"}', NULL, CURRENT_TIMESTAMP - INTERVAL '4 hours'),

-- Успешные запросы к Whisper
(8, 6, 6, '/api/v1/audio/transcriptions', 'POST', 200, 3200, 5120, 256, '192.168.1.104', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', '{"Authorization": "Bearer sk-whisper-alice-123", "Content-Type": "multipart/form-data"}', '{"Content-Type": "application/json", "X-Request-ID": "req-010"}', NULL, CURRENT_TIMESTAMP - INTERVAL '1 hour'),
(8, 6, 6, '/api/v1/audio/transcriptions', 'POST', 200, 2800, 2560, 128, '192.168.1.104', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', '{"Authorization": "Bearer sk-whisper-alice-123", "Content-Type": "multipart/form-data"}', '{"Content-Type": "application/json", "X-Request-ID": "req-011"}', NULL, CURRENT_TIMESTAMP - INTERVAL '2 hours'),

-- Запросы с ошибками (истекшие подписки)
(3, 7, 7, '/api/v1/voice/generate', 'POST', 401, 50, 256, 128, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-elevenlabs-user-expired", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-012"}', 'Subscription expired', CURRENT_TIMESTAMP - INTERVAL '35 days'),
(5, 8, 8, '/api/v1/images/generations', 'POST', 401, 45, 512, 128, '192.168.1.101', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', '{"Authorization": "Bearer sk-stable-diffusion-john-expired", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-013"}', 'Subscription expired', CURRENT_TIMESTAMP - INTERVAL '65 days'),

-- Запросы с ошибками (отмененные подписки)
(6, 9, 9, '/api/v1/content/generate', 'POST', 403, 60, 128, 128, '192.168.1.102', 'Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36', '{"Authorization": "Bearer sk-jasper-jane-cancelled", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-014"}', 'Subscription cancelled', CURRENT_TIMESTAMP - INTERVAL '50 days'),
(7, 10, 10, '/api/v1/chat/completions', 'POST', 403, 55, 256, 128, '192.168.1.103', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-claude-bob-cancelled", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-015"}', 'Subscription cancelled', CURRENT_TIMESTAMP - INTERVAL '65 days'),

-- Запросы с ошибками (приостановленные подписки)
(8, 11, 11, '/api/v1/video/generate', 'POST', 403, 70, 1024, 128, '192.168.1.104', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', '{"Authorization": "Bearer sk-runway-alice-suspended", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-016"}', 'Subscription suspended', CURRENT_TIMESTAMP - INTERVAL '85 days'),

-- Административные запросы
(1, NULL, 12, '/api/v1/admin/users', 'GET', 200, 120, 0, 2048, '192.168.1.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-admin-master", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-017"}', NULL, CURRENT_TIMESTAMP - INTERVAL '30 minutes'),
(1, NULL, 12, '/api/v1/admin/subscriptions', 'GET', 200, 95, 0, 1536, '192.168.1.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-admin-master", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-018"}', NULL, CURRENT_TIMESTAMP - INTERVAL '1 hour'),

-- Модераторские запросы
(2, NULL, 13, '/api/v1/products', 'GET', 200, 80, 0, 1024, '192.168.1.2', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', '{"Authorization": "Bearer sk-moderator-key", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-019"}', NULL, CURRENT_TIMESTAMP - INTERVAL '2 hours'),
(2, NULL, 13, '/api/v1/categories', 'GET', 200, 65, 0, 512, '192.168.1.2', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', '{"Authorization": "Bearer sk-moderator-key", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-020"}', NULL, CURRENT_TIMESTAMP - INTERVAL '3 hours'),

-- Запросы просмотрщика
(4, NULL, 14, '/api/v1/products', 'GET', 200, 75, 0, 1024, '192.168.1.4', 'Mozilla/5.0 (Linux; Android 12; Pixel 6) AppleWebKit/537.36', '{"Authorization": "Bearer sk-viewer-key", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-021"}', NULL, CURRENT_TIMESTAMP - INTERVAL '1 day'),
(4, NULL, 14, '/api/v1/plans', 'GET', 200, 60, 0, 512, '192.168.1.4', 'Mozilla/5.0 (Linux; Android 12; Pixel 6) AppleWebKit/537.36', '{"Authorization": "Bearer sk-viewer-key", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-022"}', NULL, CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- Запросы с ошибками аутентификации
(NULL, NULL, NULL, '/api/v1/chat/completions', 'POST', 401, 25, 256, 128, '192.168.1.105', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-023"}', 'Invalid API key', CURRENT_TIMESTAMP - INTERVAL '30 minutes'),
(NULL, NULL, NULL, '/api/v1/images/generations', 'POST', 401, 30, 128, 128, '192.168.1.106', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', '{"Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-024"}', 'Missing API key', CURRENT_TIMESTAMP - INTERVAL '1 hour'),

-- Запросы с ошибками валидации
(3, 1, 1, '/api/v1/chat/completions', 'POST', 422, 45, 256, 256, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '{"Authorization": "Bearer sk-chatgpt-user-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-025"}', 'Invalid request parameters', CURRENT_TIMESTAMP - INTERVAL '4 hours'),
(6, 4, 4, '/api/v1/imagine', 'POST', 422, 50, 512, 256, '192.168.1.102', 'Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36', '{"Authorization": "Bearer sk-midjourney-jane-123", "Content-Type": "application/json"}', '{"Content-Type": "application/json", "X-Request-ID": "req-026"}', 'Prompt too long', CURRENT_TIMESTAMP - INTERVAL '14 hours')
ON CONFLICT (id) DO NOTHING;

-- Комментарии к API логам
COMMENT ON TABLE api_logs IS 'Логи API запросов к нейросетевым сервисам';
COMMENT ON COLUMN api_logs.user_id IS 'Ссылка на пользователя (может быть NULL для неаутентифицированных запросов)';
COMMENT ON COLUMN api_logs.subscription_id IS 'Ссылка на подписку (может быть NULL для системных запросов)';
COMMENT ON COLUMN api_logs.api_key_id IS 'Ссылка на API ключ (может быть NULL для неаутентифицированных запросов)';
COMMENT ON COLUMN api_logs.endpoint IS 'API эндпоинт';
COMMENT ON COLUMN api_logs.method IS 'HTTP метод';
COMMENT ON COLUMN api_logs.status_code IS 'HTTP статус код ответа';
COMMENT ON COLUMN api_logs.response_time_ms IS 'Время ответа в миллисекундах';
COMMENT ON COLUMN api_logs.request_size IS 'Размер запроса в байтах';
COMMENT ON COLUMN api_logs.response_size IS 'Размер ответа в байтах';
COMMENT ON COLUMN api_logs.ip_address IS 'IP адрес клиента';
COMMENT ON COLUMN api_logs.user_agent IS 'User Agent клиента';
COMMENT ON COLUMN api_logs.request_headers IS 'Заголовки запроса в JSON формате';
COMMENT ON COLUMN api_logs.response_headers IS 'Заголовки ответа в JSON формате';
COMMENT ON COLUMN api_logs.error_message IS 'Сообщение об ошибке (если есть)';
COMMENT ON COLUMN api_logs.created_at IS 'Время создания записи';

-- Информация о тестовых API логах
COMMENT ON TABLE api_logs IS 'Тестовые API логи для демонстрации системы мониторинга';
COMMENT ON COLUMN api_logs.status_code IS 'Статус коды: 200=OK, 401=Unauthorized, 403=Forbidden, 422=Validation Error';
COMMENT ON COLUMN api_logs.response_time_ms IS 'Время ответа для анализа производительности API';
COMMENT ON COLUMN api_logs.error_message IS 'Описание ошибки для диагностики проблем';
COMMENT ON COLUMN api_logs.ip_address IS 'IP адрес для анализа географического распределения запросов';
COMMENT ON COLUMN api_logs.user_agent IS 'Информация о клиенте для анализа использования';





