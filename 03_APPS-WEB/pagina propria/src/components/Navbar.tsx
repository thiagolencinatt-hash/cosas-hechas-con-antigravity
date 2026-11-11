import { useState, useRef, useEffect } from 'react';
import { Search, ShoppingBag, Heart, X, Compass, ArrowRight } from 'lucide-react';
import { useShop } from '../context/ShopContext';

interface NavbarProps {
  onOpenWholesaleModal?: () => void;
}

export function Navbar({ onOpenWholesaleModal }: NavbarProps) {
  const {
    cartItemsCount,
    setIsCartOpen,
    wishlist,
    setIsWishlistOpen,
    setIsQuizOpen,
    searchQuery,
    setSearchQuery,
    filteredProducts,
  } = useShop();

  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const searchInputRef = useRef<HTMLInputElement>(null);

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

      {/* 2. Main Sticky Architectural Navbar (Minimalist Luxury) */}
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
          <nav className="hidden lg:flex items-center gap-8 font-mono text-xs uppercase tracking-widest text-neutral-300">
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

          {/* Right Action Controls: Lupa Search, Wishlist, Cart */}
          <div className="flex items-center gap-2 sm:gap-3">
            
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
                  ? 'bg-white text-black border-white shadow-md'
                  : 'bg-[#14161D] border-white/10 text-neutral-300 hover:text-white hover:border-white/30'
              }`}
              aria-label="Buscar perfume (Lupa)"
              title="Buscar perfume (⌘K)"
            >
              <Search className="w-4 h-4" />
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

        {/* 3. Luxury Slide-Down Search Drawer (Triggered by Lupa) */}
        {isSearchOpen && (
          <div className="w-full bg-[#12141A] border-t border-white/10 border-b border-white/15 px-4 sm:px-8 lg:px-12 py-3.5 animate-fade-in shadow-2xl transition-all">
            <div className="max-w-[1440px] mx-auto flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
              <form onSubmit={handleSearchSubmit} className="flex-1 flex items-center gap-3 bg-[#0B0C10] border border-white/15 px-4 py-2">
                <Search className="w-4 h-4 text-[#c9a24b] shrink-0" />
                <input
                  ref={searchInputRef}
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Buscar por nombre, nota (ej. Vainilla, Oud, Ámbar) o marca (ej. Lattafa, Tom Ford)..."
                  className="w-full bg-transparent text-white placeholder:text-neutral-500 font-sans text-xs sm:text-sm focus:outline-none"
                  autoFocus
                />
                {searchQuery && (
                  <button
                    type="button"
                    onClick={() => setSearchQuery('')}
                    className="p-1 text-neutral-400 hover:text-white"
                    aria-label="Borrar búsqueda"
                  >
                    <X className="w-3.5 h-3.5" />
                  </button>
                )}
              </form>

              <div className="flex items-center gap-2 justify-end">
                <span className="text-[11px] font-mono text-neutral-400">
                  {filteredProducts.length} fragancia{filteredProducts.length === 1 ? '' : 's'}
                </span>

                <button
                  onClick={() => handleSearchSubmit()}
                  className="px-4 py-2 bg-white text-black font-mono text-xs uppercase font-semibold hover:bg-neutral-200 transition-colors flex items-center gap-1.5 cursor-pointer"
                >
                  <span>Explorar</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </button>

                <button
                  onClick={() => setIsSearchOpen(false)}
                  className="p-2 text-neutral-400 hover:text-white transition-colors cursor-pointer"
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
