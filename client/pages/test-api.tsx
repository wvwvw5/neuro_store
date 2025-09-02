import React, { useState } from 'react';
import Head from 'next/head';

export default function TestApi() {
  const [result, setResult] = useState<string>('');
  const [loading, setLoading] = useState(false);

  const testHealthCheck = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:8000/health');
      const data = await response.json();
      setResult(`Health Check: ${JSON.stringify(data, null, 2)}`);
    } catch (error) {
      setResult(`Error: ${error}`);
    } finally {
      setLoading(false);
    }
  };

  const testProducts = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:8000/api/v1/products/');
      const data = await response.json();
      setResult(`Products: ${JSON.stringify(data, null, 2)}`);
    } catch (error) {
      setResult(`Error: ${error}`);
    } finally {
      setLoading(false);
    }
  };

  const testLogin = async () => {
    setLoading(true);
    try {
      const formData = new FormData();
      formData.append('username', 'test@neurostore.com');
      formData.append('password', 'test123');

      const response = await fetch('http://localhost:8000/api/v1/auth/login', {
        method: 'POST',
        body: formData,
      });
      const data = await response.json();
      setResult(`Login: ${JSON.stringify(data, null, 2)}`);
    } catch (error) {
      setResult(`Error: ${error}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <Head>
        <title>Тест API - Neuro Store</title>
      </Head>

      <div className="min-h-screen bg-gray-50 p-8">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-3xl font-bold mb-8">Тест API Neuro Store</h1>
          
          <div className="bg-white rounded-lg shadow-md p-6 mb-6">
            <h2 className="text-xl font-semibold mb-4">Тестирование эндпоинтов</h2>
            
            <div className="space-x-4 mb-6">
              <button
                onClick={testHealthCheck}
                disabled={loading}
                className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-md"
              >
                Health Check
              </button>
              
              <button
                onClick={testProducts}
                disabled={loading}
                className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md"
              >
                Получить продукты
              </button>
              
              <button
                onClick={testLogin}
                disabled={loading}
                className="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-md"
              >
                Тест входа
              </button>
            </div>

            {loading && (
              <div className="text-center py-4">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
                <p className="mt-2 text-gray-600">Загрузка...</p>
              </div>
            )}

            {result && (
              <div className="mt-6">
                <h3 className="text-lg font-medium mb-2">Результат:</h3>
                <pre className="bg-gray-100 p-4 rounded-md overflow-auto text-sm">
                  {result}
                </pre>
              </div>
            )}
          </div>

          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4">Информация о сервисах</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
              <div>
                <strong>Backend API:</strong> http://localhost:8000
              </div>
              <div>
                <strong>Swagger UI:</strong> http://localhost:8000/docs
              </div>
              <div>
                <strong>PostgreSQL:</strong> localhost:5433
              </div>
              <div>
                <strong>pgAdmin:</strong> http://localhost:5050
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
