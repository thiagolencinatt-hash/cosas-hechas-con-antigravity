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
    <section id="pilares" className="w-full bg-neutral-50 dark:bg-[#0B0C10] py-20 border-b border-black/10 dark:border-white/10 relative z-20 shadow-2xl transition-colors duration-200">
      <div className="max-w-[1440px] mx-auto px-4 sm:px-8 lg:px-12">
        
        {/* Section Header */}
        <div className="flex flex-col md:flex-row md:items-end justify-between mb-12 gap-6">
          <div>
            <div className="inline-flex items-center gap-2 font-mono text-[11px] text-[#c9a24b] uppercase tracking-[0.25em] mb-2">
              <Sparkles className="w-3.5 h-3.5" />
              <span>01 / Arquitectura Sensorial</span>
            </div>
            <h2 className="font-serif text-4xl sm:text-5xl lg:text-6xl text-neutral-900 dark:text-white font-normal tracking-tight">
              Pilares Olfativos
            </h2>
          </div>
          <p className="font-sans text-neutral-600 dark:text-neutral-400 text-sm sm:text-base max-w-md font-light leading-relaxed">
            Composiciones puras destiladas a baja temperatura. Cuatro familias primarias formuladas para perdurar más de 18 horas sobre la epidermis.
          </p>
        </div>

        {/* 4 Architectural Cards Grid (Stitch Specification) */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {PILLARS.map((p) => (
            <div
              key={p.id}
              onClick={() => handlePillarClick(p)}
              className="group relative flex flex-col bg-white dark:bg-[#12141A] border border-black/10 dark:border-white/10 overflow-hidden hover:border-[#c9a24b]/50 hover:bg-neutral-50 dark:hover:bg-[#1A1D24] transition-all duration-300 cursor-pointer shadow-xl"
            >
              {/* Photo Area */}
              <div className="aspect-[4/5] w-full overflow-hidden relative bg-black">
                <div
                  className="w-full h-full bg-cover bg-center transition-transform duration-700 ease-out group-hover:scale-105"
                  style={{ backgroundImage: `url('${p.bgImage}')` }}
                />
                <div className="absolute inset-0 bg-gradient-to-t from-white/90 dark:from-[#12141A] via-transparent to-black/30" />
                <span className="absolute top-4 left-4 font-mono text-[10px] bg-black/80 backdrop-blur-md border border-white/15 px-2.5 py-1 text-white uppercase tracking-wider">
                  PILARES // {p.num}
                </span>
              </div>

              {/* Text Meta Content */}
              <div className="p-6 flex flex-col flex-1 justify-between gap-4">
                <div>
                  <span className="font-mono text-[11px] text-[#c9a24b] tracking-[0.2em] uppercase block mb-1">
                    {p.subtitle}
                  </span>
                  <h3 className="font-serif text-2xl text-neutral-900 dark:text-white font-normal mb-2 group-hover:text-black dark:group-hover:text-[#f8f8f6] transition-colors">
                    {p.title}
                  </h3>
                  <p className="font-sans text-xs sm:text-sm text-neutral-600 dark:text-neutral-400 font-light leading-relaxed">
                    {p.desc}
                  </p>
                </div>

                <div className="pt-3 border-t border-black/10 dark:border-white/10 flex items-center justify-between text-neutral-500 dark:text-neutral-400 group-hover:text-black dark:group-hover:text-white transition-colors">
                  <span className="font-mono text-[11px] tracking-wider uppercase">
                    {p.fragranceCount} FRAGANCIAS
                  </span>
                  <div className="w-7 h-7 rounded-full bg-black/5 dark:bg-white/5 flex items-center justify-center group-hover:bg-black group-hover:text-white dark:group-hover:bg-white dark:group-hover:text-black transition-all">
                    <ArrowUpRight className="w-3.5 h-3.5" />
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

      </div>
    </section>
  );
}

