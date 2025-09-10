-- ========================================
-- Инициализация уведомлений
-- ========================================

-- Вставка тестовых уведомлений для демонстрации системы
INSERT INTO notifications (user_id, type, title, message, data, is_read, read_at, sent_at, created_at) VALUES
-- Уведомления о новых подписках
(3, 'email', 'Подписка активирована', 'Ваша подписка на ChatGPT Стандарт успешно активирована!', '{"subscription_id": 1, "product": "ChatGPT", "plan": "Стандарт", "start_date": "2024-01-01"}', true, CURRENT_TIMESTAMP - INTERVAL '25 days', CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '30 days'),
(3, 'email', 'Подписка активирована', 'Ваша подписка на DALL-E Стандарт успешно активирована!', '{"subscription_id": 2, "product": "DALL-E", "plan": "Стандарт", "start_date": "2024-01-15"}', true, CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_TIMESTAMP - INTERVAL '15 days'),
(5, 'email', 'Подписка активирована', 'Ваша подписка на ChatGPT Базовый успешно активирована!', '{"subscription_id": 3, "product": "ChatGPT", "plan": "Базовый", "start_date": "2024-01-23"}', true, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP - INTERVAL '7 days'),
(6, 'email', 'Подписка активирована', 'Ваша подписка на Midjourney Стандарт успешно активирована!', '{"subscription_id": 4, "product": "Midjourney", "plan": "Стандарт", "start_date": "2024-01-10"}', true, CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_TIMESTAMP - INTERVAL '20 days', CURRENT_TIMESTAMP - INTERVAL '20 days'),
(7, 'email', 'Подписка активирована', 'Ваша подписка на GitHub Copilot Индивидуальный успешно активирована!', '{"subscription_id": 5, "product": "GitHub Copilot", "plan": "Индивидуальный", "start_date": "2024-01-20"}', true, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '10 days'),
(8, 'email', 'Подписка активирована', 'Ваша подписка на Whisper Стандарт успешно активирована!', '{"subscription_id": 6, "product": "Whisper", "plan": "Стандарт", "start_date": "2024-01-25"}', true, CURRENT_TIMESTAMP - INTERVAL '0 days', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days'),

-- Уведомления о приближающемся окончании подписки
(3, 'email', 'Подписка скоро истечет', 'Ваша подписка на ChatGPT Стандарт истекает через 5 дней. Продлите её, чтобы не потерять доступ!', '{"subscription_id": 1, "product": "ChatGPT", "plan": "Стандарт", "days_left": 5, "renewal_price": "19.99"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(3, 'email', 'Подписка скоро истечет', 'Ваша подписка на DALL-E Стандарт истекает через 30 дней. Продлите её, чтобы не потерять доступ!', '{"subscription_id": 2, "product": "DALL-E", "plan": "Стандарт", "days_left": 30, "renewal_price": "24.99"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(5, 'email', 'Подписка скоро истечет', 'Ваша подписка на ChatGPT Базовый истекает через 16 дней. Продлите её, чтобы не потерять доступ!', '{"subscription_id": 3, "product": "ChatGPT", "plan": "Базовый", "days_left": 16, "renewal_price": "9.99"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(6, 'email', 'Подписка скоро истечет', 'Ваша подписка на Midjourney Стандарт истекает через 20 дней. Продлите её, чтобы не потерять доступ!', '{"subscription_id": 4, "product": "Midjourney", "plan": "Стандарт", "days_left": 20, "renewal_price": "29.99"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(7, 'email', 'Подписка скоро истечет', 'Ваша подписка на GitHub Copilot Индивидуальный истекает через 10 дней. Продлите её, чтобы не потерять доступ!', '{"subscription_id": 5, "product": "GitHub Copilot", "plan": "Индивидуальный", "days_left": 10, "renewal_price": "9.99"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(8, 'email', 'Подписка скоро истечет', 'Ваша подписка на Whisper Стандарт истекает через 20 дней. Продлите её, чтобы не потерять доступ!', '{"subscription_id": 6, "product": "Whisper", "plan": "Стандарт", "days_left": 20, "renewal_price": "14.99"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- Уведомления о новых продуктах
(3, 'email', 'Новый продукт доступен', 'Теперь доступен новый продукт: Stable Diffusion XL! Создавайте изображения в сверхвысоком разрешении.', '{"product_id": 6, "product_name": "Stable Diffusion XL", "category": "Генерация изображений", "special_offer": "Скидка 20% на первый месяц"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days'),
(5, 'email', 'Новый продукт доступен', 'Теперь доступен новый продукт: Claude 3! Улучшенная модель для анализа и создания контента.', '{"product_id": 2, "product_name": "Claude 3", "category": "Языковые модели", "special_offer": "Бесплатный пробный период 7 дней"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days'),
(6, 'email', 'Новый продукт доступен', 'Теперь доступен новый продукт: Runway Gen-3! Создавайте потрясающие видео с помощью AI.', '{"product_id": 9, "product_name": "Runway Gen-3", "category": "Видео и анимация", "special_offer": "Скидка 30% на первый месяц"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days'),

-- Уведомления о специальных предложениях
(3, 'email', 'Специальное предложение', 'Получите скидку 25% на годовую подписку ChatGPT! Экономьте деньги и получайте больше возможностей.', '{"product_id": 1, "product_name": "ChatGPT", "discount": "25%", "valid_until": "2024-02-15", "original_price": "239.88", "discounted_price": "179.91"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days'),
(5, 'email', 'Специальное предложение', 'Скидка 20% на все планы DALL-E! Создавайте больше изображений по выгодной цене.', '{"product_id": 4, "product_name": "DALL-E", "discount": "20%", "valid_until": "2024-02-10", "products": ["Стартовый", "Стандарт", "Профессиональный"]}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days'),
(7, 'email', 'Специальное предложение', 'Скидка 15% на GitHub Copilot для команд! Улучшите продуктивность вашей команды разработчиков.', '{"product_id": 12, "product_name": "GitHub Copilot", "discount": "15%", "valid_until": "2024-02-20", "plan": "Команда", "original_price": "19.99", "discounted_price": "16.99"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days'),

-- Уведомления о технических работах
(3, 'email', 'Технические работы', 'Внимание! 15 февраля с 02:00 до 06:00 по МСК будут проводиться технические работы. Возможны кратковременные перебои в работе сервиса.', '{"maintenance_date": "2024-02-15", "start_time": "02:00", "end_time": "06:00", "timezone": "MSK", "affected_services": ["ChatGPT", "DALL-E"]}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(5, 'email', 'Технические работы', 'Внимание! 15 февраля с 02:00 до 06:00 по МСК будут проводиться технические работы. Возможны кратковременные перебои в работе сервиса.', '{"maintenance_date": "2024-02-15", "start_time": "02:00", "end_time": "06:00", "timezone": "MSK", "affected_services": ["ChatGPT"]}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(6, 'email', 'Технические работы', 'Внимание! 15 февраля с 02:00 до 06:00 по МСК будут проводиться технические работы. Возможны кратковременные перебои в работе сервиса.', '{"maintenance_date": "2024-02-15", "start_time": "02:00", "end_time": "06:00", "timezone": "MSK", "affected_services": ["Midjourney"]}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- Уведомления о безопасности
(3, 'email', 'Обновление безопасности', 'Мы обновили систему безопасности. Рекомендуем сменить пароль для повышения защиты вашего аккаунта.', '{"security_update": "2024-01-30", "recommended_action": "change_password", "affected_users": "all", "priority": "medium"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(5, 'email', 'Обновление безопасности', 'Мы обновили систему безопасности. Рекомендуем сменить пароль для повышения защиты вашего аккаунта.', '{"security_update": "2024-01-30", "recommended_action": "change_password", "affected_users": "all", "priority": "medium"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(6, 'email', 'Обновление безопасности', 'Мы обновили систему безопасности. Рекомендуем сменить пароль для повышения защиты вашего аккаунта.', '{"security_update": "2024-01-30", "recommended_action": "change_password", "affected_users": "all", "priority": "medium"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- Push уведомления (для мобильного приложения)
(3, 'push', 'Новое сообщение', 'У вас есть непрочитанное сообщение от поддержки', '{"notification_type": "support_message", "message_id": "msg-001", "sender": "support"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '6 hours', CURRENT_TIMESTAMP - INTERVAL '6 hours'),
(5, 'push', 'Напоминание', 'Не забудьте продлить подписку на ChatGPT', '{"notification_type": "subscription_reminder", "product": "ChatGPT", "days_left": 16}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '12 hours', CURRENT_TIMESTAMP - INTERVAL '12 hours'),
(6, 'push', 'Обновление', 'Доступна новая версия мобильного приложения', '{"notification_type": "app_update", "version": "2.1.0", "features": ["Улучшенный интерфейс", "Новые функции"]}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- SMS уведомления (для критически важных сообщений)
(3, 'sms', 'Критическое обновление', 'Ваш аккаунт заблокирован из-за подозрительной активности. Обратитесь в поддержку.', '{"notification_type": "security_alert", "priority": "high", "action_required": "contact_support"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '2 hours'),
(7, 'sms', 'Подтверждение платежа', 'Подтвердите платеж 9.99 USD за GitHub Copilot. Код: 1234', '{"notification_type": "payment_confirmation", "amount": "9.99", "currency": "USD", "product": "GitHub Copilot", "confirmation_code": "1234"}', false, NULL, CURRENT_TIMESTAMP - INTERVAL '1 hour', CURRENT_TIMESTAMP - INTERVAL '1 hour')
ON CONFLICT (id) DO NOTHING;

-- Комментарии к уведомлениям
COMMENT ON TABLE notifications IS 'Уведомления пользователей системы';
COMMENT ON COLUMN notifications.user_id IS 'Ссылка на пользователя';
COMMENT ON COLUMN notifications.type IS 'Тип уведомления: email, push, sms';
COMMENT ON COLUMN notifications.title IS 'Заголовок уведомления';
COMMENT ON COLUMN notifications.message IS 'Текст уведомления';
COMMENT ON COLUMN notifications.data IS 'Дополнительные данные в JSON формате';
COMMENT ON COLUMN notifications.is_read IS 'Прочитано ли уведомление';
COMMENT ON COLUMN notifications.read_at IS 'Время прочтения уведомления';
COMMENT ON COLUMN notifications.sent_at IS 'Время отправки уведомления';
COMMENT ON COLUMN notifications.created_at IS 'Время создания записи';

-- Информация о тестовых уведомлениях
COMMENT ON TABLE notifications IS 'Тестовые уведомления для демонстрации системы уведомлений';
COMMENT ON COLUMN notifications.type IS 'Типы: email=почта, push=мобильные, sms=текстовые сообщения';
COMMENT ON COLUMN notifications.data IS 'JSON с дополнительной информацией для персонализации';
COMMENT ON COLUMN notifications.is_read IS 'Статус прочтения для отслеживания активности пользователей';
COMMENT ON COLUMN notifications.sent_at IS 'Время фактической отправки для анализа доставляемости';
COMMENT ON COLUMN notifications.created_at IS 'Время создания для анализа частоты уведомлений';





