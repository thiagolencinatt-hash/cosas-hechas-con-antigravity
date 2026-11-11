import { CheckCircle2, Download, TrendingUp } from 'lucide-react';
import { useShop } from '../context/ShopContext';

interface MatrizComercialProps {
  onOpenWholesaleModal?: () => void;
}

export function MatrizComercialB2B({ onOpenWholesaleModal }: MatrizComercialProps) {
  const { setGlobalPricingMode, showToast } = useShop();

  const handleSelectTier = (tierName: string) => {
    setGlobalPricingMode('mayorista');
    showToast(`Modalidad Mayorista activada para ${tierName}. Precios escalonados aplicados.`);
    if (onOpenWholesaleModal) {
      onOpenWholesaleModal();
    } else {
      const catEl = document.getElementById('catalogo') || document.getElementById('catalog-section');
      if (catEl) catEl.scrollIntoView({ behavior: 'smooth' });
    }
  };

  const handleDownloadTrade = () => {
    showToast('Descargando Catálogo Mayorista Trade 2025 (PDF & Lista de Precios)...');
  };

  return (
    <section id="b2b-matriz" className="w-full bg-[#0E1015] py-24 border-b border-white/10 relative">
      <div className="max-w-[1440px] mx-auto px-4 sm:px-8 lg:px-12">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-start">
          
          {/* Left Column: Context & Guarantees */}
          <div className="lg:col-span-4 flex flex-col gap-6">
            <div>
              <div className="inline-flex items-center gap-2 font-mono text-[11px] text-[#c9a24b] uppercase tracking-[0.25em] mb-2">
                <TrendingUp className="w-3.5 h-3.5" />
                <span>03 / Adquisición por Volumen</span>
              </div>
              <h2 className="font-serif text-3xl sm:text-4xl lg:text-5xl text-white font-normal tracking-tight leading-tight">
                Matriz Comercial para Boutiques & Distribuidores
              </h2>
            </div>

            <p className="font-sans text-neutral-400 text-sm sm:text-base font-light leading-relaxed">
              Acceso directo a formulaciones sin intermediarios. Facturación B2B automatizada en divisas clave (USD, ARS, EUR) con soporte logístico puerta a puerta e incoterms DAP / DDP.
            </p>

            {/* Guarantees List */}
            <div className="flex flex-col gap-3 pt-2">
              <div className="flex items-center gap-3 text-sm text-neutral-200 font-sans">
                <CheckCircle2 className="w-4 h-4 text-[#c9a24b] shrink-0" />
                <span>Lotes numerados con certificado COA & MSDS internacional</span>
              </div>
              <div className="flex items-center gap-3 text-sm text-neutral-200 font-sans">
                <CheckCircle2 className="w-4 h-4 text-[#c9a24b] shrink-0" />
                <span>Material promocional en acrílico ahumado y blotters incluido</span>
              </div>
              <div className="flex items-center gap-3 text-sm text-neutral-200 font-sans">
                <CheckCircle2 className="w-4 h-4 text-[#c9a24b] shrink-0" />
                <span>Probador tester de 100ml de cortesía por cada 12 frascos</span>
              </div>
            </div>

            {/* Action Download */}
            <div className="pt-4 flex flex-wrap gap-3">
              <button
                onClick={handleDownloadTrade}
                className="px-6 py-3.5 bg-white text-black font-mono text-xs uppercase tracking-wider font-semibold hover:bg-neutral-200 transition-colors flex items-center gap-2 cursor-pointer shadow-lg active:scale-[0.97]"
              >
                <Download className="w-4 h-4" />
                <span>Descargar Catálogo Trade</span>
              </button>
            </div>
          </div>

          {/* Right Column: 3 Tier Cards (Stitch Specifications) */}
          <div className="lg:col-span-8 grid grid-cols-1 md:grid-cols-3 gap-6">
            
            {/* Tier 1: Boutique Inicial */}
            <div className="bg-[#12141A] border border-white/10 p-6 flex flex-col justify-between gap-6 hover:border-white/30 transition-all shadow-xl">
              <div>
                <span className="font-mono text-[10px] text-neutral-400 uppercase tracking-widest block mb-2">
                  TIER I // BOUTIQUE
                </span>
                <h4 className="font-serif text-2xl text-white font-normal">
                  Pack de 6 Uds
                </h4>
                <p className="font-sans text-xs text-neutral-400 mt-2 font-light leading-relaxed">
                  Ideal para concept stores, tiendas boutique y emprendedores que inician en perfumería de autor.
                </p>
              </div>

              <div className="flex flex-col gap-2.5 pt-4 border-t border-white/10">
                <div className="flex justify-between items-baseline">
                  <span className="font-mono text-[11px] text-neutral-400 uppercase">Margen:</span>
                  <span className="font-mono text-sm text-[#c9a24b] font-semibold">-30% s/ PVP</span>
                </div>
                <div className="flex justify-between items-baseline">
                  <span className="font-mono text-[11px] text-neutral-400 uppercase">MOQ:</span>
                  <span className="font-mono text-xs text-white">6 Uds Surtidas</span>
                </div>
                <div className="flex justify-between items-baseline">
                  <span className="font-mono text-[11px] text-neutral-400 uppercase">Despacho:</span>
                  <span className="font-mono text-xs text-neutral-300">24 — 48 Horas</span>
                </div>

                <button
                  onClick={() => handleSelectTier('Pack 6 Uds')}
                  className="mt-4 w-full py-2.5 bg-[#1F232B] hover:bg-[#282D37] text-white font-mono text-xs uppercase tracking-wider transition-colors active:scale-[0.97] cursor-pointer"
                >
                  Solicitar Tier 1
                </button>
              </div>
            </div>

            {/* Tier 2: Stockist Master (Highlighted) */}
            <div className="bg-[#171A22] border-2 border-[#c9a24b] p-6 flex flex-col justify-between gap-6 relative shadow-2xl">
              <span className="absolute -top-3 right-4 font-mono text-[9px] bg-[#c9a24b] text-black px-2.5 py-0.5 uppercase font-bold tracking-widest">
                Más Elegido
              </span>

              <div>
                <span className="font-mono text-[10px] text-[#c9a24b] uppercase tracking-widest block mb-2">
                  TIER II // STOCKIST MASTER
                </span>
                <h4 className="font-serif text-2xl text-white font-normal">
                  Caja de 12 a 36 Uds
                </h4>
                <p className="font-sans text-xs text-neutral-300 mt-2 font-light leading-relaxed">
                  Para perfumerías especializadas, distribuidores departamentales y salones exclusivos de lujo.
                </p>
              </div>

              <div className="flex flex-col gap-2.5 pt-4 border-t border-white/15">
                <div className="flex justify-between items-baseline">
                  <span className="font-mono text-[11px] text-neutral-400 uppercase">Margen:</span>
                  <span className="font-mono text-sm text-[#c9a24b] font-semibold">-45% s/ PVP</span>
                </div>
                <div className="flex justify-between items-baseline">
                  <span className="font-mono text-[11px] text-neutral-400 uppercase">MOQ:</span>
                  <span className="font-mono text-xs text-white">12 Uds Surtidas</span>
                </div>
                <div className="flex justify-between items-baseline">
                  <span className="font-mono text-[11px] text-neutral-400 uppercase">Envío:</span>
                  <span className="font-mono text-xs text-[#c9a24b] font-medium">Aéreo Prioritario Gratis</span>
                </div>

                <button
                  onClick={() => handleSelectTier('Caja 12-36 Uds')}
                  className="mt-4 w-full py-2.5 bg-white text-black hover:bg-neutral-100 font-mono text-xs uppercase tracking-wider font-semibold transition-colors active:scale-[0.97] cursor-pointer"
                >
                  Activar Cuenta Tier 2
                </button>
              </div>
            </div>

            {/* Tier 3: Pallet & Gran Distribución */}
            <div className="bg-[#12141A] border border-white/10 p-6 flex flex-col justify-between gap-6 hover:border-white/30 transition-all shadow-xl">
              <div>
                <span className="font-mono text-[10px] text-neutral-400 uppercase tracking-widest block mb-2">
                  TIER III // DISTRIBUIDOR
                </span>
                <h4 className="font-serif text-2xl text-white font-normal">
                  Pallet 48+ Uds
                </h4>
                <p className="font-sans text-xs text-neutral-400 mt-2 font-light leading-relaxed">
                  Cadenas retail, importadores regionales y contratos con exclusividad territorial.
                </p>
              </div>

              <div className="flex flex-col gap-2.5 pt-4 border-t border-white/10">
                <div className="flex justify-between items-baseline">
                  <span className="font-mono text-[11px] text-neutral-400 uppercase">Margen:</span>
                  <span className="font-mono text-sm text-[#c9a24b] font-semibold">-55% s/ PVP</span>
                </div>
                <div className="flex justify-between items-baseline">
                  <span className="font-mono text-[11px] text-neutral-400 uppercase">MOQ:</span>
                  <span className="font-mono text-xs text-white">48 Uds Master</span>
                </div>
                <div className="flex justify-between items-baseline">
                  <span className="font-mono text-[11px] text-neutral-400 uppercase">Beneficio:</span>
                  <span className="font-mono text-xs text-neutral-300">Exclusividad Zonal</span>
                </div>

                <button
                  onClick={() => handleSelectTier('Pallet 48+ Uds')}
                  className="mt-4 w-full py-2.5 bg-[#1F232B] hover:bg-[#282D37] text-white font-mono text-xs uppercase tracking-wider transition-colors active:scale-[0.97] cursor-pointer"
                >
                  Contactar Representante
                </button>
              </div>
            </div>

          </div>

        </div>
      </div>
    </section>
  );
}
