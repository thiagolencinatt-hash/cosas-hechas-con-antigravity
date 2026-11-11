import { useState } from 'react';
import { Sparkles, ShoppingBag, ChevronLeft, ChevronRight, Camera } from 'lucide-react';
import { useShop } from '../context/ShopContext';
import { Product } from '../types';

interface TubePhotoSlide {
  id: string;
  image: string;
  title: string;
  tag: string;
  brands: string;
}

const TUBE_SLIDES: TubePhotoSlide[] = [
  {
    id: 'set-a',
    image: '/images/tubos/caja-tubos-set-a.jpg',
    title: 'Caja Selección A',
    tag: 'Foto Real del Producto',
    brands: 'Odyssey Revolution • Odyssey Aqua • Club de Nuit • Homme',
  },
  {
    id: 'set-b',
    image: '/images/tubos/caja-tubos-set-b.jpg',
    title: 'Caja Selección B',
    tag: 'Foto Real del Producto',
    brands: '9PM Afnan • Her Confession • Veluan Snake • Jameela',
  },
];

export function DiscoverySetShowcase() {
  const { addToCart, showToast } = useShop();
  const [activeSlide, setActiveSlide] = useState(0);

  const discoveryProduct: Product = {
    id: 9999,
    name: 'Caja 20 Perfumes en Tubo (20 x 35ml a Elección)',
    brand: 'LATHE ESSENCE',
    gender: 'unisex',
    category: 'Tubos 35ml',
    price: 43000,
    retailPrice: 48000,
    image: '/images/tubos/caja-tubos-set-a.jpg',
    inStock: true,
    rating: 5,
    reviewsCount: 38,
    description:
      'Caja con 20 frascos tubulares de 35ml con atomizador spray. Fragancias 100% a elección del cliente armadas personalmente por nosotros. Ultra prácticos para llevar en el bolso, la guantera del auto o retocar a diario. $48.000 la unidad o $43.000 c/u a partir de 3 unidades.',
    pyramid: {
      top: ['Bergamota de Calabria', 'Cardamomo Negro'],
      heart: ['Oud de Trat', 'Jazmín Sambac', 'Rosa de Mayo'],
      base: ['Sándalo de Mysore', 'Ámbar Báltico', 'Cuero Ruso'],
    },
    isFeatured: true,
  };

  const handleAddDiscovery = () => {
    addToCart(discoveryProduct, 1, 'minorista');
    showToast('Caja de 20 Perfumes en Tubo (35ml) añadida al carrito.');
  };

  const handlePrevSlide = () => {
    setActiveSlide((prev) => (prev === 0 ? TUBE_SLIDES.length - 1 : prev - 1));
  };

  const handleNextSlide = () => {
    setActiveSlide((prev) => (prev === TUBE_SLIDES.length - 1 ? 0 : prev + 1));
  };

  const currentSlide = TUBE_SLIDES[activeSlide];

  return (
    <section className="w-full bg-white dark:bg-[#08090C] text-neutral-900 dark:text-white py-20 border-b border-black/10 dark:border-white/10 relative overflow-hidden transition-colors duration-200">
      <div className="max-w-[1440px] mx-auto px-4 sm:px-8 lg:px-12">
        <div className="bg-neutral-100 dark:bg-[#12141A] border border-black/10 dark:border-white/10 p-8 sm:p-12 lg:p-16 grid grid-cols-1 lg:grid-cols-12 gap-12 items-center relative shadow-2xl">
          
          {/* Subtle Accent Glow */}
          <div className="absolute top-0 right-0 w-96 h-96 bg-[#c9a24b]/5 rounded-full blur-3xl pointer-events-none" />

          {/* Left: Content */}
          <div className="lg:col-span-7 flex flex-col gap-6 z-10">
            <div className="inline-flex items-center gap-2 font-mono text-[11px] text-[#c9a24b] uppercase tracking-[0.25em]">
              <Sparkles className="w-3.5 h-3.5" />
              <span>Experiencia Práctica en Tubos 35ml</span>
            </div>

            <h2 className="font-sans text-3xl sm:text-4xl lg:text-5xl font-bold tracking-tight text-neutral-900 dark:text-white leading-tight">
              Perfumes en Tubo: Caja de 20 Unidades (35ml)
            </h2>

            <p className="font-sans text-neutral-600 dark:text-neutral-300 text-sm sm:text-base font-normal leading-relaxed max-w-xl">
              Caja con <strong>20 frascos tubulares de 35ml</strong> con atomizador spray. 
              Las fragancias son <strong>100% a tu elección y las armamos nosotros</strong> artesanalmente según tus preferencias. 
              El formato más versátil y cómodo: ultra prácticos para llevar en el bolso, la mochila, en el auto o para usar todos los días sin cargar frascos pesados.
            </p>

            <div className="flex flex-wrap items-center gap-4 pt-2">
              <div className="flex items-baseline gap-2">
                <span className="font-mono text-xs text-neutral-500 dark:text-neutral-400 uppercase">Individual:</span>
                <span className="font-sans text-3xl font-bold text-neutral-900 dark:text-white">$ 48.000 <span className="text-sm font-normal text-neutral-500">ARS</span></span>
              </div>
              <span className="font-mono text-[11px] bg-[#c9a24b]/15 text-[#c9a24b] px-3.5 py-1.5 border border-[#c9a24b]/40 uppercase tracking-wider font-semibold">
                $ 43.000 ARS c/u llevando 3 o más cajas
              </span>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 pt-4 border-t border-black/10 dark:border-white/10 max-w-lg">
              <div>
                <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase block">Formato</span>
                <span className="font-sans text-xs text-neutral-900 dark:text-white font-semibold">20 x 35ml Tubos Spray</span>
              </div>
              <div>
                <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase block">Armado</span>
                <span className="font-sans text-xs text-neutral-900 dark:text-white font-semibold">100% a Elección</span>
              </div>
              <div>
                <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase block">Practicidad</span>
                <span className="font-sans text-xs text-[#c9a24b] font-semibold">Bolso, Auto & Salidas</span>
              </div>
            </div>

            <div className="pt-4 flex flex-wrap gap-4">
              <button
                onClick={handleAddDiscovery}
                className="px-8 py-3.5 bg-black dark:bg-white text-white dark:text-black font-sans text-xs uppercase tracking-wider font-semibold hover:opacity-90 transition-opacity flex items-center gap-2 cursor-pointer shadow-xl active:scale-[0.97]"
              >
                <ShoppingBag className="w-4 h-4" />
                <span>Añadir Caja de 20 al Carrito ($ 48.000 ARS)</span>
              </button>
            </div>
          </div>

          {/* Right: Interactive Real Photos Showcase with Arrows & Carousel */}
          <div className="lg:col-span-5 relative flex flex-col gap-3">
            <div className="aspect-[4/5] sm:aspect-square w-full overflow-hidden border border-black/15 dark:border-white/15 bg-neutral-900 relative group shadow-2xl">
              
              {/* Product Photo with Smooth Transition */}
              <img
                key={currentSlide.id}
                src={currentSlide.image}
                alt={currentSlide.title}
                className="w-full h-full object-cover object-center transition-all duration-500 ease-out group-hover:scale-105 select-none"
              />

              {/* Ambient Shadow Gradients */}
              <div className="absolute inset-0 bg-gradient-to-t from-black/85 via-transparent to-black/40 pointer-events-none" />

              {/* Top Bar: Brand Logo & Real Photo Badge */}
              <div className="absolute top-4 left-4 right-4 flex items-center justify-between pointer-events-none">
                <img
                  src="/images/logo/lathe-logo-white.png"
                  alt="LATHE ESSENCE"
                  className="h-6 w-auto object-contain filter drop-shadow-md"
                />
                <span className="inline-flex items-center gap-1.5 px-2.5 py-1 bg-black/75 backdrop-blur-md border border-white/20 text-white font-mono text-[10px] uppercase tracking-wider shadow-lg">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                  <span>Foto Real en Stock</span>
                </span>
              </div>

              {/* In-Image Left Arrow Overlay */}
              <button
                onClick={handlePrevSlide}
                className="absolute left-3 top-1/2 -translate-y-1/2 w-9 h-9 rounded-full bg-black/65 hover:bg-black/90 text-white border border-white/20 flex items-center justify-center transition-all cursor-pointer opacity-80 group-hover:opacity-100 hover:scale-105 active:scale-95 shadow-xl"
                aria-label="Ver foto anterior"
                title="Foto anterior"
              >
                <ChevronLeft className="w-5 h-5" />
              </button>

              {/* In-Image Right Arrow Overlay */}
              <button
                onClick={handleNextSlide}
                className="absolute right-3 top-1/2 -translate-y-1/2 w-9 h-9 rounded-full bg-black/65 hover:bg-black/90 text-white border border-white/20 flex items-center justify-center transition-all cursor-pointer opacity-80 group-hover:opacity-100 hover:scale-105 active:scale-95 shadow-xl"
                aria-label="Ver siguiente foto"
                title="Siguiente foto"
              >
                <ChevronRight className="w-5 h-5" />
              </button>

              {/* Bottom In-Image Metadata Overlay */}
              <div className="absolute bottom-3 left-3 right-3 flex items-center justify-between text-[11px] font-mono text-neutral-200 bg-black/80 backdrop-blur-md px-3.5 py-2 border border-white/15">
                <span className="font-semibold text-white">20 TUBOS DE 35ML</span>
                <span className="text-[#c9a24b] font-medium tracking-wide">100% A ELECCIÓN</span>
              </div>
            </div>

            {/* Bottom Arrow Navigation Bar: Flechitas para Mover y Ver la Otra */}
            <div className="flex items-center justify-between px-3 py-2.5 bg-white dark:bg-[#151821] border border-black/10 dark:border-white/10 shadow-md">
              <div className="flex items-center gap-2">
                <Camera className="w-4 h-4 text-[#c9a24b]" />
                <span className="font-sans text-xs font-semibold text-neutral-900 dark:text-white">
                  {currentSlide.title}
                </span>
                <span className="text-neutral-400 text-xs hidden sm:inline">•</span>
                <span className="font-mono text-[11px] text-neutral-500 dark:text-neutral-400 hidden sm:inline">
                  {activeSlide + 1} de {TUBE_SLIDES.length}
                </span>
              </div>

              {/* Interactive Arrow Controls & Dots */}
              <div className="flex items-center gap-2">
                {/* Dots indicator */}
                <div className="flex items-center gap-1.5 mr-2">
                  {TUBE_SLIDES.map((_, idx) => (
                    <button
                      key={idx}
                      onClick={() => setActiveSlide(idx)}
                      className={`h-2 transition-all cursor-pointer rounded-full ${
                        activeSlide === idx
                          ? 'w-6 bg-[#c9a24b]'
                          : 'w-2 bg-neutral-300 dark:bg-white/20 hover:bg-neutral-500'
                      }`}
                      aria-label={`Ver foto ${idx + 1}`}
                    />
                  ))}
                </div>

                {/* Left Arrow Button */}
                <button
                  onClick={handlePrevSlide}
                  className="w-8 h-8 flex items-center justify-center bg-neutral-100 dark:bg-white/5 hover:bg-neutral-200 dark:hover:bg-white/15 border border-black/10 dark:border-white/15 text-neutral-800 dark:text-white transition-colors cursor-pointer active:scale-95"
                  aria-label="Foto anterior"
                  title="Foto anterior"
                >
                  <ChevronLeft className="w-4 h-4" />
                </button>

                {/* Right Arrow Button */}
                <button
                  onClick={handleNextSlide}
                  className="w-8 h-8 flex items-center justify-center bg-black dark:bg-white text-white dark:text-black hover:opacity-90 transition-opacity cursor-pointer active:scale-95 shadow-sm"
                  aria-label="Foto siguiente"
                  title="Siguiente foto"
                >
                  <ChevronRight className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* Fragrances subtitle summary */}
            <p className="font-sans text-[11px] text-neutral-500 dark:text-neutral-400 px-1 italic">
              {currentSlide.brands}
            </p>
          </div>

        </div>
      </div>
    </section>
  );
}
