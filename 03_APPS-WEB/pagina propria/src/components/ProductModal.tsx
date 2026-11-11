import { useState, useEffect } from 'react';
import { X, Star, ShoppingBag, Droplets, MessageCircle, ShieldCheck, Truck, BadgeCheck, Minus, Plus, Activity } from 'lucide-react';
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

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto bg-black/85 backdrop-blur-md flex items-center justify-center p-3 sm:p-6 animate-fade-in">
      <div className="fixed inset-0" onClick={() => setSelectedProductForModal(null)} />

      <div
        className="relative w-full max-w-4xl bg-[#0D0E12] border border-white/15 text-white shadow-2xl max-h-[92vh] flex flex-col my-auto z-10 transition-colors duration-200 overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Top Header Bar */}
        <div className="p-4 sm:p-6 border-b border-white/10 flex items-center justify-between bg-[#12141A]">
          <div className="flex items-center gap-3">
            <img
              src="/images/logo/lathe-logo-white.png"
              alt="LATHE ESSENCE"
              className="h-6 w-auto object-contain"
            />
            <span className="font-mono text-[10px] text-[#c9a24b] uppercase tracking-[0.25em] border-l border-white/15 pl-3">
              FICHA TÉCNICA OFICIAL // REF #{product.id.toString().padStart(4, '0')}
            </span>
          </div>

          <button
            onClick={() => setSelectedProductForModal(null)}
            className="p-2 text-neutral-400 hover:text-white bg-white/5 hover:bg-white/10 transition-colors cursor-pointer"
            aria-label="Cerrar modal"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Modal Scrollable Body */}
        <div className="overflow-y-auto flex-1 p-6 sm:p-8 space-y-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-start">

            {/* Product Image Stage */}
            <div className="relative aspect-square bg-[#12141A] border border-white/10 p-8 flex items-center justify-center group overflow-hidden">
              <img
                src={product.image}
                alt={product.name}
                className="w-full h-full object-contain filter drop-shadow-[0_15px_30px_rgba(0,0,0,0.9)] transition-transform duration-500 group-hover:scale-105"
              />
              {product.tag && (
                <div className="absolute top-4 left-4 px-3 py-1 font-mono text-[10px] tracking-wider uppercase bg-[#1F232B] text-[#c9a24b] border border-[#c9a24b]/40 font-semibold shadow-md">
                  {product.tag}
                </div>
              )}
              <div className="absolute bottom-4 right-4 font-mono text-[10px] text-neutral-400 bg-black/70 px-2.5 py-1 border border-white/10">
                LOTE NUMERADO COA
              </div>
            </div>

            {/* Product Info & Action Controls */}
            <div className="flex flex-col justify-between">
              <div>
                <div className="flex items-center gap-2 text-xs font-mono text-[#c9a24b] uppercase tracking-widest mb-1.5">
                  <span>{product.brand}</span>
                  <span>•</span>
                  <span>{product.gender}</span>
                  <span>•</span>
                  <span>{product.category}</span>
                </div>

                <h2 className="font-serif text-3xl sm:text-4xl font-normal text-white tracking-tight leading-tight">
                  {product.name}
                </h2>

                <p className="text-xs text-neutral-400 font-mono mt-1">
                  Concentración: 32% Extrait de Parfum • Origen: Grasse & Dubái
                </p>

                {/* Rating & In-stock badge */}
                <div className="flex items-center gap-3 mt-3 text-xs text-neutral-400">
                  <div className="flex items-center gap-1 text-white font-medium">
                    <Star className="w-3.5 h-3.5 fill-[#c9a24b] text-[#c9a24b]" />
                    <span>{product.rating}</span>
                  </div>
                  <span>•</span>
                  <span className="text-emerald-400 font-mono text-[11px] flex items-center gap-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                    En Stock Inmediato ({product.inStock !== false ? '140+ uds' : 'Consultar stock'})
                  </span>
                </div>

                {/* Format Selection (50ml / 100ml / Caja Master 12u) */}
                <div className="mt-5 space-y-2">
                  <span className="font-mono text-[10px] text-neutral-400 uppercase tracking-widest block">
                    Selección de Formato
                  </span>
                  <div className="grid grid-cols-3 gap-2">
                    <button
                      type="button"
                      onClick={() => setSelectedFormat('50ml')}
                      className={`p-2 font-mono text-xs text-center border transition-all ${
                        selectedFormat === '50ml'
                          ? 'border-white bg-white text-black font-semibold'
                          : 'border-white/10 bg-[#161820] text-neutral-300 hover:border-white/30'
                      }`}
                    >
                      50 ML Flacon
                    </button>
                    <button
                      type="button"
                      onClick={() => setSelectedFormat('100ml')}
                      className={`p-2 font-mono text-xs text-center border transition-all ${
                        selectedFormat === '100ml'
                          ? 'border-white bg-white text-black font-semibold'
                          : 'border-white/10 bg-[#161820] text-neutral-300 hover:border-white/30'
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
                      className={`p-2 font-mono text-xs text-center border transition-all ${
                        selectedFormat === 'caja12'
                          ? 'border-[#c9a24b] bg-[#c9a24b] text-black font-semibold'
                          : 'border-white/10 bg-[#161820] text-[#c9a24b] hover:border-white/30'
                      }`}
                    >
                      Caja Master 12u
                    </button>
                  </div>
                </div>

                {/* Pricing Mode Selector Pill */}
                <div className="mt-4 p-1.5 bg-[#14161D] border border-white/10">
                  <div className="text-[10px] font-mono text-neutral-400 uppercase tracking-wider px-2 pt-1 pb-1">
                    Modalidad de Compra
                  </div>
                  <div className="grid grid-cols-2 gap-1.5">
                    <button
                      type="button"
                      onClick={() => handleModeChange('minorista')}
                      className={`py-2 px-3 text-xs font-mono uppercase tracking-wider transition-all text-center flex flex-col items-center justify-center ${
                        modalMode === 'minorista'
                          ? 'bg-white text-black font-bold'
                          : 'text-neutral-400 hover:text-white'
                      }`}
                    >
                      <span>Venta Minorista</span>
                      <span className="text-[9px] opacity-75 font-normal">Desde 1 unidad</span>
                    </button>

                    <button
                      type="button"
                      onClick={() => handleModeChange('mayorista')}
                      className={`py-2 px-3 text-xs font-mono uppercase tracking-wider transition-all text-center flex flex-col items-center justify-center ${
                        modalMode === 'mayorista'
                          ? 'bg-[#c9a24b] text-black font-bold'
                          : 'text-neutral-400 hover:text-white'
                      }`}
                    >
                      <span>Venta Mayorista B2B</span>
                      <span className="text-[9px] opacity-75 font-normal">Desde 3u (-35% a -45%)</span>
                    </button>
                  </div>
                </div>

                {/* Dynamic Price Box */}
                <div className="my-4 p-4 bg-[#14161D] border border-white/10">
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="text-[10px] font-mono text-neutral-400 uppercase tracking-widest">
                        {modalMode === 'mayorista' ? 'Tarifa Mayorista Neta' : 'Precio Sugerido Retail (MSRP)'}
                      </div>
                      <div className="flex items-baseline gap-2 mt-1">
                        <span className="font-serif text-3xl font-semibold tabular-nums text-white">
                          {formatPrice(activeUnitPrice)}
                        </span>
                        {modalMode === 'mayorista' && product.retailPrice && (
                          <span className="text-sm font-mono text-neutral-500 line-through tabular-nums">
                            {formatPrice(product.retailPrice)}
                          </span>
                        )}
                      </div>
                    </div>

                    {modalMode === 'mayorista' && (
                      <span className="px-3 py-1 font-mono text-xs bg-[#c9a24b]/20 text-[#c9a24b] border border-[#c9a24b]/40 font-semibold">
                        Margen Comercial: -35%
                      </span>
                    )}
                  </div>

                  <div className="text-[11px] text-neutral-400 font-mono mt-3 pt-2.5 border-t border-white/10 flex items-center justify-between">
                    <span>
                      {modalMode === 'mayorista'
                        ? 'Mínimo 3 unidades surtidas de cualquier fragancia.'
                        : 'Despacho individual sin mínimo.'}
                    </span>
                    <span className="font-bold text-white">
                      Subtotal: {formatPrice(totalPrice)}
                    </span>
                  </div>
                </div>

                {/* Quantity Stepper */}
                <div className="flex items-center justify-between p-3 bg-[#14161D] border border-white/10 mb-4">
                  <span className="text-xs font-mono uppercase text-neutral-300">
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
                      className="w-8 h-8 bg-[#1F232B] border border-white/15 flex items-center justify-center text-white disabled:opacity-30 disabled:cursor-not-allowed transition-opacity"
                      aria-label="Restar una unidad"
                    >
                      <Minus className="w-3.5 h-3.5" />
                    </button>

                    <span className="font-mono font-bold text-sm min-w-[28px] text-center text-white">
                      {quantity}
                    </span>

                    <button
                      type="button"
                      onClick={() => setQuantity(quantity + 1)}
                      className="w-8 h-8 bg-[#1F232B] border border-white/15 flex items-center justify-center text-white"
                      aria-label="Sumar una unidad"
                    >
                      <Plus className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>

                <p className="text-xs sm:text-sm text-neutral-300 font-sans leading-relaxed mb-6 font-light">
                  {product.description}
                </p>
              </div>

              {/* Action Buttons */}
              <div className="space-y-2.5">
                <button
                  onClick={handleAddToCart}
                  className="w-full py-3.5 bg-white text-black hover:bg-neutral-200 font-mono text-xs uppercase tracking-wider font-semibold flex items-center justify-center gap-2 transition-all active:scale-[0.97] cursor-pointer shadow-lg"
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
                  className="w-full py-2.5 border border-white/20 hover:border-white/50 text-white font-mono text-xs uppercase tracking-wider flex items-center justify-center gap-2 transition-all active:scale-[0.97] cursor-pointer"
                >
                  <MessageCircle className="w-4 h-4 text-emerald-400" />
                  <span>Consultar con Especialista por WhatsApp</span>
                </button>
              </div>
            </div>

          </div>

          {/* Olfactory Pyramid & Molecular Evaporation Curve (Stitch Specification) */}
          <div className="pt-6 border-t border-white/10 space-y-6">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-mono uppercase tracking-widest text-[#c9a24b] flex items-center gap-2">
                <Droplets className="w-4 h-4" />
                <span>Arquitectura Olfativa & Evolución Molecular</span>
              </h3>
              <span className="font-mono text-[10px] text-neutral-500 uppercase">
                Análisis Espectrométrico
              </span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              {/* Salida */}
              <div className="p-4 bg-[#14161D] border border-white/10 flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="font-mono text-[10px] text-neutral-400 uppercase tracking-widest">
                      01 / Notas de Salida
                    </span>
                    <span className="font-mono text-[10px] text-[#c9a24b]">0 — 30 min</span>
                  </div>
                  <p className="font-serif text-lg text-white font-normal mb-1">
                    {(product.pyramid?.top && product.pyramid.top.join(', ')) || 'Bergamota de Calabria, Cardamomo Negro'}
                  </p>
                </div>
                <span className="font-mono text-[10px] text-neutral-500 uppercase mt-2">
                  Alta volatilidad • Primera impresión
                </span>
              </div>

              {/* Corazón */}
              <div className="p-4 bg-[#14161D] border border-white/10 flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="font-mono text-[10px] text-neutral-400 uppercase tracking-widest">
                      02 / Notas de Corazón
                    </span>
                    <span className="font-mono text-[10px] text-secondary">30 min — 4h</span>
                  </div>
                  <p className="font-serif text-lg text-white font-normal mb-1">
                    {(product.pyramid?.heart && product.pyramid.heart.join(', ')) || 'Oud de Trat, Rosa Damascena, Incienso'}
                  </p>
                </div>
                <span className="font-mono text-[10px] text-neutral-500 uppercase mt-2">
                  Cuerpo central • Difusión media
                </span>
              </div>

              {/* Fondo */}
              <div className="p-4 bg-[#14161D] border border-white/10 flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="font-mono text-[10px] text-neutral-400 uppercase tracking-widest">
                      03 / Notas de Fondo
                    </span>
                    <span className="font-mono text-[10px] text-white">4h — 18h+</span>
                  </div>
                  <p className="font-serif text-lg text-white font-normal mb-1">
                    {(product.pyramid?.base && product.pyramid.base.join(', ')) || 'Sándalo de Mysore, Ámbar Fosilizado, Cuero'}
                  </p>
                </div>
                <span className="font-mono text-[10px] text-neutral-500 uppercase mt-2">
                  Fijación molecular • Estela sillage
                </span>
              </div>
            </div>

            {/* Molecular Evaporation Graph SVG (Stitch Extraction) */}
            <div className="p-6 bg-[#12141A] border border-white/10">
              <div className="flex items-center justify-between mb-4">
                <span className="font-mono text-xs uppercase tracking-widest text-neutral-300 flex items-center gap-2">
                  <Activity className="w-3.5 h-3.5 text-[#c9a24b]" />
                  Curva de Tenacidad & Evaporación Molecular
                </span>
                <span className="font-mono text-[10px] text-neutral-400 uppercase">
                  Fijación en Epidermis: 18 Horas
                </span>
              </div>

              <div className="w-full">
                <svg className="w-full h-32 sm:h-40 text-primary" fill="none" stroke="currentColor" viewBox="0 0 320 180">
                  {/* Grid Lines */}
                  <line stroke="#292A2E" strokeDasharray="2 2" strokeWidth="1" x1="40" x2="40" y1="20" y2="150" />
                  <line stroke="#292A2E" strokeWidth="1" x1="40" x2="300" y1="150" y2="150" />
                  <line stroke="#292A2E" strokeDasharray="2 2" strokeWidth="1" x1="40" x2="300" y1="90" y2="90" />
                  <line stroke="#292A2E" strokeDasharray="2 2" strokeWidth="1" x1="40" x2="300" y1="30" y2="30" />
                  
                  {/* Curve 1: Top Notes */}
                  <path d="M40,30 Q90,120 150,150" stroke="#8f9194" strokeDasharray="3 3" strokeWidth="1.5" />
                  {/* Curve 2: Heart Notes */}
                  <path d="M40,75 Q120,45 220,145" stroke="#b9c8de" strokeWidth="2" />
                  {/* Curve 3: Base Notes (Long Tenacity) */}
                  <path d="M40,110 Q110,65 300,70" stroke="#c9a24b" strokeWidth="2.5" />
                  
                  {/* Axis Labels */}
                  <text fill="#8f9194" fontFamily="Geist" fontSize="9" textAnchor="start" x="35" y="170">0H (Aplicación)</text>
                  <text fill="#8f9194" fontFamily="Geist" fontSize="9" textAnchor="middle" x="160" y="170">6 Horas</text>
                  <text fill="#8f9194" fontFamily="Geist" fontSize="9" textAnchor="end" x="300" y="170">18+ Horas</text>
                </svg>
              </div>

              <div className="flex flex-wrap items-center justify-between text-[11px] font-mono text-neutral-400 mt-2 pt-2 border-t border-white/5">
                <span className="flex items-center gap-1.5">
                  <span className="w-2.5 h-0.5 bg-[#8f9194]" /> Salida (0 - 30m)
                </span>
                <span className="flex items-center gap-1.5">
                  <span className="w-2.5 h-0.5 bg-[#b9c8de]" /> Corazón (30m - 4h)
                </span>
                <span className="flex items-center gap-1.5">
                  <span className="w-2.5 h-0.5 bg-[#c9a24b]" /> Base / Sillage (4h - 18h+)
                </span>
              </div>
            </div>

            {/* Trust & Provenance Footer */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 text-neutral-400 text-xs font-mono pt-2">
              <div className="flex items-center gap-2">
                <BadgeCheck className="w-4 h-4 text-[#c9a24b] shrink-0" />
                <span>Normas IFRA / Paris & Grasse</span>
              </div>
              <div className="flex items-center gap-2">
                <Truck className="w-4 h-4 text-[#c9a24b] shrink-0" />
                <span>Envíos Asegurados FedEx 48h</span>
              </div>
              <div className="flex items-center gap-2">
                <ShieldCheck className="w-4 h-4 text-[#c9a24b] shrink-0" />
                <span>Garantía de Origen & Autenticidad</span>
              </div>
            </div>

          </div>

        </div>
      </div>
    </div>
  );
}
