-- ========================================
-- Инициализация ролей пользователей
-- ========================================

-- Вставка базовых ролей
INSERT INTO roles (name, description, permissions) VALUES
('admin', 'Администратор системы', '["*"]'),
('moderator', 'Модератор контента', '["read:*", "write:products", "write:categories", "read:users", "read:subscriptions"]'),
('user', 'Обычный пользователь', '["read:products", "read:plans", "write:subscriptions", "read:own_subscriptions", "write:own_profile"]'),
('viewer', 'Просмотрщик', '["read:products", "read:plans"]')
ON CONFLICT (name) DO NOTHING;

-- Комментарии к ролям
COMMENT ON ROLE admin IS 'Полный доступ ко всем функциям системы';
COMMENT ON ROLE moderator IS 'Управление продуктами и категориями, просмотр пользователей';
COMMENT ON ROLE user IS 'Покупка подписок, управление профилем';
COMMENT ON ROLE viewer IS 'Только просмотр доступных продуктов и планов';





