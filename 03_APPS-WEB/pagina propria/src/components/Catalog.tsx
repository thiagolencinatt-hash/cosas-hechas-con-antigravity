import { useState, useEffect } from 'react';
import { ProductCard } from './ProductCard';
import { useShop } from '../context/ShopContext';
import {
  SlidersHorizontal,
  X,
  LayoutGrid,
  Table,
  Download,
  FileSpreadsheet,
  Eye,
  Sparkles,
  Search,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';

const ITEMS_PER_PAGE = 12;

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
    formatPrice,
    globalPricingMode,
    addToCart,
    setSelectedProductForModal,
    showToast,
  } = useShop();

  const [viewMode, setViewMode] = useState<'grid' | 'table'>('grid');
  const [currentPage, setCurrentPage] = useState(1);

  // Auto-reset to page 1 whenever active filters or search terms change
  useEffect(() => {
    setCurrentPage(1);
  }, [selectedBrand, selectedGender, selectedCategory, searchQuery]);

  const totalPages = Math.ceil(filteredProducts.length / ITEMS_PER_PAGE) || 1;
  const startIndex = (currentPage - 1) * ITEMS_PER_PAGE;
  const endIndex = Math.min(startIndex + ITEMS_PER_PAGE, filteredProducts.length);
  const paginatedProducts = filteredProducts.slice(startIndex, endIndex);

  const handlePageChange = (newPage: number) => {
    if (newPage < 1 || newPage > totalPages) return;
    setCurrentPage(newPage);
    const catEl = document.getElementById('catalogo');
    if (catEl) {
      catEl.scrollIntoView({ behavior: 'smooth' });
    }
  };

  const handleExportExcel = () => {
    showToast('Generando planilla de inventario y tarifas mayoristas (.XLSX)...');
  };

  const handleExportPDF = () => {
    showToast('Generando Catálogo Técnico Oficial B2B (.PDF)...');
  };

  return (
    <section id="catalogo" className="scroll-mt-24 py-16 bg-white dark:bg-[#0B0C10] text-neutral-900 dark:text-white border-b border-black/10 dark:border-white/10 transition-colors duration-200">
      <div className="max-w-[1440px] mx-auto px-4 sm:px-8 lg:px-12">
        
        {/* Header & Title Bar */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-8">
          <div>
            <div className="inline-flex items-center gap-2 font-mono text-[11px] text-[#c9a24b] uppercase tracking-[0.25em] mb-2">
              <Sparkles className="w-3.5 h-3.5" />
              <span>02 / Curaduría de Alta Perfumería</span>
            </div>
            <h2 className="font-serif text-3xl sm:text-5xl font-normal tracking-tight text-neutral-900 dark:text-white">
              Catálogo General de Fragancias
            </h2>
            <p className="font-sans text-xs sm:text-sm text-neutral-600 dark:text-neutral-400 mt-2 max-w-2xl font-light leading-relaxed">
              Composiciones extraídas en micro-lotes. Precios dinámicos en tiempo real según modalidad: menudeo minorista desde <strong className="text-neutral-900 dark:text-white font-medium">1 unidad</strong> o adquisición mayorista desde <strong className="text-neutral-900 dark:text-white font-medium">3 unidades surtidas</strong> con margen de hasta el 55%.
            </p>
          </div>

          {/* View Switcher, Search Lupa & Actions */}
          <div className="flex flex-wrap items-center gap-3">
            {/* Inline Catalog Search Bar with Lupa */}
            <div className="relative flex-1 sm:w-64 max-w-xs">
              <Search className="w-3.5 h-3.5 text-neutral-400 absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Buscar perfume (Lupa)..."
                className="w-full h-9 pl-9 pr-8 bg-neutral-100 dark:bg-[#14161D] border border-black/10 dark:border-white/10 hover:border-black/25 dark:hover:border-white/20 focus:border-[#c9a24b] text-neutral-900 dark:text-white placeholder:text-neutral-500 font-sans text-xs focus:outline-none transition-colors"
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery('')}
                  className="absolute right-2.5 top-1/2 -translate-y-1/2 p-0.5 text-neutral-400 hover:text-black dark:hover:text-white"
                  aria-label="Limpiar búsqueda"
                >
                  <X className="w-3 h-3" />
                </button>
              )}
            </div>

            {/* View Mode Toggle (Cuadrícula / Tabla) */}
            <div className="flex items-center bg-neutral-100 dark:bg-[#14161D] border border-black/10 dark:border-white/10 p-1">
              <button
                type="button"
                onClick={() => setViewMode('grid')}
                className={`flex items-center gap-1.5 px-3 py-1.5 font-mono text-xs uppercase tracking-wider transition-colors cursor-pointer ${
                  viewMode === 'grid'
                    ? 'bg-black text-white dark:bg-white dark:text-black font-semibold'
                    : 'text-neutral-600 dark:text-neutral-400 hover:text-black dark:hover:text-white'
                }`}
                title="Vista Cuadrícula"
              >
                <LayoutGrid className="w-3.5 h-3.5" />
                <span className="hidden sm:inline">Cuadrícula</span>
              </button>

              <button
                type="button"
                onClick={() => setViewMode('table')}
                className={`flex items-center gap-1.5 px-3 py-1.5 font-mono text-xs uppercase tracking-wider transition-colors cursor-pointer ${
                  viewMode === 'table'
                    ? 'bg-black text-white dark:bg-white dark:text-black font-semibold'
                    : 'text-neutral-600 dark:text-neutral-400 hover:text-black dark:hover:text-white'
                }`}
                title="Vista Tabla Técnica B2B"
              >
                <Table className="w-3.5 h-3.5" />
                <span className="hidden sm:inline">Tabla B2B</span>
              </button>
            </div>

            {/* Filter Drawer Trigger */}
            <button
              onClick={() => setIsFilterDrawerOpen(true)}
              className="flex items-center gap-2 px-4 py-2 bg-neutral-100 dark:bg-[#14161D] border border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30 text-neutral-900 dark:text-white font-mono text-xs uppercase tracking-wider transition-colors cursor-pointer"
            >
              <SlidersHorizontal className="w-3.5 h-3.5 text-[#c9a24b]" />
              <span>Filtros {activeFiltersCount > 0 ? `(${activeFiltersCount})` : ''}</span>
            </button>

            {/* Export Buttons */}
            <button
              onClick={handleExportExcel}
              className="hidden lg:flex items-center gap-1.5 px-3 py-2 bg-neutral-100 dark:bg-white/5 hover:bg-neutral-200 dark:hover:bg-white/10 border border-black/10 dark:border-white/10 text-neutral-700 dark:text-neutral-300 hover:text-black dark:hover:text-white font-mono text-xs uppercase tracking-wider transition-colors cursor-pointer"
              title="Descargar Excel"
            >
              <FileSpreadsheet className="w-3.5 h-3.5 text-emerald-500" />
              <span>Excel</span>
            </button>

            <button
              onClick={handleExportPDF}
              className="hidden lg:flex items-center gap-1.5 px-3 py-2 bg-neutral-100 dark:bg-white/5 hover:bg-neutral-200 dark:hover:bg-white/10 border border-black/10 dark:border-white/10 text-neutral-700 dark:text-neutral-300 hover:text-black dark:hover:text-white font-mono text-xs uppercase tracking-wider transition-colors cursor-pointer"
              title="Descargar Catálogo PDF"
            >
              <Download className="w-3.5 h-3.5 text-[#c9a24b]" />
              <span>PDF Trade</span>
            </button>
          </div>
        </div>

        {/* Active Filters Bar */}
        {activeFiltersCount > 0 && (
          <div className="flex flex-wrap items-center gap-2 mb-6 p-3 bg-neutral-100 dark:bg-[#12141A] border border-black/10 dark:border-white/10 text-xs font-mono">
            <span className="text-neutral-500 dark:text-neutral-400 uppercase">Filtros activos:</span>
            
            {selectedBrand !== 'Todas' && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-white dark:bg-black/60 text-neutral-800 dark:text-white border border-black/10 dark:border-white/15">
                Marca: {selectedBrand}
                <button onClick={() => setSelectedBrand('Todas')} className="hover:text-red-500 cursor-pointer">
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}

            {selectedGender !== 'Todos' && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-white dark:bg-black/60 text-neutral-800 dark:text-white border border-black/10 dark:border-white/15">
                Para: {selectedGender}
                <button onClick={() => setSelectedGender('Todos')} className="hover:text-red-500 cursor-pointer">
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}

            {selectedCategory !== 'Todos' && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-white dark:bg-black/60 text-neutral-800 dark:text-white border border-black/10 dark:border-white/15">
                Familia: {selectedCategory}
                <button onClick={() => setSelectedCategory('Todos')} className="hover:text-red-500 cursor-pointer">
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}

            {searchQuery && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-white dark:bg-black/60 text-neutral-800 dark:text-white border border-black/10 dark:border-white/15">
                Búsqueda: "{searchQuery}"
                <button onClick={() => setSearchQuery('')} className="hover:text-red-500 cursor-pointer">
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}

            <button
              onClick={clearFilters}
              className="text-[#c9a24b] hover:underline font-mono text-xs ml-auto cursor-pointer"
            >
              Limpiar todo
            </button>
          </div>
        )}

        {/* Empty Search State */}
        {filteredProducts.length === 0 ? (
          <div className="py-20 text-center border border-black/10 dark:border-white/10 bg-neutral-100 dark:bg-[#12141A] p-8">
            <Search className="w-8 h-8 text-[#c9a24b] mx-auto mb-3 opacity-80" />
            <h3 className="font-serif text-2xl text-neutral-900 dark:text-white mb-2">No se encontraron fragancias</h3>
            <p className="text-neutral-600 dark:text-neutral-400 font-sans text-xs sm:text-sm max-w-md mx-auto mb-6">
              No hay productos que coincidan con los criterios de búsqueda. Intenta con otro término o limpia los filtros.
            </p>
            <button
              onClick={clearFilters}
              className="px-6 py-2.5 bg-black dark:bg-white text-white dark:text-black font-mono text-xs uppercase font-semibold hover:opacity-90 transition-opacity cursor-pointer"
            >
              Restablecer filtros
            </button>
          </div>
        ) : (
          <>
            {/* View Mode 1: Luxury Product Card Grid (Paginated) */}
            {viewMode === 'grid' ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 animate-fade-in">
                {paginatedProducts.map((p) => (
                  <ProductCard key={p.id} product={p} />
                ))}
              </div>
            ) : (
              /* View Mode 2: Stitch B2B Technical Table (Paginated) */
              <div className="overflow-x-auto border border-black/10 dark:border-white/10 bg-white dark:bg-[#12141A] shadow-2xl animate-fade-in">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="border-b border-black/10 dark:border-white/10 bg-neutral-100 dark:bg-[#171A22] text-[10px] font-mono text-neutral-600 dark:text-neutral-400 uppercase tracking-widest">
                      <th className="py-3 px-4">Fragancia & Referencia</th>
                      <th className="py-3 px-4">Familia Olfativa</th>
                      <th className="py-3 px-4">Formato / Conc.</th>
                      <th className="py-3 px-4">PVP Minorista</th>
                      <th className="py-3 px-4 text-[#c9a24b]">Tarifa Mayorista B2B</th>
                      <th className="py-3 px-4">Stock</th>
                      <th className="py-3 px-4 text-right">Acción</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-black/5 dark:divide-white/5 font-mono text-xs">
                    {paginatedProducts.map((p) => (
                      <tr key={p.id} className="hover:bg-black/[0.02] dark:hover:bg-white/[0.03] transition-colors">
                        <td className="py-3.5 px-4">
                          <div className="flex items-center gap-3">
                            <img
                              src={p.image}
                              alt={p.name}
                              loading="lazy"
                              decoding="async"
                              className="w-10 h-10 object-contain bg-white dark:bg-black/60 border border-black/10 dark:border-white/10 p-1 shrink-0"
                            />
                            <div>
                              <div className="font-serif text-sm text-neutral-900 dark:text-white font-normal">{p.name}</div>
                              <div className="text-[10px] text-neutral-500 dark:text-neutral-400 uppercase">{p.brand} • REF #{p.id.toString().padStart(4, '0')}</div>
                            </div>
                          </div>
                        </td>
                        <td className="py-3.5 px-4 text-neutral-700 dark:text-neutral-300">
                          {p.category}
                        </td>
                        <td className="py-3.5 px-4 text-neutral-700 dark:text-neutral-300">
                          {p.size || '100 ML'} • 32% Extrait
                        </td>
                        <td className="py-3.5 px-4 text-neutral-500 dark:text-neutral-400">
                          {p.retailPrice ? formatPrice(p.retailPrice) : formatPrice(Math.round(p.price * 1.5))}
                        </td>
                        <td className="py-3.5 px-4 font-semibold text-[#c9a24b]">
                          {formatPrice(p.price)}
                          <span className="text-[9px] text-neutral-500 block">(-35% MOQ 3u)</span>
                        </td>
                        <td className="py-3.5 px-4">
                          <span className="inline-flex items-center gap-1.5 text-emerald-600 dark:text-emerald-400 text-[11px]">
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                            {p.inStock !== false ? '140+ uds' : 'Consultar'}
                          </span>
                        </td>
                        <td className="py-3.5 px-4 text-right">
                          <div className="inline-flex items-center gap-2">
                            <button
                              onClick={() => setSelectedProductForModal(p)}
                              className="p-1.5 text-neutral-600 dark:text-neutral-400 hover:text-black dark:hover:text-white bg-black/5 dark:bg-white/5 hover:bg-black/10 dark:hover:bg-white/10 transition-colors cursor-pointer"
                              title="Ver Ficha Técnica"
                            >
                              <Eye className="w-4 h-4" />
                            </button>
                            <button
                              onClick={() => {
                                addToCart(p, 1, globalPricingMode);
                                showToast(`Añadido ${p.name} al pedido.`);
                              }}
                              className="px-3 py-1.5 bg-black dark:bg-white text-white dark:text-black hover:opacity-90 font-mono text-[11px] uppercase font-semibold transition-all active:scale-[0.97] cursor-pointer"
                            >
                              Añadir
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            {/* Pagination Controls with Left & Right Arrows */}
            {totalPages > 1 && (
              <div className="mt-12 pt-8 border-t border-black/10 dark:border-white/10 flex flex-col sm:flex-row items-center justify-between gap-4 select-none">
                {/* Range Info */}
                <div className="font-mono text-xs text-neutral-600 dark:text-neutral-400">
                  Mostrando <span className="text-neutral-900 dark:text-white font-medium">{startIndex + 1}</span>–<span className="text-neutral-900 dark:text-white font-medium">{endIndex}</span> de <span className="text-neutral-900 dark:text-white font-medium">{filteredProducts.length}</span> fragancias
                </div>

                {/* Arrow Controls & Page Numbers */}
                <div className="flex items-center gap-1.5 sm:gap-2">
                  {/* Left Arrow Button */}
                  <button
                    onClick={() => handlePageChange(currentPage - 1)}
                    disabled={currentPage === 1}
                    className={`flex items-center gap-1.5 px-3.5 py-2 border font-mono text-xs uppercase tracking-wider transition-all cursor-pointer ${
                      currentPage === 1
                        ? 'opacity-25 border-black/5 dark:border-white/5 text-neutral-400 dark:text-neutral-600 pointer-events-none'
                        : 'border-black/15 dark:border-white/15 hover:border-black/40 dark:hover:border-white/40 text-neutral-800 dark:text-neutral-200 hover:text-black dark:hover:text-white hover:bg-black/5 dark:hover:bg-white/5 active:scale-[0.97]'
                    }`}
                    aria-label="Página anterior"
                    title="Página anterior"
                  >
                    <ChevronLeft className="w-4 h-4" />
                    <span className="hidden sm:inline">Anterior</span>
                  </button>

                  {/* Page Numbers */}
                  <div className="flex items-center gap-1">
                    {Array.from({ length: totalPages }, (_, i) => i + 1)
                      .filter((page) => {
                        if (totalPages <= 7) return true;
                        return (
                          page === 1 ||
                          page === totalPages ||
                          Math.abs(page - currentPage) <= 1
                        );
                      })
                      .map((page, idx, arr) => {
                        const prevPage = arr[idx - 1];
                        const showEllipsis = prevPage && page - prevPage > 1;

                        return (
                          <div key={page} className="flex items-center">
                            {showEllipsis && (
                              <span className="px-1.5 text-neutral-400 dark:text-neutral-600 font-mono text-xs select-none">
                                ...
                              </span>
                            )}
                            <button
                              onClick={() => handlePageChange(page)}
                              className={`min-w-[36px] h-9 px-2 flex items-center justify-center font-mono text-xs transition-all cursor-pointer ${
                                currentPage === page
                                  ? 'bg-black dark:bg-white text-white dark:text-black font-bold shadow-md'
                                  : 'text-neutral-600 dark:text-neutral-400 hover:text-black dark:hover:text-white hover:bg-black/5 dark:hover:bg-white/5 border border-transparent hover:border-black/10 dark:hover:border-white/10'
                              }`}
                              aria-current={currentPage === page ? 'page' : undefined}
                              title={`Ir a página ${page}`}
                            >
                              {page}
                            </button>
                          </div>
                        );
                      })}
                  </div>

                  {/* Right Arrow Button */}
                  <button
                    onClick={() => handlePageChange(currentPage + 1)}
                    disabled={currentPage === totalPages}
                    className={`flex items-center gap-1.5 px-3.5 py-2 border font-mono text-xs uppercase tracking-wider transition-all cursor-pointer ${
                      currentPage === totalPages
                        ? 'opacity-25 border-black/5 dark:border-white/5 text-neutral-400 dark:text-neutral-600 pointer-events-none'
                        : 'border-black/15 dark:border-white/15 hover:border-black/40 dark:hover:border-white/40 text-neutral-800 dark:text-neutral-200 hover:text-black dark:hover:text-white hover:bg-black/5 dark:hover:bg-white/5 active:scale-[0.97]'
                    }`}
                    aria-label="Página siguiente"
                    title="Página siguiente"
                  >
                    <span className="hidden sm:inline">Siguiente</span>
                    <ChevronRight className="w-4 h-4" />
                  </button>
                </div>
              </div>
            )}
          </>
        )}

      </div>
    </section>
  );
}
