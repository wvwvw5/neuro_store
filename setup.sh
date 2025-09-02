#!/bin/bash

echo "🚀 Быстрая настройка Neuro Store..."
echo ""

# Проверяем наличие .env файла
if [ -f ".env" ]; then
    echo "⚠️  Файл .env уже существует."
    read -p "Перезаписать? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Настройка отменена"
        exit 0
    fi
fi

# Копируем готовую конфигурацию
echo "📝 Создание .env файла с готовыми настройками..."
cp env.example .env

echo "✅ Файл .env создан с готовыми настройками!"
echo ""
echo "🔐 Настройки безопасности:"
echo "  ✅ JWT_SECRET - готов к использованию"
echo "  ✅ SECRET_KEY - готов к использованию"
echo "  ✅ POSTGRES_PASSWORD - neuro_password"
echo ""
echo "🎉 Настройка завершена!"
echo ""
echo "📋 Следующие шаги:"
echo "  1. Запустите проект: ./start.sh"
echo "  2. Или используйте Makefile: cd ops && make up"
echo ""
echo "🔗 После запуска будут доступны:"
echo "  • Frontend: http://localhost:3000"
echo "  • Backend API: http://localhost:8000"
echo "  • Swagger UI: http://localhost:8000/docs"
echo "  • pgAdmin: http://localhost:5050"
echo ""
echo "🔑 Тестовые аккаунты:"
echo "  • Пользователь: test@neurostore.com / test123"
echo "  • Админ: admin@neurostore.com / test123"
echo ""
echo "💡 Для production обязательно измените ключи в .env!"