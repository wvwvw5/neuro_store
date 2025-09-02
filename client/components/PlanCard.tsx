import React from 'react';
import { Plan } from '../types/plan';

interface PlanCardProps {
  plan: Plan;
  isSelected: boolean;
  onSelect: (planId: number) => void;
}

const PlanCard: React.FC<PlanCardProps> = ({ plan, isSelected, onSelect }) => {
  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('ru-RU', {
      style: 'currency',
      currency: 'RUB',
      minimumFractionDigits: 0
    }).format(price);
  };

  const formatDuration = (days: number) => {
    if (days === 30) return '1 месяц';
    if (days === 90) return '3 месяца';
    if (days === 180) return '6 месяцев';
    if (days === 365) return '1 год';
    return `${days} дней`;
  };

  return (
    <div 
      className={`relative border-2 rounded-lg p-6 cursor-pointer transition-all duration-200 ${
        isSelected 
          ? 'border-blue-500 bg-blue-50 shadow-lg scale-105' 
          : 'border-gray-200 hover:border-gray-300 hover:shadow-md'
      }`}
      onClick={() => onSelect(plan.id)}
    >
      {/* Индикатор выбора */}
      {isSelected && (
        <div className="absolute -top-3 -right-3 w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
          <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
          </svg>
        </div>
      )}

      {/* Заголовок плана */}
      <div className="text-center mb-4">
        <h3 className="text-xl font-bold text-gray-900">{plan.name}</h3>
        <p className="text-gray-600 text-sm">{plan.description}</p>
      </div>

      {/* Цена */}
      <div className="text-center mb-6">
        <div className="text-3xl font-bold text-blue-600">
          {formatPrice(plan.price)}
        </div>
        <div className="text-gray-500 text-sm">
          за {formatDuration(plan.duration_days)}
        </div>
      </div>

      {/* Особенности */}
      <div className="space-y-3 mb-6">
        <div className="flex items-center text-sm">
          <svg className="w-4 h-4 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
          </svg>
          <span>Длительность: {formatDuration(plan.duration_days)}</span>
        </div>
        
        {plan.max_requests_per_month && (
          <div className="flex items-center text-sm">
            <svg className="w-4 h-4 text-green-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
            </svg>
            <span>До {plan.max_requests_per_month} запросов/месяц</span>
          </div>
        )}
        
        {plan.features && (
          <div className="flex items-start text-sm">
            <svg className="w-4 h-4 text-green-500 mr-2 mt-0.5" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
            </svg>
            <span className="text-gray-600">{plan.features}</span>
          </div>
        )}
      </div>

      {/* Статус */}
      <div className="text-center">
        <span className={`px-3 py-1 rounded-full text-xs font-medium ${
          plan.is_active 
            ? 'bg-green-100 text-green-800' 
            : 'bg-red-100 text-red-800'
        }`}>
          {plan.is_active ? 'Доступен' : 'Недоступен'}
        </span>
      </div>

      {/* Футер */}
      <div className="mt-4 pt-4 border-t border-gray-200 text-xs text-gray-500 text-center">
        <div>Создан: {new Date(plan.created_at).toLocaleDateString('ru-RU')}</div>
        <div>Обновлен: {new Date(plan.updated_at).toLocaleDateString('ru-RU')}</div>
      </div>
    </div>
  );
};

export default PlanCard;
