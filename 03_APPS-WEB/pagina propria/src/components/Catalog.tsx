import { ProductCard } from './ProductCard';
import { useShop } from '../context/ShopContext';
import { SlidersHorizontal, X, Sparkles } from 'lucide-react';

export function Catalog() {
  const {
    filteredProducts,
    selectedBrand,
    setSelectedBrand,
    selectedGender,
    setSelectedGender,
    selectedCategory,
    setSelectedCategory,
    searchQuery,
    setSearchQuery,
    clearFilters,
    activeFiltersCount,
    setIsFilterDrawerOpen,
  } = useShop();

  return (
    <section id="catalogo" className="py-10 sm:py-16 bg-white dark:bg-[#000000] transition-colors duration-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        
        {/* Header & Title */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 mb-8">
          <div>
            <div className="inline-flex items-center gap-2 mb-2">
              <span className="w-1.5 h-1.5 rounded-full bg-neutral-400 dark:bg-white" />
              <span className="text-[11px] font-sans font-semibold tracking-widest uppercase text-neutral-500 dark:text-neutral-400">
                Importaciones Directas
              </span>
            </div>
            <h2 className="font-sans text-2xl sm:text-4xl font-semibold text-neutral-900 dark:text-white tracking-tight">
              Catálogo de Fragancias
            </h2>
            <p className="font-sans text-xs sm:text-sm text-neutral-500 dark:text-neutral-400 mt-1 max-w-2xl font-normal">
              Precios dinámicos según tu modalidad: compra minorista desde <strong className="text-black dark:text-white font-semibold">1 unidad</strong> o compra mayorista desde <strong className="text-black dark:text-white font-semibold">3 unidades combinables</strong> con tarifa preferencial.
            </p>
          </div>

          {/* Quick Filter Drawer Trigger & Counter */}
          <div className="flex items-center gap-3">
            <span className="text-xs font-sans text-neutral-500 dark:text-neutral-400 font-medium">
              {filteredProducts.length} {filteredProducts.length === 1 ? 'perfume' : 'perfumes'}
            </span>

            <button
              onClick={() => setIsFilterDrawerOpen(true)}
              className="flex items-center gap-2 px-4 py-2 rounded-full border border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30 text-neutral-800 dark:text-neutral-200 text-xs font-sans font-medium transition-colors"
            >
              <SlidersHorizontal className="w-3.5 h-3.5" />
              <span>Filtros {activeFiltersCount > 0 ? `(${activeFiltersCount})` : ''}</span>
            </button>
          </div>
        </div>

        {/* Active Filter Badges (if any applied) */}
        {activeFiltersCount > 0 && (
          <div className="flex flex-wrap items-center gap-2 mb-6 p-3 rounded-2xl bg-neutral-100 dark:bg-white/[0.04] border border-black/5 dark:border-white/5 text-xs font-sans">
            <span className="text-neutral-500 dark:text-neutral-400">Filtros activos:</span>
            
            {selectedBrand !== 'Todas' && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-black/5 dark:bg-white/10 text-neutral-800 dark:text-white border border-black/10 dark:border-white/15">
                Marca: {selectedBrand}
                <button onClick={() => setSelectedBrand('Todas')} className="hover:text-neutral-500">
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}

            {selectedGender !== 'Todos' && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-black/5 dark:bg-white/10 text-neutral-800 dark:text-white border border-black/10 dark:border-white/15">
                Para: {selectedGender}
                <button onClick={() => setSelectedGender('Todos')} className="hover:text-neutral-500">
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}

            {selectedCategory !== 'Todos' && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-black/5 dark:bg-white/10 text-neutral-800 dark:text-white border border-black/10 dark:border-white/15">
                Categoría: {selectedCategory}
                <button onClick={() => setSelectedCategory('Todos')} className="hover:text-neutral-500">
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}

            {searchQuery && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-black/5 dark:bg-white/10 text-neutral-800 dark:text-white border border-black/10 dark:border-white/15">
                Búsqueda: "{searchQuery}"
                <button onClick={() => setSearchQuery('')} className="hover:text-neutral-500">
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}

            <button
              onClick={clearFilters}
              className="ml-auto text-xs text-neutral-500 hover:text-black dark:hover:text-white underline underline-offset-2"
            >
              Borrar todos los filtros
            </button>
          </div>
        )}

        {/* Products Grid */}
        {filteredProducts.length > 0 ? (
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3 sm:gap-5">
            {filteredProducts.map((product) => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        ) : (
          <div className="py-20 text-center rounded-3xl border border-dashed border-black/10 dark:border-white/10 p-8">
            <Sparkles className="w-8 h-8 text-neutral-400 mx-auto mb-3 opacity-60" />
            <h3 className="font-sans text-xl font-semibold text-neutral-800 dark:text-white mb-2">
              No encontramos perfumes con esos filtros
            </h3>
            <p className="font-sans text-xs sm:text-sm text-neutral-500 dark:text-neutral-400 max-w-md mx-auto mb-6">
              Probá cambiando la búsqueda o restableciendo los filtros para ver los 145 perfumes de nuestro catálogo.
            </p>
            <button
              onClick={clearFilters}
              className="px-6 py-2.5 rounded-full bg-black text-white dark:bg-white dark:text-black font-sans font-semibold text-xs tracking-wide hover:opacity-90 transition-all"
            >
              Ver todos los perfumes
            </button>
          </div>
        )}

      </div>
    </section>
  );
}
