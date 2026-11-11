import React, { createContext, useContext, useState, useEffect, useMemo } from 'react';
import { Currency, CurrencyConfig, Product, CartItem, Theme, CustomerOrderData, PricingMode } from '../types';
import { PRODUCTS } from '../data/products';
import { sanitizeInput } from '../utils/security';

export const CURRENCY_CONFIGS: Record<Currency, CurrencyConfig> = {
  ARS: { code: 'ARS', symbol: '$', rate: 1.0, label: 'Pesos Argentinos ($)' },
  USD: { code: 'USD', symbol: 'US$', rate: 0.00095, label: 'Dólares (US$)' },
  EUR: { code: 'EUR', symbol: '€', rate: 0.00088, label: 'Euros (€)' },
};

export const WHOLESALE_MIN_UNITS = 3;
export const DEFAULT_WHATSAPP_NUMBER = "5491166573519";

export type SortOption = 'rec' | 'asc' | 'desc' | 'az';
export type ShowOption = 'todos' | 'ofertas' | 'stock';

interface ShopContextType {
  currency: Currency;
  setCurrency: (c: Currency) => void;
  formatPrice: (priceARS: number) => string;
  theme: Theme;
  toggleTheme: () => void;
  setTheme: (t: Theme) => void;
  
  // Pricing Mode (Minorista vs Mayorista)
  globalPricingMode: PricingMode;
  setGlobalPricingMode: (mode: PricingMode) => void;
  toggleGlobalPricingMode: () => void;
  
  // Cart
  cart: CartItem[];
  addToCart: (product: Product, quantity?: number, mode?: PricingMode) => void;
  removeFromCart: (itemId: string) => void;
  updateQuantity: (itemId: string, delta: number) => void;
  updateItemMode: (itemId: string, newMode: PricingMode) => void;
  clearCart: () => void;
  cartTotalARS: number;
  cartItemsCount: number;
  wholesaleMin: number;
  isWholesaleReached: boolean;
  neededForWholesale: number;
  isCartOpen: boolean;
  setIsCartOpen: (open: boolean) => void;
  getItemQuantityInCart: (productId: number | string) => number;
  
  // Filters
  searchQuery: string;
  setSearchQuery: (q: string) => void;
  selectedBrand: string;
  setSelectedBrand: (b: string) => void;
  selectedGender: string;
  setSelectedGender: (g: string) => void;
  selectedCategory: string;
  setSelectedCategory: (c: string) => void;
  selectedShow: ShowOption;
  setSelectedShow: (s: ShowOption) => void;
  sortBy: SortOption;
  setSortBy: (s: SortOption) => void;
  isFilterDrawerOpen: boolean;
  setIsFilterDrawerOpen: (open: boolean) => void;
  clearFilters: () => void;
  activeFiltersCount: number;
  filteredProducts: Product[];
  brandsList: string[];
  
  // Modals & Wishlist
  wishlist: string[];
  toggleWishlist: (productId: string | number) => void;
  isWishlistOpen: boolean;
  setIsWishlistOpen: (open: boolean) => void;
  selectedProductForModal: Product | null;
  setSelectedProductForModal: (p: Product | null) => void;
  isQuizOpen: boolean;
  setIsQuizOpen: (open: boolean) => void;
  
  // Checkout & WhatsApp
  customerData: CustomerOrderData;
  setCustomerData: React.Dispatch<React.SetStateAction<CustomerOrderData>>;
  sendOrderViaWhatsApp: () => void;
  
  // Toast
  toastMessage: string | null;
  showToast: (msg: string) => void;
}

const ShopContext = createContext<ShopContextType | undefined>(undefined);

export function ShopProvider({ children }: { children: React.ReactNode }) {
  const [currency, setCurrency] = useState<Currency>('ARS');
  
  // Global pricing mode (minorista min 1u vs mayorista min 3u)
  const [globalPricingMode, setGlobalPricingMode] = useState<PricingMode>(() => {
    try {
      const saved = localStorage.getItem('lathe_pricing_mode');
      return saved === 'minorista' || saved === 'mayorista' ? saved : 'mayorista';
    } catch {
      return 'mayorista';
    }
  });

  const toggleGlobalPricingMode = () => {
    const next: PricingMode = globalPricingMode === 'mayorista' ? 'minorista' : 'mayorista';
    setGlobalPricingMode(next);
    try {
      localStorage.setItem('lathe_pricing_mode', next);
    } catch {}
    showToast(next === 'mayorista' ? 'Modalidad Mayorista activada (mín. 3u)' : 'Modalidad Minorista activada (desde 1u)');
  };

  // Theme state: dark luxury default
  const [theme, setThemeState] = useState<Theme>(() => {
    try {
      const saved = localStorage.getItem('lathe_theme');
      if (saved === 'light' || saved === 'dark') return saved;
      return 'dark';
    } catch {
      return 'dark';
    }
  });

  useEffect(() => {
    const root = document.documentElement;
    if (theme === 'light') {
      root.classList.remove('dark');
      root.classList.add('light');
    } else {
      root.classList.remove('light');
      root.classList.add('dark');
    }
    try {
      localStorage.setItem('lathe_theme', theme);
    } catch {}
  }, [theme]);

  const toggleTheme = () => {
    const next = theme === 'dark' ? 'light' : 'dark';
    setThemeState(next);
    showToast(next === 'light' ? 'Modo Claro activado' : 'Modo Oscuro activado');
  };

  const setTheme = (t: Theme) => {
    setThemeState(t);
  };

  // Cart state persisted
  const [cart, setCart] = useState<CartItem[]>(() => {
    try {
      const saved = localStorage.getItem('lathe_cart');
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  // Wishlist state
  const [wishlist, setWishlist] = useState<string[]>(() => {
    try {
      const saved = localStorage.getItem('lathe_wishlist');
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  // Filter states
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedBrand, setSelectedBrand] = useState('Todas');
  const [selectedGender, setSelectedGender] = useState('Todos');
  const [selectedCategory, setSelectedCategory] = useState('Todos');
  const [selectedShow, setSelectedShow] = useState<ShowOption>('todos');
  const [sortBy, setSortBy] = useState<SortOption>('rec');
  const [isFilterDrawerOpen, setIsFilterDrawerOpen] = useState(false);

  // Modals state
  const [isCartOpen, setIsCartOpen] = useState(false);
  const [isWishlistOpen, setIsWishlistOpen] = useState(false);
  const [selectedProductForModal, setSelectedProductForModal] = useState<Product | null>(null);
  const [isQuizOpen, setIsQuizOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Customer order info
  const [customerData, setCustomerData] = useState<CustomerOrderData>(() => {
    try {
      const saved = localStorage.getItem('lathe_customer');
      return saved ? JSON.parse(saved) : { name: '', province: '', locality: '', notes: '' };
    } catch {
      return { name: '', province: '', locality: '', notes: '' };
    }
  });

  useEffect(() => {
    try {
      localStorage.setItem('lathe_cart', JSON.stringify(cart));
    } catch {}
  }, [cart]);

  useEffect(() => {
    try {
      localStorage.setItem('lathe_wishlist', JSON.stringify(wishlist));
    } catch {}
  }, [wishlist]);

  useEffect(() => {
    try {
      localStorage.setItem('lathe_customer', JSON.stringify(customerData));
    } catch {}
  }, [customerData]);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 3200);
  };

  const formatPrice = (priceARS: number) => {
    const config = CURRENCY_CONFIGS[currency];
    const converted = priceARS * config.rate;
    if (currency === 'ARS') {
      return `$ ${Math.round(converted).toLocaleString('es-AR')}`;
    }
    return `${config.symbol} ${converted.toFixed(2)}`;
  };

  // Cart operations
  const addToCart = (product: Product, quantity = 1, mode?: PricingMode) => {
    const effectiveMode = mode || globalPricingMode;
    // Wholesale mode strictly requires minimum 3 units
    const effectiveQty = effectiveMode === 'mayorista' ? Math.max(WHOLESALE_MIN_UNITS, quantity) : Math.max(1, quantity);
    const unitPrice = effectiveMode === 'mayorista' ? product.price : product.retailPrice;
    const itemId = `prod-${product.id}-${effectiveMode}`;

    setCart((prev) => {
      const existing = prev.find((item) => item.id === itemId);
      if (existing) {
        return prev.map((item) =>
          item.id === itemId ? { ...item, quantity: item.quantity + effectiveQty } : item
        );
      }
      return [
        ...prev,
        {
          id: itemId,
          product,
          priceARS: unitPrice,
          quantity: effectiveQty,
          size: product.size || '100ml',
          mode: effectiveMode,
        },
      ];
    });

    showToast(`Añadido al pedido (${effectiveMode === 'mayorista' ? 'Mayorista' : 'Minorista'}): ${product.name}`);
  };

  const updateQuantity = (itemId: string, delta: number) => {
    setCart((prev) =>
      prev
        .map((item) => {
          if (item.id === itemId) {
            const newQty = item.quantity + delta;
            if (newQty <= 0) return null;

            // If wholesale and qty falls below 3, convert to retail or warn
            if (item.mode === 'mayorista' && newQty < WHOLESALE_MIN_UNITS) {
              showToast('Menos de 3 unidades: recalculado a tarifa minorista.');
              return {
                ...item,
                quantity: newQty,
                mode: 'minorista' as PricingMode,
                priceARS: item.product.retailPrice,
              };
            }

            return { ...item, quantity: newQty };
          }
          return item;
        })
        .filter(Boolean) as CartItem[]
    );
  };

  const updateItemMode = (itemId: string, newMode: PricingMode) => {
    setCart((prev) =>
      prev.map((item) => {
        if (item.id === itemId) {
          const qty = newMode === 'mayorista' ? Math.max(WHOLESALE_MIN_UNITS, item.quantity) : item.quantity;
          const unitPrice = newMode === 'mayorista' ? item.product.price : item.product.retailPrice;
          return {
            ...item,
            mode: newMode,
            quantity: qty,
            priceARS: unitPrice,
          };
        }
        return item;
      })
    );
  };

  const removeFromCart = (itemId: string) => {
    setCart((prev) => prev.filter((item) => item.id !== itemId));
    showToast('Producto quitado del pedido.');
  };

  const clearCart = () => {
    setCart([]);
  };

  const getItemQuantityInCart = (productId: number | string) => {
    const items = cart.filter((i) => String(i.product.id) === String(productId));
    return items.reduce((sum, it) => sum + it.quantity, 0);
  };

  const toggleWishlist = (productId: string | number) => {
    const idStr = String(productId);
    setWishlist((prev) => {
      const exists = prev.includes(idStr);
      if (exists) {
        showToast('Eliminado de favoritos');
        return prev.filter((id) => id !== idStr);
      } else {
        showToast('Guardado en favoritos');
        return [...prev, idStr];
      }
    });
  };

  // Cart calculations
  const cartItemsCount = useMemo(() => {
    return cart.reduce((sum, item) => sum + item.quantity, 0);
  }, [cart]);

  const cartTotalARS = useMemo(() => {
    return cart.reduce((sum, item) => sum + item.priceARS * item.quantity, 0);
  }, [cart]);

  const wholesaleItemsCount = useMemo(() => {
    return cart.filter((i) => i.mode === 'mayorista').reduce((sum, item) => sum + item.quantity, 0);
  }, [cart]);

  const isWholesaleReached = wholesaleItemsCount >= WHOLESALE_MIN_UNITS || cart.every((i) => i.mode === 'minorista');
  const neededForWholesale = Math.max(0, WHOLESALE_MIN_UNITS - wholesaleItemsCount);

  // Brands list
  const brandsList = useMemo(() => {
    const set = new Set<string>();
    PRODUCTS.forEach((p) => {
      if (p.brand) set.add(p.brand);
    });
    return ['Todas', ...Array.from(set).sort()];
  }, []);

  // Filter count
  const activeFiltersCount = useMemo(() => {
    let count = 0;
    if (selectedBrand !== 'Todas') count++;
    if (selectedGender !== 'Todos') count++;
    if (selectedCategory !== 'Todos') count++;
    if (selectedShow !== 'todos') count++;
    if (sortBy !== 'rec') count++;
    return count;
  }, [selectedBrand, selectedGender, selectedCategory, selectedShow, sortBy]);

  const clearFilters = () => {
    setSelectedBrand('Todas');
    setSelectedGender('Todos');
    setSelectedCategory('Todos');
    setSelectedShow('todos');
    setSortBy('rec');
    setSearchQuery('');
  };

  // Filtered and sorted products
  const filteredProducts = useMemo(() => {
    let result = [...PRODUCTS];

    // Search query
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase().trim();
      result = result.filter(
        (p) =>
          p.name.toLowerCase().includes(q) ||
          p.brand.toLowerCase().includes(q) ||
          p.category?.toLowerCase().includes(q) ||
          p.gender?.toLowerCase().includes(q)
      );
    }

    // Brand
    if (selectedBrand !== 'Todas') {
      result = result.filter((p) => p.brand === selectedBrand);
    }

    // Gender
    if (selectedGender !== 'Todos') {
      result = result.filter((p) => p.gender?.toLowerCase() === selectedGender.toLowerCase());
    }

    // Category or Olfactory Family Filter (Smart Semantic Match)
    if (selectedCategory !== 'Todos') {
      const target = selectedCategory.toLowerCase();
      result = result.filter((p) => {
        const cat = (p.category || '').toLowerCase();
        const fam = (p.family || '').toLowerCase();
        const tag = (p.tag || '').toLowerCase();
        const notes = (p.keyNotePills || []).map((k) => k.toLowerCase()).join(' ');
        const pyramidNotes = [
          ...(p.pyramid?.top || []),
          ...(p.pyramid?.heart || []),
          ...(p.pyramid?.base || []),
        ]
          .map((n) => n.toLowerCase())
          .join(' ');
        const desc = (p.description || '').toLowerCase();
        const name = (p.name || '').toLowerCase();

        // 1. Direct Category Match (e.g. Arabes, Diseñador, Body splash, Nicho)
        if (cat === target) return true;

        // 2. Direct string inclusion across family, tags, notes, description
        if (
          fam.includes(target) ||
          tag.includes(target) ||
          notes.includes(target) ||
          pyramidNotes.includes(target) ||
          desc.includes(target) ||
          name.includes(target)
        ) {
          return true;
        }

        // 3. Olfactory Pillars Semantic Mapping
        if (
          target === 'amaderado' &&
          (fam.includes('cuero') ||
            fam.includes('tabaco') ||
            notes.includes('madera') ||
            pyramidNotes.includes('cedro') ||
            pyramidNotes.includes('sándalo') ||
            desc.includes('madera'))
        ) {
          return true;
        }
        if (
          target === 'cítrico' &&
          (pyramidNotes.includes('bergamota') ||
            pyramidNotes.includes('mandarina') ||
            pyramidNotes.includes('limón') ||
            notes.includes('fruta') ||
            fam.includes('frutal'))
        ) {
          return true;
        }
        if (
          target === 'oriental' &&
          (cat === 'arabes' ||
            fam.includes('especiad') ||
            pyramidNotes.includes('ámbar') ||
            pyramidNotes.includes('incienso') ||
            pyramidNotes.includes('oud'))
        ) {
          return true;
        }
        if (
          target === 'floral' &&
          (fam.includes('gourmand') ||
            pyramidNotes.includes('rosa') ||
            pyramidNotes.includes('orquídea') ||
            pyramidNotes.includes('jazmín') ||
            desc.includes('floral'))
        ) {
          return true;
        }

        return false;
      });
    }

    // Show (ofertas, stock)
    if (selectedShow === 'ofertas') {
      result = result.filter((p) => p.originalPrice && p.originalPrice > p.price);
    } else if (selectedShow === 'stock') {
      result = result.filter((p) => p.inStock !== false);
    }

    // Sort
    if (sortBy === 'asc') {
      result.sort((a, b) => a.price - b.price);
    } else if (sortBy === 'desc') {
      result.sort((a, b) => b.price - a.price);
    } else if (sortBy === 'az') {
      result.sort((a, b) => a.name.localeCompare(b.name));
    }

    return result;
  }, [searchQuery, selectedBrand, selectedGender, selectedCategory, selectedShow, sortBy]);

  // WhatsApp Order Submission (Professional formatting, NO emojis)
  const sendOrderViaWhatsApp = () => {
    if (cart.length === 0) {
      showToast('Tu carrito está vacío.');
      return;
    }

    const itemsText = cart
      .map(
        (item) =>
          `• ${item.quantity}x ${item.product.name} (${item.product.brand}) [${item.mode === 'mayorista' ? 'Mayorista' : 'Minorista'}] - $ ${item.priceARS.toLocaleString('es-AR')} c/u = $ ${(item.priceARS * item.quantity).toLocaleString('es-AR')}`
      )
      .join('\n');

    // Sanitización estricta anti-XSS antes de procesar y concatenar
    const cleanName = sanitizeInput(customerData.name || '', 80);
    const cleanProvince = sanitizeInput(customerData.province || '', 50);
    const cleanLocality = sanitizeInput(customerData.locality || '', 80);
    const cleanNotes = sanitizeInput(customerData.notes || '', 300);

    const customerDetails = [
      cleanName ? `Cliente: ${cleanName}` : '',
      cleanProvince ? `Provincia: ${cleanProvince}` : '',
      cleanLocality ? `Localidad: ${cleanLocality}` : '',
      cleanNotes ? `Notas: ${cleanNotes}` : '',
    ]
      .filter(Boolean)
      .join('\n');

    const message = `*SOLICITUD DE PEDIDO - LATHE ESSENCE*\n\n${customerDetails ? customerDetails + '\n\n' : ''}*DETALLE DEL PEDIDO (${cartItemsCount} unidades):*\n${itemsText}\n\n*TOTAL ESTIMADO:* $ ${cartTotalARS.toLocaleString('es-AR')} ARS\n\nHola, les envío mi pedido armado desde el catálogo web para coordinar confirmación, medios de pago y despacho.`;

    const encoded = encodeURIComponent(message);
    const url = `https://wa.me/${DEFAULT_WHATSAPP_NUMBER}?text=${encoded}`;
    window.open(url, '_blank');
  };

  return (
    <ShopContext.Provider
      value={{
        currency,
        setCurrency,
        formatPrice,
        theme,
        toggleTheme,
        setTheme,
        globalPricingMode,
        setGlobalPricingMode,
        toggleGlobalPricingMode,
        cart,
        addToCart,
        removeFromCart,
        updateQuantity,
        updateItemMode,
        clearCart,
        cartTotalARS,
        cartItemsCount,
        wholesaleMin: WHOLESALE_MIN_UNITS,
        isWholesaleReached,
        neededForWholesale,
        isCartOpen,
        setIsCartOpen,
        getItemQuantityInCart,
        searchQuery,
        setSearchQuery,
        selectedBrand,
        setSelectedBrand,
        selectedGender,
        setSelectedGender,
        selectedCategory,
        setSelectedCategory,
        selectedShow,
        setSelectedShow,
        sortBy,
        setSortBy,
        isFilterDrawerOpen,
        setIsFilterDrawerOpen,
        clearFilters,
        activeFiltersCount,
        filteredProducts,
        brandsList,
        wishlist,
        toggleWishlist,
        isWishlistOpen,
        setIsWishlistOpen,
        selectedProductForModal,
        setSelectedProductForModal,
        isQuizOpen,
        setIsQuizOpen,
        customerData,
        setCustomerData,
        sendOrderViaWhatsApp,
        toastMessage,
        showToast,
      }}
    >
      {children}
    </ShopContext.Provider>
  );
}

export function useShop() {
  const context = useContext(ShopContext);
  if (!context) {
    throw new Error('useShop must be used within a ShopProvider');
  }
  return context;
}
