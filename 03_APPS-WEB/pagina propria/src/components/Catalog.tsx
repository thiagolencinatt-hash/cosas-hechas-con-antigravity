import { useState } from 'react';
import { ProductCard } from './ProductCard';
import { useShop } from '../context/ShopContext';
import { SlidersHorizontal, X, LayoutGrid, Table, Download, FileSpreadsheet, Eye, Sparkles } from 'lucide-react';

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

  const handleExportExcel = () => {
    showToast('Generando planilla de inventario y tarifas mayoristas (.XLSX)...');
  };

  const handleExportPDF = () => {
    showToast('Generando Catálogo Técnico Oficial B2B (.PDF)...');
  };

  return (
    <section id="catalogo" className="py-16 bg-[#0B0C10] text-white border-b border-white/10 transition-colors duration-200">
      <div className="max-w-[1440px] mx-auto px-4 sm:px-8 lg:px-12">
        
        {/* Header & Title Bar */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-8">
          <div>
            <div className="inline-flex items-center gap-2 font-mono text-[11px] text-[#c9a24b] uppercase tracking-[0.25em] mb-2">
              <Sparkles className="w-3.5 h-3.5" />
              <span>02 / Curaduría de Alta Perfumería</span>
            </div>
            <h2 className="font-serif text-3xl sm:text-5xl font-normal tracking-tight text-white">
              Catálogo General de Fragancias
            </h2>
            <p className="font-sans text-xs sm:text-sm text-neutral-400 mt-2 max-w-2xl font-light leading-relaxed">
              Composiciones extraídas en micro-lotes. Precios dinámicos en tiempo real según modalidad: menudeo minorista desde <strong className="text-white font-medium">1 unidad</strong> o adquisición mayorista desde <strong className="text-white font-medium">3 unidades surtidas</strong> con margen de hasta el 55%.
            </p>
          </div>

          {/* View Switcher & Actions */}
          <div className="flex flex-wrap items-center gap-3">
            {/* View Mode Toggle (Stitch Specification) */}
            <div className="flex items-center bg-[#14161D] border border-white/10 p-1">
              <button
                type="button"
                onClick={() => setViewMode('grid')}
                className={`flex items-center gap-1.5 px-3 py-1.5 font-mono text-xs uppercase tracking-wider transition-colors ${
                  viewMode === 'grid'
                    ? 'bg-white text-black font-semibold'
                    : 'text-neutral-400 hover:text-white'
                }`}
                title="Vista Cuadrícula"
              >
                <LayoutGrid className="w-3.5 h-3.5" />
                <span className="hidden sm:inline">Cuadrícula</span>
              </button>

              <button
                type="button"
                onClick={() => setViewMode('table')}
                className={`flex items-center gap-1.5 px-3 py-1.5 font-mono text-xs uppercase tracking-wider transition-colors ${
                  viewMode === 'table'
                    ? 'bg-white text-black font-semibold'
                    : 'text-neutral-400 hover:text-white'
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
              className="flex items-center gap-2 px-4 py-2 bg-[#14161D] border border-white/10 hover:border-white/30 text-white font-mono text-xs uppercase tracking-wider transition-colors"
            >
              <SlidersHorizontal className="w-3.5 h-3.5 text-[#c9a24b]" />
              <span>Filtros {activeFiltersCount > 0 ? `(${activeFiltersCount})` : ''}</span>
            </button>

            {/* Export Buttons */}
            <button
              onClick={handleExportExcel}
              className="hidden lg:flex items-center gap-1.5 px-3 py-2 bg-white/5 hover:bg-white/10 border border-white/10 text-neutral-300 hover:text-white font-mono text-xs uppercase tracking-wider transition-colors"
              title="Descargar Excel"
            >
              <FileSpreadsheet className="w-3.5 h-3.5 text-emerald-400" />
              <span>Excel</span>
            </button>

            <button
              onClick={handleExportPDF}
              className="hidden lg:flex items-center gap-1.5 px-3 py-2 bg-white/5 hover:bg-white/10 border border-white/10 text-neutral-300 hover:text-white font-mono text-xs uppercase tracking-wider transition-colors"
              title="Descargar Catálogo PDF"
            >
              <Download className="w-3.5 h-3.5 text-[#c9a24b]" />
              <span>PDF Trade</span>
            </button>
          </div>
        </div>

        {/* Active Filters Bar */}
        {activeFiltersCount > 0 && (
          <div className="flex flex-wrap items-center gap-2 mb-6 p-3 bg-[#12141A] border border-white/10 text-xs font-mono">
            <span className="text-neutral-400 uppercase">Filtros activos:</span>
            
            {selectedBrand !== 'Todas' && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-black/60 text-white border border-white/15">
                Marca: {selectedBrand}
                <button onClick={() => setSelectedBrand('Todas')} className="hover:text-red-400">
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}

            {selectedGender !== 'Todos' && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-black/60 text-white border border-white/15">
                Para: {selectedGender}
                <button onClick={() => setSelectedGender('Todos')} className="hover:text-red-400">
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}

            {selectedCategory !== 'Todos' && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-black/60 text-white border border-white/15">
                Familia: {selectedCategory}
                <button onClick={() => setSelectedCategory('Todos')} className="hover:text-red-400">
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}

            {searchQuery && (
              <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-black/60 text-white border border-white/15">
                Búsqueda: "{searchQuery}"
                <button onClick={() => setSearchQuery('')} className="hover:text-red-400">
                  <X className="w-3 h-3" />
                </button>
              </span>
            )}

            <button
              onClick={clearFilters}
              className="text-[#c9a24b] hover:underline font-mono text-xs ml-auto"
            >
              Limpiar todo
            </button>
          </div>
        )}

        {/* View Mode 1: Luxury Product Card Grid */}
        {viewMode === 'grid' ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {filteredProducts.map((p) => (
              <ProductCard key={p.id} product={p} />
            ))}
          </div>
        ) : (
          /* View Mode 2: Stitch B2B Technical Table */
          <div className="overflow-x-auto border border-white/10 bg-[#12141A] shadow-2xl">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="border-b border-white/10 bg-[#171A22] text-[10px] font-mono text-neutral-400 uppercase tracking-widest">
                  <th className="py-3 px-4">Fragancia & Referencia</th>
                  <th className="py-3 px-4">Familia Olfativa</th>
                  <th className="py-3 px-4">Formato / Conc.</th>
                  <th className="py-3 px-4">PVP Minorista</th>
                  <th className="py-3 px-4 text-[#c9a24b]">Tarifa Mayorista B2B</th>
                  <th className="py-3 px-4">Stock</th>
                  <th className="py-3 px-4 text-right">Acción</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5 font-mono text-xs">
                {filteredProducts.map((p) => (
                  <tr key={p.id} className="hover:bg-white/[0.03] transition-colors">
                    <td className="py-3.5 px-4">
                      <div className="flex items-center gap-3">
                        <img
                          src={p.image}
                          alt={p.name}
                          className="w-10 h-10 object-contain bg-black/60 border border-white/10 p-1 shrink-0"
                        />
                        <div>
                          <div className="font-serif text-sm text-white font-normal">{p.name}</div>
                          <div className="text-[10px] text-neutral-400 uppercase">{p.brand} • REF #{p.id.toString().padStart(4, '0')}</div>
                        </div>
                      </div>
                    </td>
                    <td className="py-3.5 px-4 text-neutral-300">
                      {p.category}
                    </td>
                    <td className="py-3.5 px-4 text-neutral-300">
                      {p.size || '100 ML'} • 32% Extrait
                    </td>
                    <td className="py-3.5 px-4 text-neutral-400">
                      {p.retailPrice ? formatPrice(p.retailPrice) : formatPrice(Math.round(p.price * 1.5))}
                    </td>
                    <td className="py-3.5 px-4 font-semibold text-[#c9a24b]">
                      {formatPrice(p.price)}
                      <span className="text-[9px] text-neutral-500 block">(-35% MOQ 3u)</span>
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="inline-flex items-center gap-1.5 text-emerald-400 text-[11px]">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />
                        {p.inStock !== false ? '140+ uds' : 'Consultar'}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <div className="inline-flex items-center gap-2">
                        <button
                          onClick={() => setSelectedProductForModal(p)}
                          className="p-1.5 text-neutral-400 hover:text-white bg-white/5 hover:bg-white/10 transition-colors"
                          title="Ver Ficha Técnica"
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => {
                            addToCart(p, 1, globalPricingMode);
                            showToast(`Añadido ${p.name} al pedido.`);
                          }}
                          className="px-3 py-1.5 bg-white text-black hover:bg-neutral-200 font-mono text-[11px] uppercase font-semibold transition-all active:scale-[0.97]"
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

      </div>
    </section>
  );
}
