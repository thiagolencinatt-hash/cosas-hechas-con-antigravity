import { Sun, Moon } from 'lucide-react';
import { useShop } from '../context/ShopContext';

export function FloatingThemeToggle() {
  const { theme, toggleTheme } = useShop();

  return (
    <div className="fixed bottom-6 left-1/2 -translate-x-1/2 sm:left-8 sm:translate-x-0 z-50 pointer-events-auto">
      <button
        onClick={toggleTheme}
        className={`group flex items-center justify-center gap-3 px-5 py-3 rounded-full shadow-[0_12px_36px_rgba(0,0,0,0.3)] transition-all duration-200 active:scale-95 border backdrop-blur-2xl whitespace-nowrap min-w-[210px] ${
          theme === 'light'
            ? 'bg-[#111111] text-white hover:bg-[#222222] border-neutral-700 shadow-[0_10px_30px_rgba(0,0,0,0.25)]'
            : 'bg-white text-[#111111] hover:bg-neutral-100 border-neutral-200 shadow-[0_10px_30px_rgba(255,255,255,0.15)]'
        }`}
        title={theme === 'light' ? 'Cambiar a Modo Negro' : 'Cambiar a Modo Blanco'}
        aria-label="Alternar entre modo blanco y negro"
      >
        <div
          className={`w-7 h-7 rounded-full flex items-center justify-center transition-transform duration-300 group-hover:rotate-45 ${
            theme === 'light' ? 'bg-white/15 text-amber-300' : 'bg-black/10 text-amber-600'
          }`}
        >
          {theme === 'light' ? (
            <Moon className="w-4 h-4 text-white" />
          ) : (
            <Sun className="w-4 h-4 text-amber-500" />
          )}
        </div>

        <div className="text-left font-sans flex flex-col leading-tight">
          <span className={`text-[9px] uppercase tracking-widest font-semibold ${theme === 'light' ? 'text-neutral-400' : 'text-neutral-500'}`}>
            VISTA DE PÁGINA
          </span>
          <span className="text-xs font-bold tracking-wider">
            {theme === 'light' ? 'Cambiar a Fondo Negro' : 'Cambiar a Fondo Blanco'}
          </span>
        </div>
      </button>
    </div>
  );
}
