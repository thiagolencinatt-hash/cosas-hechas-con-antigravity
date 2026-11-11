import { useState, useEffect } from 'react';
import {
  X,
  Star,
  ShoppingBag,
  Droplets,
  MessageCircle,
  ShieldCheck,
  Truck,
  BadgeCheck,
  Minus,
  Plus,
  Activity,
  Clock,
  Wind,
  Flame,
} from 'lucide-react';
import { useShop, DEFAULT_WHATSAPP_NUMBER, WHOLESALE_MIN_UNITS } from '../context/ShopContext';
import { PricingMode } from '../types';

export function ProductModal() {
  const {
    selectedProductForModal,
    setSelectedProductForModal,
    formatPrice,
    addToCart,
    getItemQuantityInCart,
    globalPricingMode,
    showToast,
  } = useShop();

  const product = selectedProductForModal;

  const [modalMode, setModalMode] = useState<PricingMode>(globalPricingMode);
  const [quantity, setQuantity] = useState<number>(1);
  const [selectedFormat, setSelectedFormat] = useState<'100ml' | '50ml' | 'caja12'>('100ml');

  useEffect(() => {
    if (product) {
      setModalMode(globalPricingMode);
      setQuantity(globalPricingMode === 'mayorista' ? WHOLESALE_MIN_UNITS : 1);
    }
  }, [product, globalPricingMode]);

  const handleModeChange = (newMode: PricingMode) => {
    setModalMode(newMode);
    if (newMode === 'mayorista' && quantity < WHOLESALE_MIN_UNITS) {
      setQuantity(WHOLESALE_MIN_UNITS);
    } else if (newMode === 'minorista' && quantity < 1) {
      setQuantity(1);
    }
  };

  if (!product) return null;

  const inCartQty = getItemQuantityInCart(product.id);
  const baseUnitPrice = modalMode === 'mayorista' ? product.price : product.retailPrice;
  const activeUnitPrice = selectedFormat === 'caja12' ? Math.round(baseUnitPrice * 0.85) : baseUnitPrice;
  const totalPrice = activeUnitPrice * quantity;

  const handleAddToCart = () => {
    addToCart(product, quantity, modalMode);
    showToast(`Añadido ${quantity}u de ${product.name} al pedido.`);
    setSelectedProductForModal(null);
  };

  const askAboutThisPerfume = () => {
    const text = encodeURIComponent(
      `Hola LATHE ESSENCE! Deseo consultar disponibilidad sobre ${product.name} (${product.brand}) en formato ${selectedFormat.toUpperCase()} y modalidad ${modalMode.toUpperCase()} (${quantity} unidad${quantity > 1 ? 'es' : ''} a $ ${activeUnitPrice.toLocaleString('es-AR')} c/u).`
    );
    window.open(`https://wa.me/${DEFAULT_WHATSAPP_NUMBER}?text=${text}`, '_blank');
  };

  // Helper to safely parse comma-separated notes into chips
  const parseNotes = (notesList?: string[] | string): string[] => {
    if (!notesList) return [];
    if (Array.isArray(notesList)) return notesList;
    return typeof notesList === 'string' ? (notesList as string).split(',').map((n) => n.trim()) : [];
  };

  const topNotes = parseNotes(product.pyramid?.top || ['Bergamota de Calabria', 'Cardamomo Negro', 'Mandarina']);
  const heartNotes = parseNotes(product.pyramid?.heart || ['Oud de Trat', 'Rosa Damascena', 'Jazmín Sambac']);
  const baseNotes = parseNotes(product.pyramid?.base || ['Sándalo de Mysore', 'Ámbar Fosilizado', 'Cuero Ruso']);

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto bg-black/80 dark:bg-black/85 backdrop-blur-md flex items-center justify-center p-3 sm:p-6 animate-fade-in">
      {/* Click outside backdrop */}
      <div className="fixed inset-0" onClick={() => setSelectedProductForModal(null)} />

      {/* Main Modal Card */}
      <div
        className="relative w-full max-w-4xl bg-white dark:bg-[#0E1015] border border-black/10 dark:border-white/15 text-neutral-900 dark:text-white shadow-2xl max-h-[92vh] flex flex-col my-auto z-10 transition-colors duration-200 overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Top Header Bar */}
        <div className="p-4 sm:p-6 border-b border-black/10 dark:border-white/10 flex items-center justify-between bg-neutral-50 dark:bg-[#12141A] transition-colors">
          <div className="flex items-center gap-3">
            <img
              src="/images/logo/lathe-logo-black.png"
              alt="LATHE ESSENCE"
              className="h-6 w-auto object-contain dark:hidden"
            />
            <img
              src="/images/logo/lathe-logo-white.png"
              alt="LATHE ESSENCE"
              className="h-6 w-auto object-contain hidden dark:block"
            />
            <span className="font-mono text-[10px] text-[#c9a24b] uppercase tracking-[0.25em] border-l border-black/15 dark:border-white/15 pl-3 font-semibold">
              FICHA TÉCNICA OFICIAL // REF #{product.id.toString().padStart(4, '0')}
            </span>
          </div>

          <button
            onClick={() => setSelectedProductForModal(null)}
            className="p-2 text-neutral-500 hover:text-black dark:text-neutral-400 dark:hover:text-white bg-black/5 dark:bg-white/5 hover:bg-black/10 dark:hover:bg-white/10 transition-colors cursor-pointer"
            aria-label="Cerrar modal"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Modal Scrollable Body */}
        <div className="overflow-y-auto flex-1 p-6 sm:p-8 space-y-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-start">

            {/* Product Image Stage */}
            <div className="relative aspect-square bg-neutral-100 dark:bg-[#12141A] border border-black/10 dark:border-white/10 p-8 flex items-center justify-center group overflow-hidden transition-colors">
              <img
                src={product.image}
                alt={product.name}
                className="w-full h-full object-contain filter drop-shadow-[0_15px_30px_rgba(0,0,0,0.15)] dark:drop-shadow-[0_15px_30px_rgba(0,0,0,0.9)] transition-transform duration-500 group-hover:scale-105"
              />
              {product.tag && (
                <div className="absolute top-4 left-4 px-3 py-1 font-sans text-[11px] tracking-wider uppercase bg-white dark:bg-[#1F232B] text-neutral-900 dark:text-[#c9a24b] border border-black/10 dark:border-[#c9a24b]/40 font-bold shadow-md">
                  {product.tag}
                </div>
              )}
              <div className="absolute bottom-4 right-4 font-mono text-[10px] text-neutral-700 dark:text-neutral-300 bg-white/90 dark:bg-black/80 px-2.5 py-1 border border-black/10 dark:border-white/10 font-medium">
                LOTE NUMERADO COA
              </div>
            </div>

            {/* Product Info & Action Controls */}
            <div className="flex flex-col justify-between">
              <div>
                <div className="flex items-center gap-2 text-xs font-sans font-semibold text-[#c9a24b] uppercase tracking-wider mb-2">
                  <span>{product.brand}</span>
                  <span>•</span>
                  <span>{product.gender}</span>
                  <span>•</span>
                  <span>{product.category}</span>
                </div>

                <h2 className="font-serif text-3xl sm:text-4xl font-normal text-neutral-900 dark:text-white tracking-tight leading-tight">
                  {product.name}
                </h2>

                <p className="text-xs text-neutral-600 dark:text-neutral-400 font-sans font-normal mt-1.5">
                  Concentración: <strong>32% Extrait de Parfum</strong> • Origen: Grasse & Dubái
                </p>

                {/* Rating & In-stock badge */}
                <div className="flex items-center gap-3 mt-3 text-xs text-neutral-600 dark:text-neutral-400 font-sans">
                  <div className="flex items-center gap-1 text-neutral-900 dark:text-white font-semibold">
                    <Star className="w-3.5 h-3.5 fill-[#c9a24b] text-[#c9a24b]" />
                    <span>{product.rating}</span>
                  </div>
                  <span>•</span>
                  <span className="text-emerald-600 dark:text-emerald-400 font-sans text-xs flex items-center gap-1.5 font-medium">
                    <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                    En Stock Inmediato ({product.inStock !== false ? '140+ uds' : 'Consultar stock'})
                  </span>
                </div>

                {/* Format Selection (50ml / 100ml / Caja Master 12u) */}
                <div className="mt-5 space-y-2">
                  <span className="font-sans text-xs font-semibold text-neutral-600 dark:text-neutral-400 uppercase tracking-wider block">
                    Selección de Formato
                  </span>
                  <div className="grid grid-cols-3 gap-2">
                    <button
                      type="button"
                      onClick={() => setSelectedFormat('50ml')}
                      className={`p-2 font-sans text-xs text-center border transition-all cursor-pointer ${
                        selectedFormat === '50ml'
                          ? 'border-black bg-black text-white dark:border-white dark:bg-white dark:text-black font-semibold shadow-sm'
                          : 'border-black/10 dark:border-white/10 bg-neutral-100 dark:bg-[#161820] text-neutral-700 dark:text-neutral-300 hover:border-black/30 dark:hover:border-white/30'
                      }`}
                    >
                      50 ML Flacon
                    </button>
                    <button
                      type="button"
                      onClick={() => setSelectedFormat('100ml')}
                      className={`p-2 font-sans text-xs text-center border transition-all cursor-pointer ${
                        selectedFormat === '100ml'
                          ? 'border-black bg-black text-white dark:border-white dark:bg-white dark:text-black font-semibold shadow-sm'
                          : 'border-black/10 dark:border-white/10 bg-neutral-100 dark:bg-[#161820] text-neutral-700 dark:text-neutral-300 hover:border-black/30 dark:hover:border-white/30'
                      }`}
                    >
                      100 ML Extrait
                    </button>
                    <button
                      type="button"
                      onClick={() => {
                        setSelectedFormat('caja12');
                        handleModeChange('mayorista');
                      }}
                      className={`p-2 font-sans text-xs text-center border transition-all cursor-pointer ${
                        selectedFormat === 'caja12'
                          ? 'border-[#c9a24b] bg-[#c9a24b] text-black font-bold shadow-md'
                          : 'border-black/10 dark:border-white/10 bg-neutral-100 dark:bg-[#161820] text-[#c9a24b] hover:border-[#c9a24b]/40 font-medium'
                      }`}
                    >
                      Caja Master 12u
                    </button>
                  </div>
                </div>

                {/* Pricing Mode Selector Pill */}
                <div className="mt-4 p-1.5 bg-neutral-100 dark:bg-[#14161D] border border-black/10 dark:border-white/10 transition-colors">
                  <div className="text-[11px] font-sans font-semibold text-neutral-500 dark:text-neutral-400 uppercase tracking-wider px-2 pt-1 pb-1">
                    Modalidad de Compra
                  </div>
                  <div className="grid grid-cols-2 gap-1.5">
                    <button
                      type="button"
                      onClick={() => handleModeChange('minorista')}
                      className={`py-2 px-3 text-xs font-sans uppercase tracking-wider transition-all text-center flex flex-col items-center justify-center cursor-pointer ${
                        modalMode === 'minorista'
                          ? 'bg-white dark:bg-black text-black dark:text-white font-bold shadow-sm border border-black/10 dark:border-white/15'
                          : 'text-neutral-600 dark:text-neutral-400 hover:text-black dark:hover:text-white'
                      }`}
                    >
                      <span className="font-bold">Venta Minorista</span>
                      <span className="text-[10px] opacity-80 font-normal">Desde 1 unidad</span>
                    </button>

                    <button
                      type="button"
                      onClick={() => handleModeChange('mayorista')}
                      className={`py-2 px-3 text-xs font-sans uppercase tracking-wider transition-all text-center flex flex-col items-center justify-center cursor-pointer ${
                        modalMode === 'mayorista'
                          ? 'bg-[#c9a24b] text-black font-bold shadow-sm'
                          : 'text-neutral-600 dark:text-neutral-400 hover:text-black dark:hover:text-white'
                      }`}
                    >
                      <span className="font-bold">Venta Mayorista B2B</span>
                      <span className="text-[10px] opacity-90 font-medium">Desde 3u (-35% a -45%)</span>
                    </button>
                  </div>
                </div>

                {/* Dynamic Price Box */}
                <div className="my-4 p-4 bg-neutral-50 dark:bg-[#14161D] border border-black/10 dark:border-white/10 transition-colors">
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="text-[10px] font-mono text-neutral-500 dark:text-neutral-400 uppercase tracking-widest font-semibold">
                        {modalMode === 'mayorista' ? 'Tarifa Mayorista Neta' : 'Precio Sugerido Retail (PVP)'}
                      </div>
                      <div className="flex items-baseline gap-2 mt-1">
                        <span className="font-sans text-3xl font-bold tabular-nums text-neutral-900 dark:text-white">
                          {formatPrice(activeUnitPrice)}
                        </span>
                        {modalMode === 'mayorista' && product.retailPrice && (
                          <span className="text-sm font-sans text-neutral-400 line-through tabular-nums">
                            {formatPrice(product.retailPrice)}
                          </span>
                        )}
                      </div>
                    </div>

                    {modalMode === 'mayorista' && (
                      <span className="px-3 py-1 font-sans text-xs bg-[#c9a24b]/20 text-[#c9a24b] border border-[#c9a24b]/40 font-bold">
                        Margen Comercial: -35%
                      </span>
                    )}
                  </div>

                  <div className="text-xs text-neutral-600 dark:text-neutral-400 font-sans mt-3 pt-2.5 border-t border-black/10 dark:border-white/10 flex items-center justify-between">
                    <span>
                      {modalMode === 'mayorista'
                        ? 'Mínimo 3 unidades surtidas de cualquier fragancia.'
                        : 'Despacho individual sin mínimo.'}
                    </span>
                    <span className="font-bold text-neutral-900 dark:text-white">
                      Subtotal: {formatPrice(totalPrice)}
                    </span>
                  </div>
                </div>

                {/* Quantity Stepper */}
                <div className="flex items-center justify-between p-3 bg-neutral-50 dark:bg-[#14161D] border border-black/10 dark:border-white/10 mb-4 transition-colors">
                  <span className="text-xs font-sans font-semibold uppercase tracking-wide text-neutral-700 dark:text-neutral-300">
                    Cantidad a solicitar:
                  </span>
                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => {
                        const minAllowed = modalMode === 'mayorista' ? WHOLESALE_MIN_UNITS : 1;
                        if (quantity > minAllowed) setQuantity(quantity - 1);
                      }}
                      disabled={quantity <= (modalMode === 'mayorista' ? WHOLESALE_MIN_UNITS : 1)}
                      className="w-8 h-8 bg-white dark:bg-[#1F232B] border border-black/15 dark:border-white/15 flex items-center justify-center text-neutral-900 dark:text-white disabled:opacity-30 disabled:cursor-not-allowed transition-opacity cursor-pointer shadow-sm active:scale-95"
                      aria-label="Restar una unidad"
                    >
                      <Minus className="w-3.5 h-3.5" />
                    </button>

                    <span className="font-sans font-bold text-sm min-w-[28px] text-center text-neutral-900 dark:text-white">
                      {quantity}
                    </span>

                    <button
                      type="button"
                      onClick={() => setQuantity(quantity + 1)}
                      className="w-8 h-8 bg-white dark:bg-[#1F232B] border border-black/15 dark:border-white/15 flex items-center justify-center text-neutral-900 dark:text-white cursor-pointer shadow-sm active:scale-95"
                      aria-label="Sumar una unidad"
                    >
                      <Plus className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>

                <p className="text-xs sm:text-sm text-neutral-600 dark:text-neutral-300 font-sans leading-relaxed mb-6 font-normal">
                  {product.description}
                </p>
              </div>

              {/* Action Buttons */}
              <div className="space-y-2.5">
                <button
                  onClick={handleAddToCart}
                  className="w-full py-3.5 bg-black dark:bg-white text-white dark:text-black hover:opacity-90 font-sans text-xs uppercase tracking-wider font-bold flex items-center justify-center gap-2 transition-all active:scale-[0.97] cursor-pointer shadow-lg"
                >
                  <ShoppingBag className="w-4 h-4" />
                  <span>
                    {inCartQty > 0
                      ? `Sumar ${quantity} u. (Ya tenés ${inCartQty} en pedido)`
                      : `Añadir ${quantity} ${quantity === 1 ? 'unidad' : 'unidades'} al pedido`}
                  </span>
                </button>

                <button
                  onClick={askAboutThisPerfume}
                  className="w-full py-2.5 border border-black/15 dark:border-white/20 hover:border-black/40 dark:hover:border-white/50 text-neutral-800 dark:text-white font-sans text-xs uppercase tracking-wider font-semibold flex items-center justify-center gap-2 transition-all active:scale-[0.97] cursor-pointer bg-neutral-100/50 dark:bg-white/5"
                >
                  <MessageCircle className="w-4 h-4 text-emerald-500" />
                  <span>Consultar con Especialista por WhatsApp</span>
                </button>
              </div>
            </div>

          </div>

          {/* ═══════════════════════════════════════════════════════════════
             FICHA TÉCNICA OFICIAL & ARQUITECTURA OLFATIVA (MÁXIMA LEGIBILIDAD)
             ═══════════════════════════════════════════════════════════════ */}
          <div className="pt-6 border-t border-black/10 dark:border-white/10 space-y-6">
            
            {/* Header section with clean sans typography */}
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
              <div className="flex items-center gap-2.5">
                <div className="w-7 h-7 rounded-full bg-[#c9a24b]/15 flex items-center justify-center text-[#c9a24b]">
                  <Droplets className="w-4 h-4" />
                </div>
                <div>
                  <h3 className="font-sans text-base sm:text-lg font-bold text-neutral-900 dark:text-white tracking-tight">
                    Pirámide Olfativa & Evolución en Piel
                  </h3>
                  <p className="font-sans text-xs text-neutral-500 dark:text-neutral-400">
                    Ficha técnica de destilación sensorial y curvas moleculares
                  </p>
                </div>
              </div>
              <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase tracking-wider bg-neutral-100 dark:bg-white/5 px-2.5 py-1 self-start sm:self-auto border border-black/5 dark:border-white/10">
                Lote Certificado IFRA
              </span>
            </div>

            {/* 3 Clear Editorial Cards for Top, Heart and Base Notes */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              
              {/* 01 / Notas de Salida */}
              <div className="p-5 bg-neutral-50 dark:bg-[#14161D] border border-black/10 dark:border-white/10 flex flex-col justify-between transition-colors">
                <div>
                  <div className="flex items-center justify-between mb-3 pb-2 border-b border-black/5 dark:border-white/10">
                    <span className="font-sans text-xs font-bold uppercase tracking-wider text-neutral-800 dark:text-neutral-200">
                      01 / Salida
                    </span>
                    <span className="font-mono text-[11px] font-semibold text-[#c9a24b] bg-[#c9a24b]/10 px-2 py-0.5 rounded-full">
                      0 — 30 min
                    </span>
                  </div>

                  {/* Note Chips */}
                  <div className="flex flex-wrap gap-1.5 mb-3">
                    {topNotes.map((note, idx) => (
                      <span
                        key={idx}
                        className="inline-block px-2.5 py-1 bg-white dark:bg-white/10 border border-black/10 dark:border-white/15 rounded-md text-xs font-sans font-medium text-neutral-900 dark:text-neutral-100 shadow-sm"
                      >
                        {note}
                      </span>
                    ))}
                  </div>
                </div>

                <div className="pt-2 border-t border-black/5 dark:border-white/5 flex items-center gap-1.5 text-[11px] font-sans text-neutral-500 dark:text-neutral-400">
                  <Wind className="w-3.5 h-3.5 text-neutral-400" />
                  <span>Alta volatilidad • Primera impresión</span>
                </div>
              </div>

              {/* 02 / Notas de Corazón */}
              <div className="p-5 bg-neutral-50 dark:bg-[#14161D] border border-black/10 dark:border-white/10 flex flex-col justify-between transition-colors">
                <div>
                  <div className="flex items-center justify-between mb-3 pb-2 border-b border-black/5 dark:border-white/10">
                    <span className="font-sans text-xs font-bold uppercase tracking-wider text-neutral-800 dark:text-neutral-200">
                      02 / Corazón
                    </span>
                    <span className="font-mono text-[11px] font-semibold text-blue-600 dark:text-blue-400 bg-blue-500/10 px-2 py-0.5 rounded-full">
                      30 min — 4h
                    </span>
                  </div>

                  {/* Note Chips */}
                  <div className="flex flex-wrap gap-1.5 mb-3">
                    {heartNotes.map((note, idx) => (
                      <span
                        key={idx}
                        className="inline-block px-2.5 py-1 bg-white dark:bg-white/10 border border-black/10 dark:border-white/15 rounded-md text-xs font-sans font-medium text-neutral-900 dark:text-neutral-100 shadow-sm"
                      >
                        {note}
                      </span>
                    ))}
                  </div>
                </div>

                <div className="pt-2 border-t border-black/5 dark:border-white/5 flex items-center gap-1.5 text-[11px] font-sans text-neutral-500 dark:text-neutral-400">
                  <Flame className="w-3.5 h-3.5 text-blue-400" />
                  <span>Cuerpo central • Carácter distintivo</span>
                </div>
              </div>

              {/* 03 / Notas de Fondo */}
              <div className="p-5 bg-neutral-50 dark:bg-[#14161D] border border-black/10 dark:border-white/10 flex flex-col justify-between transition-colors">
                <div>
                  <div className="flex items-center justify-between mb-3 pb-2 border-b border-black/5 dark:border-white/10">
                    <span className="font-sans text-xs font-bold uppercase tracking-wider text-neutral-800 dark:text-neutral-200">
                      03 / Fondo
                    </span>
                    <span className="font-mono text-[11px] font-semibold text-amber-600 dark:text-[#e6cb85] bg-amber-500/10 px-2 py-0.5 rounded-full">
                      4h — 18h+
                    </span>
                  </div>

                  {/* Note Chips */}
                  <div className="flex flex-wrap gap-1.5 mb-3">
                    {baseNotes.map((note, idx) => (
                      <span
                        key={idx}
                        className="inline-block px-2.5 py-1 bg-white dark:bg-white/10 border border-black/10 dark:border-white/15 rounded-md text-xs font-sans font-medium text-neutral-900 dark:text-neutral-100 shadow-sm"
                      >
                        {note}
                      </span>
                    ))}
                  </div>
                </div>

                <div className="pt-2 border-t border-black/5 dark:border-white/5 flex items-center gap-1.5 text-[11px] font-sans text-neutral-500 dark:text-neutral-400">
                  <Clock className="w-3.5 h-3.5 text-amber-500" />
                  <span>Fijación duradera • Estela magnética</span>
                </div>
              </div>

            </div>

            {/* Performance Metrics: 4 Clear Boxes */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
              <div className="p-3.5 bg-neutral-100/70 dark:bg-[#12141A] border border-black/10 dark:border-white/10">
                <span className="font-sans text-[10px] uppercase font-bold text-neutral-500 dark:text-neutral-400 block mb-1">
                  Longevidad en Piel
                </span>
                <span className="font-sans text-sm font-bold text-neutral-900 dark:text-white">
                  12 a 18 Horas
                </span>
                <span className="text-[10px] text-emerald-600 dark:text-emerald-400 block mt-0.5 font-medium">
                  Excelente tenacidad
                </span>
              </div>

              <div className="p-3.5 bg-neutral-100/70 dark:bg-[#12141A] border border-black/10 dark:border-white/10">
                <span className="font-sans text-[10px] uppercase font-bold text-neutral-500 dark:text-neutral-400 block mb-1">
                  Estela & Sillage
                </span>
                <span className="font-sans text-sm font-bold text-neutral-900 dark:text-white">
                  Alta Proyección (2m)
                </span>
                <span className="text-[10px] text-neutral-500 dark:text-neutral-400 block mt-0.5">
                  Firma olfativa marcada
                </span>
              </div>

              <div className="p-3.5 bg-neutral-100/70 dark:bg-[#12141A] border border-black/10 dark:border-white/10">
                <span className="font-sans text-[10px] uppercase font-bold text-neutral-500 dark:text-neutral-400 block mb-1">
                  Concentración
                </span>
                <span className="font-sans text-sm font-bold text-[#c9a24b]">
                  32% Extrait de Parfum
                </span>
                <span className="text-[10px] text-neutral-500 dark:text-neutral-400 block mt-0.5">
                  Aceites puros destilados
                </span>
              </div>

              <div className="p-3.5 bg-neutral-100/70 dark:bg-[#12141A] border border-black/10 dark:border-white/10">
                <span className="font-sans text-[10px] uppercase font-bold text-neutral-500 dark:text-neutral-400 block mb-1">
                  Garantía & Origen
                </span>
                <span className="font-sans text-sm font-bold text-neutral-900 dark:text-white">
                  100% Original
                </span>
                <span className="text-[10px] text-neutral-500 dark:text-neutral-400 block mt-0.5">
                  Lote con trazabilidad
                </span>
              </div>
            </div>

            {/* Molecular Evaporation Graph SVG (Clean Theme-Adaptive) */}
            <div className="p-5 bg-neutral-50 dark:bg-[#12141A] border border-black/10 dark:border-white/10 transition-colors">
              <div className="flex items-center justify-between mb-3">
                <span className="font-sans text-xs uppercase font-bold tracking-wider text-neutral-800 dark:text-neutral-200 flex items-center gap-2">
                  <Activity className="w-4 h-4 text-[#c9a24b]" />
                  Curva de Tenacidad & Difusión Molecular
                </span>
                <span className="font-sans text-xs text-neutral-500 dark:text-neutral-400 font-medium">
                  Fijación Epidérmica: 18h+
                </span>
              </div>

              <div className="w-full">
                <svg className="w-full h-32 sm:h-36" fill="none" viewBox="0 0 320 160">
                  {/* Grid Lines */}
                  <line stroke="currentColor" className="text-black/10 dark:text-white/10" strokeDasharray="3 3" strokeWidth="1" x1="40" x2="40" y1="20" y2="130" />
                  <line stroke="currentColor" className="text-black/15 dark:text-white/15" strokeWidth="1" x1="40" x2="300" y1="130" y2="130" />
                  <line stroke="currentColor" className="text-black/10 dark:text-white/10" strokeDasharray="3 3" strokeWidth="1" x1="40" x2="300" y1="80" y2="80" />
                  <line stroke="currentColor" className="text-black/10 dark:text-white/10" strokeDasharray="3 3" strokeWidth="1" x1="40" x2="300" y1="30" y2="30" />
                  
                  {/* Curve 1: Top Notes (Fast evaporation) */}
                  <path d="M40,30 Q90,110 150,130" stroke="#9ca3af" strokeDasharray="4 3" strokeWidth="2" />
                  {/* Curve 2: Heart Notes (Medium diffusion) */}
                  <path d="M40,75 Q120,40 220,125" stroke="#3b82f6" strokeWidth="2.5" />
                  {/* Curve 3: Base Notes (Long Tenacity) */}
                  <path d="M40,110 Q110,60 300,65" stroke="#c9a24b" strokeWidth="3" />
                  
                  {/* Axis Labels */}
                  <text className="fill-neutral-500 dark:fill-neutral-400 font-sans text-[10px]" textAnchor="start" x="35" y="148">0h (Salida)</text>
                  <text className="fill-neutral-500 dark:fill-neutral-400 font-sans text-[10px]" textAnchor="middle" x="160" y="148">6 Horas</text>
                  <text className="fill-neutral-500 dark:fill-neutral-400 font-sans text-[10px]" textAnchor="end" x="300" y="148">18+ Horas</text>
                </svg>
              </div>

              <div className="flex flex-wrap items-center justify-between text-xs font-sans text-neutral-600 dark:text-neutral-400 mt-2 pt-2 border-t border-black/5 dark:border-white/5">
                <span className="flex items-center gap-1.5 font-medium">
                  <span className="w-3 h-1 bg-[#9ca3af] rounded-full" /> Salida (0 — 30m)
                </span>
                <span className="flex items-center gap-1.5 font-medium">
                  <span className="w-3 h-1 bg-[#3b82f6] rounded-full" /> Corazón (30m — 4h)
                </span>
                <span className="flex items-center gap-1.5 font-medium">
                  <span className="w-3 h-1 bg-[#c9a24b] rounded-full" /> Base / Sillage (4h — 18h+)
                </span>
              </div>
            </div>

            {/* Trust Badges Footer */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 text-neutral-600 dark:text-neutral-400 text-xs font-sans pt-2">
              <div className="flex items-center gap-2">
                <BadgeCheck className="w-4 h-4 text-[#c9a24b] shrink-0" />
                <span>Normas IFRA / Paris & Grasse</span>
              </div>
              <div className="flex items-center gap-2">
                <Truck className="w-4 h-4 text-[#c9a24b] shrink-0" />
                <span>Envíos Asegurados a Todo el País</span>
              </div>
              <div className="flex items-center gap-2">
                <ShieldCheck className="w-4 h-4 text-[#c9a24b] shrink-0" />
                <span>Garantía de Origen 100% Original</span>
              </div>
            </div>

          </div>

        </div>
      </div>
    </div>
  );
}
