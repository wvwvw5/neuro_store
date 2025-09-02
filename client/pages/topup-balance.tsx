import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import Link from 'next/link';

interface TopUpForm {
  amount: string;
  cardNumber: string;
  cardHolder: string;
  expiryMonth: string;
  expiryYear: string;
  cvv: string;
  phone: string;
}

interface VerificationForm {
  verificationCode: string;
}

export default function TopUpBalance() {
  const router = useRouter();
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [userToken, setUserToken] = useState<string | null>(null);
  const [currentBalance, setCurrentBalance] = useState<number>(0);
  const [showVerification, setShowVerification] = useState(false);
  const [paymentId, setPaymentId] = useState<number | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const [topUpForm, setTopUpForm] = useState<TopUpForm>({
    amount: '',
    cardNumber: '',
    cardHolder: '',
    expiryMonth: '',
    expiryYear: '',
    cvv: '',
    phone: ''
  });

  const [verificationForm, setVerificationForm] = useState<VerificationForm>({
    verificationCode: ''
  });

  useEffect(() => {
    checkAuthStatus();
    if (isAuthenticated) {
      fetchBalance();
    }
  }, [isAuthenticated]);

  const checkAuthStatus = () => {
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('access_token');
      if (token) {
        setIsAuthenticated(true);
        setUserToken(token);
      } else {
        router.push('/login');
      }
    }
  };

  const fetchBalance = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/v1/balance', {
        headers: {
          'Authorization': `Bearer ${userToken}`
        }
      });
      
      if (response.ok) {
        const data = await response.json();
        setCurrentBalance(data.balance);
      }
    } catch (err) {
      console.error('Ошибка получения баланса:', err);
    }
  };

  const handleTopUpSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const response = await fetch('http://localhost:8000/api/v1/topup-balance', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${userToken}`
        },
        body: JSON.stringify({
          amount: parseFloat(topUpForm.amount),
          card_number: topUpForm.cardNumber.replace(/\s/g, ''),
          card_holder: topUpForm.cardHolder,
          expiry_month: parseInt(topUpForm.expiryMonth),
          expiry_year: parseInt(topUpForm.expiryYear),
          cvv: topUpForm.cvv,
          phone: topUpForm.phone || undefined
        })
      });

      if (response.ok) {
        const data = await response.json();
        setPaymentId(data.payment_id);
        setShowVerification(true);
        setSuccess('Введите код верификации, отправленный на ваш телефон');
      } else {
        const errorData = await response.json();
        throw new Error(errorData.detail || 'Ошибка пополнения баланса');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Ошибка пополнения баланса');
    } finally {
      setLoading(false);
    }
  };

  const handleVerificationSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const response = await fetch('http://localhost:8000/api/v1/verify-payment', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${userToken}`
        },
        body: JSON.stringify({
          payment_id: paymentId,
          verification_code: verificationForm.verificationCode
        })
      });

      if (response.ok) {
        const data = await response.json();
        setSuccess(data.message);
        setCurrentBalance(data.new_balance);
        setShowVerification(false);
        
        // Очищаем формы
        setTopUpForm({
          amount: '',
          cardNumber: '',
          cardHolder: '',
          expiryMonth: '',
          expiryYear: '',
          cvv: '',
          phone: ''
        });
        setVerificationForm({ verificationCode: '' });
        
        setTimeout(() => {
          router.push('/dashboard');
        }, 2000);
      } else {
        const errorData = await response.json();
        throw new Error(errorData.detail || 'Ошибка верификации');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Ошибка верификации');
    } finally {
      setLoading(false);
    }
  };

  const formatCardNumber = (value: string) => {
    const v = value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
    const matches = v.match(/\d{4,16}/g);
    const match = matches && matches[0] || '';
    const parts = [];
    
    for (let i = 0, len = match.length; i < len; i += 4) {
      parts.push(match.substring(i, i + 4));
    }
    
    if (parts.length) {
      return parts.join(' ');
    } else {
      return v;
    }
  };

  if (!isAuthenticated) {
    return null;
  }

  return (
    <>
      <Head>
        <title>Пополнение баланса - Neuro Store</title>
        <meta name="description" content="Пополнение баланса для покупки подписок" />
      </Head>

      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <header className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center py-6">
              <div className="flex items-center">
                <div className="text-3xl mr-3">💳</div>
                <h1 className="text-2xl font-bold text-gray-900">Пополнение баланса</h1>
              </div>
              <nav className="hidden md:flex space-x-8">
                <Link href="/">
                  <span className="text-gray-500 hover:text-gray-900 cursor-pointer">Главная</span>
                </Link>
                <Link href="/dashboard">
                  <span className="text-gray-500 hover:text-gray-900 cursor-pointer">Личный кабинет</span>
                </Link>
                <span className="text-blue-600 font-medium">💳 Пополнение баланса</span>
              </nav>
            </div>
          </div>
        </header>

        <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {/* Текущий баланс */}
          <div className="bg-white rounded-lg shadow-md p-6 mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Текущий баланс</h2>
            <div className="text-4xl font-bold text-green-600">{currentBalance} ₽</div>
          </div>

          {/* Форма пополнения баланса */}
          {!showVerification && (
            <div className="bg-white rounded-lg shadow-md p-8">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Пополнение баланса</h2>
              
              {/* Кнопка автозаполнения тестовыми данными */}
              <div className="mb-6">
                <button
                  type="button"
                  onClick={() => {
                    setTopUpForm({
                      amount: '1000',
                      cardNumber: '4111 1111 1111 1111',
                      cardHolder: 'TEST USER',
                      expiryMonth: '12',
                      expiryYear: '2025',
                      cvv: '123',
                      phone: '+7 (999) 123-45-67'
                    });
                  }}
                  className="bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-4 rounded-lg transition-colors text-sm"
                >
                  🧪 Заполнить тестовыми данными
                </button>
              </div>
              
              {error && (
                <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
                  <div className="flex items-center">
                    <div className="text-red-500 text-xl mr-3">⚠️</div>
                    <div className="text-red-800">{error}</div>
                  </div>
                </div>
              )}

              <form onSubmit={handleTopUpSubmit} className="space-y-6">
                {/* Сумма пополнения */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Сумма пополнения (₽)
                  </label>
                  <input
                    type="number"
                    min="1"
                    step="0.01"
                    required
                    value={topUpForm.amount}
                    onChange={(e) => setTopUpForm({...topUpForm, amount: e.target.value})}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="1000"
                  />
                </div>

                {/* Номер карты */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Номер карты
                  </label>
                  <input
                    type="text"
                    required
                    value={topUpForm.cardNumber}
                    onChange={(e) => setTopUpForm({...topUpForm, cardNumber: formatCardNumber(e.target.value)})}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="1234 5678 9012 3456"
                    maxLength={19}
                  />
                </div>

                {/* Имя владельца */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Имя владельца карты
                  </label>
                  <input
                    type="text"
                    required
                    value={topUpForm.cardHolder}
                    onChange={(e) => setTopUpForm({...topUpForm, cardHolder: e.target.value})}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="IVAN IVANOV"
                  />
                </div>

                {/* Срок действия и CVV */}
                <div className="grid grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Месяц
                    </label>
                    <select
                      required
                      value={topUpForm.expiryMonth}
                      onChange={(e) => setTopUpForm({...topUpForm, expiryMonth: e.target.value})}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">ММ</option>
                      {Array.from({length: 12}, (_, i) => i + 1).map(month => (
                        <option key={month} value={month.toString().padStart(2, '0')}>
                          {month.toString().padStart(2, '0')}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Год
                    </label>
                    <select
                      required
                      value={topUpForm.expiryYear}
                      onChange={(e) => setTopUpForm({...topUpForm, expiryYear: e.target.value})}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">ГГГГ</option>
                      {Array.from({length: 7}, (_, i) => new Date().getFullYear() + i).map(year => (
                        <option key={year} value={year}>{year}</option>
                      ))}
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      CVV
                    </label>
                    <input
                      type="text"
                      required
                      value={topUpForm.cvv}
                      onChange={(e) => setTopUpForm({...topUpForm, cvv: e.target.value.replace(/\D/g, '')})}
                      className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="123"
                      maxLength={4}
                    />
                  </div>
                </div>

                {/* Телефон */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Телефон для SMS (необязательно)
                  </label>
                  <input
                    type="tel"
                    value={topUpForm.phone}
                    onChange={(e) => setTopUpForm({...topUpForm, phone: e.target.value})}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="+7 (999) 123-45-67"
                  />
                  <p className="text-sm text-gray-500 mt-1">
                    Если не указан, будет использован телефон из профиля
                  </p>
                </div>

                {/* Кнопка отправки */}
                <button
                  type="submit"
                  disabled={loading}
                  className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-semibold py-3 px-6 rounded-lg transition-colors"
                >
                  {loading ? 'Обработка...' : 'Пополнить баланс'}
                </button>
              </form>
            </div>
          )}

          {/* Форма верификации */}
          {showVerification && (
            <div className="bg-white rounded-lg shadow-md p-8">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Верификация платежа</h2>
              
              {success && (
                <div className="bg-green-50 border border-green-200 rounded-lg p-4 mb-6">
                  <div className="flex items-center">
                    <div className="text-green-500 text-xl mr-3">✅</div>
                    <div className="text-green-800">{success}</div>
                  </div>
                </div>
              )}

              {error && (
                <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
                  <div className="flex items-center">
                    <div className="text-red-500 text-xl mr-3">⚠️</div>
                    <div className="text-red-800">{error}</div>
                  </div>
                </div>
              )}

              <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-6">
                <div className="text-center">
                  <div className="text-4xl mb-4">📱</div>
                  <h3 className="text-lg font-semibold text-blue-900 mb-2">
                    Введите код верификации
                  </h3>
                  <p className="text-blue-800 mb-4">
                    Код отправлен на ваш телефон
                  </p>
                  <div className="bg-white border-2 border-blue-300 rounded-lg p-4 inline-block">
                    <span className="text-2xl font-mono text-blue-600">1111</span>
                  </div>
                  <p className="text-sm text-blue-600 mt-2">
                    Для демо используйте код: <strong>1111</strong>
                  </p>
                </div>
              </div>

              <form onSubmit={handleVerificationSubmit} className="space-y-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Код верификации
                  </label>
                  <input
                    type="text"
                    required
                    value={verificationForm.verificationCode}
                    onChange={(e) => setVerificationForm({...verificationForm, verificationCode: e.target.value})}
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-center text-2xl font-mono"
                    placeholder="1111"
                    maxLength={4}
                  />
                </div>

                <div className="flex space-x-4">
                  <button
                    type="button"
                    onClick={() => setShowVerification(false)}
                    className="flex-1 bg-gray-600 hover:bg-gray-700 text-white font-semibold py-3 px-6 rounded-lg transition-colors"
                  >
                    Назад
                  </button>
                  
                  <button
                    type="submit"
                    disabled={loading}
                    className="flex-1 bg-green-600 hover:bg-green-700 disabled:bg-gray-400 text-white font-semibold py-3 px-6 rounded-lg transition-colors"
                  >
                    {loading ? 'Проверка...' : 'Подтвердить'}
                  </button>
                </div>
              </form>
            </div>
          )}
        </main>
      </div>
    </>
  );
}
