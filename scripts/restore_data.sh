#!/bin/bash

# Скрипт для восстановления данных Neuro Store из резервной копии
# Восстанавливает все данные после перезапуска контейнеров

set -e

# Проверяем аргументы
if [ $# -eq 0 ]; then
    echo "❌ Ошибка: Укажите файл бэкапа для восстановления"
    echo "💡 Использование: $0 <backup_file>"
    echo ""
    echo "📂 Доступные бэкапы:"
    ls -la ./backups/ 2>/dev/null || echo "   Директория backups не найдена"
    exit 1
fi

BACKUP_FILE="$1"
BACKUP_DIR="./backups"
FULL_BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILE}"

# Проверяем существование файла
if [ ! -f "${FULL_BACKUP_PATH}" ]; then
    echo "❌ Ошибка: Файл бэкапа не найден: ${FULL_BACKUP_PATH}"
    echo "💡 Проверьте правильность имени файла"
    exit 1
fi

# Настройки
CONTAINER_NAME="neuro_store_db"
DB_NAME="neuro_store"
DB_USER="postgres"

echo "🧠 Восстановление Neuro Store из резервной копии..."
echo "📅 Время: $(date)"
echo "📁 Файл: ${BACKUP_FILE}"
echo "🗄️ База данных: ${DB_NAME}"

# Проверяем, что контейнер запущен
if ! docker ps | grep -q "${CONTAINER_NAME}"; then
    echo "❌ Ошибка: Контейнер ${CONTAINER_NAME} не запущен"
    echo "💡 Запустите контейнеры: docker compose -f ops/docker-compose.yml up -d"
    exit 1
fi

# Подтверждение
echo ""
echo "⚠️  ВНИМАНИЕ: Это действие перезапишет все существующие данные!"
echo "📊 Размер бэкапа: $(du -h "${FULL_BACKUP_PATH}" | cut -f1)"
read -p "🤔 Продолжить восстановление? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Восстановление отменено"
    exit 1
fi

# Восстанавливаем данные
echo "💾 Восстановление данных..."
docker exec -i ${CONTAINER_NAME} psql -U ${DB_USER} -d ${DB_NAME} < "${FULL_BACKUP_PATH}"

echo "✅ Данные восстановлены успешно!"
echo "🔄 Перезапустите backend для применения изменений:"
echo "   docker compose -f ops/docker-compose.yml restart backend"
