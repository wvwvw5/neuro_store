#!/bin/bash

# ========================================
# Скрипт создания финального дампа БД
# Neuro Store Database Backup Script
# ========================================

set -e  # Остановка при ошибке

# Загрузка переменных окружения
if [ -f "ops/.env" ]; then
    source ops/.env
    echo "✅ Переменные окружения загружены из ops/.env"
elif [ -f ".env" ]; then
    source .env
    echo "✅ Переменные окружения загружены из .env"
else
    echo "❌ Файл .env не найден. Создайте его из ops/.env.example"
    exit 1
fi

# Значения по умолчанию
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}
POSTGRES_DB=${POSTGRES_DB:-neuro_store}
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}

# Создание директории для бэкапов
BACKUP_DIR="db/backup"
mkdir -p "$BACKUP_DIR"

# Генерация имени файла с датой и временем
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/neuro_store_final_dump_$TIMESTAMP.sql"

echo "🚀 Создание финального дампа базы данных Neuro Store..."
echo ""
echo "📊 Параметры подключения:"
echo "  Хост: $POSTGRES_HOST:$POSTGRES_PORT"
echo "  База данных: $POSTGRES_DB"
echo "  Пользователь: $POSTGRES_USER"
echo "  Файл дампа: $BACKUP_FILE"
echo ""

# Проверка доступности PostgreSQL
echo "🔍 Проверка подключения к PostgreSQL..."
if command -v docker compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    echo "❌ Docker Compose не найден"
    exit 1
fi

# Проверяем, запущен ли контейнер БД
if ! $DOCKER_COMPOSE_CMD -f ops/docker-compose.yml ps db | grep -q "Up"; then
    echo "❌ Контейнер PostgreSQL не запущен. Запустите сервисы: make up"
    exit 1
fi

# Создание дампа через Docker
echo "💾 Создание дампа базы данных..."
$DOCKER_COMPOSE_CMD -f ops/docker-compose.yml exec -T db pg_dump \
    -U "$POSTGRES_USER" \
    -d "$POSTGRES_DB" \
    --verbose \
    --clean \
    --if-exists \
    --create \
    --encoding=UTF8 \
    > "$BACKUP_FILE"

# Проверка успешности создания дампа
if [ $? -eq 0 ] && [ -s "$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo ""
    echo "✅ Дамп базы данных успешно создан!"
    echo "📁 Файл: $BACKUP_FILE"
    echo "📊 Размер: $BACKUP_SIZE"
    echo ""
    
    # Создание сжатого архива
    echo "🗜️ Создание сжатого архива..."
    gzip -c "$BACKUP_FILE" > "$BACKUP_FILE.gz"
    
    if [ -s "$BACKUP_FILE.gz" ]; then
        COMPRESSED_SIZE=$(du -h "$BACKUP_FILE.gz" | cut -f1)
        echo "✅ Сжатый архив создан: $BACKUP_FILE.gz"
        echo "📊 Размер сжатого файла: $COMPRESSED_SIZE"
    fi
    
    echo ""
    echo "📋 Информация о дампе:"
    echo "  Дата создания: $(date)"
    echo "  Версия PostgreSQL: $(docker compose -f ops/docker-compose.yml exec db psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -c 'SELECT version();' | head -1 | xargs)"
    
    # Подсчет таблиц и записей
    echo ""
    echo "📊 Статистика базы данных:"
    $DOCKER_COMPOSE_CMD -f ops/docker-compose.yml exec db psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
    SELECT 
        schemaname as schema,
        tablename as table,
        n_tup_ins as inserts,
        n_tup_upd as updates,
        n_tup_del as deletes
    FROM pg_stat_user_tables 
    ORDER BY schemaname, tablename;" 2>/dev/null || echo "Не удалось получить статистику таблиц"
    
    echo ""
    echo "🎉 Финальный дамп базы данных готов!"
    echo ""
    echo "📚 Для восстановления используйте:"
    echo "  make restore FILE=$BACKUP_FILE"
    echo "  или"
    echo "  gunzip -c $BACKUP_FILE.gz | docker compose -f ops/docker-compose.yml exec -T db psql -U $POSTGRES_USER -d $POSTGRES_DB"
    
else
    echo "❌ Ошибка создания дампа базы данных"
    echo "🔍 Проверьте логи: make logs SERVICE=db"
    exit 1
fi
