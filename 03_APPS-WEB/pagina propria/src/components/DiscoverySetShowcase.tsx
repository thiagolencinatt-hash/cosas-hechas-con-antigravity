import { Sparkles, ShoppingBag } from 'lucide-react';
import { useShop } from '../context/ShopContext';
import { Product } from '../types';

export function DiscoverySetShowcase() {
  const { addToCart, showToast } = useShop();

  const discoveryProduct: Product = {
    id: 9999,
    name: 'Kit de Descubrimiento Privado (5 x 5ml)',
    brand: 'LATHE ESSENCE',
    gender: 'unisex',
    category: 'Discovery Set',
    price: 43000,
    retailPrice: 48000,
    image:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBVp-lLW0vZGhfWExYQkwWFWrLfNZQbOcp_bchfCFmJn04GuII1cKbMgd5LfAiK4I3qpQmg9mYPPFAKKI-Ql1c9SFR_y1DvBrIU9w9eKuPycCYnoTIq3Qx6CqYltoA0snlV476PN5ufnKuCo6hf0wq9UUzTeDmcWcJoCLzeFn5DbxhjAkvExTVrYBC1HK3S7vRqTPEAxKCOsdfSpTDM6yr-Ig9wAsm66X3Z9Qmmib50',
    inStock: true,
    rating: 5,
    reviewsCount: 38,
    description:
      'Cinco frascos tubulares de 5ml en estuche de lujo con atomizadores de micro-niebla. $48.000 la unidad o $43.000 c/u a partir de 3 unidades.',
    pyramid: {
      top: ['Bergamota de Calabria', 'Cardamomo Negro'],
      heart: ['Oud de Trat', 'Jazmín Sambac', 'Rosa de Mayo'],
      base: ['Sándalo de Mysore', 'Ámbar Báltico', 'Cuero Ruso'],
    },
    isFeatured: true,
  };

  const handleAddDiscovery = () => {
    addToCart(discoveryProduct, 1, 'minorista');
    showToast('Kit de Descubrimiento Privado añadido al carrito.');
  };

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
              <span>Experiencia Sensorial en Tubos</span>
            </div>

            <h2 className="font-sans text-3xl sm:text-4xl lg:text-5xl font-bold tracking-tight text-neutral-900 dark:text-white leading-tight">
              Perfumes en Tubo: Caja Colección Privada
            </h2>

            <p className="font-sans text-neutral-600 dark:text-neutral-300 text-sm sm:text-base font-normal leading-relaxed max-w-xl">
              Cinco frascos tubulares de 5ml con atomizadores de micro-niebla. El formato estrella para probar fijación en piel a lo largo del día o revender con altísima rotación.
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
                <span className="font-sans text-xs text-neutral-900 dark:text-white font-semibold">5 x 5ml Tubos Spray</span>
              </div>
              <div>
                <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase block">Concentración</span>
                <span className="font-sans text-xs text-neutral-900 dark:text-white font-semibold">32% Extrait de Parfum</span>
              </div>
              <div>
                <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase block">Despacho</span>
                <span className="font-sans text-xs text-[#c9a24b] font-semibold">A todo el país</span>
              </div>
            </div>

            <div className="pt-4 flex flex-wrap gap-4">
              <button
                onClick={handleAddDiscovery}
                className="px-8 py-3.5 bg-black dark:bg-white text-white dark:text-black font-sans text-xs uppercase tracking-wider font-semibold hover:opacity-90 transition-opacity flex items-center gap-2 cursor-pointer shadow-xl active:scale-[0.97]"
              >
                <ShoppingBag className="w-4 h-4" />
                <span>Añadir Set al Carrito ($ 48.000 ARS)</span>
              </button>
            </div>
          </div>

          {/* Right: Visual Image Showcase */}
          <div className="lg:col-span-5 relative">
            <div className="aspect-[4/3] sm:aspect-square w-full overflow-hidden border border-white/15 bg-black relative group shadow-2xl">
              <div
                className="w-full h-full bg-cover bg-center transition-transform duration-700 ease-out group-hover:scale-105"
                style={{
                  backgroundImage:
                    "url('https://lh3.googleusercontent.com/aida-public/AB6AXuAFsIJF_kDqJEkH0weJWMri6iLN9zroULF-2cbCRxFPGTBHbNuu4cDPM1hQ45u6FibSfITT-qv6ZWGwgSYYlWRSPuwgGcdvYo8D71oxvD_8ZxkCuILOOdxPBqKyWYAFz9YMdOGv3-_r9CHp_6OYexb5L8fSbVnRGEs77DTt1mp5_VbWGj1gffxC6Q_MTyCUZsB9bY4G-8S-LwWpvwdQ-mUi6Es6Y_RKnKLEo_tedLFC')",
                }}
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent" />
              <div className="absolute top-4 left-4">
                <img
                  src="/images/logo/lathe-logo-white.png"
                  alt="LATHE ESSENCE"
                  className="h-6 w-auto object-contain filter drop-shadow-md"
                />
              </div>
              <div className="absolute bottom-4 left-4 right-4 flex items-center justify-between text-[11px] font-mono text-neutral-300 bg-black/70 backdrop-blur-md px-3 py-1.5 border border-white/10">
                <span>5 EXTRACTOS SELECTOS</span>
                <span className="text-[#c9a24b]">ESTUCHE ÉBANO MATE</span>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
  );
}
