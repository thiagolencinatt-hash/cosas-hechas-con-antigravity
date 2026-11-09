export type Currency = 'ARS' | 'USD' | 'EUR';

export interface CurrencyConfig {
  code: Currency;
  symbol: string;
  rate: number; // multiplier relative to ARS
  label: string;
}

export type PricingMode = 'minorista' | 'mayorista';

export type OlfactoryFamily =
  | 'Oud & Maderas'
  | 'Ámbar & Resinas'
  | 'Especiados Cálidos'
  | 'Rosa & Floral Oriental'
  | 'Cuero & Tabaco'
  | 'Cítricos & Acuáticos'
  | 'Gourmand & Frutales'
  | 'Vainilla & Almizcle';

export type GenderCategory = 'Hombre' | 'Mujer' | 'Unisex' | 'Todos';

export interface OlfactoryPyramid {
  top: string[];
  heart: string[];
  base: string[];
}

export interface PerfumeReview {
  author: string;
  location: string;
  rating: number;
  date: string;
  comment: string;
}

export interface Product {
  id: number | string;
  name: string;
  brand: string;
  gender: string;
  category: string;
  price: number; // Wholesale price in ARS (Mayorista, mín 3u)
  retailPrice: number; // Retail price in ARS (Minorista, mín 1u)
  originalPrice?: number;
  shape?: 'square' | 'round' | 'flask' | 'tall';
  image: string;
  isFeatured?: boolean;
  inStock?: boolean;
  size?: string;
  concentration?: string;
  rating: number;
  reviewsCount: number;
  subtitle?: string;
  family?: string;
  tag?: string;
  intensity?: number; // 1 to 5
  keyNotePills?: string[];
  pyramid?: OlfactoryPyramid;
  performance?: {
    longevity: string;
    sillage: string;
    season: string;
  };
  description?: string;
  story?: string;
  ritual?: string;
  ingredients?: string;
  pricesBySize?: Record<string, number>;
  reviews?: PerfumeReview[];
}

export interface CartItem {
  id: string;
  product: Product;
  priceARS: number;
  quantity: number;
  size: string;
  mode: PricingMode;
}

export type Theme = 'dark' | 'light';

export interface CustomerOrderData {
  name: string;
  province: string;
  locality: string;
  notes?: string;
}
