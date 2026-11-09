import { useRef, useEffect } from 'react';
import { Search, ShoppingBag, Heart, Sparkles, X, SlidersHorizontal, Sun, Moon, ChevronDown } from 'lucide-react';
import { useShop, CURRENCY_CONFIGS } from '../context/ShopContext';
import { Currency } from '../types';

export function Navbar() {
  const {
    currency,
    setCurrency,
    theme,
    toggleTheme,
    globalPricingMode,
    setGlobalPricingMode,
    cartItemsCount,
    setIsCartOpen,
    wishlist,
    setIsWishlistOpen,
    setIsQuizOpen,
    searchQuery,
    setSearchQuery,
    activeFiltersCount,
    isFilterDrawerOpen,
    setIsFilterDrawerOpen,
  } = useShop();

  const isDark = theme === 'dark';
  const searchInputRef = useRef<HTMLInputElement>(null);

  // Keyboard shortcut: Cmd/Ctrl+K or / to search, Esc to clear
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        searchInputRef.current?.focus();
      }
      if (e.key === 'Escape') {
        searchInputRef.current?.blur();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  return (
    <>
      {/* Top Wholesale / Retail Announcement Bar — Minimalist Monochrome */}
      <aside aria-label="Aviso comercial" className="bg-[#0a0a0a] text-neutral-300 text-center py-1.5 px-4 text-[11px] sm:text-xs font-medium tracking-wider uppercase border-b border-white/[0.06] flex items-center justify-center gap-2 select-none z-30 relative">
        <span className="font-bold text-white tracking-widest">Modalidad Dual</span>
        <span className="text-neutral-600">•</span>
        <span>Minorista desde 1 unidad</span>
        <span className="text-neutral-600">•</span>
        <span>Mayorista desde 3 unidades (podés combinar marcas)</span>
        <span className="text-neutral-600 hidden md:inline">•</span>
        <span className="hidden md:inline">Envíos asegurados a todo el país</span>
      </aside>

      {/* Main Sticky Navbar */}
      <header className="sticky top-0 z-40 bg-white/95 dark:bg-[#000000]/95 backdrop-blur-md border-b border-black/[0.08] dark:border-white/[0.08] transition-colors duration-200">
        <div className="max-w-7xl mx-auto px-3 sm:px-6 lg:px-8 h-16 sm:h-20 flex items-center justify-between gap-3 sm:gap-6">
          
          {/* Brand Logo Real (Left) */}
          <a
            href="#top"
            className="flex items-center gap-2 group flex-shrink-0 text-inherit no-underline"
            aria-label="LATHE ESSENCE Inicio"
          >
            <img
              src={isDark ? '/images/logo/lathe-logo-white.png' : '/images/logo/lathe-logo-black.png'}
              alt="LATHE ESSENCE"
              className="h-8 sm:h-10 w-auto object-contain transition-transform duration-200 group-hover:scale-[1.02]"
              onError={(e) => {
                (e.target as HTMLElement).style.display = 'none';
              }}
            />
          </a>

          {/* Central Live Search Bar */}
          <div className="flex-1 max-w-md mx-2 relative">
            <div className="relative flex items-center">
              <Search className="w-4 h-4 absolute left-3.5 text-neutral-400 pointer-events-none" />
              <input
                ref={searchInputRef}
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Buscar perfume o marca (ej. Khamrah, Asad, Yara, Jean Paul)..."
                className="w-full h-10 sm:h-11 pl-10 pr-9 rounded-full bg-neutral-100 dark:bg-white/[0.06] border border-black/10 dark:border-white/10 text-neutral-900 dark:text-white placeholder:text-neutral-500 text-xs sm:text-sm font-sans focus:outline-none focus:border-neutral-400 dark:focus:border-white/40 focus:ring-1 focus:ring-neutral-400/20 dark:focus:ring-white/20 transition-all"
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery('')}
                  className="absolute right-3 p-1 text-neutral-400 hover:text-white"
                  aria-label="Limpiar búsqueda"
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              )}
            </div>
          </div>

          {/* Pricing Mode Selector Pill (Minorista 1u vs Mayorista 3u) */}
          <div className="hidden lg:flex items-center p-0.5 rounded-full bg-neutral-100 dark:bg-white/[0.06] border border-black/10 dark:border-white/10 select-none">
            <button
              onClick={() => setGlobalPricingMode('minorista')}
              className={`px-3 py-1.5 rounded-full text-[11px] font-sans font-medium transition-all ${
                globalPricingMode === 'minorista'
                  ? 'bg-black text-white dark:bg-white dark:text-black font-semibold shadow-sm'
                  : 'text-neutral-600 dark:text-neutral-400 hover:text-black dark:hover:text-white'
              }`}
            >
              Minorista (1+ u)
            </button>
            <button
              onClick={() => setGlobalPricingMode('mayorista')}
              className={`px-3 py-1.5 rounded-full text-[11px] font-sans font-medium transition-all ${
                globalPricingMode === 'mayorista'
                  ? 'bg-black text-white dark:bg-white dark:text-black font-semibold shadow-sm'
                  : 'text-neutral-600 dark:text-neutral-400 hover:text-black dark:hover:text-white'
              }`}
            >
              Mayorista (3+ u)
            </button>
          </div>

          {/* Right Action Utilities */}
          <div className="flex items-center gap-1.5 sm:gap-2 flex-shrink-0">
            {/* Fragrance Quiz Discovery Button */}
            <button
              onClick={() => setIsQuizOpen(true)}
              className="hidden xl:flex items-center gap-1.5 px-3 py-1.5 rounded-full border border-black/10 dark:border-white/15 text-neutral-700 dark:text-neutral-200 hover:bg-neutral-100 dark:hover:bg-white/[0.08] text-xs font-sans tracking-wide transition-all"
              title="Test de Fragancia"
            >
              <Sparkles className="w-3.5 h-3.5 text-neutral-400 dark:text-neutral-300" />
              <span>Test Olfativo</span>
            </button>

            {/* Currency Selector */}
            <div className="relative hidden md:block">
              <select
                value={currency}
                onChange={(e) => setCurrency(e.target.value as Currency)}
                className="appearance-none bg-neutral-100 dark:bg-white/[0.06] border border-black/10 dark:border-white/10 text-neutral-800 dark:text-neutral-200 text-xs font-sans rounded-full py-2 pl-3 pr-7 cursor-pointer hover:border-neutral-400 focus:outline-none transition-colors"
                aria-label="Seleccionar moneda"
              >
                {(Object.keys(CURRENCY_CONFIGS) as Currency[]).map((c) => (
                  <option key={c} value={c} className="bg-neutral-900 text-white">
                    {c} ({CURRENCY_CONFIGS[c].symbol})
                  </option>
                ))}
              </select>
              <ChevronDown className="w-3 h-3 absolute right-2.5 top-1/2 -translate-y-1/2 pointer-events-none text-neutral-400" />
            </div>

            {/* Theme Toggle (Blanco / Negro) */}
            <button
              onClick={toggleTheme}
              className="w-9 h-9 sm:w-10 sm:h-10 rounded-full flex items-center justify-center border border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30 text-neutral-700 dark:text-neutral-200 transition-all active:scale-95"
              title={isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'}
              aria-label="Alternar tema"
            >
              {isDark ? <Sun className="w-4 h-4 text-neutral-200" /> : <Moon className="w-4 h-4 text-neutral-800" />}
            </button>

            {/* Wishlist Button */}
            <button
              onClick={() => setIsWishlistOpen(true)}
              className="relative w-9 h-9 sm:w-10 sm:h-10 rounded-full flex items-center justify-center border border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30 text-neutral-700 dark:text-neutral-200 transition-all active:scale-95"
              title="Favoritos"
              aria-label="Favoritos"
            >
              <Heart className="w-4 h-4" />
              {wishlist.length > 0 && (
                <span className="absolute -top-1 -right-1 bg-black text-white dark:bg-white dark:text-black font-bold text-[10px] w-4 h-4 rounded-full flex items-center justify-center shadow-sm">
                  {wishlist.length}
                </span>
              )}
            </button>

            {/* Cart Button: Mi Pedido */}
            <button
              onClick={() => setIsCartOpen(true)}
              className="relative flex items-center gap-2 h-9 sm:h-10 px-3.5 sm:px-4 rounded-full bg-black text-white dark:bg-white dark:text-black hover:opacity-90 font-sans font-semibold text-xs tracking-wide transition-all active:scale-95 shadow-sm"
              aria-label="Abrir mi pedido"
            >
              <ShoppingBag className="w-4 h-4" />
              <span className="hidden sm:inline">Mi Pedido</span>
              <span className="bg-white/20 dark:bg-black/10 text-white dark:text-black font-bold text-[11px] px-1.5 py-0.5 rounded-full min-w-[20px] text-center">
                {cartItemsCount}
              </span>
            </button>

            {/* Filter Toggle Button */}
            <button
              onClick={() => setIsFilterDrawerOpen(!isFilterDrawerOpen)}
              className={`relative w-9 h-9 sm:w-10 sm:h-10 rounded-full flex items-center justify-center border transition-all active:scale-95 ${
                activeFiltersCount > 0
                  ? 'border-black bg-black text-white dark:border-white dark:bg-white dark:text-black'
                  : 'border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30 text-neutral-700 dark:text-neutral-200'
              }`}
              title="Filtros"
              aria-label="Filtros"
            >
              <SlidersHorizontal className="w-4 h-4" />
              {activeFiltersCount > 0 && (
                <span className="absolute -top-1 -right-1 bg-black text-white dark:bg-white dark:text-black font-bold text-[10px] w-4 h-4 rounded-full flex items-center justify-center shadow-sm">
                  {activeFiltersCount}
                </span>
              )}
            </button>
          </div>

        </div>
      </header>
    </>
  );
}
