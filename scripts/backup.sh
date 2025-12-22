#!/bin/bash

# Резервное копирование домашней директории
# Копирует все, кроме скрытых файлов и папок

BACKUP_SRC="$HOME"
BACKUP_DST="/tmp/backup"
LOG_FILE="/var/log/home_backup.log"
LOCK_FILE="/tmp/backup.lock"

# Проверяем, не запущен ли уже скрипт
if [ -f "$LOCK_FILE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Скрипт уже выполняется" >> "$LOG_FILE"
    logger -t "backup" "Скрипт уже выполняется"
    exit 1
fi

# Создаем lock-файл
touch "$LOCK_FILE"

# Начало резервного копирования
echo "=======================================" >> "$LOG_FILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Начало копирования" >> "$LOG_FILE"
logger -t "backup" "Начало резервного копирования"

# Создаем папку для бэкапа, если её нет
mkdir -p "$BACKUP_DST" 2>/dev/null

# Выполняем копирование
rsync -a --delete \
    --exclude='.*' \
    --exclude='*/.*' \
    --checksum \
    --quiet \
    "$BACKUP_SRC/" "$BACKUP_DST/" 2>&1

# Проверяем результат
if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Копирование успешно" >> "$LOG_FILE"
    logger -t "backup" "Резервное копирование успешно"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Ошибка при копировании" >> "$LOG_FILE"
    logger -t "backup" "Ошибка резервного копирования"
fi

# Удаляем lock-файл
rm -f "$LOCK_FILE"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Конец копирования" >> "$LOG_FILE"
echo "=======================================" >> "$LOG_FILE"
