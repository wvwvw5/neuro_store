-- ========================================
-- Инициализация тестовых пользователей
-- ========================================

-- Вставка тестовых пользователей с хешированными паролями
-- Пароли: admin123, moderator123, user123, viewer123
INSERT INTO users (email, username, full_name, hashed_password, role_id, is_active, is_verified) VALUES
('admin@neurostore.com', 'admin', 'Администратор системы', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 1, true, true),
('moderator@neurostore.com', 'moderator', 'Модератор контента', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 2, true, true),
('user@neurostore.com', 'testuser', 'Тестовый пользователь', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 3, true, true),
('viewer@neurostore.com', 'viewer', 'Просмотрщик', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 4, true, true),
('john.doe@example.com', 'johndoe', 'Джон Доу', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 3, true, true),
('jane.smith@example.com', 'janesmith', 'Джейн Смит', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 3, true, true),
('bob.wilson@example.com', 'bobwilson', 'Боб Уилсон', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 3, true, true),
('alice.brown@example.com', 'alicebrown', 'Алиса Браун', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5u.Gi', 3, true, true)
ON CONFLICT (email) DO NOTHING;

-- Комментарии к пользователям
COMMENT ON TABLE users IS 'Пользователи системы Neuro Store';
COMMENT ON COLUMN users.email IS 'Email пользователя для входа';
COMMENT ON COLUMN users.username IS 'Уникальное имя пользователя';
COMMENT ON COLUMN users.full_name IS 'Полное имя пользователя';
COMMENT ON COLUMN users.hashed_password IS 'Хеш пароля пользователя';
COMMENT ON COLUMN users.role_id IS 'Ссылка на роль пользователя';
COMMENT ON COLUMN users.is_active IS 'Статус активности пользователя';
COMMENT ON COLUMN users.is_verified IS 'Статус верификации email';

-- Информация о тестовых аккаунтах
COMMENT ON TABLE users IS 'Тестовые пользователи для демонстрации системы';
COMMENT ON COLUMN users.email IS 'Email для входа в систему';
COMMENT ON COLUMN users.username IS 'Логин для входа в систему';
COMMENT ON COLUMN users.full_name IS 'Отображаемое имя пользователя';
COMMENT ON COLUMN users.hashed_password IS 'Хеш пароля (все пароли: 123)';
COMMENT ON COLUMN users.role_id IS 'ID роли: 1=admin, 2=moderator, 3=user, 4=viewer';
COMMENT ON COLUMN users.is_active IS 'Активен ли пользователь';
COMMENT ON COLUMN users.is_verified IS 'Подтвержден ли email';





