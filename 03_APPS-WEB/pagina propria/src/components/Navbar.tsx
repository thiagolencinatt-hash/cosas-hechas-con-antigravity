import { useRef, useEffect } from 'react';
import { Search, ShoppingBag, Heart, X, ShieldCheck, Compass } from 'lucide-react';
import { useShop } from '../context/ShopContext';

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
    showToast,
  } = useShop();

  const searchInputRef = useRef<HTMLInputElement>(null);

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

  const handleToggleMode = () => {
    const newMode = globalPricingMode === 'mayorista' ? 'minorista' : 'mayorista';
    setGlobalPricingMode(newMode);
    showToast(
      newMode === 'mayorista'
        ? 'Modalidad Mayorista activada (Mínimo 3 unidades surtidas con 35% a 55% de descuento).'
        : 'Modalidad Minorista activada (Venta individual sin mínimo de compra).'
    );
  };

  return (
    <>
      {/* 1. Micro Ticker / Announcement Bar (Stitch Specification) */}
      <aside aria-label="Aviso comercial" className="bg-[#050608] text-neutral-300 py-2 px-4 sm:px-8 text-[11px] font-mono tracking-wider uppercase border-b border-white/10 select-none z-30 relative">
        <div className="max-w-[1440px] mx-auto flex flex-col sm:flex-row items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <span className="w-1.5 h-1.5 rounded-full bg-[#c9a24b] animate-pulse" />
            <span className="font-semibold text-white tracking-widest">DESPACHO ASEGURADO FEDEX PRIORITY 48H</span>
            <span className="text-neutral-600 hidden sm:inline">•</span>
            <span className="text-neutral-400 hidden sm:inline">Lotes Certificados IFRA / Paris & Dubái</span>
          </div>
          <div className="flex items-center gap-4">
            <span className="text-[#c9a24b] hidden md:inline">
              Precios Escalonados (Pack 6u: -30% • Caja 12u: -45% • Pallet: -55%)
            </span>
            <button
              onClick={onOpenWholesaleModal}
              className="text-white hover:text-[#c9a24b] underline underline-offset-4 transition-colors font-semibold cursor-pointer"
            >
              Tarifas B2B
            </button>
          </div>
        </div>
      </aside>

      {/* 2. Main Sticky Architectural Navbar */}
      <header className="sticky top-0 z-40 bg-[#0B0C10]/95 backdrop-blur-xl border-b border-white/10 transition-colors duration-200">
        <div className="max-w-[1440px] mx-auto px-4 sm:px-8 lg:px-12 h-20 flex items-center justify-between gap-4 sm:gap-6">
          
          {/* Brand Logo Real (LATHE ESSENCE) */}
          <a
            href="#top"
            className="flex items-center gap-3 group flex-shrink-0 text-inherit no-underline"
            aria-label="LATHE ESSENCE Inicio"
          >
            <img
              src="/images/logo/lathe-logo-white.png"
              alt="LATHE ESSENCE"
              className="h-8 sm:h-11 w-auto object-contain transition-transform duration-200 group-hover:scale-[1.03]"
            />
          </a>

          {/* Navigation Links (Desktop) */}
          <nav className="hidden xl:flex items-center gap-8 font-mono text-xs uppercase tracking-widest text-neutral-300">
            <a href="#top" className="hover:text-white transition-colors py-1 border-b border-transparent hover:border-white">
              Inicio
            </a>
            <a href="#pilares" className="hover:text-white transition-colors py-1 border-b border-transparent hover:border-white">
              Pilares
            </a>
            <a href="#catalogo" className="hover:text-white transition-colors py-1 border-b border-transparent hover:border-white">
              Catálogo
            </a>
            <a href="#b2b-matriz" className="hover:text-white transition-colors py-1 border-b border-transparent hover:border-white">
              Tarifas B2B
            </a>
            <button
              onClick={() => setIsQuizOpen(true)}
              className="hover:text-[#c9a24b] transition-colors flex items-center gap-1.5 cursor-pointer py-1"
            >
              <Compass className="w-3.5 h-3.5 text-[#c9a24b]" />
              <span>Oráculo</span>
            </button>
          </nav>

          {/* Central Live Search Bar */}
          <div className="flex-1 max-w-xs md:max-w-sm mx-2 relative hidden md:block">
            <div className="relative flex items-center">
              <Search className="w-3.5 h-3.5 absolute left-3.5 text-neutral-400 pointer-events-none" />
              <input
                ref={searchInputRef}
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Buscar esencia o lote (⌘K)..."
                className="w-full h-10 pl-9 pr-8 bg-[#14161D] border border-white/10 text-white placeholder:text-neutral-500 font-mono text-xs focus:outline-none focus:border-[#c9a24b] transition-colors"
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery('')}
                  className="absolute right-3 p-1 text-neutral-400 hover:text-white"
                  aria-label="Limpiar búsqueda"
                >
                  <X className="w-3 h-3" />
                </button>
              )}
            </div>
          </div>

          {/* Right Action Controls: Pricing Mode Toggle, Currency, Wishlist, Cart */}
          <div className="flex items-center gap-2 sm:gap-3">
            
            {/* Dual Mode Switcher Button (B2C / B2B) */}
            <button
              onClick={handleToggleMode}
              className="hidden sm:flex items-center bg-[#14161D] border border-white/10 px-3 py-1.5 gap-2 hover:border-white/30 transition-all cursor-pointer"
              title="Cambiar modalidad de precios"
            >
              <span className={`font-mono text-[10px] uppercase font-bold tracking-wider ${
                globalPricingMode === 'mayorista' ? 'text-[#c9a24b]' : 'text-neutral-400'
              }`}>
                {globalPricingMode === 'mayorista' ? 'MAYORISTA B2B' : 'MINORISTA'}
              </span>
              <span className="font-mono text-[9px] bg-white/10 px-1.5 py-0.5 text-neutral-300">
                {globalPricingMode === 'mayorista' ? '-35%' : '1u'}
              </span>
            </button>

            {/* B2B Portal Modal Trigger Button */}
            <button
              onClick={onOpenWholesaleModal}
              className="hidden lg:flex items-center gap-1.5 px-3 py-2 bg-white/10 hover:bg-white/20 border border-white/20 text-white font-mono text-xs uppercase tracking-wider transition-colors cursor-pointer"
            >
              <ShieldCheck className="w-3.5 h-3.5 text-[#c9a24b]" />
              <span>Cotizador B2B</span>
            </button>

            {/* Wishlist Button */}
            <button
              onClick={() => setIsWishlistOpen(true)}
              className="p-2.5 text-neutral-300 hover:text-white bg-[#14161D] border border-white/10 relative transition-colors cursor-pointer"
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
              className="p-2.5 bg-white text-black hover:bg-neutral-200 transition-colors relative flex items-center justify-center cursor-pointer shadow-lg active:scale-[0.97]"
              aria-label="Carrito de compras"
            >
              <ShoppingBag className="w-4 h-4" />
              {cartItemsCount > 0 && (
                <span className="absolute -top-1.5 -right-1.5 bg-[#c9a24b] text-black font-mono text-[10px] font-bold px-1.5 py-0.2 shadow-md">
                  {cartItemsCount}
                </span>
              )}
            </button>

          </div>

        </div>
      </header>
    </>
  );
}
