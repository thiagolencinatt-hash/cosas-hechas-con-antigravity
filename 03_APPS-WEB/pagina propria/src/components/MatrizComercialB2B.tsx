import { useState, useRef, MouseEvent } from 'react';
import {
  Sparkles,
  Truck,
  HeartHandshake,
  PackageCheck,
  ShoppingBag,
  ArrowRight,
  MessageCircle,
  TrendingUp,
  Layers,
} from 'lucide-react';
import { useShop, DEFAULT_WHATSAPP_NUMBER } from '../context/ShopContext';
import { Product } from '../types';

interface MatrizComercialProps {
  onOpenWholesaleModal?: () => void;
}

// 3D Tilt Card Component (Interactive GPU Accelerated with Emil Kowalski spring easing)
function Interactive3DCard({
  children,
  className = '',
  highlighted = false,
}: {
  children: React.ReactNode;
  className?: string;
  highlighted?: boolean;
}) {
  const cardRef = useRef<HTMLDivElement>(null);
  const [tilt, setTilt] = useState({ rotateX: 0, rotateY: 0, scale: 1 });

  const handleMouseMove = (e: MouseEvent<HTMLDivElement>) => {
    if (!cardRef.current) return;
    const rect = cardRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    const centerX = rect.width / 2;
    const centerY = rect.height / 2;

    const rotateX = -((y - centerY) / centerY) * 5;
    const rotateY = ((x - centerX) / centerX) * 5;

    setTilt({ rotateX, rotateY, scale: 1.02 });
  };

  const handleMouseLeave = () => {
    setTilt({ rotateX: 0, rotateY: 0, scale: 1 });
  };

  return (
    <div
      ref={cardRef}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      style={{
        transform: `perspective(1000px) rotateX(${tilt.rotateX}deg) rotateY(${tilt.rotateY}deg) scale3d(${tilt.scale}, ${tilt.scale}, ${tilt.scale})`,
        transition: 'transform 200ms cubic-bezier(0.16, 1, 0.3, 1), box-shadow 200ms ease',
      }}
      className={`relative rounded-none p-6 sm:p-7 flex flex-col justify-between transition-[background-color,border-color] duration-200 select-none ${
        highlighted
          ? 'bg-neutral-900 dark:bg-[#151821] border-2 border-[#c9a24b] shadow-[0_20px_50px_rgba(201,162,75,0.15)]'
          : 'bg-white dark:bg-[#12141A] border border-black/10 dark:border-white/10 hover:border-black/25 dark:hover:border-white/25 shadow-xl'
      } ${className}`}
    >
      {children}
    </div>
  );
}

export function MatrizComercialB2B({ onOpenWholesaleModal }: MatrizComercialProps) {
  const { setGlobalPricingMode, addToCart, setIsCartOpen, showToast } = useShop();

  // Tubos Discovery Product
  const discoverySetProduct: Product = {
    id: 9999,
    name: 'Caja 20 Perfumes en Tubo (20x35ml a Elección)',
    brand: 'LATHE ESSENCE',
    gender: 'unisex',
    category: 'Tubos 35ml',
    price: 43000,
    retailPrice: 48000,
    image: '/images/tubos/caja-tubos-set-a.jpg',
    inStock: true,
    rating: 5,
    reviewsCount: 42,
    description:
      'Caja con 20 frascos tubulares de 35ml atomizadores spray. Fragancias 100% a tu elección y armadas por nosotros. Prácticos para llevar en el bolso, en el auto y retocar en cualquier momento. $48.000 la unidad o $43.000 c/u llevando 3 o más cajas.',
    isFeatured: true,
  };

  const handleAddDiscoverySet = () => {
    addToCart(discoverySetProduct, 1, 'minorista');
    setIsCartOpen(true);
    showToast('Caja de 20 Perfumes en Tubo (35ml) añadida al pedido ($ 48.000 ARS).');
  };

  const handleStartEmprendedor = () => {
    setGlobalPricingMode('mayorista');
    showToast('¡Modalidad Combo Emprendedor activada! Elegí mínimo 3 perfumes en el catálogo.');
    const catEl = document.getElementById('catalogo');
    if (catEl) catEl.scrollIntoView({ behavior: 'smooth' });
  };

  const handleContactWhatsApp = (tema: string) => {
    const text = encodeURIComponent(
      `Hola! Vengo de la web de LATHE ESSENCE. Me interesa consultar sobre: ${tema}. ¿Me podrían brindar más información?`
    );
    window.open(`https://wa.me/${DEFAULT_WHATSAPP_NUMBER}?text=${text}`, '_blank');
  };

  return (
    <section
      id="b2b-matriz"
      className="w-full bg-neutral-100 dark:bg-[#0E1015] text-neutral-900 dark:text-white py-20 sm:py-28 border-b border-black/10 dark:border-white/10 relative transition-colors duration-200"
    >
      <div className="max-w-[1440px] mx-auto px-4 sm:px-8 lg:px-12">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 lg:gap-14 items-start">
          
          {/* Left Column: Real Business Story (Couple Founders, Vision & Scalability) */}
          <div className="lg:col-span-5 flex flex-col gap-6">
            <div>
              <div className="inline-flex items-center gap-2 font-mono text-[11px] text-[#c9a24b] uppercase tracking-[0.25em] mb-3">
                <HeartHandshake className="w-4 h-4" />
                <span>NUESTRA HISTORIA & VISIÓN // LATHE ESSENCE</span>
              </div>
              <h2 className="font-sans text-3xl sm:text-4xl lg:text-5xl font-bold tracking-tight text-neutral-900 dark:text-white leading-[1.15]">
                Un Negocio de Pareja con Ambición de Escala Nacional
              </h2>
            </div>

            <p className="font-sans text-neutral-600 dark:text-neutral-300 text-sm sm:text-base font-normal leading-relaxed">
              Somos un proyecto fundado por una pareja apasionada por la perfumería internacional con una meta clara: 
              <strong> escalar y profesionalizar la distribución de alta perfumería en toda la Argentina</strong>. 
              Seleccionamos e importamos directamente fragancias de autor, árabes y diseñador, eliminando intermediarios 
              para brindarte la mayor calidad al precio más competitivo del mercado.
            </p>

            <p className="font-sans text-neutral-600 dark:text-neutral-400 text-xs sm:text-sm font-normal leading-relaxed">
              Tanto si buscás tu fragancia personal como si querés iniciar o hacer crecer tu propio negocio de reventa, 
              acá podés armar <strong>pedidos 100% personalizados a tu gusto</strong>, combinar marcas en combos emprendedores y recibir todo con envíos protegidos a cualquier rincón del país.
            </p>

            {/* Core Value Pillars */}
            <div className="flex flex-col gap-3.5 pt-2">
              <div className="flex items-start gap-3 text-xs sm:text-sm text-neutral-700 dark:text-neutral-200 font-sans">
                <PackageCheck className="w-4 h-4 text-[#c9a24b] shrink-0 mt-0.5" />
                <span>
                  <strong>Pedidos 100% Personalizados:</strong> Vos elegís cada frasco y marca a tu medida, sin cajas cerradas obligatorias.
                </span>
              </div>
              <div className="flex items-start gap-3 text-xs sm:text-sm text-neutral-700 dark:text-neutral-200 font-sans">
                <TrendingUp className="w-4 h-4 text-[#c9a24b] shrink-0 mt-0.5" />
                <span>
                  <strong>Combos Emprendedores desde 3u:</strong> Tarifas mayoristas escalonadas pensadas para que arranques con margen real de ganancia.
                </span>
              </div>
              <div className="flex items-start gap-3 text-xs sm:text-sm text-neutral-700 dark:text-neutral-200 font-sans">
                <Truck className="w-4 h-4 text-[#c9a24b] shrink-0 mt-0.5" />
                <span>
                  <strong>Envíos Asegurados a Todo el País:</strong> Despachos diarios con seguimiento puerta a puerta vía Correo y expresos.
                </span>
              </div>
            </div>

            {/* Direct Action Buttons */}
            <div className="pt-2 flex flex-wrap items-center gap-3">
              <button
                onClick={handleStartEmprendedor}
                className="px-6 py-3.5 bg-black dark:bg-white text-white dark:text-black font-sans text-xs uppercase font-semibold tracking-wider hover:opacity-90 transition-opacity flex items-center gap-2 cursor-pointer shadow-lg active:scale-[0.97]"
              >
                <span>Armar Pedido Personalizado</span>
                <ArrowRight className="w-4 h-4" />
              </button>

              <button
                onClick={() => handleContactWhatsApp('Asesoramiento con los Fundadores')}
                className="px-5 py-3.5 bg-white dark:bg-[#1A1D24] text-neutral-800 dark:text-white border border-black/10 dark:border-white/15 hover:border-black/30 dark:hover:border-white/30 font-sans text-xs font-semibold tracking-wide transition-colors flex items-center gap-2 cursor-pointer shadow-md active:scale-[0.97]"
              >
                <MessageCircle className="w-4 h-4 text-emerald-500" />
                <span>Hablar con Nosotros</span>
              </button>
            </div>
          </div>

          {/* Right Column: 3 High-End 3D Cards */}
          <div className="lg:col-span-7 grid grid-cols-1 md:grid-cols-3 gap-5">
            
            {/* Card 1: Perfumes en Tubos (Discovery Sets) */}
            <Interactive3DCard className="border border-black/10 dark:border-white/10">
              <div>
                <span className="font-mono text-[9px] bg-[#c9a24b]/15 text-[#c9a24b] px-2 py-0.5 uppercase tracking-widest font-semibold inline-block mb-3">
                  FORMATO MÁS PEDIDO
                </span>
                
                <div className="flex items-center gap-2 mb-1 text-neutral-900 dark:text-white">
                  <Layers className="w-4 h-4 text-[#c9a24b]" />
                  <h3 className="font-sans text-lg sm:text-xl font-bold tracking-tight">
                    Caja 20 Tubos (35ml)
                  </h3>
                </div>

                <p className="font-sans text-xs text-neutral-600 dark:text-neutral-400 mt-1 leading-relaxed">
                  Caja de <strong>20 perfumes en tubo de 35ml</strong> con atomizador spray. Fragancias a elección y las armamos nosotros a tu gusto.
                </p>

                {/* Practicality badges */}
                <div className="mt-3 flex flex-wrap gap-1.5 text-[10px] font-sans text-neutral-600 dark:text-neutral-300">
                  <span className="inline-flex items-center gap-1 bg-black/5 dark:bg-white/5 border border-black/5 dark:border-white/10 px-2 py-0.5">
                    👜 Para el bolso o mochila
                  </span>
                  <span className="inline-flex items-center gap-1 bg-black/5 dark:bg-white/5 border border-black/5 dark:border-white/10 px-2 py-0.5">
                    🚗 En el auto
                  </span>
                  <span className="inline-flex items-center gap-1 bg-black/5 dark:bg-white/5 border border-black/5 dark:border-white/10 px-2 py-0.5">
                    ✨ Ultra prácticos
                  </span>
                </div>
              </div>

              <div className="flex flex-col gap-3 pt-5 mt-4 border-t border-black/10 dark:border-white/10">
                <div>
                  <span className="text-[10px] font-mono uppercase text-neutral-500 dark:text-neutral-400 block">
                    Precio Individual:
                  </span>
                  <span className="text-xl font-sans font-bold text-neutral-900 dark:text-white">
                    $ 48.000 <span className="text-xs font-normal text-neutral-500">ARS</span>
                  </span>
                </div>

                <div className="p-2.5 bg-neutral-100 dark:bg-black/40 border border-black/5 dark:border-white/10 rounded-none">
                  <span className="text-[10px] font-mono uppercase text-[#c9a24b] font-bold block">
                    Llevando 3 o más cajas:
                  </span>
                  <span className="text-sm font-sans font-bold text-neutral-900 dark:text-white">
                    $ 43.000 <span className="text-[10px] font-normal text-neutral-400">ARS c/u</span>
                  </span>
                  <span className="text-[10px] text-emerald-600 dark:text-emerald-400 font-medium block mt-0.5">
                    ¡Ahorrás $5.000 por caja!
                  </span>
                </div>

                <button
                  onClick={handleAddDiscoverySet}
                  className="mt-2 w-full py-2.5 bg-black dark:bg-white text-white dark:text-black font-sans text-xs font-semibold uppercase tracking-wider hover:opacity-90 transition-opacity flex items-center justify-center gap-1.5 cursor-pointer shadow-md active:scale-[0.97]"
                >
                  <ShoppingBag className="w-3.5 h-3.5" />
                  <span>Añadir Caja ($ 48.000)</span>
                </button>
              </div>
            </Interactive3DCard>

            {/* Card 2: Combo Emprendedor (Highlighted / Gold Accent) */}
            <Interactive3DCard highlighted className="relative">
              <span className="absolute -top-3 right-4 font-mono text-[9px] bg-[#c9a24b] text-black px-2.5 py-0.5 uppercase font-bold tracking-widest shadow-md">
                ESCALA TU NEGOCIO
              </span>

              <div>
                <span className="font-mono text-[9px] text-[#c9a24b] uppercase tracking-widest font-semibold block mb-3">
                  DESDE SOLO 3 UNIDADES
                </span>

                <div className="flex items-center gap-2 mb-1 text-white">
                  <Sparkles className="w-4 h-4 text-[#e6cb85]" />
                  <h3 className="font-sans text-lg sm:text-xl font-bold tracking-tight">
                    Combo Emprendedor
                  </h3>
                </div>

                <p className="font-sans text-xs text-neutral-300 mt-1 leading-relaxed">
                  Armá tu lote personalizado combinando marcas (Lattafa, Diseñador o Nicho) con margen directo de reventa.
                </p>
              </div>

              <div className="flex flex-col gap-3 pt-5 mt-4 border-t border-white/15">
                <div>
                  <span className="text-[10px] font-mono uppercase text-neutral-400 block">
                    Margen de Ganancia:
                  </span>
                  <span className="text-xl font-sans font-bold text-[#e6cb85]">
                    35% al 50% <span className="text-xs font-normal text-neutral-300">Neto</span>
                  </span>
                </div>

                <div className="p-2.5 bg-black/50 border border-white/10 rounded-none">
                  <span className="text-[10px] font-mono uppercase text-neutral-400 block">
                    Mínimo Requerido:
                  </span>
                  <span className="text-xs font-sans font-bold text-white">
                    3 perfumes surtidos
                  </span>
                  <span className="text-[10px] text-neutral-400 block mt-0.5">
                    100% a tu elección
                  </span>
                </div>

                <button
                  onClick={handleStartEmprendedor}
                  className="mt-2 w-full py-2.5 bg-[#c9a24b] hover:bg-[#d8b35c] text-black font-sans text-xs font-bold uppercase tracking-wider transition-colors flex items-center justify-center gap-1.5 cursor-pointer shadow-lg active:scale-[0.97]"
                >
                  <ArrowRight className="w-3.5 h-3.5" />
                  <span>Elegir en Catálogo</span>
                </button>
              </div>
            </Interactive3DCard>

            {/* Card 3: Mayorista & Distribución (12+ Uds) */}
            <Interactive3DCard className="border border-black/10 dark:border-white/10">
              <div>
                <span className="font-mono text-[9px] bg-neutral-200 dark:bg-white/10 text-neutral-700 dark:text-neutral-300 px-2 py-0.5 uppercase tracking-widest font-semibold inline-block mb-3">
                  VOLUMEN BOUTIQUE
                </span>

                <div className="flex items-center gap-2 mb-1 text-neutral-900 dark:text-white">
                  <TrendingUp className="w-4 h-4 text-[#c9a24b]" />
                  <h3 className="font-sans text-lg sm:text-xl font-bold tracking-tight">
                    Lote Mayorista 12+
                  </h3>
                </div>

                <p className="font-sans text-xs text-neutral-600 dark:text-neutral-400 mt-1 leading-relaxed">
                  Para boutiques, salones y revendedores avanzados que buscan la máxima escala y precio de distribución.
                </p>
              </div>

              <div className="flex flex-col gap-3 pt-5 mt-4 border-t border-black/10 dark:border-white/10">
                <div>
                  <span className="text-[10px] font-mono uppercase text-neutral-500 dark:text-neutral-400 block">
                    Margen de Ganancia:
                  </span>
                  <span className="text-xl font-sans font-bold text-neutral-900 dark:text-white">
                    Hasta 55% <span className="text-xs font-normal text-neutral-500">Rentabilidad</span>
                  </span>
                </div>

                <div className="p-2.5 bg-neutral-100 dark:bg-black/40 border border-black/5 dark:border-white/10 rounded-none">
                  <span className="text-[10px] font-mono uppercase text-[#c9a24b] font-bold block">
                    Beneficio Exclusivo:
                  </span>
                  <span className="text-[11px] font-sans font-medium text-neutral-800 dark:text-neutral-200 block">
                    Tester 100ml de cortesía + envío bonificado
                  </span>
                </div>

                <button
                  onClick={() => {
                    if (onOpenWholesaleModal) {
                      onOpenWholesaleModal();
                    } else {
                      handleContactWhatsApp('Lote Mayorista 12+ Unidades');
                    }
                  }}
                  className="mt-2 w-full py-2.5 bg-neutral-200 dark:bg-[#1F232B] hover:bg-neutral-300 dark:hover:bg-[#282D37] text-neutral-900 dark:text-white font-sans text-xs font-semibold uppercase tracking-wider transition-colors flex items-center justify-center gap-1.5 cursor-pointer shadow-sm active:scale-[0.97]"
                >
                  <MessageCircle className="w-3.5 h-3.5 text-emerald-500" />
                  <span>Cotizar por WhatsApp</span>
                </button>
              </div>
            </Interactive3DCard>

          </div>

        </div>
      </div>
    </section>
  );
}
