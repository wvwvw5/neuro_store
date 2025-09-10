-- ========================================
-- Инициализация продуктов (нейросетей)
-- ========================================

-- Вставка базовых продуктов
INSERT INTO products (name, description, short_description, slug, category_id, logo_url, website_url, api_documentation_url, features, tags, sort_order) VALUES
-- Языковые модели
('ChatGPT', 'Мощная языковая модель для генерации текста, диалогов, анализа и создания контента', 'AI чат-бот для генерации текста и диалогов', 'chatgpt', 1, 'https://example.com/chatgpt-logo.png', 'https://chat.openai.com', 'https://platform.openai.com/docs', '["text_generation", "conversation", "content_creation", "translation", "summarization"]', ARRAY['AI', 'chatbot', 'text', 'openai'], 1),
('Claude', 'Продвинутая AI модель для анализа текста, написания контента и решения сложных задач', 'AI ассистент для анализа и создания контента', 'claude', 1, 'https://example.com/claude-logo.png', 'https://claude.ai', 'https://docs.anthropic.com', '["text_analysis", "content_writing", "problem_solving", "research", "creative_writing"]', ARRAY['AI', 'anthropic', 'analysis', 'writing'], 2),
('Gemini', 'Мультимодальная AI модель Google для работы с текстом, изображениями и кодом', 'Универсальная AI модель от Google', 'gemini', 1, 'https://example.com/gemini-logo.png', 'https://gemini.google.com', 'https://ai.google.dev/docs', '["multimodal", "text_generation", "image_analysis", "code_generation", "reasoning"]', ARRAY['AI', 'google', 'multimodal', 'gemini'], 3),

-- Генерация изображений
('DALL-E', 'Нейросеть OpenAI для генерации изображений по текстовому описанию', 'AI генератор изображений по тексту', 'dalle', 2, 'https://example.com/dalle-logo.png', 'https://labs.openai.com', 'https://platform.openai.com/docs/guides/images', '["image_generation", "text_to_image", "art_creation", "design", "concept_art"]', ARRAY['AI', 'openai', 'image', 'generation'], 4),
('Midjourney', 'Продвинутая нейросеть для создания художественных и фотографических изображений', 'AI для создания высококачественных изображений', 'midjourney', 2, 'https://example.com/midjourney-logo.png', 'https://midjourney.com', 'https://docs.midjourney.com', '["artistic_generation", "photorealistic", "style_transfer", "creative_design", "high_quality"]', ARRAY['AI', 'midjourney', 'art', 'photography'], 5),
('Stable Diffusion', 'Открытая нейросеть для генерации изображений с возможностью локального запуска', 'Открытая AI модель для генерации изображений', 'stable-diffusion', 2, 'https://example.com/stable-diffusion-logo.png', 'https://stability.ai', 'https://github.com/CompVis/stable-diffusion', '["open_source", "image_generation", "local_deployment", "custom_models", "fast_generation"]', ARRAY['AI', 'open_source', 'image', 'stability'], 6),

-- Обработка аудио
('Whisper', 'Нейросеть OpenAI для распознавания и транскрипции речи', 'AI для распознавания речи и аудио', 'whisper', 3, 'https://example.com/whisper-logo.png', 'https://openai.com/research/whisper', 'https://platform.openai.com/docs/guides/speech-to-text', '["speech_recognition", "transcription", "multilingual", "audio_processing", "subtitles"]', ARRAY['AI', 'openai', 'audio', 'speech'], 7),
('ElevenLabs', 'AI платформа для генерации человеческого голоса и клонирования голосов', 'AI генератор и клонировщик голосов', 'elevenlabs', 3, 'https://example.com/elevenlabs-logo.png', 'https://elevenlabs.io', 'https://docs.elevenlabs.io', '["voice_generation", "voice_cloning", "text_to_speech", "voice_editing", "emotion_control"]', ARRAY['AI', 'elevenlabs', 'voice', 'audio'], 8),

-- Видео и анимация
('Runway', 'AI платформа для создания, редактирования и анимации видео контента', 'AI для работы с видео и анимацией', 'runway', 4, 'https://example.com/runway-logo.png', 'https://runwayml.com', 'https://docs.runwayml.com', '["video_generation", "video_editing", "animation", "special_effects", "motion_graphics"]', ARRAY['AI', 'runway', 'video', 'animation'], 9),
('Pika Labs', 'AI инструмент для создания коротких видео по текстовому описанию', 'AI генератор коротких видео', 'pika-labs', 4, 'https://example.com/pika-labs-logo.png', 'https://pika.art', 'https://docs.pika.art', '["video_generation", "text_to_video", "short_videos", "creative_content", "social_media"]', ARRAY['AI', 'pika', 'video', 'generation'], 10),

-- Анализ данных
('DataRobot', 'AI платформа для автоматизации машинного обучения и анализа данных', 'AI для автоматизации ML и анализа данных', 'datarobot', 5, 'https://example.com/datarobot-logo.png', 'https://datarobot.com', 'https://docs.datarobot.com', '["machine_learning", "data_analysis", "automation", "predictive_modeling", "business_intelligence"]', ARRAY['AI', 'datarobot', 'ml', 'analytics'], 11),

-- Программирование
('GitHub Copilot', 'AI помощник для программирования с автодополнением кода', 'AI ассистент для разработчиков', 'github-copilot', 6, 'https://example.com/github-copilot-logo.png', 'https://github.com/features/copilot', 'https://docs.github.com/copilot', '["code_completion", "programming_assistant", "github_integration", "multiple_languages", "pair_programming"]', ARRAY['AI', 'github', 'coding', 'assistant'], 12),
('Tabnine', 'AI инструмент для автодополнения кода на основе машинного обучения', 'AI автодополнение кода', 'tabnine', 6, 'https://example.com/tabnine-logo.png', 'https://tabnine.com', 'https://docs.tabnine.com', '["code_completion", "ml_based", "privacy_focused", "multiple_ides", "custom_models"]', ARRAY['AI', 'tabnine', 'coding', 'completion'], 13),

-- Маркетинг и реклама
('Jasper', 'AI платформа для создания маркетингового контента и рекламных материалов', 'AI для маркетинга и рекламы', 'jasper', 7, 'https://example.com/jasper-logo.png', 'https://jasper.ai', 'https://docs.jasper.ai', '["marketing_content", "ad_copy", "social_media", "email_marketing", "brand_voice"]', ARRAY['AI', 'jasper', 'marketing', 'advertising'], 14),

-- Образование
('Khanmigo', 'AI образовательный помощник от Khan Academy для персонализированного обучения', 'AI репетитор для персонализированного обучения', 'khanmigo', 8, 'https://example.com/khanmigo-logo.png', 'https://khanmigo.khanacademy.org', 'https://docs.khanmigo.org', '["education", "personalized_learning", "tutoring", "homework_help", "subject_support"]', ARRAY['AI', 'khan', 'education', 'tutoring'], 15)
ON CONFLICT (slug) DO NOTHING;

-- Комментарии к продуктам
COMMENT ON TABLE products IS 'Нейросетевые сервисы и AI инструменты';
COMMENT ON COLUMN products.name IS 'Название нейросети';
COMMENT ON COLUMN products.description IS 'Подробное описание возможностей';
COMMENT ON COLUMN products.short_description IS 'Краткое описание для карточек';
COMMENT ON COLUMN products.slug IS 'URL-friendly идентификатор продукта';
COMMENT ON COLUMN products.category_id IS 'Ссылка на категорию';
COMMENT ON COLUMN products.logo_url IS 'URL логотипа продукта';
COMMENT ON COLUMN products.website_url IS 'Официальный сайт продукта';
COMMENT ON COLUMN products.api_documentation_url IS 'Документация API';
COMMENT ON COLUMN products.features IS 'JSON массив возможностей';
COMMENT ON COLUMN products.tags IS 'Массив тегов для поиска';
COMMENT ON COLUMN products.sort_order IS 'Порядок сортировки в списке';





