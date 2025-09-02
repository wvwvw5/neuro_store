import React, { useState } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import Link from 'next/link';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const formData = new FormData();
      formData.append('username', email);
      formData.append('password', password);

      const response = await fetch('http://localhost:8000/api/v1/auth/login', {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail || 'Ошибка входа');
      }

      const data = await response.json();
      
      // Сохраняем токен в localStorage
      localStorage.setItem('access_token', data.access_token);
      localStorage.setItem('token_type', data.token_type);
      
      // Проверяем роли пользователя для правильного перенаправления
      try {
        const rolesResponse = await fetch('http://localhost:8000/api/v1/auth/me/roles', {
          headers: {
            'Authorization': `${data.token_type} ${data.access_token}`,
          },
        });

        if (rolesResponse.ok) {
          const rolesData = await rolesResponse.json();
          
          // Если пользователь админ - перенаправляем на админ-панель
          if (rolesData.is_admin) {
            router.push('/admin');
          } else {
            // Обычных пользователей - в личный кабинет
            router.push('/dashboard');
          }
        } else {
          // Если не удалось получить роли - в личный кабинет
          router.push('/dashboard');
        }
      } catch (err) {
        // При ошибке - в личный кабинет
        router.push('/dashboard');
      }
      
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Неизвестная ошибка');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <Head>
        <title>Вход - Neuro Store</title>
        <meta name="description" content="Вход в систему Neuro Store" />
      </Head>

      <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
        <div className="sm:mx-auto sm:w-full sm:max-w-md">
          <div className="flex justify-center">
            <div className="text-6xl">🧠</div>
          </div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Вход в Neuro Store
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Или{' '}
            <Link href="/register">
              <span className="font-medium text-blue-600 hover:text-blue-500 cursor-pointer">
                создайте новый аккаунт
              </span>
            </Link>
          </p>
        </div>

        <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
          <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
            {error && (
              <div className="mb-4 bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded">
                {error}
              </div>
            )}

            <form className="space-y-6" onSubmit={handleSubmit}>
              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-700">
                  Email
                </label>
                <div className="mt-1">
                  <input
                    id="email"
                    name="email"
                    type="email"
                    autoComplete="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                    placeholder="test@neurostore.com"
                  />
                </div>
              </div>

              <div>
                <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                  Пароль
                </label>
                <div className="mt-1">
                  <input
                    id="password"
                    name="password"
                    type="password"
                    autoComplete="current-password"
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                    placeholder="test123"
                  />
                </div>
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <input
                    id="remember-me"
                    name="remember-me"
                    type="checkbox"
                    className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  />
                  <label htmlFor="remember-me" className="ml-2 block text-sm text-gray-900">
                    Запомнить меня
                  </label>
                </div>

                <div className="text-sm">
                  <a href="#" className="font-medium text-blue-600 hover:text-blue-500">
                    Забыли пароль?
                  </a>
                </div>
              </div>

              <div>
                <button
                  type="submit"
                  disabled={loading}
                  className={`group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white ${
                    loading 
                      ? 'bg-gray-400 cursor-not-allowed' 
                      : 'bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500'
                  }`}
                >
                  {loading ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                      Вход...
                    </>
                  ) : (
                    'Войти'
                  )}
                </button>
              </div>
            </form>

            {/* Кнопка автозаполнения тестовыми данными */}
            <div className="mb-6 text-center">
              <button
                type="button"
                onClick={() => {
                  setEmail('admin@neurostore.com');
                  setPassword('admin123');
                }}
                className="bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-4 rounded-lg transition-colors text-sm"
              >
                🧪 Заполнить тестовыми данными (Админ)
              </button>
            </div>

            <div className="mt-6">
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-gray-300" />
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-2 bg-white text-gray-500">Тестовые данные</span>
                </div>
              </div>

              <div className="mt-6 text-center">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                  <div className="bg-blue-50 p-3 rounded">
                    <p className="font-medium text-blue-800 mb-1">👤 Обычный пользователь:</p>
                    <p className="text-blue-700">
                      <strong>Email:</strong> test@neurostore.com<br />
                      <strong>Пароль:</strong> test123
                    </p>
                    <button
                      type="button"
                      onClick={() => {
                        setEmail('test@neurostore.com');
                        setPassword('test123');
                      }}
                      className="mt-2 text-blue-600 hover:text-blue-500 text-xs font-medium"
                    >
                      Заполнить данными
                    </button>
                  </div>
                  
                  <div className="bg-red-50 p-3 rounded">
                    <p className="font-medium text-red-800 mb-1">🛡️ Администратор:</p>
                    <p className="text-red-700">
                      <strong>Email:</strong> admin@neurostore.com<br />
                      <strong>Пароль:</strong> admin123
                    </p>
                    <button
                      type="button"
                      onClick={() => {
                        setEmail('admin@neurostore.com');
                        setPassword('admin123');
                      }}
                      className="mt-2 text-red-600 hover:text-red-500 text-xs font-medium"
                    >
                      Заполнить данными
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
