#!/bin/bash

# Скрипт для резервного копирования данных Neuro Store
# Сохраняет все данные в файл, который можно восстановить после перезапуска

set -e

# Настройки
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="neuro_store_backup_${TIMESTAMP}.sql"
CONTAINER_NAME="neuro_store_db"
DB_NAME="neuro_store"
DB_USER="postgres"

echo "🧠 Создание резервной копии Neuro Store..."
echo "📅 Время: $(date)"
echo "📁 Директория: ${BACKUP_DIR}"
echo "🗄️ База данных: ${DB_NAME}"

# Создаем директорию для бэкапов
mkdir -p "${BACKUP_DIR}"

# Создаем резервную копию
echo "💾 Создание бэкапа..."
docker exec ${CONTAINER_NAME} pg_dump -U ${DB_USER} -d ${DB_NAME} > "${BACKUP_DIR}/${BACKUP_FILE}"

# Проверяем размер файла
BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)

echo "✅ Резервная копия создана успешно!"
echo "📄 Файл: ${BACKUP_DIR}/${BACKUP_FILE}"
echo "📏 Размер: ${BACKUP_SIZE}"
echo "🔗 Путь: $(pwd)/${BACKUP_DIR}/${BACKUP_FILE}"

# Показываем содержимое директории
echo ""
echo "📂 Все доступные бэкапы:"
ls -la "${BACKUP_DIR}/"

echo ""
echo "💡 Для восстановления используйте:"
echo "   ./scripts/restore_data.sh ${BACKUP_FILE}"
