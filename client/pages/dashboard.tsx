import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import Link from 'next/link';
import { Subscription } from '../types/subscription';
import { Product } from '../types/product';

interface UserInfo {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  phone?: string;
  is_active: boolean;
  created_at: string;
}

export default function Dashboard() {
  const [user, setUser] = useState<UserInfo | null>(null);
  const [subscriptions, setSubscriptions] = useState<Subscription[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    // Проверяем аутентификацию только на клиенте
    if (typeof window !== 'undefined') {
      checkAuth();
    }
  }, []);

  const checkAuth = async () => {
    // Проверяем, что мы на клиенте
    if (typeof window === 'undefined') {
      return;
    }

    const token = localStorage.getItem('access_token');
    const tokenType = localStorage.getItem('token_type');

    if (!token) {
      router.push('/login');
      return;
    }

    try {
      // Получаем информацию о пользователе
      const userResponse = await fetch('http://localhost:8000/api/v1/auth/me', {
        headers: {
          'Authorization': `${tokenType} ${token}`,
        },
      });

      if (!userResponse.ok) {
        throw new Error('Ошибка аутентификации');
      }

      const userData = await userResponse.json();
      setUser(userData);

      // Получаем подписки пользователя
      const subscriptionsResponse = await fetch('http://localhost:8000/api/v1/subscriptions/', {
        headers: {
          'Authorization': `${tokenType} ${token}`,
        },
      });

      if (subscriptionsResponse.ok) {
        const subscriptionsData = await subscriptionsResponse.json();
        setSubscriptions(subscriptionsData);
      }

    } catch (err) {
      setError(err instanceof Error ? err.message : 'Ошибка загрузки данных');
      localStorage.removeItem('access_token');
      localStorage.removeItem('token_type');
      router.push('/login');
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('access_token');
      localStorage.removeItem('token_type');
    }
    router.push('/');
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('ru-RU', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'bg-green-100 text-green-800';
      case 'expired':
        return 'bg-red-100 text-red-800';
      case 'cancelled':
        return 'bg-gray-100 text-gray-800';
      default:
        return 'bg-yellow-100 text-yellow-800';
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'active':
        return 'Активна';
      case 'expired':
        return 'Истекла';
      case 'cancelled':
        return 'Отменена';
      default:
        return status;
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Загрузка данных...</p>
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
            onClick={() => router.push('/login')}
            className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-md"
          >
            Войти заново
          </button>
        </div>
      </div>
    );
  }

  return (
    <>
      <Head>
        <title>Личный кабинет - Neuro Store</title>
        <meta name="description" content="Личный кабинет пользователя" />
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
                <Link href="/">
                  <span className="text-gray-500 hover:text-gray-900 cursor-pointer">Продукты</span>
                </Link>
                <Link href="/dashboard">
                  <span className="text-blue-600 font-medium cursor-pointer">Мои подписки</span>
                </Link>
              </nav>
              <div className="flex items-center space-x-4">
                <span className="text-gray-700">
                  Привет, {user?.first_name}!
                </span>
                <button
                  onClick={handleLogout}
                  className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-md"
                >
                  Выйти
                </button>
              </div>
            </div>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {/* Информация о пользователе */}
          <div className="bg-white rounded-lg shadow-md p-6 mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Личная информация</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <p className="text-sm font-medium text-gray-500">Email</p>
                <p className="mt-1 text-sm text-gray-900">{user?.email}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Имя</p>
                <p className="mt-1 text-sm text-gray-900">{user?.first_name} {user?.last_name}</p>
              </div>
              {user?.phone && (
                <div>
                  <p className="text-sm font-medium text-gray-500">Телефон</p>
                  <p className="mt-1 text-sm text-gray-900">{user.phone}</p>
                </div>
              )}
              <div>
                <p className="text-sm font-medium text-gray-500">Дата регистрации</p>
                <p className="mt-1 text-sm text-gray-900">{formatDate(user?.created_at || '')}</p>
              </div>
            </div>
          </div>

          {/* Подписки */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold text-gray-900">Мои подписки</h2>
              <Link href="/">
                <span className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md cursor-pointer inline-block">
                  Добавить подписку
                </span>
              </Link>
            </div>

            {subscriptions.length === 0 ? (
              <div className="text-center py-12">
                <div className="text-6xl mb-4">📱</div>
                <h3 className="text-lg font-medium text-gray-900 mb-2">Подписок пока нет</h3>
                <p className="text-gray-600 mb-6">
                  Начните использовать нейросети уже сегодня
                </p>
                <Link href="/">
                  <span className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg cursor-pointer inline-block">
                    Выбрать нейросеть
                  </span>
                </Link>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {subscriptions.map((subscription) => (
                  <div key={subscription.id} className="border border-gray-200 rounded-lg p-6">
                    <div className="flex justify-between items-start mb-4">
                      <div>
                        <h3 className="text-lg font-medium text-gray-900">
                          Подписка #{subscription.id}
                        </h3>
                        <p className="text-sm text-gray-500">
                          Продукт ID: {subscription.product_id}
                        </p>
                      </div>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(subscription.status)}`}>
                        {getStatusText(subscription.status)}
                      </span>
                    </div>

                    <div className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-500">Начало:</span>
                        <span className="text-gray-900">{formatDate(subscription.start_date)}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-500">Окончание:</span>
                        <span className="text-gray-900">{formatDate(subscription.end_date)}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-500">Использовано запросов:</span>
                        <span className="text-gray-900">{subscription.requests_used}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-500">Автопродление:</span>
                        <span className="text-gray-900">{subscription.auto_renew ? 'Да' : 'Нет'}</span>
                      </div>
                    </div>

                    {subscription.status === 'active' && (
                      <div className="mt-4 pt-4 border-t border-gray-200">
                        <button className="w-full bg-red-600 hover:bg-red-700 text-white py-2 px-4 rounded-md text-sm">
                          Отменить подписку
                        </button>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        </main>
      </div>
    </>
  );
}
