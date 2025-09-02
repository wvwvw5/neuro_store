import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import Link from 'next/link';

interface AdminStats {
  users: {
    total: number;
    active: number;
    inactive: number;
  };
  subscriptions: {
    total: number;
    active: number;
    inactive: number;
  };
  orders: {
    total: number;
    completed: number;
    pending: number;
  };
}

interface User {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  is_active: boolean;
  created_at: string;
}

export default function AdminPanel() {
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState('stats');
  const router = useRouter();

  useEffect(() => {
    checkAdminAccess();
  }, []);

  const checkAdminAccess = async () => {
    const token = localStorage.getItem('access_token');
    const tokenType = localStorage.getItem('token_type');

    if (!token) {
      router.push('/login');
      return;
    }

    try {
      // Проверяем доступ к админ-панели
      const response = await fetch('http://localhost:8000/api/v1/admin/protected-route', {
        headers: {
          'Authorization': `${tokenType} ${token}`,
        },
      });

      if (!response.ok) {
        if (response.status === 403) {
          alert('У вас нет прав доступа к админ-панели');
          router.push('/dashboard');
          return;
        }
        throw new Error('Ошибка проверки доступа');
      }

      // Загружаем статистику
      await loadStatistics();
      await loadUsers();

    } catch (err) {
      setError(err instanceof Error ? err.message : 'Ошибка загрузки данных');
      router.push('/login');
    } finally {
      setLoading(false);
    }
  };

  const loadStatistics = async () => {
    const token = localStorage.getItem('access_token');
    const tokenType = localStorage.getItem('token_type');

    try {
      const response = await fetch('http://localhost:8000/api/v1/admin/statistics', {
        headers: {
          'Authorization': `${tokenType} ${token}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setStats(data);
      }
    } catch (err) {
      console.error('Ошибка загрузки статистики:', err);
    }
  };

  const loadUsers = async () => {
    const token = localStorage.getItem('access_token');
    const tokenType = localStorage.getItem('token_type');

    try {
      const response = await fetch('http://localhost:8000/api/v1/admin/users', {
        headers: {
          'Authorization': `${tokenType} ${token}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setUsers(data);
      }
    } catch (err) {
      console.error('Ошибка загрузки пользователей:', err);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('token_type');
    router.push('/');
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Загрузка админ-панели...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-red-500 text-6xl mb-4">🚫</div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Доступ запрещен</h2>
          <p className="text-gray-600 mb-4">{error}</p>
          <button
            onClick={() => router.push('/dashboard')}
            className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-md"
          >
            Вернуться в личный кабинет
          </button>
        </div>
      </div>
    );
  }

  return (
    <>
      <Head>
        <title>Админ-панель - Neuro Store</title>
        <meta name="description" content="Административная панель управления" />
      </Head>

      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <header className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center py-6">
              <div className="flex items-center">
                <div className="text-3xl mr-3">🛡️</div>
                <h1 className="text-2xl font-bold text-gray-900">Админ-панель</h1>
              </div>
              <nav className="hidden md:flex space-x-8">
                <Link href="/">
                  <span className="text-gray-500 hover:text-gray-900 cursor-pointer">Главная</span>
                </Link>
                <Link href="/dashboard">
                  <span className="text-gray-500 hover:text-gray-900 cursor-pointer">Личный кабинет</span>
                </Link>
                <span className="text-red-600 font-medium">🛡️ Админ-панель</span>
              </nav>
              <button
                onClick={handleLogout}
                className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-md"
              >
                Выйти
              </button>
            </div>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {/* Предупреждение */}
          <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-8">
            <div className="flex items-center">
              <div className="text-red-500 text-xl mr-3">🚨</div>
              <div>
                <h3 className="text-sm font-medium text-red-800">Административная панель</h3>
                <p className="text-sm text-red-700">
                  Доступ ограничен. Только для пользователей с ролью администратора.
                </p>
              </div>
            </div>
          </div>
          {/* Табы */}
          <div className="bg-white rounded-lg shadow-md mb-8">
            <div className="border-b border-gray-200">
              <nav className="-mb-px flex space-x-8 px-6">
                <button
                  onClick={() => setActiveTab('stats')}
                  className={`py-4 px-1 border-b-2 font-medium text-sm ${
                    activeTab === 'stats'
                      ? 'border-blue-500 text-blue-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  📊 Статистика
                </button>
                <button
                  onClick={() => setActiveTab('users')}
                  className={`py-4 px-1 border-b-2 font-medium text-sm ${
                    activeTab === 'users'
                      ? 'border-blue-500 text-blue-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  👥 Пользователи
                </button>
              </nav>
            </div>

            {/* Контент табов */}
            <div className="p-6">
              {activeTab === 'stats' && stats && (
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-6">Статистика системы</h2>
                  
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    {/* Пользователи */}
                    <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
                      <div className="flex items-center">
                        <div className="text-3xl mr-4">👥</div>
                        <div>
                          <h3 className="text-lg font-semibold text-blue-900">Пользователи</h3>
                          <p className="text-2xl font-bold text-blue-600">{stats.users.total}</p>
                          <p className="text-sm text-blue-700">
                            Активных: {stats.users.active} | Неактивных: {stats.users.inactive}
                          </p>
                        </div>
                      </div>
                    </div>

                    {/* Подписки */}
                    <div className="bg-green-50 border border-green-200 rounded-lg p-6">
                      <div className="flex items-center">
                        <div className="text-3xl mr-4">📱</div>
                        <div>
                          <h3 className="text-lg font-semibold text-green-900">Подписки</h3>
                          <p className="text-2xl font-bold text-green-600">{stats.subscriptions.total}</p>
                          <p className="text-sm text-green-700">
                            Активных: {stats.subscriptions.active} | Неактивных: {stats.subscriptions.inactive}
                          </p>
                        </div>
                      </div>
                    </div>

                    {/* Заказы */}
                    <div className="bg-purple-50 border border-purple-200 rounded-lg p-6">
                      <div className="flex items-center">
                        <div className="text-3xl mr-4">🛒</div>
                        <div>
                          <h3 className="text-lg font-semibold text-purple-900">Заказы</h3>
                          <p className="text-2xl font-bold text-purple-600">{stats.orders.total}</p>
                          <p className="text-sm text-purple-700">
                            Завершенных: {stats.orders.completed} | В ожидании: {stats.orders.pending}
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {activeTab === 'users' && (
                <div>
                  <h2 className="text-2xl font-bold text-gray-900 mb-6">Управление пользователями</h2>
                  
                  <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                      <thead className="bg-gray-50">
                        <tr>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            ID
                          </th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Email
                          </th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Имя
                          </th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Статус
                          </th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Дата регистрации
                          </th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Действия
                          </th>
                        </tr>
                      </thead>
                      <tbody className="bg-white divide-y divide-gray-200">
                        {users.map((user) => (
                          <tr key={user.id}>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                              {user.id}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                              {user.email}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                              {user.first_name} {user.last_name}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap">
                              <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                                user.is_active 
                                  ? 'bg-green-100 text-green-800' 
                                  : 'bg-red-100 text-red-800'
                              }`}>
                                {user.is_active ? 'Активен' : 'Неактивен'}
                              </span>
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                              {new Date(user.created_at).toLocaleDateString('ru-RU')}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                              <button className="text-blue-600 hover:text-blue-900 mr-4">
                                Редактировать
                              </button>
                              <button className={`${
                                user.is_active 
                                  ? 'text-red-600 hover:text-red-900' 
                                  : 'text-green-600 hover:text-green-900'
                              }`}>
                                {user.is_active ? 'Деактивировать' : 'Активировать'}
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Быстрые действия */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-bold text-gray-900 mb-4">Быстрые действия</h2>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md">
                📊 Экспорт данных
              </button>
              <button className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-md">
                📧 Рассылка
              </button>
              <button className="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-md">
                🔧 Настройки
              </button>
              <Link href="http://localhost:5050" target="_blank">
                <span className="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-md cursor-pointer inline-block w-full text-center">
                  🗄️ pgAdmin
                </span>
              </Link>
            </div>
          </div>
        </main>
      </div>
    </>
  );
}
