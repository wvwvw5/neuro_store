export interface Product {
  id: number;
  name: string;
  description?: string;
  category: string;
  api_endpoint?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Plan {
  id: number;
  name: string;
  description?: string;
  price: number;
  duration_days: number;
  max_requests_per_month?: number;
  features?: string[];
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ProductWithPlans extends Product {
  plans: Plan[];
}
