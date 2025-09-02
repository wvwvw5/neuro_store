import React, { useState, useEffect } from 'react';
import Head from 'next/head';
import Link from 'next/link';
import ProductCard from '../components/ProductCard';
import PlanCard from '../components/PlanCard';
import { Product, Plan } from '../types/product';
import { SubscriptionCreate } from '../types/subscription';

export default function Home() {
  const [products, setProducts] = useState<Product[]>([]);
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const [plans, setPlans] = useState<Plan[]>([]);
  const [selectedPlan, setSelectedPlan] = useState<Plan | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [userToken, setUserToken] = useState<string | null>(null);

  // Загрузка продуктов при монтировании
  useEffect(() => {
    fetchProducts();
    checkAuthStatus();
  }, []);

  const checkAuthStatus = () => {
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('access_token');
      const tokenType = localStorage.getItem('token_type');
      setIsAuthenticated(!!token);
      setUserToken(token);
    }
  };

  // Загрузка планов при выборе продукта
  useEffect(() => {
    if (selectedProduct) {
      fetchProductPlans(selectedProduct.id);
    }
  }, [selectedProduct]);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      const response = await fetch('http://localhost:8000/api/v1/products/');
      if (!response.ok) throw new Error('Ошибка загрузки продуктов');
      
      const data = await response.json();
      setProducts(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Неизвестная ошибка');
    } finally {
      setLoading(false);
    }
  };

  const fetchProductPlans = async (productId: number) => {
    try {
      const response = await fetch(`http://localhost:8000/api/v1/products/${productId}/plans`);
      if (!response.ok) throw new Error('Ошибка загрузки планов');
      
      const data = await response.json();
      setPlans(data);
      setSelectedPlan(null); // Сбрасываем выбранный план
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Неизвестная ошибка');
    }
  };

  const handleProductSelect = (product: Product) => {
    setSelectedProduct(product);
  };

  const handlePlanSelect = (planId: number) => {
    const plan = plans.find(p => p.id === planId);
    setSelectedPlan(plan || null);
  };

  const handleSubscribe = async () => {
    if (!selectedProduct || !selectedPlan) {
      setError('Выберите продукт и план');
      return;
    }

    // Проверяем аутентификацию
    if (!isAuthenticated || !userToken) {
      alert('Для создания подписки необходимо войти в систему');
      window.location.href = '/login';
      return;
    }

    const tokenType = localStorage.getItem('token_type') || 'bearer';

    try {
      const subscriptionData: SubscriptionCreate = {
        product_id: selectedProduct.id,
        plan_id: selectedPlan.id
      };

      const response = await fetch('http://localhost:8000/api/v1/subscriptions/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `${tokenType} ${userToken}`
        },
        body: JSON.stringify(subscriptionData)
      });

      if (!response.ok) {
        if (response.status === 401) {
          alert('Сессия истекла. Пожалуйста, войдите заново.');
          localStorage.removeItem('access_token');
          localStorage.removeItem('token_type');
          window.location.href = '/login';
          return;
        }
        const errorData = await response.json();
        throw new Error(errorData.detail || 'Ошибка создания подписки');
      }

      // Успешная подписка
      alert('Подписка успешно создана! Перейдите в личный кабинет для просмотра.');
      setSelectedProduct(null);
      setSelectedPlan(null);
      setPlans([]);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Ошибка создания подписки');
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Загрузка продуктов...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-red-500 text-6xl mb-4">⚠️</div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Ошибка</h2>
          <p className="text-gray-600 mb-4">{error}</p>
          <button
            onClick={fetchProducts}
            className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-md"
          >
            Попробовать снова
          </button>
        </div>
      </div>
    );
  }

  return (
    <>
      <Head>
        <title>Neuro Store - Магазин подписок на нейросети</title>
        <meta name="description" content="Подписки на нейросетевые сервисы" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>

      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <header className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center py-6">
              <div className="flex items-center">
                <div className="text-3xl mr-3">🧠</div>
                <h1 className="text-2xl font-bold text-gray-900">Neuro Store</h1>
              </div>
              <nav className="hidden md:flex space-x-8">
                <Link href="/" className="text-gray-500 hover:text-gray-900">
                  Продукты
                </Link>
                <Link href="/dashboard" className="text-gray-500 hover:text-gray-900">
                  Мои подписки
                </Link>
                <Link href="/dashboard" className="text-gray-500 hover:text-gray-900">
                  Личный кабинет
                </Link>
              </nav>
              {isAuthenticated ? (
                <Link href="/dashboard">
                  <span className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-md cursor-pointer">
                    Личный кабинет
                  </span>
                </Link>
              ) : (
                <Link href="/login">
                  <span className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md cursor-pointer">
                    Войти
                  </span>
                </Link>
              )}
            </div>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {/* Заголовок */}
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">
              Выберите нейросеть для подписки
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Доступ к самым передовым ИИ-сервисам по выгодным тарифам. 
              Выбирайте план, который подходит именно вам.
            </p>
          </div>

          {/* Выбор продукта */}
          <div className="mb-12">
            <h3 className="text-2xl font-semibold text-gray-900 mb-6">
              Доступные нейросети
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {products.map((product) => (
                <div
                  key={product.id}
                  onClick={() => handleProductSelect(product)}
                  className="cursor-pointer"
                >
                  <ProductCard
                    product={product}
                    onSubscribe={() => handleProductSelect(product)}
                  />
                </div>
              ))}
            </div>
          </div>
          
          {/* Кнопки быстрых действий */}
          <div className="mt-12 space-y-4">
            <h2 className="text-2xl font-bold text-gray-800 mb-6 text-center">Быстрые действия</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <button
                onClick={() => window.location.href = '/register'}
                className="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-6 rounded-lg transition-colors shadow-md"
              >
                📝 Регистрация
              </button>
              
              <button
                onClick={() => window.location.href = '/login'}
                className="bg-green-600 hover:bg-green-700 text-white font-semibold py-3 px-6 rounded-lg transition-colors shadow-md"
              >
                🔐 Войти
              </button>
              
              <button
                onClick={() => window.location.href = '/dashboard'}
                className="bg-purple-600 hover:bg-purple-700 text-white font-semibold py-3 px-6 rounded-lg transition-colors shadow-md"
              >
                🏠 Личный кабинет
              </button>
              
              <button
                onClick={() => window.location.href = '/admin'}
                className="bg-red-600 hover:bg-red-700 text-white font-semibold py-3 px-6 rounded-lg transition-colors shadow-md"
              >
                ⚙️ Админ панель
              </button>
            </div>
          </div>

          {/* Выбор плана */}
          {selectedProduct && plans.length > 0 && (
            <div className="mb-12">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-2xl font-semibold text-gray-900">
                  Тарифные планы для {selectedProduct.name}
                </h3>
                <button
                  onClick={() => setSelectedProduct(null)}
                  className="text-gray-500 hover:text-gray-700"
                >
                  ← Выбрать другую нейросеть
                </button>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {plans.map((plan) => (
                  <PlanCard
                    key={plan.id}
                    plan={plan}
                    isSelected={selectedPlan?.id === plan.id}
                    onSelect={handlePlanSelect}
                  />
                ))}
              </div>

              {/* Кнопка подписки */}
              {selectedPlan && (
                <div className="text-center mt-8">
                  <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 max-w-md mx-auto mb-6">
                    <h4 className="text-lg font-semibold text-blue-900 mb-2">
                      Выбранный план
                    </h4>
                    <p className="text-blue-800">
                      {selectedPlan.name} - {selectedPlan.price} ₽ за {selectedPlan.duration_days} дней
                    </p>
                  </div>
                  
                  <button
                    onClick={handleSubscribe}
                    className="bg-green-600 hover:bg-green-700 text-white px-8 py-3 rounded-lg text-lg font-semibold shadow-lg"
                  >
                    Оформить подписку
                  </button>
                </div>
              )}
            </div>
          )}

          {/* Информация о подписках */}
          {!selectedProduct && (
            <div className="bg-white rounded-lg shadow-md p-8 text-center">
              <div className="text-6xl mb-4">🚀</div>
              <h3 className="text-2xl font-semibold text-gray-900 mb-4">
                Готовы начать?
              </h3>
              <p className="text-gray-600 mb-6 max-w-2xl mx-auto">
                Выберите нейросеть выше, чтобы увидеть доступные тарифные планы. 
                Мы предлагаем гибкие условия и выгодные цены для всех пользователей.
              </p>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 text-left">
                <div className="text-center">
                  <div className="text-3xl mb-2">⚡</div>
                  <h4 className="font-semibold mb-2">Быстрый старт</h4>
                  <p className="text-sm text-gray-600">Подписка активируется мгновенно</p>
                </div>
                <div className="text-center">
                  <div className="text-3xl mb-2">🔒</div>
                  <h4 className="font-semibold mb-2">Безопасность</h4>
                  <p className="text-sm text-gray-600">Защищенные платежи и данные</p>
                </div>
                <div className="text-center">
                  <div className="text-3xl mb-2">📱</div>
                  <h4 className="font-semibold mb-2">Удобство</h4>
                  <p className="text-sm text-gray-600">Управление через личный кабинет</p>
                </div>
              </div>
            </div>
          )}
        </main>

        {/* Footer */}
        <footer className="bg-gray-900 text-white py-12">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
              <div>
                <h4 className="text-lg font-semibold mb-4">Neuro Store</h4>
                <p className="text-gray-400">
                  Лучшие нейросетевые сервисы по выгодным ценам
                </p>
              </div>
              <div>
                <h4 className="text-lg font-semibold mb-4">Продукты</h4>
                <ul className="space-y-2 text-gray-400">
                  <li>Языковые модели</li>
                  <li>Генерация изображений</li>
                  <li>Анализ данных</li>
                </ul>
              </div>
              <div>
                <h4 className="text-lg font-semibold mb-4">Поддержка</h4>
                <ul className="space-y-2 text-gray-400">
                  <li>FAQ</li>
                  <li>Контакты</li>
                  <li>Документация</li>
                </ul>
              </div>
              <div>
                <h4 className="text-lg font-semibold mb-4">Компания</h4>
                <ul className="space-y-2 text-gray-400">
                  <li>О нас</li>
                  <li>Блог</li>
                  <li>Карьера</li>
                </ul>
              </div>
            </div>
            <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-400">
              <p>&copy; 2024 Neuro Store. Все права защищены.</p>
            </div>
          </div>
        </footer>
      </div>
    </>
  );
}
