#!/bin/bash

echo "🚀 Запуск Neuro Store..."

# Проверяем наличие Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Установите Docker и попробуйте снова."
    exit 1
fi

# Проверяем наличие Docker Compose (поддержка v1 и v2)
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose не установлен. Установите Docker Compose и попробуйте снова."
    exit 1
fi

# Создаем необходимые директории
echo "📁 Создание директорий..."
mkdir -p db/backup
mkdir -p db/restore
mkdir -p ops/nginx

# Проверяем наличие .env файла
if [ ! -f ".env" ]; then
    echo "📝 Создание .env файла..."
    cp env.example .env
    echo "✅ .env файл создан. Отредактируйте его при необходимости."
fi

# Запускаем Docker Compose
echo "🐳 Запуск Docker Compose..."
cd ops

# Определяем команду Docker Compose (v1 или v2)
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    DOCKER_COMPOSE_CMD="docker compose"
fi

$DOCKER_COMPOSE_CMD up --build -d

# Ждем запуска сервисов
echo "⏳ Ожидание запуска сервисов..."
sleep 30

# Проверяем статус сервисов
echo "🔍 Проверка статуса сервисов..."
$DOCKER_COMPOSE_CMD ps

echo ""
echo "🎉 Neuro Store запущен!"
echo ""
echo "📱 Доступные сервисы:"
echo "   • Frontend: http://localhost:3000"
echo "   • Backend API: http://localhost:8000"
echo "   • Swagger UI: http://localhost:8000/docs"
echo "   • PostgreSQL: localhost:5433"
echo "   • pgAdmin: http://localhost:5050"
echo "   • Redis: localhost:6379"
echo ""
echo "🔑 Тестовые данные:"
echo "   • Администратор: admin@neurostore.com / 123"
echo "   • Модератор: moderator@neurostore.com / 123"
echo "   • Пользователь: user@neurostore.com / 123"
echo ""
echo "📚 Документация:"
echo "   • README.md - основная документация"
echo "   • /docs/ - полная документация проекта"
echo "   • /docs/erd.md - схема базы данных"
echo "   • /db/ddl.sql - структура БД"
echo "   • /db/triggers.sql - триггеры и процедуры"
echo ""
echo "🛑 Для остановки выполните: cd ops && $DOCKER_COMPOSE_CMD down"
