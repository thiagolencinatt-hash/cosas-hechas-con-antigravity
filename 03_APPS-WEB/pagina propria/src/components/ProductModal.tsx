import { useState, useEffect } from 'react';
import { X, Star, ShoppingBag, Droplets, MessageCircle, ShieldCheck, Truck, BadgeCheck, Minus, Plus } from 'lucide-react';
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
  } = useShop();

  const product = selectedProductForModal;

  // Local mode selector in modal
  const [modalMode, setModalMode] = useState<PricingMode>(globalPricingMode);
  const [quantity, setQuantity] = useState<number>(1);

  // Sync mode and quantity when modal opens or product changes
  useEffect(() => {
    if (product) {
      setModalMode(globalPricingMode);
      setQuantity(globalPricingMode === 'mayorista' ? WHOLESALE_MIN_UNITS : 1);
    }
  }, [product, globalPricingMode]);

  // When user switches mode inside the modal
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
  const activeUnitPrice = modalMode === 'mayorista' ? product.price : product.retailPrice;
  const totalPrice = activeUnitPrice * quantity;

  const handleAddToCart = () => {
    addToCart(product, quantity, modalMode);
    setSelectedProductForModal(null);
  };

  const askAboutThisPerfume = () => {
    const text = encodeURIComponent(
      `Hola LATHE ESSENCE! Quería consultar disponibilidad sobre ${product.name} (${product.brand}) en modalidad ${modalMode.toUpperCase()} (${quantity} unidad${quantity > 1 ? 'es' : ''} a $ ${activeUnitPrice.toLocaleString('es-AR')} c/u).`
    );
    window.open(`https://wa.me/${DEFAULT_WHATSAPP_NUMBER}?text=${text}`, '_blank');
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto bg-black/80 backdrop-blur-md flex items-center justify-center p-3 sm:p-6 animate-fade-in">
      {/* Click outside to close */}
      <div className="fixed inset-0" onClick={() => setSelectedProductForModal(null)} />

      <div
        className="relative w-full max-w-3xl bg-white dark:bg-[#0f0f0f] border border-black/10 dark:border-white/10 rounded-3xl overflow-hidden shadow-2xl max-h-[92vh] flex flex-col my-auto z-10 text-neutral-900 dark:text-white transition-colors duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Top Close Button */}
        <button
          onClick={() => setSelectedProductForModal(null)}
          className="absolute top-4 right-4 z-20 w-9 h-9 rounded-full bg-neutral-100 hover:bg-neutral-200 dark:bg-black/60 dark:hover:bg-neutral-800 border border-black/10 dark:border-white/15 text-neutral-700 dark:text-neutral-300 hover:text-black dark:hover:text-white flex items-center justify-center transition-colors shadow-sm"
          aria-label="Cerrar modal"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Modal Scrollable Body */}
        <div className="overflow-y-auto flex-1 p-5 sm:p-8 space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 sm:gap-8 items-start">

            {/* Image Column */}
            <div className="relative aspect-square rounded-2xl overflow-hidden bg-neutral-50 dark:bg-[#161616] border border-black/5 dark:border-white/10 p-6 flex items-center justify-center">
              <img
                src={product.image}
                alt={product.name}
                className="w-full h-full object-contain filter drop-shadow-xl"
              />
              {product.tag && (
                <div className="absolute top-3 left-3 px-3 py-1 rounded-full text-[10px] font-sans tracking-wider uppercase bg-black text-white dark:bg-white dark:text-black font-semibold shadow-md">
                  {product.tag}
                </div>
              )}
            </div>

            {/* Info Column */}
            <div className="flex flex-col justify-between">
              <div>
                <div className="flex items-center gap-2 text-xs font-sans text-neutral-500 dark:text-neutral-400 uppercase tracking-wider mb-1 font-semibold">
                  <span>{product.brand}</span>
                  <span>•</span>
                  <span>{product.gender}</span>
                  <span>•</span>
                  <span>{product.category}</span>
                </div>

                <h2 className="font-sans text-2xl sm:text-3xl font-semibold text-neutral-900 dark:text-white tracking-tight">
                  {product.name}
                </h2>

                <p className="text-xs text-neutral-500 dark:text-neutral-400 font-sans mt-0.5 font-normal">
                  {product.size || '100ml'} • {product.concentration || 'Eau de Parfum'}
                </p>

                {/* Rating */}
                <div className="flex items-center gap-2 mt-2 text-xs text-neutral-500 dark:text-neutral-400">
                  <div className="flex items-center gap-1 text-neutral-900 dark:text-white font-semibold">
                    <Star className="w-3.5 h-3.5 fill-current text-neutral-900 dark:text-white" />
                    <span>{product.rating}</span>
                  </div>
                  <span>•</span>
                  <span>{product.reviewsCount} reseñas de clientes</span>
                </div>

                {/* Pricing Mode Selector Pill */}
                <div className="mt-4 p-1 rounded-2xl bg-neutral-100 dark:bg-white/[0.05] border border-black/5 dark:border-white/10">
                  <div className="text-[10px] font-sans text-neutral-500 dark:text-neutral-400 uppercase tracking-wider font-semibold px-2 pt-1 pb-1.5">
                    Modalidad de Compra
                  </div>
                  <div className="grid grid-cols-2 gap-1.5">
                    <button
                      type="button"
                      onClick={() => handleModeChange('minorista')}
                      className={`py-2 px-3 rounded-xl text-xs font-sans transition-all text-center flex flex-col items-center justify-center ${
                        modalMode === 'minorista'
                          ? 'bg-white dark:bg-black text-black dark:text-white font-bold shadow-sm border border-black/10 dark:border-white/10'
                          : 'text-neutral-600 dark:text-neutral-400 hover:text-black dark:hover:text-white'
                      }`}
                    >
                      <span className="font-semibold">Venta Minorista</span>
                      <span className="text-[10px] opacity-75 font-normal">A partir de 1 unidad</span>
                    </button>

                    <button
                      type="button"
                      onClick={() => handleModeChange('mayorista')}
                      className={`py-2 px-3 rounded-xl text-xs font-sans transition-all text-center flex flex-col items-center justify-center ${
                        modalMode === 'mayorista'
                          ? 'bg-black text-white dark:bg-white dark:text-black font-bold shadow-sm border border-black/10 dark:border-white/10'
                          : 'text-neutral-600 dark:text-neutral-400 hover:text-black dark:hover:text-white'
                      }`}
                    >
                      <span className="font-semibold">Venta Mayorista</span>
                      <span className="text-[10px] opacity-75 font-normal">Mínimo 3 unidades (-35%)</span>
                    </button>
                  </div>
                </div>

                {/* Dynamic Price Box */}
                <div className="my-4 p-4 rounded-2xl bg-neutral-50 dark:bg-white/[0.03] border border-black/5 dark:border-white/10">
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="text-[10px] font-sans text-neutral-500 dark:text-neutral-400 uppercase tracking-widest font-semibold">
                        {modalMode === 'mayorista' ? 'Precio Mayorista por Unidad' : 'Precio Minorista Final'}
                      </div>
                      <div className="flex items-baseline gap-2 mt-1">
                        <span className="font-sans text-2xl sm:text-3xl font-bold tabular-nums text-neutral-900 dark:text-white">
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
                      <span className="px-2.5 py-1 rounded-full bg-black/10 dark:bg-white/15 text-neutral-900 dark:text-white text-xs font-semibold">
                        Ahorrás 35%
                      </span>
                    )}
                  </div>

                  <div className="text-[11px] text-neutral-600 dark:text-neutral-400 font-sans mt-2 pt-2 border-t border-black/5 dark:border-white/5 flex items-center justify-between">
                    <span>
                      {modalMode === 'mayorista'
                        ? 'Válido para pedidos de 3 o más unidades combinables.'
                        : 'Sin compra mínima requerida.'}
                    </span>
                    <span className="font-semibold text-neutral-900 dark:text-white">
                      Subtotal: {formatPrice(totalPrice)}
                    </span>
                  </div>
                </div>

                {/* Quantity Stepper */}
                <div className="flex items-center justify-between p-3 rounded-2xl bg-neutral-100 dark:bg-white/[0.04] border border-black/5 dark:border-white/5 mb-4">
                  <span className="text-xs font-sans font-semibold text-neutral-700 dark:text-neutral-300">
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
                      className="w-8 h-8 rounded-full bg-white dark:bg-neutral-800 border border-black/10 dark:border-white/10 flex items-center justify-center text-neutral-700 dark:text-neutral-300 hover:text-black dark:hover:text-white disabled:opacity-30 disabled:cursor-not-allowed shadow-sm transition-opacity"
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
                      className="w-8 h-8 rounded-full bg-white dark:bg-neutral-800 border border-black/10 dark:border-white/10 flex items-center justify-center text-neutral-700 dark:text-neutral-300 hover:text-black dark:hover:text-white shadow-sm"
                      aria-label="Sumar una unidad"
                    >
                      <Plus className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>

                {/* Key Note Pills */}
                {product.keyNotePills && product.keyNotePills.length > 0 && (
                  <div className="flex flex-wrap gap-1.5 mb-4">
                    {product.keyNotePills.map((pill, idx) => (
                      <span
                        key={idx}
                        className="px-2.5 py-1 rounded-full bg-neutral-100 dark:bg-white/[0.06] border border-black/5 dark:border-white/10 text-[11px] font-sans text-neutral-700 dark:text-neutral-300 font-medium"
                      >
                        {pill}
                      </span>
                    ))}
                  </div>
                )}

                <p className="text-xs sm:text-sm text-neutral-600 dark:text-neutral-300 font-sans leading-relaxed mb-6 font-normal">
                  {product.description}
                </p>
              </div>

              {/* Actions */}
              <div className="space-y-2.5">
                <button
                  onClick={handleAddToCart}
                  className="w-full py-3.5 rounded-full bg-black text-white dark:bg-white dark:text-black hover:opacity-90 font-sans font-semibold text-xs uppercase tracking-wider flex items-center justify-center gap-2 transition-all active:scale-95 shadow-md"
                >
                  <ShoppingBag className="w-4 h-4" />
                  <span>
                    {inCartQty > 0
                      ? `Sumar ${quantity} u. (Ya tenés ${inCartQty} en pedido)`
                      : `Añadir ${quantity} ${quantity === 1 ? 'unidad' : 'unidades'} al pedido (${modalMode})`}
                  </span>
                </button>

                <button
                  onClick={askAboutThisPerfume}
                  className="w-full py-2.5 rounded-full border border-black/15 dark:border-white/15 hover:border-black/30 dark:hover:border-white/30 text-neutral-800 dark:text-white font-sans font-medium text-xs flex items-center justify-center gap-2 transition-colors"
                >
                  <MessageCircle className="w-4 h-4 text-emerald-500" />
                  <span>Consultar por WhatsApp</span>
                </button>
              </div>
            </div>

          </div>

          {/* Olfactory Pyramid */}
          {product.pyramid && (
            <div className="pt-6 border-t border-black/10 dark:border-white/10">
              <h3 className="text-xs font-sans font-semibold uppercase tracking-wider text-neutral-500 dark:text-neutral-400 mb-3 flex items-center gap-2">
                <Droplets className="w-3.5 h-3.5" />
                <span>Pirámide Olfativa</span>
              </h3>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div className="p-3.5 rounded-2xl bg-neutral-50 dark:bg-white/[0.03] border border-black/5 dark:border-white/5">
                  <span className="text-[10px] font-sans text-neutral-500 dark:text-neutral-400 uppercase tracking-widest font-semibold block mb-1">
                    Notas de Salida (15m)
                  </span>
                  <p className="text-xs text-neutral-900 dark:text-white font-medium">
                    {product.pyramid.top.join(', ')}
                  </p>
                </div>

                <div className="p-3.5 rounded-2xl bg-neutral-50 dark:bg-white/[0.03] border border-black/5 dark:border-white/5">
                  <span className="text-[10px] font-sans text-neutral-500 dark:text-neutral-400 uppercase tracking-widest font-semibold block mb-1">
                    Notas de Corazón (2 a 6h)
                  </span>
                  <p className="text-xs text-neutral-900 dark:text-white font-medium">
                    {product.pyramid.heart.join(', ')}
                  </p>
                </div>

                <div className="p-3.5 rounded-2xl bg-neutral-50 dark:bg-white/[0.03] border border-black/5 dark:border-white/5">
                  <span className="text-[10px] font-sans text-neutral-500 dark:text-neutral-400 uppercase tracking-widest font-semibold block mb-1">
                    Notas de Fondo (8h+ Fijación)
                  </span>
                  <p className="text-xs text-neutral-900 dark:text-white font-medium">
                    {product.pyramid.base.join(', ')}
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Trust Badges Bar */}
          <div className="pt-4 border-t border-black/10 dark:border-white/10 grid grid-cols-1 sm:grid-cols-3 gap-3 text-neutral-600 dark:text-neutral-400 text-xs">
            <div className="flex items-center gap-2">
              <BadgeCheck className="w-4 h-4 text-neutral-800 dark:text-white flex-shrink-0" />
              <span className="text-[11px]">100% Sellado de Origen</span>
            </div>
            <div className="flex items-center gap-2">
              <Truck className="w-4 h-4 text-neutral-800 dark:text-white flex-shrink-0" />
              <span className="text-[11px]">Envíos a Toda Argentina</span>
            </div>
            <div className="flex items-center gap-2">
              <ShieldCheck className="w-4 h-4 text-neutral-800 dark:text-white flex-shrink-0" />
              <span className="text-[11px]">Garantía de Satisfacción</span>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
