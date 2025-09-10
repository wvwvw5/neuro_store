-- ========================================
-- Инициализация API ключей
-- ========================================

-- Вставка тестовых API ключей для демонстрации системы
INSERT INTO api_keys (user_id, subscription_id, name, key_hash, permissions, is_active, last_used, expires_at) VALUES
-- API ключи для активных подписок
(3, 1, 'ChatGPT API Key', 'sk-chatgpt-user-123-hash', '["chat", "text_generation", "conversation"]', true, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP + INTERVAL '30 days'),
(3, 2, 'DALL-E API Key', 'sk-dalle-user-123-hash', '["image_generation", "text_to_image", "variations"]', true, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP + INTERVAL '45 days'),
(5, 3, 'ChatGPT API Key', 'sk-chatgpt-john-123-hash', '["chat", "text_generation"]', true, CURRENT_TIMESTAMP - INTERVAL '6 hours', CURRENT_TIMESTAMP + INTERVAL '23 days'),
(6, 4, 'Midjourney API Key', 'sk-midjourney-jane-123-hash', '["image_generation", "fast_mode"]', true, CURRENT_TIMESTAMP - INTERVAL '12 hours', CURRENT_TIMESTAMP + INTERVAL '40 days'),
(7, 5, 'GitHub Copilot API Key', 'sk-copilot-bob-123-hash', '["code_completion", "github_integration"]', true, CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP + INTERVAL '20 days'),
(8, 6, 'Whisper API Key', 'sk-whisper-alice-123-hash', '["speech_recognition", "transcription"]', true, CURRENT_TIMESTAMP - INTERVAL '1 hour', CURRENT_TIMESTAMP + INTERVAL '25 days'),

-- API ключи для истекших подписок
(3, 7, 'ElevenLabs API Key', 'sk-elevenlabs-user-expired-hash', '["voice_generation", "voice_cloning"]', false, CURRENT_TIMESTAMP - INTERVAL '35 days', CURRENT_TIMESTAMP - INTERVAL '5 days'),
(5, 8, 'Stable Diffusion API Key', 'sk-stable-diffusion-john-expired-hash', '["image_generation", "cloud_processing"]', false, CURRENT_TIMESTAMP - INTERVAL '65 days', CURRENT_TIMESTAMP - INTERVAL '5 days'),

-- API ключи для отмененных подписок
(6, 9, 'Jasper API Key', 'sk-jasper-jane-cancelled-hash', '["content_creation", "templates"]', false, CURRENT_TIMESTAMP - INTERVAL '50 days', CURRENT_TIMESTAMP - INTERVAL '20 days'),
(7, 10, 'Claude API Key', 'sk-claude-bob-cancelled-hash', '["text_analysis", "content_writing"]', false, CURRENT_TIMESTAMP - INTERVAL '65 days', CURRENT_TIMESTAMP - INTERVAL '35 days'),

-- API ключи для приостановленных подписок
(8, 11, 'Runway API Key', 'sk-runway-alice-suspended-hash', '["video_generation", "video_editing", "animation"]', false, CURRENT_TIMESTAMP - INTERVAL '85 days', CURRENT_TIMESTAMP - INTERVAL '5 days'),

-- Дополнительные API ключи для тестирования
(1, NULL, 'Admin Master Key', 'sk-admin-master-hash', '["*"]', true, CURRENT_TIMESTAMP - INTERVAL '30 minutes', NULL),
(2, NULL, 'Moderator Key', 'sk-moderator-key-hash', '["read:*", "write:products", "write:categories"]', true, CURRENT_TIMESTAMP - INTERVAL '2 hours', NULL),
(4, NULL, 'Viewer Key', 'sk-viewer-key-hash', '["read:products", "read:plans"]', true, CURRENT_TIMESTAMP - INTERVAL '1 day', NULL)
ON CONFLICT (key_hash) DO NOTHING;

-- Комментарии к API ключам
COMMENT ON TABLE api_keys IS 'API ключи для доступа к нейросетевым сервисам';
COMMENT ON COLUMN api_keys.user_id IS 'Ссылка на пользователя';
COMMENT ON COLUMN api_keys.subscription_id IS 'Ссылка на подписку (может быть NULL для системных ключей)';
COMMENT ON COLUMN api_keys.name IS 'Название API ключа';
COMMENT ON COLUMN api_keys.key_hash IS 'Хеш API ключа для безопасности';
COMMENT ON COLUMN api_keys.permissions IS 'JSON массив разрешений для ключа';
COMMENT ON COLUMN api_keys.is_active IS 'Активен ли API ключ';
COMMENT ON COLUMN api_keys.last_used IS 'Время последнего использования ключа';
COMMENT ON COLUMN api_keys.expires_at IS 'Время истечения ключа (NULL = бессрочно)';

-- Информация о тестовых API ключах
COMMENT ON TABLE api_keys IS 'Тестовые API ключи для демонстрации системы';
COMMENT ON COLUMN api_keys.key_hash IS 'Хеш API ключа (в реальной системе это будет bcrypt хеш)';
COMMENT ON COLUMN api_keys.permissions IS 'Разрешения: ["*"] = все, ["read:*"] = только чтение, конкретные разрешения';
COMMENT ON COLUMN api_keys.is_active IS 'Активность ключа (false для истекших/отмененных подписок)';
COMMENT ON COLUMN api_keys.last_used IS 'Время последнего использования для мониторинга активности';
COMMENT ON COLUMN api_keys.expires_at IS 'Дата истечения (NULL для бессрочных системных ключей)';





