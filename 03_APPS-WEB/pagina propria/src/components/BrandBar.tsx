import { useRef } from 'react';
import { useShop } from '../context/ShopContext';

export function BrandBar() {
  const { brandsList, selectedBrand, setSelectedBrand } = useShop();
  const scrollContainerRef = useRef<HTMLDivElement>(null);

  return (
    <section className="border-b border-black/[0.06] dark:border-white/[0.06] bg-neutral-50 dark:bg-[#0a0a0a] py-3.5 transition-colors duration-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div
          ref={scrollContainerRef}
          className="flex items-center gap-2 overflow-x-auto no-scrollbar scroll-smooth py-1"
          style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
          role="group"
          aria-label="Filtrar por marca"
        >
          {brandsList.map((brand) => {
            const isSelected = selectedBrand === brand;
            return (
              <button
                key={brand}
                onClick={() => setSelectedBrand(brand)}
                className={`flex-none text-xs sm:text-[13px] font-sans px-4 py-2 rounded-full border transition-[color,background-color,border-color,transform] duration-200 ease-out active:scale-[0.97] cursor-pointer ${
                  isSelected
                    ? 'bg-black text-white dark:bg-white dark:text-black font-semibold border-transparent shadow-sm'
                    : 'bg-transparent border-black/10 dark:border-white/10 text-neutral-600 dark:text-neutral-300 hover:border-black/30 dark:hover:border-white/30 hover:text-black dark:hover:text-white'
                }`}
                aria-pressed={isSelected}
              >
                {brand}
              </button>
            );
          })}
        </div>
      </div>
    </section>
  );
}
