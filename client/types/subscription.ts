export interface Subscription {
  id: number;
  user_id: number;
  product_id: number;
  plan_id: number;
  status: 'active' | 'expired' | 'cancelled' | 'suspended';
  start_date: string;
  end_date: string;
  auto_renew: boolean;
  requests_used: number;
  created_at: string;
  updated_at: string;
}

export interface SubscriptionStatus {
  id: number;
  status: string;
  start_date: string;
  end_date: string;
  days_left: number;
  requests_used: number;
  auto_renew: boolean;
}

export interface SubscriptionCreate {
  product_id: number;
  plan_id: number;
}

export interface SubscriptionWithDetails extends Subscription {
  product: {
    id: number;
    name: string;
    category: string;
  };
  plan: {
    id: number;
    name: string;
    price: number;
    duration_days: number;
  };
}
