import { X, Trash2, ShoppingBag, Heart } from 'lucide-react';
import { useShop } from '../context/ShopContext';
import { PRODUCTS } from '../data/products';
import { Product } from '../types';

export function WishlistModal() {
  const {
    isWishlistOpen,
    setIsWishlistOpen,
    wishlist,
    toggleWishlist,
    addToCart,
    formatPrice,
    globalPricingMode,
  } = useShop();

  if (!isWishlistOpen) return null;

  const wishedProducts: Product[] = PRODUCTS.filter((p: Product) =>
    wishlist.includes(String(p.id))
  );

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/80 backdrop-blur-md transition-opacity duration-300"
        onClick={() => setIsWishlistOpen(false)}
      />

      {/* Modal Dialog */}
      <div className="relative w-full max-w-2xl bg-white dark:bg-[#111111] border border-black/10 dark:border-white/10 rounded-3xl shadow-2xl p-6 md:p-8 max-h-[88vh] flex flex-col z-10 overflow-hidden text-neutral-900 dark:text-white transition-colors duration-200">
        {/* Header */}
        <div className="flex items-center justify-between pb-5 border-b border-black/10 dark:border-white/10">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-black/5 dark:bg-white/10 border border-black/10 dark:border-white/15 flex items-center justify-center text-red-500">
              <Heart className="w-5 h-5 fill-current text-red-500" />
            </div>
            <div>
              <h2 className="font-sans text-xl font-semibold flex items-center gap-2">
                Tus Fragancias Favoritas
                <span className="text-[10px] font-sans px-2.5 py-0.5 rounded-full bg-black/5 dark:bg-white/10 text-neutral-700 dark:text-neutral-300 font-medium">
                  {wishedProducts.length} {wishedProducts.length === 1 ? 'ítem' : 'ítems'}
                </span>
              </h2>
              <p className="text-[10px] text-neutral-500 dark:text-neutral-400 tracking-widest uppercase mt-0.5 font-medium">
                LATHE ESSENCE · Selección Personal
              </p>
            </div>
          </div>

          <button
            onClick={() => setIsWishlistOpen(false)}
            className="w-9 h-9 rounded-full border border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30 text-neutral-500 dark:text-neutral-400 hover:text-black dark:hover:text-white flex items-center justify-center transition-colors"
            aria-label="Cerrar modal"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Body */}
        <div className="flex-1 overflow-y-auto py-5 pr-1 space-y-3">
          {wishedProducts.length === 0 ? (
            <div className="text-center py-12 px-4">
              <Heart className="w-12 h-12 mx-auto text-neutral-400 dark:text-neutral-600 stroke-1 mb-4" />
              <h3 className="font-sans text-lg mb-2 font-semibold text-neutral-900 dark:text-white">
                Tu lista de favoritos está vacía
              </h3>
              <p className="text-xs text-neutral-500 dark:text-neutral-400 max-w-sm mx-auto mb-6 font-normal">
                Hacé clic en el corazón de cualquier perfume del catálogo para guardarlo acá.
              </p>
              <button
                onClick={() => {
                  setIsWishlistOpen(false);
                  const el = document.getElementById('catalogo');
                  if (el) el.scrollIntoView({ behavior: 'smooth' });
                }}
                className="px-6 py-2.5 rounded-full bg-black text-white dark:bg-white dark:text-black font-semibold text-xs tracking-wider uppercase hover:opacity-90 transition-opacity shadow-sm"
              >
                Ver Catálogo Completo
              </button>
            </div>
          ) : (
            <div className="space-y-3">
              {wishedProducts.map((product) => {
                const currentPrice =
                  globalPricingMode === 'mayorista' ? product.price : product.retailPrice;

                return (
                  <div
                    key={product.id}
                    className="flex flex-col sm:flex-row sm:items-center justify-between p-3.5 rounded-2xl bg-neutral-50 dark:bg-white/[0.03] border border-black/5 dark:border-white/5 hover:border-black/15 dark:hover:border-white/10 transition-all gap-4"
                  >
                    <div className="flex items-center gap-4">
                      <div className="w-14 h-14 rounded-xl overflow-hidden border border-black/10 dark:border-white/10 bg-white dark:bg-black flex-shrink-0 p-1 flex items-center justify-center">
                        <img
                          src={product.image}
                          alt={product.name}
                          className="w-full h-full object-contain"
                        />
                      </div>
                      <div>
                        <span className="text-[10px] tracking-wider uppercase text-neutral-500 dark:text-neutral-400 font-semibold">
                          {product.brand}
                        </span>
                        <h4 className="font-sans text-sm font-semibold text-neutral-900 dark:text-white leading-tight">
                          {product.name}
                        </h4>
                        <p className="text-xs font-sans font-bold tabular-nums text-neutral-900 dark:text-neutral-200 mt-1">
                          {formatPrice(currentPrice)}{' '}
                          <span className="text-[10px] text-neutral-500 dark:text-neutral-400 font-normal">
                            c/u ({globalPricingMode})
                          </span>
                        </p>
                      </div>
                    </div>

                    <div className="flex items-center gap-2 self-end sm:self-center">
                      <button
                        onClick={() => addToCart(product)}
                        className="px-4 py-2 rounded-full bg-black text-white dark:bg-white dark:text-black font-semibold text-xs tracking-wide flex items-center gap-1.5 hover:opacity-90 transition-opacity shadow-sm"
                      >
                        <ShoppingBag className="w-3.5 h-3.5" />
                        Sumar
                      </button>
                      <button
                        onClick={() => toggleWishlist(product.id)}
                        className="p-2 rounded-full border border-black/10 dark:border-white/10 text-neutral-500 dark:text-neutral-400 hover:text-red-500 dark:hover:text-red-400 transition-colors"
                        title="Eliminar de favoritos"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
