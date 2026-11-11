import { X, Check } from 'lucide-react';
import { useShop, SortOption, ShowOption } from '../context/ShopContext';

export function FilterDrawer() {
  const {
    isFilterDrawerOpen,
    setIsFilterDrawerOpen,
    selectedGender,
    setSelectedGender,
    selectedCategory,
    setSelectedCategory,
    selectedShow,
    setSelectedShow,
    sortBy,
    setSortBy,
    clearFilters,
    activeFiltersCount,
    filteredProducts,
  } = useShop();

  if (!isFilterDrawerOpen) return null;

  return (
    <div className="fixed inset-0 z-50 overflow-hidden">
      {/* Scrim Backdrop */}
      <div
        className="fixed inset-0 bg-black/75 backdrop-blur-sm transition-opacity"
        onClick={() => setIsFilterDrawerOpen(false)}
      />

      {/* Drawer */}
      <aside
        className="fixed inset-y-0 right-0 w-full max-w-sm bg-white dark:bg-[#0d0d0d] border-l border-black/10 dark:border-white/10 shadow-2xl flex flex-col z-50 animate-slide-left text-neutral-900 dark:text-white transition-colors duration-200"
        role="dialog"
        aria-modal="true"
        aria-label="Filtros de perfumes"
      >
        {/* Drawer Header */}
        <div className="p-4 sm:p-5 border-b border-black/10 dark:border-white/10 flex items-center justify-between">
          <div>
            <h2 className="font-sans text-xl font-semibold text-neutral-900 dark:text-white">Filtros</h2>
            <p className="text-xs text-neutral-500 dark:text-neutral-400 font-sans mt-0.5">
              Personalizá tu búsqueda ({filteredProducts.length} disponibles)
            </p>
          </div>
          <button
            onClick={() => setIsFilterDrawerOpen(false)}
            className="w-9 h-9 rounded-full border border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30 text-neutral-500 dark:text-neutral-300 hover:text-black dark:hover:text-white flex items-center justify-center transition-colors"
            aria-label="Cerrar filtros"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Drawer Body */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-5 space-y-6">
          
          {/* Para (Género) */}
          <div>
            <h3 className="text-xs font-sans font-semibold tracking-wider uppercase text-neutral-500 dark:text-neutral-400 mb-2.5">
              Para
            </h3>
            <div className="flex flex-wrap gap-2">
              {['Todos', 'Hombre', 'Mujer', 'Unisex'].map((g) => (
                <button
                  key={g}
                  onClick={() => setSelectedGender(g)}
                  className={`px-3.5 py-1.5 rounded-full text-xs font-sans transition-colors duration-150 ease-out active:scale-[0.97] cursor-pointer ${
                    selectedGender === g
                      ? 'bg-black text-white dark:bg-white dark:text-black font-semibold shadow-sm'
                      : 'bg-neutral-100 dark:bg-white/5 border border-black/5 dark:border-white/10 text-neutral-700 dark:text-neutral-300 hover:border-black/20 dark:hover:border-white/20'
                  }`}
                >
                  {g}
                </button>
              ))}
            </div>
          </div>

          {/* Mostrar (Ofertas, Stock) */}
          <div>
            <h3 className="text-xs font-sans font-semibold tracking-wider uppercase text-neutral-500 dark:text-neutral-400 mb-2.5">
              Mostrar
            </h3>
            <div className="flex flex-wrap gap-2">
              {[
                { id: 'todos', label: 'Todos' },
                { id: 'ofertas', label: 'En oferta' },
                { id: 'stock', label: 'Con stock' },
              ].map((opt) => (
                <button
                  key={opt.id}
                  onClick={() => setSelectedShow(opt.id as ShowOption)}
                  className={`px-3.5 py-1.5 rounded-full text-xs font-sans transition-colors duration-150 ease-out active:scale-[0.97] cursor-pointer ${
                    selectedShow === opt.id
                      ? 'bg-black text-white dark:bg-white dark:text-black font-semibold shadow-sm'
                      : 'bg-neutral-100 dark:bg-white/5 border border-black/5 dark:border-white/10 text-neutral-700 dark:text-neutral-300 hover:border-black/20 dark:hover:border-white/20'
                  }`}
                >
                  {opt.label}
                </button>
              ))}
            </div>
          </div>

          {/* Categoría */}
          <div>
            <h3 className="text-xs font-sans font-semibold tracking-wider uppercase text-neutral-500 dark:text-neutral-400 mb-2.5">
              Categoría
            </h3>
            <div className="flex flex-wrap gap-2">
              {['Todos', 'Arabes', 'Diseñador', 'Nicho', 'Body splash'].map((cat) => (
                <button
                  key={cat}
                  onClick={() => setSelectedCategory(cat)}
                  className={`px-3.5 py-1.5 rounded-full text-xs font-sans transition-colors duration-150 ease-out active:scale-[0.97] cursor-pointer ${
                    selectedCategory === cat
                      ? 'bg-black text-white dark:bg-white dark:text-black font-semibold shadow-sm'
                      : 'bg-neutral-100 dark:bg-white/5 border border-black/5 dark:border-white/10 text-neutral-700 dark:text-neutral-300 hover:border-black/20 dark:hover:border-white/20'
                  }`}
                >
                  {cat === 'Arabes' ? 'Árabes' : cat}
                </button>
              ))}
            </div>
          </div>

          {/* Ordenar por */}
          <div>
            <h3 className="text-xs font-sans font-semibold tracking-wider uppercase text-neutral-500 dark:text-neutral-400 mb-2.5">
              Ordenar por
            </h3>
            <div className="space-y-1.5">
              {[
                { id: 'rec', label: 'Sugerido / Más vendidos' },
                { id: 'asc', label: 'Precio: menor a mayor' },
                { id: 'desc', label: 'Precio: mayor a menor' },
                { id: 'az', label: 'Nombre: de la A a la Z' },
              ].map((sort) => {
                const isSelected = sortBy === sort.id;
                return (
                  <button
                    key={sort.id}
                    onClick={() => setSortBy(sort.id as SortOption)}
                    className={`w-full text-left px-4 py-2.5 rounded-xl border text-xs font-sans flex items-center justify-between transition-colors duration-150 ease-out active:scale-[0.98] cursor-pointer ${
                      isSelected
                        ? 'border-black dark:border-white bg-black/10 dark:bg-white/15 text-neutral-900 dark:text-white font-medium'
                        : 'border-black/5 dark:border-white/10 bg-neutral-50 dark:bg-white/[0.02] text-neutral-700 dark:text-neutral-300 hover:border-black/20 dark:hover:border-white/20'
                    }`}
                  >
                    <span>{sort.label}</span>
                    {isSelected && <Check className="w-3.5 h-3.5 text-neutral-900 dark:text-white" />}
                  </button>
                );
              })}
            </div>
          </div>

        </div>

        {/* Drawer Footer */}
        <div className="p-4 sm:p-5 border-t border-black/10 dark:border-white/10 space-y-2 bg-neutral-50 dark:bg-transparent">
          <button
            onClick={() => setIsFilterDrawerOpen(false)}
            className="w-full py-3 rounded-full bg-black text-white dark:bg-white dark:text-black hover:opacity-90 font-sans font-bold text-xs tracking-wider uppercase transition-[opacity,transform] duration-150 ease-out active:scale-[0.97] cursor-pointer shadow-sm"
          >
            Ver {filteredProducts.length} perfumes
          </button>
          
          {activeFiltersCount > 0 && (
            <button
              onClick={clearFilters}
              className="w-full py-2 text-center text-xs text-neutral-500 dark:text-neutral-400 hover:text-black dark:hover:text-white underline underline-offset-2 transition-colors"
            >
              Borrar filtros
            </button>
          )}
        </div>
      </aside>
    </div>
  );
}
