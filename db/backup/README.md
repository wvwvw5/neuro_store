# Резервное копирование базы данных Neuro Store

Эта папка содержит скрипты и инструкции для резервного копирования и восстановления базы данных Neuro Store.

## 📁 Структура папки

```
db/backup/
├── README.md                    # Этот файл
├── scripts/                     # Скрипты резервного копирования
│   ├── backup_full.sh          # Полное резервное копирование
│   ├── backup_incremental.sh   # Инкрементальное резервное копирование
│   ├── backup_schema.sh        # Резервное копирование только схемы
│   └── backup_data.sh          # Резервное копирование только данных
├── schedules/                   # Расписания автоматического резервного копирования
│   ├── daily_backup.sh         # Ежедневное резервное копирование
│   ├── weekly_backup.sh        # Еженедельное резервное копирование
│   └── monthly_backup.sh       # Ежемесячное резервное копирование
├── restore/                     # Скрипты восстановления
│   ├── restore_full.sh         # Полное восстановление
│   ├── restore_schema.sh       # Восстановление схемы
│   └── restore_data.sh         # Восстановление данных
└── archives/                    # Архивы резервных копий (создается автоматически)
    ├── daily/                   # Ежедневные архивы
    ├── weekly/                  # Еженедельные архивы
    └── monthly/                 # Ежемесячные архивы
```

## 🚀 Быстрый старт

### Создание полной резервной копии

```bash
# Переход в папку скриптов
cd db/backup/scripts

# Создание полной резервной копии
./backup_full.sh

# Создание резервной копии только схемы
./backup_schema.sh

# Создание резервной копии только данных
./backup_data.sh
```

### Автоматическое резервное копирование

```bash
# Настройка ежедневного резервного копирования
crontab -e

# Добавить строку для ежедневного резервного копирования в 02:00
0 2 * * * /path/to/neuro_store/db/backup/schedules/daily_backup.sh

# Добавить строку для еженедельного резервного копирования в воскресенье в 03:00
0 3 * * 0 /path/to/neuro_store/db/backup/schedules/weekly_backup.sh

# Добавить строку для ежемесячного резервного копирования 1-го числа в 04:00
0 4 1 * * /path/to/neuro_store/db/backup/schedules/monthly_backup.sh
```

## 📋 Типы резервного копирования

### 1. Полное резервное копирование (`backup_full.sh`)

**Описание**: Создает полную резервную копию всей базы данных
**Содержит**: Схему, данные, индексы, триггеры, функции, представления
**Размер**: Максимальный
**Время**: Наиболее длительное
**Частота**: Еженедельно или ежемесячно

**Использование**:
```bash
./backup_full.sh [database_name] [backup_path]
```

**Пример**:
```bash
./backup_full.sh neuro_store /var/backups/postgres
```

### 2. Резервное копирование схемы (`backup_schema.sh`)

**Описание**: Создает резервную копию только структуры базы данных
**Содержит**: Таблицы, индексы, триггеры, функции, представления
**Размер**: Минимальный
**Время**: Быстрое
**Частота**: При изменении схемы

**Использование**:
```bash
./backup_schema.sh [database_name] [backup_path]
```

**Пример**:
```bash
./backup_schema.sh neuro_store /var/backups/postgres/schema
```

### 3. Резервное копирование данных (`backup_data.sh`)

**Описание**: Создает резервную копию только данных
**Содержит**: Содержимое таблиц
**Размер**: Средний
**Время**: Среднее
**Частота**: Ежедневно

**Использование**:
```bash
./backup_data.sh [database_name] [backup_path]
```

**Пример**:
```bash
./backup_data.sh neuro_store /var/backups/postgres/data
```

### 4. Инкрементальное резервное копирование (`backup_incremental.sh`)

**Описание**: Создает резервную копию только измененных данных
**Содержит**: Данные, измененные с момента последнего резервного копирования
**Размер**: Минимальный
**Время**: Очень быстрое
**Частота**: Каждые несколько часов

**Использование**:
```bash
./backup_incremental.sh [database_name] [backup_path]
```

**Пример**:
```bash
./backup_incremental.sh neuro_store /var/backups/postgres/incremental
```

## 🔄 Восстановление

### Полное восстановление

```bash
# Восстановление из полной резервной копии
./restore_full.sh [backup_file] [database_name]

# Пример
./restore_full.sh /var/backups/postgres/neuro_store_2024-01-30_02-00.sql neuro_store
```

### Восстановление схемы

```bash
# Восстановление только схемы
./restore_schema.sh [backup_file] [database_name]

# Пример
./restore_schema.sh /var/backups/postgres/schema/neuro_store_schema_2024-01-30.sql neuro_store
```

### Восстановление данных

```bash
# Восстановление только данных
./restore_data.sh [backup_file] [database_name]

# Пример
./restore_data.sh /var/backups/postgres/data/neuro_store_data_2024-01-30.sql neuro_store
```

## ⚙️ Настройка

### Переменные окружения

Создайте файл `.env` в папке `db/backup/`:

```env
# Параметры базы данных
DB_HOST=localhost
DB_PORT=5433
DB_NAME=neuro_store
DB_USER=neuro_user
DB_PASSWORD=neuro_password

# Параметры резервного копирования
BACKUP_PATH=/var/backups/postgres
BACKUP_RETENTION_DAYS=30
BACKUP_RETENTION_WEEKS=12
BACKUP_RETENTION_MONTHS=12

# Параметры сжатия
COMPRESS_BACKUPS=true
COMPRESSION_LEVEL=9

# Параметры уведомлений
NOTIFY_ON_SUCCESS=true
NOTIFY_ON_FAILURE=true
NOTIFY_EMAIL=admin@neurostore.com
```

### Права доступа

Убедитесь, что пользователь `neuro_user` имеет права на:

```sql
-- Права на создание резервных копий
GRANT CONNECT ON DATABASE neuro_store TO neuro_user;
GRANT USAGE ON SCHEMA public TO neuro_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO neuro_user;

-- Права на восстановление (для администраторов)
GRANT CREATE ON DATABASE neuro_store TO neuro_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO neuro_user;
```

## 📅 Расписания

### Ежедневное резервное копирование

**Время**: 02:00
**Тип**: Данные + инкрементальное
**Хранение**: 30 дней
**Уведомления**: При ошибках

### Еженедельное резервное копирование

**Время**: Воскресенье 03:00
**Тип**: Полное
**Хранение**: 12 недель
**Уведомления**: При ошибках

### Ежемесячное резервное копирование

**Время**: 1-е число месяца 04:00
**Тип**: Полное + схема
**Хранение**: 12 месяцев
**Уведомления**: Всегда

## 🔍 Мониторинг

### Проверка статуса резервного копирования

```bash
# Проверка последних резервных копий
ls -la /var/backups/postgres/

# Проверка размера резервных копий
du -sh /var/backups/postgres/*

# Проверка логов резервного копирования
tail -f /var/log/postgresql/backup.log
```

### Проверка целостности

```bash
# Проверка целостности резервной копии
pg_restore --list [backup_file]

# Тестовое восстановление в отдельную базу данных
./restore_full.sh [backup_file] neuro_store_test
```

## 🚨 Устранение неполадок

### Частые проблемы

1. **Ошибка доступа к базе данных**
   ```bash
   # Проверьте права пользователя
   psql -U neuro_user -d neuro_store -c "SELECT current_user, current_database();"
   ```

2. **Недостаточно места на диске**
   ```bash
   # Проверьте свободное место
   df -h /var/backups/postgres/
   
   # Очистите старые резервные копии
   find /var/backups/postgres/ -name "*.sql" -mtime +30 -delete
   ```

3. **Ошибки при восстановлении**
   ```bash
   # Проверьте версию PostgreSQL
   psql --version
   
   # Проверьте совместимость резервной копии
   pg_restore --version
   ```

### Логи и отладка

```bash
# Включение подробного логирования
export PGOPTIONS="-c log_statement=all"

# Запуск с отладкой
bash -x ./backup_full.sh neuro_store /var/backups/postgres
```

## 📚 Дополнительная информация

### Полезные команды

```bash
# Создание резервной копии одной таблицы
pg_dump -U neuro_user -t users neuro_store > users_backup.sql

# Создание резервной копии с фильтрацией
pg_dump -U neuro_user -t "users_*" neuro_store > users_tables_backup.sql

# Создание резервной копии с исключением таблиц
pg_dump -U neuro_user -T api_logs -T notifications neuro_store > filtered_backup.sql
```

### Автоматизация через Docker

```bash
# Создание резервной копии в Docker контейнере
docker compose -f ops/docker-compose.yml exec postgres pg_dump -U neuro_user neuro_store > backup.sql

# Восстановление в Docker контейнере
docker compose -f ops/docker-compose.yml exec -T postgres psql -U neuro_user neuro_store < backup.sql
```

### Интеграция с CI/CD

```yaml
# GitHub Actions для автоматического резервного копирования
name: Database Backup
on:
  schedule:
    - cron: '0 2 * * *'  # Ежедневно в 02:00

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Create backup
        run: |
          cd db/backup/scripts
          ./backup_full.sh neuro_store /tmp/backup
      - name: Upload backup
        uses: actions/upload-artifact@v2
        with:
          name: database-backup
          path: /tmp/backup/
```

## 📞 Поддержка

При возникновении проблем:

1. **Проверьте логи** в `/var/log/postgresql/`
2. **Проверьте права доступа** пользователя
3. **Проверьте свободное место** на диске
4. **Обратитесь к документации** PostgreSQL
5. **Создайте issue** в репозитории проекта

## 📄 Лицензия

Скрипты резервного копирования распространяются под той же лицензией, что и основной проект Neuro Store.





