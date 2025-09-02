import React from 'react'
import { NextPage } from 'next'
import Head from 'next/head'

const Home: NextPage = () => {
  return (
    <div className="min-h-screen bg-gray-100">
      <Head>
        <title>Neuro Store - Магазин подписок на нейросети</title>
        <meta name="description" content="Подписки на ChatGPT, DALL-E, Midjourney и другие нейросети" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className="container mx-auto px-4 py-8">
        <div className="text-center">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            🧠 Neuro Store
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            Магазин подписок на нейросетевые сервисы
          </p>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-4xl mx-auto">
            <div className="card">
              <h3 className="text-lg font-semibold mb-2">ChatGPT</h3>
              <p className="text-gray-600">Мощная языковая модель для генерации текста</p>
            </div>
            
            <div className="card">
              <h3 className="text-lg font-semibold mb-2">DALL-E</h3>
              <p className="text-gray-600">Создание изображений по текстовому описанию</p>
            </div>
            
            <div className="card">
              <h3 className="text-lg font-semibold mb-2">Midjourney</h3>
              <p className="text-gray-600">Художественные изображения высокого качества</p>
            </div>
          </div>
          
          <div className="mt-8">
            <button className="btn-primary">
              Начать подписку
            </button>
          </div>
        </div>
      </main>
    </div>
  )
}

export default Home
