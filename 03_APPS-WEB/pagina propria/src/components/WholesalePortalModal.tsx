import { useState } from 'react';
import { X, Calculator, Download, Send, Building2, User, Phone, Mail } from 'lucide-react';
import { useShop } from '../context/ShopContext';

interface WholesalePortalModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function WholesalePortalModal({ isOpen, onClose }: WholesalePortalModalProps) {
  const { showToast, setGlobalPricingMode } = useShop();

  // Calculator State
  const [tierSelection, setTierSelection] = useState<'apertura' | 'coleccion' | 'master'>('coleccion');
  const [customUnits, setCustomUnits] = useState(18);

  // Registration Form State
  const [businessName, setBusinessName] = useState('');
  const [contactName, setContactName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');

  if (!isOpen) return null;

  // Calculation parameters
  const avgRetailPriceUSD = 150; // Average MSRP
  let discountRate = 0.30;
  if (customUnits >= 48) {
    discountRate = 0.55;
  } else if (customUnits >= 12) {
    discountRate = 0.45;
  } else {
    discountRate = 0.30;
  }

  const totalRetailMSRP = customUnits * avgRetailPriceUSD;
  const costPerUnit = Math.round(avgRetailPriceUSD * (1 - discountRate));
  const totalWholesaleCost = customUnits * costPerUnit;
  const projectedProfit = totalRetailMSRP - totalWholesaleCost;
  const profitMarginPercent = Math.round((projectedProfit / totalRetailMSRP) * 100);

  const handleSelectTierPreset = (tier: 'apertura' | 'coleccion' | 'master') => {
    setTierSelection(tier);
    if (tier === 'apertura') setCustomUnits(6);
    if (tier === 'coleccion') setCustomUnits(18);
    if (tier === 'master') setCustomUnits(48);
  };

  const handleProformaDownload = () => {
    showToast(`Generando cotización proforma oficial para lote de ${customUnits} unidades...`);
  };

  const handleSubmitRegistration = (e: React.FormEvent) => {
    e.preventDefault();
    setGlobalPricingMode('mayorista');
    showToast(`Solicitud enviada con éxito para "${businessName}". Te contactará un ejecutivo comercial.`);
    onClose();
  };

  const handleWhatsAppQuote = () => {
    const text = encodeURIComponent(
      `Hola LATHE ESSENCE B2B. Deseo solicitar cotización mayorista para:\n- Unidades: ${customUnits}\n- Descuento: -${Math.round(discountRate * 100)}%\n- Costo Estimado: $${totalWholesaleCost.toLocaleString()} USD\n- Negocio: ${businessName || 'Boutique'}`
    );
    window.open(`https://wa.me/5491123456789?text=${text}`, '_blank');
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto bg-black/80 backdrop-blur-md flex items-center justify-center p-4 sm:p-6 animate-fade-in">
      <div className="relative w-full max-w-5xl bg-white dark:bg-[#0D0E12] border border-black/10 dark:border-white/15 text-neutral-900 dark:text-white shadow-2xl overflow-hidden my-8 transition-colors">
        
        {/* Modal Header */}
        <div className="p-6 sm:p-8 border-b border-black/10 dark:border-white/10 flex items-center justify-between bg-neutral-50 dark:bg-[#12141A] transition-colors">
          <div className="flex items-center gap-4">
            <img
              src="/images/logo/lathe-logo-black.png"
              alt="LATHE ESSENCE"
              className="h-8 w-auto object-contain dark:hidden hidden sm:block"
            />
            <img
              src="/images/logo/lathe-logo-white.png"
              alt="LATHE ESSENCE"
              className="h-8 w-auto object-contain hidden dark:sm:block"
            />
            <div className="sm:border-l sm:border-black/15 dark:sm:border-white/20 sm:pl-4">
              <span className="font-mono text-[10px] text-[#c9a24b] uppercase tracking-[0.25em] block font-semibold">
                PORTAL MAYORISTA B2B // LATHE ESSENCE
              </span>
              <h3 className="font-serif text-2xl sm:text-3xl text-neutral-900 dark:text-white font-normal">
                Centro de Adquisición & Cotizador de Lotes
              </h3>
            </div>
          </div>

          <button
            onClick={onClose}
            className="p-2.5 text-neutral-500 hover:text-black dark:text-neutral-400 dark:hover:text-white bg-black/5 dark:bg-white/5 hover:bg-black/10 dark:hover:bg-white/10 transition-colors cursor-pointer"
            aria-label="Cerrar modal"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Body */}
        <div className="p-6 sm:p-8 space-y-10 max-h-[80vh] overflow-y-auto">
          
          {/* 4 Core B2B Threshold Metrics (Stitch Architecture) */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div className="bg-neutral-50 dark:bg-[#151820] border border-black/10 dark:border-white/10 p-4 transition-colors">
              <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase block mb-1">
                MOQ Mínimo
              </span>
              <span className="font-serif text-2xl text-neutral-900 dark:text-white font-normal">6 Uds</span>
              <p className="font-sans text-[11px] text-neutral-600 dark:text-neutral-400 mt-1">Combinables de cualquier línea</p>
            </div>
            <div className="bg-neutral-50 dark:bg-[#151820] border border-black/10 dark:border-white/10 p-4 transition-colors">
              <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase block mb-1">
                Margen Bruto
              </span>
              <span className="font-serif text-2xl text-[#c9a24b] font-normal">Hasta 55%</span>
              <p className="font-sans text-[11px] text-neutral-600 dark:text-neutral-400 mt-1">Retorno garantizado sobre MSRP</p>
            </div>
            <div className="bg-neutral-50 dark:bg-[#151820] border border-black/10 dark:border-white/10 p-4 transition-colors">
              <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase block mb-1">
                Despacho Prioritario
              </span>
              <span className="font-serif text-2xl text-neutral-900 dark:text-white font-normal">24 — 48H</span>
              <p className="font-sans text-[11px] text-neutral-600 dark:text-neutral-400 mt-1">FedEx Priority asegurado</p>
            </div>
            <div className="bg-neutral-50 dark:bg-[#151820] border border-black/10 dark:border-white/10 p-4 transition-colors">
              <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase block mb-1">
                Certificaciones
              </span>
              <span className="font-serif text-2xl text-neutral-900 dark:text-white font-normal">IFRA / COA</span>
              <p className="font-sans text-[11px] text-neutral-600 dark:text-neutral-400 mt-1">Grasse y Dubái certificados</p>
            </div>
          </div>

          {/* Interactive Cotizador Rápido de Lote */}
          <div className="bg-neutral-50 dark:bg-[#12141A] border border-black/10 dark:border-white/15 p-6 sm:p-8 transition-colors">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6 pb-4 border-b border-black/10 dark:border-white/10">
              <div className="flex items-center gap-2">
                <Calculator className="w-5 h-5 text-[#c9a24b]" />
                <h4 className="font-serif text-2xl text-neutral-900 dark:text-white font-normal">
                  Cotizador Rápido de Lote Mayorista
                </h4>
              </div>
              <span className="font-mono text-xs text-[#c9a24b] uppercase tracking-wider font-semibold">
                Descuento Actual: -{Math.round(discountRate * 100)}%
              </span>
            </div>

            {/* Presets Toggle */}
            <div className="grid grid-cols-3 gap-3 mb-6">
              <button
                type="button"
                onClick={() => handleSelectTierPreset('apertura')}
                className={`py-3 px-2 font-mono text-xs uppercase tracking-wider transition-all border cursor-pointer ${
                  tierSelection === 'apertura'
                    ? 'bg-black text-white dark:bg-white dark:text-black border-transparent font-semibold shadow-sm'
                    : 'bg-white dark:bg-[#181B23] text-neutral-700 dark:text-neutral-300 border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30'
                }`}
              >
                Pack Apertura (6u • -30%)
              </button>
              <button
                type="button"
                onClick={() => handleSelectTierPreset('coleccion')}
                className={`py-3 px-2 font-mono text-xs uppercase tracking-wider transition-all border cursor-pointer ${
                  tierSelection === 'coleccion'
                    ? 'bg-black text-white dark:bg-white dark:text-black border-transparent font-semibold shadow-sm'
                    : 'bg-white dark:bg-[#181B23] text-neutral-700 dark:text-neutral-300 border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30'
                }`}
              >
                Colección Nicho (18u • -45%)
              </button>
              <button
                type="button"
                onClick={() => handleSelectTierPreset('master')}
                className={`py-3 px-2 font-mono text-xs uppercase tracking-wider transition-all border cursor-pointer ${
                  tierSelection === 'master'
                    ? 'bg-black text-white dark:bg-white dark:text-black border-transparent font-semibold shadow-sm'
                    : 'bg-white dark:bg-[#181B23] text-neutral-700 dark:text-neutral-300 border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30'
                }`}
              >
                Master Pallet (48u • -55%)
              </button>
            </div>

            {/* Units Slider */}
            <div className="space-y-3 mb-8">
              <div className="flex justify-between items-center text-xs font-mono">
                <span className="text-neutral-600 dark:text-neutral-400 uppercase">Cantidad de Unidades Surtidas:</span>
                <span className="text-neutral-900 dark:text-white text-sm font-semibold">{customUnits} frascos</span>
              </div>
              <input
                type="range"
                min="6"
                max="100"
                step="2"
                value={customUnits}
                onChange={(e) => setCustomUnits(Number(e.target.value))}
                className="w-full accent-[#c9a24b] h-2 bg-neutral-200 dark:bg-[#282D37] cursor-pointer"
              />
              <div className="flex justify-between text-[10px] font-mono text-neutral-500">
                <span>6 Uds (Tier I: -30%)</span>
                <span>12 - 36 Uds (Tier II: -45%)</span>
                <span>48+ Uds (Tier III: -55%)</span>
              </div>
            </div>

            {/* Financial Output Dashboard */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 p-5 bg-white dark:bg-[#090A0D] border border-black/10 dark:border-white/10 mb-6 transition-colors">
              <div>
                <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase block">Costo Por Frasco</span>
                <span className="font-serif text-xl sm:text-2xl text-[#c9a24b] font-semibold">${costPerUnit} USD</span>
                <span className="font-mono text-[10px] text-neutral-400 line-through block">${avgRetailPriceUSD} USD</span>
              </div>
              <div>
                <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase block">Total Costo Neto</span>
                <span className="font-serif text-xl sm:text-2xl text-neutral-900 dark:text-white font-semibold">${totalWholesaleCost.toLocaleString()} USD</span>
                <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 block">{customUnits} unidades</span>
              </div>
              <div>
                <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase block">Valor Retail MSRP</span>
                <span className="font-serif text-xl sm:text-2xl text-neutral-700 dark:text-neutral-300">${totalRetailMSRP.toLocaleString()} USD</span>
                <span className="font-mono text-[10px] text-neutral-400 block">Venta sugerida</span>
              </div>
              <div>
                <span className="font-mono text-[10px] text-[#c9a24b] uppercase block font-semibold">Ganancia Proyectada</span>
                <span className="font-serif text-xl sm:text-2xl text-emerald-600 dark:text-emerald-400 font-semibold">+${projectedProfit.toLocaleString()} USD</span>
                <span className="font-mono text-[10px] text-emerald-600 dark:text-emerald-400 block font-medium">{profitMarginPercent}% margen</span>
              </div>
            </div>

            {/* Quote CTA actions */}
            <div className="flex flex-wrap gap-4">
              <button
                type="button"
                onClick={handleWhatsAppQuote}
                className="px-6 py-3.5 bg-[#25D366] text-black font-sans text-xs uppercase tracking-wider font-bold hover:bg-[#20ba59] transition-colors flex items-center gap-2 cursor-pointer shadow-lg active:scale-[0.97]"
              >
                <Send className="w-4 h-4" />
                <span>Solicitar Lote vía WhatsApp</span>
              </button>

              <button
                type="button"
                onClick={handleProformaDownload}
                className="px-6 py-3.5 bg-neutral-100 hover:bg-neutral-200 dark:bg-white/10 dark:hover:bg-white/20 border border-black/10 dark:border-white/20 text-neutral-900 dark:text-white font-sans text-xs uppercase tracking-wider font-semibold transition-colors flex items-center gap-2 cursor-pointer active:scale-[0.97]"
              >
                <Download className="w-4 h-4" />
                <span>Descargar Proforma Formal</span>
              </button>
            </div>
          </div>

          {/* Registration Form for Verified Boutiques */}
          <div className="bg-neutral-50 dark:bg-[#12141A] border border-black/10 dark:border-white/15 p-6 sm:p-8 transition-colors">
            <h4 className="font-serif text-2xl text-neutral-900 dark:text-white font-normal mb-2">
              Registro de Boutique o Distribuidor Autorizado
            </h4>
            <p className="font-sans text-xs text-neutral-600 dark:text-neutral-400 mb-6 font-normal">
              Obtén acceso a la lista de precios FOB, material visual para salón, muestras y términos de pago diferido.
            </p>

            <form onSubmit={handleSubmitRegistration} className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase mb-1 font-semibold">
                  Nombre de la Boutique / Empresa
                </label>
                <div className="relative">
                  <Building2 className="w-4 h-4 absolute left-3 top-3 text-neutral-400" />
                  <input
                    type="text"
                    required
                    value={businessName}
                    onChange={(e) => setBusinessName(e.target.value)}
                    placeholder="Ej. Maison Belle, Palermo Soho"
                    className="w-full bg-white dark:bg-[#1A1D24] border border-black/15 dark:border-white/15 px-3 py-2.5 pl-10 text-xs text-neutral-900 dark:text-white placeholder-neutral-400 focus:outline-none focus:border-[#c9a24b] transition-colors"
                  />
                </div>
              </div>

              <div>
                <label className="block font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase mb-1 font-semibold">
                  Nombre del Titular o Comprador
                </label>
                <div className="relative">
                  <User className="w-4 h-4 absolute left-3 top-3 text-neutral-400" />
                  <input
                    type="text"
                    required
                    value={contactName}
                    onChange={(e) => setContactName(e.target.value)}
                    placeholder="Ej. Lucas Ferrari"
                    className="w-full bg-white dark:bg-[#1A1D24] border border-black/15 dark:border-white/15 px-3 py-2.5 pl-10 text-xs text-neutral-900 dark:text-white placeholder-neutral-400 focus:outline-none focus:border-[#c9a24b] transition-colors"
                  />
                </div>
              </div>

              <div>
                <label className="block font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase mb-1 font-semibold">
                  WhatsApp Directo
                </label>
                <div className="relative">
                  <Phone className="w-4 h-4 absolute left-3 top-3 text-neutral-400" />
                  <input
                    type="tel"
                    required
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="+54 9 11 1234-5678"
                    className="w-full bg-white dark:bg-[#1A1D24] border border-black/15 dark:border-white/15 px-3 py-2.5 pl-10 text-xs text-neutral-900 dark:text-white placeholder-neutral-400 focus:outline-none focus:border-[#c9a24b] transition-colors"
                  />
                </div>
              </div>

              <div>
                <label className="block font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase mb-1 font-semibold">
                  Correo Electrónico Comercial
                </label>
                <div className="relative">
                  <Mail className="w-4 h-4 absolute left-3 top-3 text-neutral-400" />
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="contacto@boutique.com"
                    className="w-full bg-white dark:bg-[#1A1D24] border border-black/15 dark:border-white/15 px-3 py-2.5 pl-10 text-xs text-neutral-900 dark:text-white placeholder-neutral-400 focus:outline-none focus:border-[#c9a24b] transition-colors"
                  />
                </div>
              </div>

              <div className="sm:col-span-2 pt-2">
                <button
                  type="submit"
                  className="w-full py-3.5 bg-black dark:bg-white text-white dark:text-black font-sans text-xs uppercase tracking-wider font-semibold hover:opacity-90 transition-opacity cursor-pointer shadow-xl active:scale-[0.97]"
                >
                  Registrar Boutique & Activar Tarifas Trade
                </button>
              </div>
            </form>
          </div>

        </div>

      </div>
    </div>
  );
}
