import { ArrowUpRight, Sparkles } from 'lucide-react';
import { useShop } from '../context/ShopContext';

interface Pillar {
  id: string;
  num: string;
  title: string;
  subtitle: string;
  desc: string;
  fragranceCount: number;
  bgImage: string;
  categoryFilter: string;
}

const PILLARS: Pillar[] = [
  {
    id: 'amaderados',
    num: 'I',
    title: 'Amaderados & Cuero',
    subtitle: 'Extracto Seco',
    desc: 'Cedro del Atlas, cuero ruso curtido al humo de abedul y resinas oscuras maceradas.',
    fragranceCount: 28,
    bgImage:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBVp-lLW0vZGhfWExYQkwWFWrLfNZQbOcp_bchfCFmJn04GuII1cKbMgd5LfAiK4I3qpQmg9mYPPFAKKI-Ql1c9SFR_y1DvBrIU9w9eKuPycCYnoTIq3Qx6CqYltoA0snlV476PN5ufnKuCo6hf0wq9UUzTeDmcWcJoCLzeFn5DbxhjAkvExTVrYBC1HK3S7vRqTPEAxKCOsdfSpTDM6yr-Ig9wAsm66X3Z9Qmmib50',
    categoryFilter: 'Amaderado',
  },
  {
    id: 'citricos',
    num: 'II',
    title: 'Cítricos & Neroli',
    subtitle: 'Cítrico Espectral',
    desc: 'Bergamota de Calabria prensada en frío, flor de azahar tunecina y petitgrain glacial.',
    fragranceCount: 22,
    bgImage:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCXLBizg4HBBZpiTo4YBiK0V8we5i2ZMd-ljQWIaQVnMKIclnYi2V6M3iyNcWcbcH56Dw222bQhwCNx4Dorf4f2jepS3bb30FDT1eu2U05JDfgTqi78CpbRhsknwJp3Co31T8ZqDnAvd976Y4Wt-VLkNVDOZV2muSZaV6xf6Jpf2b3UncxA7jHhSkG8M6CrgB1Tgb4H0Qy0M4o2ZX8EwAb2PiC3SO3kFjan01SVpktx',
    categoryFilter: 'Cítrico',
  },
  {
    id: 'ambar',
    num: 'III',
    title: 'Ámbar & Especias',
    subtitle: 'Oriental Profundo',
    desc: 'Incienso de Omán, haba tonka tostada, azafrán kashmiri y ládano fosilizado.',
    fragranceCount: 35,
    bgImage:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDPlhaH98Mlv0p3rn96fNvlJNUtRSKgD__JePWc3MULEkeeXDPFZkpNdHl0U7GaNAT4_OiMNTIb7ULTwOE_phqCzB2GPO-YgPpiA6ZaU4NGS_1D3gDUx_nKH2aLFuMeCRaWNLSw7P1B3EYkyuvilJYqxuMOQTSIx9r0Ti1eUp7X-ASm0yJ36Zkj6qH7ZgQEObvnm4tK92hwP8P18sCCOMYXpHU3Ovei9xshvedByNsr',
    categoryFilter: 'Oriental',
  },
  {
    id: 'floral',
    num: 'IV',
    title: 'Floral Blanco & Musgo',
    subtitle: 'Chypre Nocturno',
    desc: 'Tubérculos nocturnos, jazmín sambac, musgo de roble y una base sutil de almizcle blanco.',
    fragranceCount: 24,
    bgImage:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDSuM9Sbyvt-aRwn8Tnsy9qH1bukZdQwLjjfn02CyzQaFrjot6LXWpMfTnmg0TYhuVn_JolA0XAXLc1yY809uRmEZbIsPRKPP0BdLbNVQP4jt0FHN6Hy3fY1KDubAvdq9Zll0LA4bF3QbQl2Qbq8OSIO22jUtd699kOLmehtQPNHzgjQXr6gBrRE3cbZbyGNj5rY4fO9jgfjFzvo7OwY1UySyNx7WbQDtux1cmIwzKk',
    categoryFilter: 'Floral',
  },
];

export function PilaresOlfativos() {
  const { setSelectedCategory, showToast } = useShop();

  const handlePillarClick = (pillar: Pillar) => {
    setSelectedCategory(pillar.categoryFilter);
    showToast(`Filtrando catálogo por familia: ${pillar.title}`);
    const catEl = document.getElementById('catalogo') || document.getElementById('catalog-section');
    if (catEl) {
      catEl.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <section id="pilares" className="w-full bg-neutral-100 dark:bg-[#0B0C10] py-8 sm:py-10 border-b border-black/10 dark:border-white/10 relative z-20 transition-colors duration-200">
      <div className="max-w-[1440px] mx-auto px-4 sm:px-8 lg:px-12">
        
        {/* Compact & Discreet Section Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between mb-5 gap-2">
          <div className="flex items-center gap-3">
            <span className="inline-flex items-center gap-1.5 font-mono text-[10px] text-[#c9a24b] uppercase tracking-[0.25em] bg-[#c9a24b]/10 border border-[#c9a24b]/30 px-2.5 py-0.5 font-semibold">
              <Sparkles className="w-3 h-3" />
              <span>01 // ARQUITECTURA SENSORIAL</span>
            </span>
            <h2 className="font-sans text-base sm:text-lg font-bold tracking-tight text-neutral-900 dark:text-white">
              Pilares Olfativos
            </h2>
          </div>
          <p className="font-sans text-xs text-neutral-600 dark:text-neutral-400 font-normal">
            Elegí una familia olfativa para filtrar el catálogo al instante
          </p>
        </div>

        {/* Compact Architectural Landscape Tiles (Minimalist & Discreet) */}
        <div className="flex gap-3 overflow-x-auto no-scrollbar sm:grid sm:grid-cols-4 sm:gap-4 snap-x snap-mandatory py-1">
          {PILLARS.map((p) => (
            <div
              key={p.id}
              onClick={() => handlePillarClick(p)}
              className="group relative flex flex-col justify-between h-28 sm:h-32 lg:h-36 p-3.5 sm:p-4 rounded-none border border-black/10 dark:border-white/10 hover:border-[#c9a24b] transition-all duration-300 cursor-pointer overflow-hidden shadow-lg active:scale-[0.98] shrink-0 min-w-[220px] sm:min-w-0 snap-start select-none"
            >
              {/* Background Atmospheric Artwork */}
              <div
                className="absolute inset-0 bg-cover bg-center transition-transform duration-700 ease-out group-hover:scale-105"
                style={{ backgroundImage: `url('${p.bgImage}')` }}
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/55 to-black/30 group-hover:from-black/85 transition-colors" />

              {/* Top Meta: Roman Numeral & Subtitle */}
              <div className="relative z-10 flex items-center justify-between">
                <span className="font-mono text-[9px] bg-black/75 backdrop-blur-md border border-white/15 px-2 py-0.5 text-white uppercase tracking-wider">
                  PILARES // {p.num}
                </span>
                <span className="font-mono text-[9px] text-[#e6cb85] uppercase tracking-wider font-semibold">
                  {p.subtitle}
                </span>
              </div>

              {/* Bottom Meta: Title & Fragrance Count */}
              <div className="relative z-10 flex items-end justify-between gap-2">
                <div>
                  <h3 className="font-sans text-sm sm:text-base font-bold text-white tracking-tight group-hover:text-[#f8f8f6] transition-colors leading-snug">
                    {p.title}
                  </h3>
                  <span className="font-mono text-[10px] text-neutral-300 block mt-0.5">
                    {p.fragranceCount} fragancias
                  </span>
                </div>
                <div className="w-6 h-6 rounded-full bg-white/10 group-hover:bg-[#c9a24b] group-hover:text-black text-white flex items-center justify-center transition-all shrink-0">
                  <ArrowUpRight className="w-3.5 h-3.5" />
                </div>
              </div>
            </div>
          ))}
        </div>

      </div>
    </section>
  );
}

