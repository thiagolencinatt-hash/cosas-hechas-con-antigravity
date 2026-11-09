import { Sparkles, ShoppingBag, ArrowRight, CheckCircle2, Zap } from 'lucide-react';
import { useShop } from '../context/ShopContext';
import { useReveal } from '../hooks/useReveal';

export function PromoSection() {
  const { formatPrice } = useShop();
  const { ref: sectionRef, visible: sectionVisible } = useReveal(0.15);

  return (
    <section id="promo" className="py-20 sm:py-28 bg-white dark:bg-[#0D0D0D] border-y border-neutral-200 dark:border-white/[0.06] relative overflow-hidden transition-colors duration-300">
      {/* Background ambient glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[300px] bg-amber-500/[0.03] rounded-full blur-[120px] pointer-events-none" />

      <div
        ref={sectionRef as React.RefObject<HTMLDivElement>}
        className={`max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 reveal ${sectionVisible ? 'visible' : ''}`}
      >
        <div className="rounded-2xl bg-neutral-50 dark:bg-gradient-to-b dark:from-[#141414] dark:to-[#0A0A0A] border border-neutral-200 dark:border-white/[0.1] p-8 sm:p-12 lg:p-16 shadow-sm dark:shadow-2xl relative overflow-hidden">
          {/* Corner badge */}
          <div className="absolute top-0 right-0 bg-black dark:bg-white text-white dark:text-black font-sans text-[10px] sm:text-xs font-bold tracking-[0.25em] uppercase px-6 py-2 rounded-bl-xl shadow-md flex items-center gap-1.5">
            <Zap className="w-3.5 h-3.5 fill-current" />
            PROMO EXCLUSIVA
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 items-center">
            {/* Left Column: Big Offer Headline */}
            <div className="lg:col-span-7 space-y-6">
              <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-white dark:bg-white/[0.05] border border-neutral-200 dark:border-white/10 text-neutral-800 dark:text-neutral-300 text-[11px] font-sans tracking-widest uppercase shadow-sm">
                <Sparkles className="w-3.5 h-3.5 text-amber-500 dark:text-amber-300" />
                <span>LATHE ESSENCE · Oferta Especial</span>
              </div>

              <h2 className="font-sans text-3xl sm:text-5xl lg:text-6xl font-light text-neutral-950 dark:text-white tracking-tight uppercase leading-[1.1]">
                Llevate <span className="font-semibold text-neutral-950 dark:text-white">3 Perfumes</span>
                <br />
                por solo <span className="font-mono font-bold text-neutral-950 dark:text-white tracking-normal">{formatPrice(10000)}</span>
              </h2>

              <p className="text-neutral-600 dark:text-neutral-400 text-sm sm:text-base leading-relaxed font-light max-w-xl">
                Elegí tus 3 fragancias favoritas de 35ml de nuestro catálogo exclusivo en stock. Precio regular individual: <span className="text-black dark:text-white font-medium">{formatPrice(4000)}</span> cada una.
              </p>

              {/* Benefits list */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-2">
                <div className="p-3.5 rounded-lg bg-white dark:bg-white/[0.03] border border-neutral-200 dark:border-white/[0.06] shadow-sm">
                  <div className="text-neutral-950 dark:text-white font-semibold text-xs font-sans">Ahorrás {formatPrice(2000)}</div>
                  <div className="text-neutral-500 text-[11px] mt-0.5">Descuento automático en carrito</div>
                </div>
                <div className="p-3.5 rounded-lg bg-white dark:bg-white/[0.03] border border-neutral-200 dark:border-white/[0.06] shadow-sm">
                  <div className="text-neutral-950 dark:text-white font-semibold text-xs font-sans">Combinables 100%</div>
                  <div className="text-neutral-500 text-[11px] mt-0.5">Cualquiera de los 16 perfumes</div>
                </div>
                <div className="p-3.5 rounded-lg bg-white dark:bg-white/[0.03] border border-neutral-200 dark:border-white/[0.06] shadow-sm">
                  <div className="text-neutral-950 dark:text-white font-semibold text-xs font-sans">Envíos a Todo el País</div>
                  <div className="text-neutral-500 text-[11px] mt-0.5">Embalaje protegido y seguro</div>
                </div>
              </div>

              {/* Call to Action Button */}
              <div className="pt-4 flex flex-col sm:flex-row items-stretch sm:items-center gap-4">
                <a
                  href="#catalogo"
                  className="px-8 py-4 bg-black dark:bg-white text-white dark:text-black hover:bg-neutral-800 dark:hover:bg-neutral-100 font-sans text-xs uppercase tracking-[0.2em] font-semibold transition-all duration-200 active:scale-[0.98] inline-flex items-center justify-center gap-3 rounded-md shadow-md"
                >
                  <ShoppingBag className="w-4 h-4" />
                  Armar mi Trío en el Catálogo
                  <ArrowRight className="w-4 h-4" />
                </a>

                <span className="text-neutral-500 text-xs font-sans text-center sm:text-left">
                  Agregá 3 unidades al carrito y el descuento se aplica solo.
                </span>
              </div>
            </div>

            {/* Right Column: Visual Trío Showcase */}
            <div className="lg:col-span-5 flex flex-col items-center justify-center">
              <div className="w-full max-w-sm rounded-xl bg-white dark:bg-[#161616] border border-neutral-200 dark:border-white/[0.08] p-6 text-center space-y-5 shadow-sm dark:shadow-inner">
                <div className="text-[11px] font-sans uppercase tracking-[0.25em] text-neutral-600 dark:text-neutral-400 font-semibold">
                  Resumen de la Promoción
                </div>

                <div className="flex items-center justify-center gap-2 py-4 border-y border-neutral-200 dark:border-white/[0.06]">
                  <div className="flex-1 p-3 rounded-md bg-neutral-50 dark:bg-[#1F1F1F] border border-neutral-200 dark:border-white/[0.06]">
                    <div className="text-[10px] text-neutral-500 uppercase tracking-wider">1 Perfume</div>
                    <div className="text-sm font-mono font-bold text-neutral-900 dark:text-white mt-1">{formatPrice(4000)}</div>
                  </div>
                  <span className="text-neutral-400 font-light">+</span>
                  <div className="flex-1 p-3 rounded-md bg-neutral-50 dark:bg-[#1F1F1F] border border-neutral-200 dark:border-white/[0.06]">
                    <div className="text-[10px] text-neutral-500 uppercase tracking-wider">2 Perfumes</div>
                    <div className="text-sm font-mono font-bold text-neutral-900 dark:text-white mt-1">{formatPrice(8000)}</div>
                  </div>
                  <span className="text-neutral-400 font-light">=</span>
                  <div className="flex-1 p-3 rounded-md bg-black dark:bg-white text-white dark:text-black shadow-md border border-black dark:border-white">
                    <div className="text-[9px] uppercase tracking-wider font-bold">3 Perfumes</div>
                    <div className="text-sm font-mono font-bold mt-1">{formatPrice(10000)}</div>
                  </div>
                </div>

                <div className="text-xs text-neutral-600 dark:text-neutral-400 font-medium flex items-center justify-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 dark:text-emerald-400 flex-shrink-0" />
                  <span>Sin límites: comprás 6 y pagás {formatPrice(20000)}</span>
                </div>

                <p className="text-[11px] text-neutral-500 leading-normal pt-1 font-light">
                  Podés mezclar fragancias masculinas, femeninas y unisex en un mismo pedido.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
