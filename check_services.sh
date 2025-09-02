#!/bin/bash

echo "🔍 Проверка статуса сервисов Neuro Store..."
echo ""

# Проверка Docker Compose
echo "📋 Статус контейнеров:"
cd ops && docker compose ps && cd ..
echo ""

# Проверка Backend API
echo "🚀 Backend API:"
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health)
if [ "$BACKEND_STATUS" = "200" ]; then
    echo "✅ Backend API работает (http://localhost:8000)"
    echo "   📊 Swagger UI: http://localhost:8000/docs"
else
    echo "❌ Backend API недоступен (статус: $BACKEND_STATUS)"
fi

# Проверка Frontend
echo ""
echo "🎨 Frontend:"
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✅ Frontend работает (http://localhost:3000)"
    echo "   🔐 Страница входа: http://localhost:3000/login"
    echo "   📱 Личный кабинет: http://localhost:3000/dashboard"
else
    echo "❌ Frontend недоступен (статус: $FRONTEND_STATUS)"
fi

# Проверка PostgreSQL
echo ""
echo "🗄️ PostgreSQL:"
cd ops
if docker compose exec -T db pg_isready -U neuro_user -d neuro_store > /dev/null 2>&1; then
    echo "✅ PostgreSQL работает (localhost:5433)"
    TABLES_COUNT=$(docker compose exec -T db psql -U neuro_user -d neuro_store -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')
    echo "   📊 Таблиц в БД: $TABLES_COUNT"
else
    echo "❌ PostgreSQL недоступен"
fi
cd ..

# Проверка pgAdmin
echo ""
echo "🔧 pgAdmin:"
PGADMIN_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5050)
if [ "$PGADMIN_STATUS" = "200" ]; then
    echo "✅ pgAdmin работает (http://localhost:5050)"
    echo "   👤 Email: admin@neurostore.com"
    echo "   🔑 Пароль: admin123"
else
    echo "❌ pgAdmin недоступен (статус: $PGADMIN_STATUS)"
fi

# Проверка Redis
echo ""
echo "📦 Redis:"
cd ops
if docker compose exec -T redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis работает (localhost:6379)"
else
    echo "❌ Redis недоступен"
fi
cd ..

# Проверка API endpoints
echo ""
echo "🔌 API Endpoints:"
PRODUCTS_COUNT=$(curl -s "http://localhost:8000/api/v1/products/" | jq '. | length' 2>/dev/null)
if [ "$PRODUCTS_COUNT" != "null" ] && [ "$PRODUCTS_COUNT" != "" ]; then
    echo "✅ API /products работает (найдено $PRODUCTS_COUNT продуктов)"
else
    echo "❌ API /products недоступен"
fi

# Тестовые данные
echo ""
echo "🔑 Тестовые данные:"
echo "   📧 Email: test@neurostore.com"
echo "   🔐 Пароль: test123"
echo ""

# Полезные команды
echo "📚 Полезные команды:"
echo "   Остановка: docker compose down"
echo "   Логи: docker compose logs [service]"
echo "   Перезапуск: docker compose restart [service]"
echo ""

echo "🎉 Проверка завершена!"
