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
