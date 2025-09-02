import React from 'react';
import { Product } from '../types/product';

interface ProductCardProps {
  product: Product;
  onSubscribe: (productId: number) => void;
}

const ProductCard: React.FC<ProductCardProps> = ({ product, onSubscribe }) => {
  return (
    <div className="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300 overflow-hidden">
      {/* Заголовок карточки */}
      <div className="bg-gradient-to-r from-blue-500 to-purple-600 p-4 text-white">
        <h3 className="text-xl font-semibold">{product.name}</h3>
        <p className="text-blue-100 text-sm">{product.category}</p>
      </div>
      
      {/* Описание */}
      <div className="p-4">
        <p className="text-gray-600 mb-4 line-clamp-3">
          {product.description || 'Описание продукта отсутствует'}
        </p>
        
        {/* Статус */}
        <div className="flex items-center justify-between mb-4">
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${
            product.is_active 
              ? 'bg-green-100 text-green-800' 
              : 'bg-red-100 text-red-800'
          }`}>
            {product.is_active ? 'Активен' : 'Неактивен'}
          </span>
          
          <span className="text-sm text-gray-500">
            ID: {product.id}
          </span>
        </div>
      </div>
      
      {/* Кнопка подписки */}
      <div className="px-4 pb-4">
        <button
          onClick={() => onSubscribe(product.id)}
          disabled={!product.is_active}
          className={`w-full py-2 px-4 rounded-md font-medium transition-colors duration-200 ${
            product.is_active
              ? 'bg-blue-600 hover:bg-blue-700 text-white'
              : 'bg-gray-300 text-gray-500 cursor-not-allowed'
          }`}
        >
          {product.is_active ? 'Выбрать план' : 'Недоступен'}
        </button>
      </div>
      
      {/* Футер с датами */}
      <div className="bg-gray-50 px-4 py-3 text-xs text-gray-500">
        <div className="flex justify-between">
          <span>Создан: {new Date(product.created_at).toLocaleDateString('ru-RU')}</span>
          <span>Обновлен: {new Date(product.updated_at).toLocaleDateString('ru-RU')}</span>
        </div>
      </div>
    </div>
  );
};

export default ProductCard;
