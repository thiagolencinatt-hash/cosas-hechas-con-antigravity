import { useState, useRef, useEffect } from 'react';
import { Search, ShoppingBag, Heart, X, ArrowRight, Sun, Moon, ShieldCheck, Sparkles } from 'lucide-react';
import { useShop } from '../context/ShopContext';
import { sanitizeInput } from '../utils/security';

interface NavbarProps {
  onOpenWholesaleModal?: () => void;
}

export function Navbar({ onOpenWholesaleModal }: NavbarProps) {
  const {
    globalPricingMode,
    setGlobalPricingMode,
    cartItemsCount,
    setIsCartOpen,
    wishlist,
    setIsWishlistOpen,
    setIsQuizOpen,
    searchQuery,
    setSearchQuery,
    filteredProducts,
    theme,
    toggleTheme,
    showToast,
  } = useShop();

  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const searchInputRef = useRef<HTMLInputElement>(null);

  const handleToggleMode = () => {
    const newMode = globalPricingMode === 'mayorista' ? 'minorista' : 'mayorista';
    setGlobalPricingMode(newMode);
    showToast(
      newMode === 'mayorista'
        ? 'Modalidad Mayorista activada (-35% a -55% de descuento en catálogo).'
        : 'Modalidad Minorista activada (Venta individual sin mínimo).'
    );
  };

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        setIsSearchOpen(true);
        setTimeout(() => searchInputRef.current?.focus(), 50);
      }
      if (e.key === 'Escape') {
        setIsSearchOpen(false);
        searchInputRef.current?.blur();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  const handleSearchSubmit = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    const catEl = document.getElementById('catalogo');
    if (catEl) {
      catEl.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <>
      {/* 1. Micro Ticker / Announcement Bar (Minimalist Luxury) */}
      <aside aria-label="Aviso comercial" className="bg-neutral-100 dark:bg-[#050608] text-neutral-700 dark:text-neutral-300 py-2 px-4 sm:px-8 text-[11px] font-mono tracking-wider uppercase border-b border-black/5 dark:border-white/10 select-none z-30 relative transition-colors duration-200">
        <div className="max-w-[1440px] mx-auto flex flex-col sm:flex-row items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <span className="w-1.5 h-1.5 rounded-full bg-[#c9a24b] animate-pulse" />
            <span className="font-semibold text-neutral-900 dark:text-white tracking-widest">DESPACHO ASEGURADO FEDEX PRIORITY 48H</span>
            <span className="text-neutral-400 dark:text-neutral-600 hidden sm:inline">•</span>
            <span className="text-neutral-500 dark:text-neutral-400 hidden sm:inline">Lotes Certificados IFRA / Paris & Dubái</span>
          </div>
          <div className="flex items-center gap-4">
            <span className="text-[#c9a24b] hidden md:inline font-medium">
              Combos Emprendedores desde 3u • Pedidos Personalizados
            </span>
            <button
              onClick={onOpenWholesaleModal}
              className="text-neutral-900 dark:text-white hover:text-[#c9a24b] underline underline-offset-4 transition-colors font-semibold cursor-pointer"
            >
              Tarifas B2B
            </button>
          </div>
        </div>
      </aside>

      {/* 2. Main Sticky Architectural Navbar (Minimalist Luxury) */}
      <header className="sticky top-0 z-40 bg-white/95 dark:bg-[#0B0C10]/95 backdrop-blur-xl border-b border-black/10 dark:border-white/10 text-neutral-900 dark:text-white transition-colors duration-200">
        <div className="max-w-[1440px] mx-auto px-4 sm:px-8 lg:px-12 h-20 flex items-center justify-between gap-4 sm:gap-6">
          
          {/* Brand Logo Real (LATHE ESSENCE) - Luxury Cream 3D Wave Animation */}
          <a
            href="#top"
            className="flex items-center gap-3 group flex-shrink-0 text-inherit no-underline select-none"
            aria-label="LATHE ESSENCE Inicio"
          >
            <div className="relative h-8 sm:h-11 w-28 sm:w-36 transition-transform duration-300 group-hover:scale-[1.03] flex items-center">
              <div
                className="w-full h-full logo-cream-wave"
                title="LATHE ESSENCE Haute Parfumerie"
              />
            </div>
          </a>

          {/* Navigation Links (Desktop) */}
          <nav className="hidden lg:flex items-center gap-8 font-mono text-xs uppercase tracking-widest text-neutral-600 dark:text-neutral-300">
            <a href="#top" className="hover:text-black dark:hover:text-white transition-colors py-1 border-b border-transparent hover:border-black dark:hover:border-white">
              Inicio
            </a>
            <a href="#pilares" className="hover:text-black dark:hover:text-white transition-colors py-1 border-b border-transparent hover:border-black dark:hover:border-white">
              Pilares
            </a>
            <a href="#catalogo" className="hover:text-black dark:hover:text-white transition-colors py-1 border-b border-transparent hover:border-black dark:hover:border-white">
              Catálogo
            </a>
            <a href="#b2b-matriz" className="hover:text-black dark:hover:text-white transition-colors py-1 border-b border-transparent hover:border-black dark:hover:border-white">
              Emprendedores
            </a>
            <button
              onClick={() => setIsQuizOpen(true)}
              className="hover:text-[#c9a24b] transition-colors flex items-center gap-1.5 cursor-pointer py-1"
              title="Test Olfativo: Descubrí tus Gustos y Perfume Ideal"
            >
              <Sparkles className="w-3.5 h-3.5 text-[#c9a24b]" />
              <span>Descubrí tu Fragancia</span>
            </button>
          </nav>

          {/* Right Action Controls: B2B Switcher, Cotizador B2B, Lupa Search, Wishlist, Cart, Static Theme Switcher */}
          <div className="flex items-center gap-2 sm:gap-3 shrink-0">
            
            {/* Mode Switcher Button (B2C / B2B) - Exact match to user reference */}
            <button
              onClick={handleToggleMode}
              className="hidden sm:flex items-center bg-neutral-100 dark:bg-[#14161D] border border-black/10 dark:border-white/10 px-3 py-1.5 gap-2 hover:border-black/30 dark:hover:border-white/30 transition-all cursor-pointer select-none active:scale-[0.97]"
              title="Alternar entre Precios Minorista y Mayorista"
            >
              <span className={`font-mono text-[10px] uppercase font-bold tracking-wider ${
                globalPricingMode === 'mayorista' ? 'text-[#c9a24b]' : 'text-neutral-600 dark:text-neutral-400'
              }`}>
                {globalPricingMode === 'mayorista' ? 'MAYORISTA B2B' : 'MINORISTA'}
              </span>
              <span className={`font-mono text-[9px] px-1.5 py-0.5 font-semibold ${
                globalPricingMode === 'mayorista'
                  ? 'bg-[#c9a24b]/20 text-[#c9a24b] border border-[#c9a24b]/40'
                  : 'bg-black/5 dark:bg-white/10 text-neutral-700 dark:text-neutral-300'
              }`}>
                {globalPricingMode === 'mayorista' ? '-35%' : '1u'}
              </span>
            </button>

            {/* B2B Portal Modal Trigger Button - Exact match to user reference */}
            <button
              onClick={onOpenWholesaleModal}
              className="hidden md:flex items-center gap-1.5 px-3 py-1.5 bg-neutral-100 dark:bg-white/10 hover:bg-neutral-200 dark:hover:bg-white/20 border border-black/10 dark:border-white/20 text-neutral-900 dark:text-white font-mono text-xs uppercase tracking-wider transition-colors cursor-pointer active:scale-[0.97]"
              title="Abrir Cotizador B2B"
            >
              <ShieldCheck className="w-3.5 h-3.5 text-[#c9a24b]" />
              <span className="font-semibold text-[11px]">COTIZADOR B2B</span>
            </button>

            {/* Lupa (Search Button) - Visible on ALL screens */}
            <button
              onClick={() => {
                setIsSearchOpen((prev) => !prev);
                if (!isSearchOpen) {
                  setTimeout(() => searchInputRef.current?.focus(), 80);
                }
              }}
              className={`p-2.5 transition-colors cursor-pointer border ${
                isSearchOpen || searchQuery
                  ? 'bg-black text-white dark:bg-white dark:text-black border-black dark:border-white shadow-md'
                  : 'bg-neutral-100 dark:bg-[#14161D] border-black/10 dark:border-white/10 text-neutral-700 dark:text-neutral-300 hover:text-black dark:hover:text-white hover:border-black/30 dark:hover:border-white/30'
              }`}
              aria-label="Buscar perfume (Lupa)"
              title="Buscar perfume (⌘K)"
            >
              <Search className="w-4 h-4" />
            </button>

            {/* Wishlist Button */}
            <button
              onClick={() => setIsWishlistOpen(true)}
              className="p-2.5 text-neutral-700 dark:text-neutral-300 hover:text-black dark:hover:text-white bg-neutral-100 dark:bg-[#14161D] border border-black/10 dark:border-white/10 relative transition-colors cursor-pointer"
              aria-label="Favoritos"
            >
              <Heart className="w-4 h-4" />
              {wishlist.length > 0 && (
                <span className="absolute -top-1 -right-1 w-4 h-4 bg-[#c9a24b] text-black font-mono text-[9px] font-bold flex items-center justify-center">
                  {wishlist.length}
                </span>
              )}
            </button>

            {/* Cart Drawer Button */}
            <button
              onClick={() => setIsCartOpen(true)}
              className="p-2.5 bg-black dark:bg-white text-white dark:text-black hover:opacity-90 transition-opacity relative flex items-center justify-center cursor-pointer shadow-lg active:scale-[0.97]"
              aria-label="Carrito de compras"
            >
              <ShoppingBag className="w-4 h-4" />
              {cartItemsCount > 0 && (
                <span className="absolute -top-1.5 -right-1.5 bg-[#c9a24b] text-black font-mono text-[10px] font-bold px-1.5 py-0.2 shadow-md">
                  {cartItemsCount}
                </span>
              )}
            </button>

            {/* Static Theme Switcher (Color Blanco / Oscuro) - Statically Anchored */}
            <button
              onClick={toggleTheme}
              className="w-10 h-10 flex items-center justify-center shrink-0 border border-neutral-300 dark:border-white/10 bg-neutral-100 dark:bg-[#14161D] text-neutral-800 dark:text-neutral-200 hover:border-black/40 dark:hover:border-white/40 transition-colors cursor-pointer select-none active:scale-[0.97]"
              aria-label={theme === 'dark' ? 'Cambiar a color blanco' : 'Cambiar a color oscuro'}
              title={theme === 'dark' ? 'Cambiar a color blanco' : 'Cambiar a color oscuro'}
            >
              {theme === 'dark' ? (
                <Sun className="w-4 h-4 text-[#e6cb85]" />
              ) : (
                <Moon className="w-4 h-4 text-neutral-800" />
              )}
            </button>

          </div>

        </div>

        {/* 3. Luxury Slide-Down Search Drawer (Triggered by Lupa) */}
        {isSearchOpen && (
          <div className="w-full bg-neutral-100 dark:bg-[#12141A] border-t border-black/10 dark:border-white/10 border-b border-black/15 dark:border-white/15 px-4 sm:px-8 lg:px-12 py-3.5 animate-fade-in shadow-2xl transition-all">
            <div className="max-w-[1440px] mx-auto flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
              <form onSubmit={handleSearchSubmit} className="flex-1 flex items-center gap-3 bg-white dark:bg-[#0B0C10] border border-black/15 dark:border-white/15 px-4 py-2">
                <Search className="w-4 h-4 text-[#c9a24b] shrink-0" />
                <input
                  ref={searchInputRef}
                  type="text"
                  maxLength={80}
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(sanitizeInput(e.target.value, 80))}
                  placeholder="Buscar por nombre, nota (ej. Vainilla, Oud, Ámbar) o marca (ej. Lattafa, Tom Ford)..."
                  className="w-full bg-transparent text-neutral-900 dark:text-white placeholder:text-neutral-500 font-sans text-xs sm:text-sm focus:outline-none"
                  autoFocus
                />
                {searchQuery && (
                  <button
                    type="button"
                    onClick={() => setSearchQuery('')}
                    className="p-1 text-neutral-500 hover:text-black dark:text-neutral-400 dark:hover:text-white"
                    aria-label="Borrar búsqueda"
                  >
                    <X className="w-3.5 h-3.5" />
                  </button>
                )}
              </form>

              <div className="flex items-center gap-2 justify-end">
                <span className="text-[11px] font-mono text-neutral-600 dark:text-neutral-400">
                  {filteredProducts.length} fragancia{filteredProducts.length === 1 ? '' : 's'}
                </span>

                <button
                  onClick={() => handleSearchSubmit()}
                  className="px-4 py-2 bg-black dark:bg-white text-white dark:text-black font-mono text-xs uppercase font-semibold hover:opacity-90 transition-opacity flex items-center gap-1.5 cursor-pointer"
                >
                  <span>Explorar</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </button>

                <button
                  onClick={() => setIsSearchOpen(false)}
                  className="p-2 text-neutral-600 hover:text-black dark:text-neutral-400 dark:hover:text-white transition-colors cursor-pointer"
                  aria-label="Cerrar buscador"
                  title="Cerrar (Esc)"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        )}
      </header>
    </>
  );
}
