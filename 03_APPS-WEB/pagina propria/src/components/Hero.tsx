import { useState, useEffect } from 'react';
import { ArrowLeft, ArrowRight, ShoppingBag, Eye, Sparkles } from 'lucide-react';
import { FEATURED_PRODUCTS } from '../data/products';
import { useShop } from '../context/ShopContext';

export function Hero() {
  const { formatPrice, addToCart, setSelectedProductForModal, globalPricingMode } = useShop();
  const [currentIndex, setCurrentIndex] = useState(0);

  const featured = FEATURED_PRODUCTS.length > 0 ? FEATURED_PRODUCTS : [];
  const current = featured[currentIndex];

  const prevSlide = () => {
    setCurrentIndex((prev) => (prev === 0 ? featured.length - 1 : prev - 1));
  };

  const nextSlide = () => {
    setCurrentIndex((prev) => (prev === featured.length - 1 ? 0 : prev + 1));
  };

  // Auto-advance every 6.5 seconds
  useEffect(() => {
    if (featured.length <= 1) return;
    const timer = setInterval(() => {
      nextSlide();
    }, 6500);
    return () => clearInterval(timer);
  }, [currentIndex, featured.length]);

  if (!current) return null;

  const currentPrice = globalPricingMode === 'mayorista' ? current.price : current.retailPrice;

  return (
    <section className="relative overflow-hidden border-b border-black/[0.08] dark:border-white/[0.08] bg-white dark:bg-[#000000] py-8 sm:py-16 transition-colors duration-200">
      {/* Background ambient clean silver/light aura */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[350px] sm:w-[600px] h-[350px] sm:h-[600px] bg-black/[0.02] dark:bg-white/[0.04] rounded-full blur-[120px] pointer-events-none" />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 sm:gap-12 items-center min-h-[460px] sm:min-h-[520px]">
          
          {/* Left Column: Copy & Details */}
          <div className="lg:col-span-7 flex flex-col justify-center order-2 lg:order-1 text-center lg:text-left">
            <div className="inline-flex items-center justify-center lg:justify-start gap-2 mb-3">
              <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-black/5 dark:bg-white/10 border border-black/10 dark:border-white/15 text-neutral-800 dark:text-neutral-200 text-[11px] font-sans font-semibold tracking-wider uppercase">
                <Sparkles className="w-3 h-3 text-neutral-700 dark:text-neutral-300" />
                <span>Perfume Destacado</span>
              </span>
              <span className="text-xs font-sans text-neutral-500 dark:text-neutral-400">
                {current.gender} • {current.category}
              </span>
            </div>

            <h1 className="font-sans text-3xl sm:text-5xl lg:text-6xl font-semibold tracking-tight text-neutral-900 dark:text-white leading-[1.05] mb-2">
              {current.name}
            </h1>

            <p className="font-sans text-base sm:text-lg text-neutral-500 dark:text-neutral-400 font-semibold uppercase tracking-widest mb-3">
              {current.brand}
            </p>

            <p className="font-sans text-sm sm:text-base text-neutral-600 dark:text-neutral-300 max-w-xl mx-auto lg:mx-0 line-clamp-3 mb-6 font-normal leading-relaxed">
              {current.description}
            </p>

            {/* Price Display */}
            <div className="flex flex-wrap items-baseline justify-center lg:justify-start gap-3 mb-8">
              <span className="font-sans text-3xl sm:text-4xl font-bold tabular-nums text-neutral-900 dark:text-white">
                {formatPrice(currentPrice)}
              </span>
              <span className="text-xs sm:text-sm font-sans text-neutral-500 dark:text-neutral-400">
                {globalPricingMode === 'mayorista'
                  ? 'por unidad mayorista (mín. 3u)'
                  : 'precio final minorista'}
              </span>
              {globalPricingMode === 'mayorista' && (
                <span className="text-xs font-sans px-2.5 py-0.5 rounded-full bg-black/5 dark:bg-white/10 text-neutral-700 dark:text-neutral-300 font-semibold">
                  Ahorro mayorista 35%
                </span>
              )}
            </div>

            {/* CTAs */}
            <div className="flex flex-wrap items-center justify-center lg:justify-start gap-3 sm:gap-4">
              <button
                onClick={() => addToCart(current)}
                className="flex items-center justify-center gap-2 px-7 py-3.5 rounded-full bg-black text-white dark:bg-white dark:text-black hover:opacity-90 font-sans font-semibold text-sm tracking-wide transition-all duration-200 active:scale-95 shadow-md"
              >
                <ShoppingBag className="w-4 h-4" />
                <span>
                  {globalPricingMode === 'mayorista'
                    ? 'Añadir Mayorista (3u)'
                    : 'Añadir Minorista (1u)'}
                </span>
              </button>

              <button
                onClick={() => setSelectedProductForModal(current)}
                className="flex items-center justify-center gap-2 px-6 py-3.5 rounded-full border border-black/15 dark:border-white/20 hover:border-black/40 dark:hover:border-white/50 text-neutral-800 dark:text-neutral-200 font-sans font-medium text-sm transition-all duration-200 active:scale-95"
              >
                <Eye className="w-4 h-4" />
                <span>Ver ficha técnica</span>
              </button>
            </div>
          </div>

          {/* Right Column: Clean Bottle Presentation */}
          <div className="lg:col-span-5 flex items-center justify-center order-1 lg:order-2">
            <div className="relative group cursor-pointer" onClick={() => setSelectedProductForModal(current)}>
              {/* Subtle Halo */}
              <div className="absolute inset-0 -m-6 sm:-m-10 rounded-full border border-black/5 dark:border-white/10 pointer-events-none" />
              <div className="absolute inset-0 -m-2 sm:-m-4 rounded-full bg-gradient-to-tr from-white/[0.04] via-transparent to-transparent pointer-events-none" />

              <div className="relative w-64 h-64 sm:w-80 sm:h-80 md:w-96 md:h-96 rounded-3xl overflow-hidden border border-black/10 dark:border-white/10 bg-neutral-100 dark:bg-[#0f0f0f] shadow-2xl p-6 flex items-center justify-center">
                <img
                  src={current.image}
                  alt={current.name}
                  className="w-full h-full object-contain transition-transform duration-500 group-hover:scale-105"
                  onError={(e) => {
                    (e.target as HTMLElement).style.display = 'none';
                  }}
                />
              </div>

              {/* Tag pill */}
              {current.tag && (
                <div className="absolute top-4 left-4 px-3 py-1 rounded-full bg-black/80 dark:bg-white/10 backdrop-blur-md border border-black/10 dark:border-white/20 text-white text-[11px] font-sans font-medium flex items-center gap-1.5 shadow-lg">
                  <Sparkles className="w-3 h-3 text-neutral-300" />
                  <span>{current.tag}</span>
                </div>
              )}
            </div>
          </div>

        </div>

        {/* Carousel Controls */}
        <div className="flex items-center justify-between pt-8 border-t border-black/5 dark:border-white/5 mt-8">
          <div className="flex items-center gap-2">
            <button
              onClick={prevSlide}
              className="w-10 h-10 rounded-full border border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30 text-neutral-700 dark:text-neutral-200 flex items-center justify-center transition-all active:scale-95"
              aria-label="Perfume anterior"
            >
              <ArrowLeft className="w-4 h-4" />
            </button>
            <button
              onClick={nextSlide}
              className="w-10 h-10 rounded-full border border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30 text-neutral-700 dark:text-neutral-200 flex items-center justify-center transition-all active:scale-95"
              aria-label="Perfume siguiente"
            >
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>

          {/* Dots Indicator */}
          <div className="flex items-center gap-2">
            {featured.map((_, idx) => (
              <button
                key={idx}
                onClick={() => setCurrentIndex(idx)}
                className={`h-1.5 rounded-full transition-all duration-300 ${
                  currentIndex === idx ? 'w-8 bg-black dark:bg-white' : 'w-2 bg-neutral-300 dark:bg-white/20'
                }`}
                aria-label={`Ir a slide ${idx + 1}`}
              />
            ))}
          </div>
        </div>

      </div>
    </section>
  );
}
