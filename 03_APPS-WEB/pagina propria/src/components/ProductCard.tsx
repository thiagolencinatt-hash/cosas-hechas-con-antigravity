import { useState, useRef, useEffect, MouseEvent } from 'react';
import { Heart, Plus, Minus, ShoppingBag, Eye } from 'lucide-react';
import { Product, PricingMode } from '../types';
import { useShop, WHOLESALE_MIN_UNITS } from '../context/ShopContext';

interface ProductCardProps {
  product: Product;
}

export function ProductCard({ product }: ProductCardProps) {
  const {
    formatPrice,
    addToCart,
    cart,
    updateQuantity,
    wishlist,
    toggleWishlist,
    setSelectedProductForModal,
    globalPricingMode,
  } = useShop();

  // Local card pricing mode (defaults to global, can be toggled locally on each card)
  const [cardMode, setCardMode] = useState<PricingMode>(globalPricingMode);

  // Sync with global mode when user switches mode in navbar
  useEffect(() => {
    setCardMode(globalPricingMode);
  }, [globalPricingMode]);

  // 3D Card Tilt State
  const cardRef = useRef<HTMLDivElement>(null);
  const [tilt, setTilt] = useState({ rotateX: 0, rotateY: 0, scale: 1 });

  const handleMouseMove = (e: MouseEvent<HTMLDivElement>) => {
    if (!cardRef.current) return;
    const rect = cardRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    const centerX = rect.width / 2;
    const centerY = rect.height / 2;

    // Subtle 3D tilt angles max 5 degrees
    const rotateX = -((y - centerY) / centerY) * 4.5;
    const rotateY = ((x - centerX) / centerX) * 4.5;

    setTilt({ rotateX, rotateY, scale: 1.01 });
  };

  const handleMouseLeave = () => {
    setTilt({ rotateX: 0, rotateY: 0, scale: 1 });
  };

  const isLiked = wishlist.includes(String(product.id));

  // Current price according to cardMode
  const activePrice = cardMode === 'mayorista' ? product.price : product.retailPrice;

  // Cart item matching this product and mode
  const cartItemId = `prod-${product.id}-${cardMode}`;
  const cartItem = cart.find((i) => i.id === cartItemId);
  const quantityInCart = cartItem ? cartItem.quantity : 0;

  const handleAddToCart = () => {
    const initialQty = cardMode === 'mayorista' ? WHOLESALE_MIN_UNITS : 1;
    addToCart(product, initialQty, cardMode);
  };

  return (
    <div
      ref={cardRef}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      style={{
        transform: `perspective(1000px) rotateX(${tilt.rotateX}deg) rotateY(${tilt.rotateY}deg) scale3d(${tilt.scale}, ${tilt.scale}, ${tilt.scale})`,
        transition: tilt.scale === 1 ? 'transform 0.4s cubic-bezier(0.16, 1, 0.3, 1)' : 'none',
        transformStyle: 'preserve-3d',
      }}
      className="group relative flex flex-col rounded-3xl p-3 sm:p-4 bg-neutral-50 dark:bg-[#0c0c0c] border border-black/[0.08] dark:border-white/[0.08] hover:border-black/20 dark:hover:border-white/20 shadow-sm hover:shadow-xl transition-colors duration-300 will-change-transform"
    >
      {/* Top Image Container with 3D Pop Layer */}
      <div
        style={{ transform: 'translateZ(15px)' }}
        className="relative aspect-square w-full rounded-2xl overflow-hidden bg-white dark:bg-[#141414] p-3 sm:p-4 flex items-center justify-center cursor-pointer select-none border border-black/5 dark:border-white/5 transition-transform"
        onClick={() => setSelectedProductForModal(product)}
      >
        {/* Category Pill */}
        <span className="absolute top-2.5 left-2.5 z-10 px-2 py-0.5 rounded-full bg-black/60 dark:bg-black/80 backdrop-blur-md text-white font-sans text-[10px] font-medium tracking-wide uppercase border border-white/10">
          {product.category}
        </span>

        {/* Wishlist Heart Icon */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            toggleWishlist(product.id);
          }}
          className={`absolute top-2.5 right-2.5 z-10 w-8 h-8 rounded-full flex items-center justify-center backdrop-blur-md transition-[color,background-color,border-color,transform] duration-150 ease-out active:scale-[0.97] cursor-pointer ${
            isLiked
              ? 'bg-neutral-900 text-red-500 border border-red-500/30'
              : 'bg-black/20 dark:bg-black/40 text-neutral-700 dark:text-neutral-300 hover:text-white hover:bg-black/60'
          }`}
          aria-label={isLiked ? 'Quitar de favoritos' : 'Añadir a favoritos'}
        >
          <Heart className={`w-3.5 h-3.5 ${isLiked ? 'fill-red-500 text-red-500' : ''}`} />
        </button>

        {/* Perfume Bottle Real Image */}
        <img
          src={product.image}
          alt={product.name}
          loading="lazy"
          decoding="async"
          className="w-full h-full object-contain transition-transform duration-500 group-hover:scale-105"
          onError={(e) => {
            (e.target as HTMLElement).style.opacity = '0.7';
          }}
        />

        {/* Hover Quick View Overlay Hint */}
        <div className="absolute inset-0 bg-black/30 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center pointer-events-none">
          <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white text-black text-[11px] font-sans font-semibold shadow-lg">
            <Eye className="w-3.5 h-3.5" />
            <span>Ficha técnica</span>
          </span>
        </div>
      </div>

      {/* Card Body */}
      <div className="flex flex-col flex-1 pt-3" style={{ transform: 'translateZ(10px)' }}>
        {/* Brand & Gender */}
        <div className="flex items-center justify-between gap-2 mb-1">
          <span className="text-[11px] font-sans font-semibold tracking-wider uppercase text-neutral-500 dark:text-neutral-400">
            {product.brand}
          </span>
          <span className="text-[10px] font-sans px-2 py-0.5 rounded-full bg-black/5 dark:bg-white/[0.08] text-neutral-600 dark:text-neutral-400 font-medium">
            {product.gender}
          </span>
        </div>

        {/* Perfume Name */}
        <h3
          onClick={() => setSelectedProductForModal(product)}
          className="font-sans font-semibold text-sm sm:text-base text-neutral-900 dark:text-white line-clamp-1 cursor-pointer group-hover:opacity-80 transition-opacity"
          title={product.name}
        >
          {product.name}
        </h3>

        {/* Size / Specs */}
        <p className="text-[11px] font-sans text-neutral-500 dark:text-neutral-400 mb-2.5 font-normal">
          {product.size || '100ml'} • {product.concentration || 'Eau de Parfum'}
        </p>

        {/* Mode Selector (Minorista vs Mayorista) */}
        <div className="grid grid-cols-2 gap-1 p-0.5 rounded-xl bg-neutral-200/70 dark:bg-white/[0.06] border border-black/5 dark:border-white/5 mb-3 select-none">
          <button
            type="button"
            onClick={() => setCardMode('minorista')}
            className={`py-1 text-[10px] font-sans font-medium rounded-lg transition-colors duration-150 ease-out active:scale-[0.97] cursor-pointer text-center ${
              cardMode === 'minorista'
                ? 'bg-white text-black dark:bg-black dark:text-white font-semibold shadow-sm'
                : 'text-neutral-500 dark:text-neutral-400 hover:text-black dark:hover:text-white'
            }`}
          >
            Minorista (1u)
          </button>
          <button
            type="button"
            onClick={() => setCardMode('mayorista')}
            className={`py-1 text-[10px] font-sans font-medium rounded-lg transition-colors duration-150 ease-out active:scale-[0.97] cursor-pointer text-center ${
              cardMode === 'mayorista'
                ? 'bg-black text-white dark:bg-white dark:text-black font-semibold shadow-sm'
                : 'text-neutral-500 dark:text-neutral-400 hover:text-black dark:hover:text-white'
            }`}
          >
            Mayorista (mín 3u)
          </button>
        </div>

        {/* Price Display */}
        <div className="mt-auto pt-2 border-t border-black/5 dark:border-white/5 flex items-baseline justify-between mb-3">
          <div>
            <span className="font-sans text-lg sm:text-xl font-bold tabular-nums text-neutral-900 dark:text-white">
              {formatPrice(activePrice)}
            </span>
            <span className="block text-[10px] font-sans text-neutral-400 dark:text-neutral-500">
              {cardMode === 'mayorista' ? 'por unidad (mín. 3u)' : 'precio final por unidad'}
            </span>
          </div>

          {cardMode === 'mayorista' && (
            <span className="text-[10px] font-sans font-medium px-2 py-0.5 rounded-full bg-neutral-200 dark:bg-white/10 text-neutral-700 dark:text-neutral-300">
              Ahorrás 35%
            </span>
          )}
        </div>

        {/* Actions: Stepper or Add Button */}
        <div>
          {quantityInCart > 0 ? (
            <div className="flex items-center justify-between w-full h-9 rounded-full bg-neutral-200 dark:bg-white/10 p-1">
              <button
                onClick={() => updateQuantity(cartItemId, -1)}
                className="w-7 h-7 rounded-full bg-white dark:bg-neutral-800 text-black dark:text-white flex items-center justify-center font-bold active:scale-[0.97] transition-transform duration-150 ease-out cursor-pointer shadow-sm"
                aria-label="Disminuir cantidad"
              >
                <Minus className="w-3.5 h-3.5" />
              </button>
              <span className="font-sans font-bold text-xs text-neutral-900 dark:text-white">
                {quantityInCart} en pedido
              </span>
              <button
                onClick={() => updateQuantity(cartItemId, 1)}
                className="w-7 h-7 rounded-full bg-white dark:bg-neutral-800 text-black dark:text-white flex items-center justify-center font-bold active:scale-[0.97] transition-transform duration-150 ease-out cursor-pointer shadow-sm"
                aria-label="Aumentar cantidad"
              >
                <Plus className="w-3.5 h-3.5" />
              </button>
            </div>
          ) : (
            <button
              onClick={handleAddToCart}
              className="w-full h-9 rounded-full bg-black text-white dark:bg-white dark:text-black hover:opacity-90 font-sans font-semibold text-xs flex items-center justify-center gap-1.5 active:scale-[0.97] transition-[opacity,transform] duration-150 ease-out cursor-pointer shadow-sm"
            >
              <ShoppingBag className="w-3.5 h-3.5" />
              <span>
                {cardMode === 'mayorista' ? 'Añadir Mayorista (3u)' : 'Añadir Minorista (1u)'}
              </span>
            </button>
          )}
        </div>

      </div>
    </div>
  );
}
