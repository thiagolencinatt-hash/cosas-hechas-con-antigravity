import { X, Plus, Minus, Trash2, MessageCircle, AlertCircle, Sparkles, ShieldCheck, Truck, BadgeCheck } from 'lucide-react';
import { useShop, WHOLESALE_MIN_UNITS } from '../context/ShopContext';
import { ARGENTINA_PROVINCES } from '../data/products';

export function CartDrawer() {
  const {
    isCartOpen,
    setIsCartOpen,
    cart,
    cartItemsCount,
    cartTotalARS,
    formatPrice,
    updateQuantity,
    removeFromCart,
    customerData,
    setCustomerData,
    sendOrderViaWhatsApp,
    isWholesaleReached,
    neededForWholesale,
    updateItemMode,
  } = useShop();

  if (!isCartOpen) return null;

  // Count items by mode
  const wholesaleCount = cart
    .filter((i) => i.mode === 'mayorista')
    .reduce((sum, item) => sum + item.quantity, 0);

  const hasWholesaleItems = wholesaleCount > 0;
  const progressPercent = Math.min(100, Math.round((wholesaleCount / WHOLESALE_MIN_UNITS) * 100));

  // Determine if ready to submit:
  // If cart has wholesale items, they must reach at least 3 units.
  // If cart has only retail items, 1 unit is enough.
  const canSubmitOrder = cart.length > 0 && (!hasWholesaleItems || wholesaleCount >= WHOLESALE_MIN_UNITS);

  return (
    <div className="fixed inset-0 z-50 overflow-hidden">
      {/* Scrim Backdrop */}
      <div
        className="fixed inset-0 bg-black/75 backdrop-blur-sm transition-opacity"
        onClick={() => setIsCartOpen(false)}
      />

      {/* Slide-over Drawer */}
      <aside
        className="fixed inset-y-0 right-0 w-full max-w-md bg-white dark:bg-[#0c0c0c] border-l border-black/10 dark:border-white/10 shadow-2xl flex flex-col z-50 text-neutral-900 dark:text-white animate-slide-left transition-colors duration-200"
        role="dialog"
        aria-modal="true"
        aria-label="Tu pedido LATHE ESSENCE"
      >
        {/* Header */}
        <div className="p-4 sm:p-5 border-b border-black/10 dark:border-white/10 flex items-center justify-between">
          <div>
            <h2 className="font-sans text-xl sm:text-2xl font-semibold text-neutral-900 dark:text-white">
              Tu Pedido
            </h2>
            <p className="text-xs text-neutral-500 dark:text-neutral-400 font-sans mt-0.5">
              {cartItemsCount} {cartItemsCount === 1 ? 'unidad seleccionada' : 'unidades seleccionadas'}
            </p>
          </div>
          <button
            onClick={() => setIsCartOpen(false)}
            className="w-9 h-9 rounded-full border border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30 text-neutral-600 dark:text-neutral-300 hover:text-black dark:hover:text-white flex items-center justify-center transition-colors"
            aria-label="Cerrar pedido"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Wholesale Progress Banner (Calibrated to 3 Units) */}
        {hasWholesaleItems && (
          <div className="px-4 sm:px-5 py-3 bg-neutral-100 dark:bg-white/[0.04] border-b border-black/10 dark:border-white/10">
            <div className="flex items-center justify-between text-xs font-sans mb-1.5">
              <span className="font-medium text-neutral-800 dark:text-neutral-200">
                {isWholesaleReached ? (
                  <span className="flex items-center gap-1.5 font-semibold text-neutral-900 dark:text-white">
                    <Sparkles className="w-3.5 h-3.5 text-emerald-500" />
                    ¡Mínimo mayorista alcanzado (3+ u.)!
                  </span>
                ) : (
                  <span>
                    Faltan <strong className="font-bold text-neutral-900 dark:text-white">{neededForWholesale}</strong> para el mínimo mayorista (3 u.)
                  </span>
                )}
              </span>
              <span className="text-[11px] font-mono text-neutral-600 dark:text-neutral-300 font-bold">
                {wholesaleCount}/{WHOLESALE_MIN_UNITS} u.
              </span>
            </div>

            <div className="w-full h-1.5 rounded-full bg-neutral-200 dark:bg-white/10 overflow-hidden">
              <div
                className={`h-full transition-all duration-300 rounded-full ${
                  isWholesaleReached ? 'bg-emerald-500' : 'bg-black dark:bg-white'
                }`}
                style={{ width: `${progressPercent}%` }}
              />
            </div>

            {!isWholesaleReached && (
              <p className="text-[10px] text-neutral-500 dark:text-neutral-400 mt-1.5 font-normal">
                Podés combinar cualquier perfume del catálogo para alcanzar las 3 unidades con tarifa mayorista.
              </p>
            )}
          </div>
        )}

        {/* Cart Item List */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-5 space-y-3">
          {cart.length > 0 ? (
            cart.map((item) => (
              <div
                key={item.id}
                className="flex items-center gap-3 p-3 rounded-2xl bg-neutral-50 dark:bg-white/[0.03] border border-black/5 dark:border-white/5 hover:border-black/15 dark:hover:border-white/10 transition-colors"
              >
                {/* Thumbnail */}
                <div className="w-14 h-14 rounded-xl bg-white dark:bg-[#141414] border border-black/10 dark:border-white/10 p-1 flex-shrink-0 flex items-center justify-center overflow-hidden">
                  <img
                    src={item.product.image}
                    alt={item.product.name}
                    className="w-full h-full object-contain"
                  />
                </div>

                {/* Info */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-0.5">
                    <span className="text-[10px] font-sans uppercase tracking-wider text-neutral-500 dark:text-neutral-400 font-semibold">
                      {item.product.brand}
                    </span>
                    <span
                      onClick={() =>
                        updateItemMode(item.id, item.mode === 'mayorista' ? 'minorista' : 'mayorista')
                      }
                      title="Haz clic para alternar entre Minorista y Mayorista"
                      className={`text-[9px] font-sans px-2 py-0.5 rounded-full font-semibold cursor-pointer transition-colors ${
                        item.mode === 'mayorista'
                          ? 'bg-black text-white dark:bg-white dark:text-black'
                          : 'bg-neutral-200 text-neutral-800 dark:bg-white/10 dark:text-neutral-300'
                      }`}
                    >
                      {item.mode === 'mayorista' ? 'Mayorista' : 'Minorista'}
                    </span>
                  </div>

                  <h4
                    className="font-sans font-semibold text-sm text-neutral-900 dark:text-white line-clamp-1"
                    title={item.product.name}
                  >
                    {item.product.name}
                  </h4>

                  <div className="text-xs font-sans font-bold tabular-nums text-neutral-900 dark:text-neutral-200 mt-0.5">
                    {formatPrice(item.priceARS)}{' '}
                    <span className="text-[10px] text-neutral-500 dark:text-neutral-400 font-normal">
                      c/u {item.quantity > 1 ? `(${formatPrice(item.priceARS * item.quantity)})` : ''}
                    </span>
                  </div>
                </div>

                {/* Stepper */}
                <div className="flex items-center gap-1.5 border border-black/10 dark:border-white/15 rounded-full px-2 py-1 bg-white dark:bg-black/60 shadow-sm">
                  <button
                    onClick={() => {
                      if (item.quantity === 1) {
                        removeFromCart(item.id);
                      } else {
                        updateQuantity(item.id, -1);
                      }
                    }}
                    className="w-5 h-5 rounded-full flex items-center justify-center text-neutral-500 dark:text-neutral-400 hover:text-black dark:hover:text-white transition-colors"
                    aria-label="Restar una unidad"
                  >
                    <Minus className="w-3 h-3" />
                  </button>

                  <span className="font-sans font-bold text-xs text-neutral-900 dark:text-white min-w-[16px] text-center">
                    {item.quantity}
                  </span>

                  <button
                    onClick={() => updateQuantity(item.id, 1)}
                    className="w-5 h-5 rounded-full flex items-center justify-center text-neutral-500 dark:text-neutral-400 hover:text-black dark:hover:text-white transition-colors"
                    aria-label="Sumar una unidad"
                  >
                    <Plus className="w-3 h-3" />
                  </button>
                </div>

                {/* Remove */}
                <button
                  onClick={() => removeFromCart(item.id)}
                  className="p-1.5 text-neutral-400 hover:text-red-500 dark:hover:text-red-400 transition-colors"
                  aria-label="Eliminar del pedido"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            ))
          ) : (
            <div className="py-16 text-center text-neutral-500 dark:text-neutral-400">
              <AlertCircle className="w-8 h-8 text-neutral-400 dark:text-neutral-600 mx-auto mb-3 opacity-60" />
              <p className="font-sans text-base text-neutral-900 dark:text-white mb-1 font-semibold">
                Tu pedido está vacío
              </p>
              <p className="text-xs font-sans max-w-xs mx-auto">
                Explorá el catálogo y seleccioná fragancias en modalidad minorista (desde 1u) o mayorista (mín. 3u).
              </p>
            </div>
          )}
        </div>

        {/* Checkout Form & WhatsApp Action */}
        {cart.length > 0 && (
          <div className="p-4 sm:p-5 border-t border-black/10 dark:border-white/10 bg-neutral-50 dark:bg-[#0e0e0e] space-y-3">
            {/* Total */}
            <div className="flex items-baseline justify-between mb-1">
              <span className="text-xs font-sans text-neutral-500 dark:text-neutral-400 uppercase tracking-wider font-semibold">
                Total estimado ({cartItemsCount} u.):
              </span>
              <strong className="font-sans text-2xl font-bold tabular-nums text-neutral-900 dark:text-white">
                {formatPrice(cartTotalARS)}
              </strong>
            </div>

            {/* Customer Data Inputs */}
            <div className="space-y-2">
              <input
                type="text"
                placeholder="Nombre y Apellido *"
                value={customerData.name}
                onChange={(e) => setCustomerData((prev) => ({ ...prev, name: e.target.value }))}
                className="w-full h-10 px-3.5 rounded-xl bg-white dark:bg-white/[0.06] border border-black/10 dark:border-white/10 text-xs text-neutral-900 dark:text-white placeholder:text-neutral-400 focus:outline-none focus:border-black/30 dark:focus:border-white/40 shadow-sm"
              />

              <div className="grid grid-cols-2 gap-2">
                <select
                  value={customerData.province}
                  onChange={(e) => setCustomerData((prev) => ({ ...prev, province: e.target.value }))}
                  className="h-10 px-3 rounded-xl bg-white dark:bg-neutral-900 border border-black/10 dark:border-white/10 text-xs text-neutral-900 dark:text-white focus:outline-none focus:border-black/30 dark:focus:border-white/40 shadow-sm"
                >
                  <option value="">Provincia...</option>
                  {ARGENTINA_PROVINCES.map((prov) => (
                    <option key={prov} value={prov} className="bg-white dark:bg-neutral-900 text-neutral-900 dark:text-white">
                      {prov}
                    </option>
                  ))}
                </select>

                <input
                  type="text"
                  placeholder="Localidad / Ciudad"
                  value={customerData.locality}
                  onChange={(e) => setCustomerData((prev) => ({ ...prev, locality: e.target.value }))}
                  className="h-10 px-3.5 rounded-xl bg-white dark:bg-white/[0.06] border border-black/10 dark:border-white/10 text-xs text-neutral-900 dark:text-white placeholder:text-neutral-400 focus:outline-none focus:border-black/30 dark:focus:border-white/40 shadow-sm"
                />
              </div>

              <input
                type="text"
                placeholder="Aclaraciones o notas (opcional)"
                value={customerData.notes || ''}
                onChange={(e) => setCustomerData((prev) => ({ ...prev, notes: e.target.value }))}
                className="w-full h-9 px-3.5 rounded-xl bg-white dark:bg-white/[0.04] border border-black/10 dark:border-white/10 text-xs text-neutral-900 dark:text-white placeholder:text-neutral-400 focus:outline-none focus:border-black/30 dark:focus:border-white/40 shadow-sm"
              />
            </div>

            {/* Send WhatsApp Order Button */}
            <button
              onClick={sendOrderViaWhatsApp}
              disabled={!canSubmitOrder}
              className={`w-full py-3.5 rounded-full flex items-center justify-center gap-2 font-sans font-bold text-xs uppercase tracking-wider transition-all duration-200 active:scale-95 shadow-md ${
                canSubmitOrder
                  ? 'bg-[#25D366] hover:bg-[#20ba5a] text-black cursor-pointer shadow-[0_4px_16px_rgba(37,211,102,0.25)]'
                  : 'bg-neutral-300 dark:bg-white/10 text-neutral-500 cursor-not-allowed opacity-60'
              }`}
            >
              <MessageCircle className="w-4 h-4 fill-black text-black" />
              <span>
                {canSubmitOrder
                  ? 'Enviar pedido por WhatsApp'
                  : `Sumá ${neededForWholesale} más para tarifa mayorista`}
              </span>
            </button>

            {/* Trust Mini-badges */}
            <div className="pt-2 border-t border-black/5 dark:border-white/5 flex items-center justify-between text-[10px] text-neutral-500 dark:text-neutral-400">
              <span className="flex items-center gap-1">
                <ShieldCheck className="w-3.5 h-3.5 text-neutral-700 dark:text-neutral-300" />
                Pago coordinado
              </span>
              <span className="flex items-center gap-1">
                <Truck className="w-3.5 h-3.5 text-neutral-700 dark:text-neutral-300" />
                Despacho en 24h
              </span>
              <span className="flex items-center gap-1">
                <BadgeCheck className="w-3.5 h-3.5 text-neutral-700 dark:text-neutral-300" />
                100% Original
              </span>
            </div>
          </div>
        )}
      </aside>
    </div>
  );
}
