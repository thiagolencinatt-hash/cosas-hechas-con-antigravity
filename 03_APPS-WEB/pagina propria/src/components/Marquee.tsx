import { useShop } from '../context/ShopContext';

export function Marquee() {
  const { theme } = useShop();
  const isDark = theme === 'dark';

  const items = [
    'LATHE ESSENCE · ALTA PERFUMERÍA',
    'VENTA MINORISTA DESDE 1 UNIDAD',
    'VENTA MAYORISTA CON 35% DE DESCUENTO (MÍN. 3 UNIDADES)',
    'IMPORTADOS · ÁRABES · DISEÑADOR · NICHO',
    '100% ORIGINALES CON SELLO DE ORIGEN',
    'ENVÍOS A TODO EL PAÍS',
  ];

  return (
    <div
      style={{
        backgroundColor: isDark ? '#070707' : '#F5F5F0',
        borderColor: isDark ? 'rgba(255, 255, 255, 0.05)' : 'rgba(0, 0, 0, 0.06)',
      }}
      className="relative w-full py-3.5 border-y overflow-hidden flex items-center select-none transition-colors duration-300"
    >
      <div
        style={{
          background: isDark
            ? 'linear-gradient(to right, #070707, transparent)'
            : 'linear-gradient(to right, #F5F5F0, transparent)',
        }}
        className="absolute left-0 top-0 bottom-0 w-24 z-10 pointer-events-none"
      />
      <div
        style={{
          background: isDark
            ? 'linear-gradient(to left, #070707, transparent)'
            : 'linear-gradient(to left, #F5F5F0, transparent)',
        }}
        className="absolute right-0 top-0 bottom-0 w-24 z-10 pointer-events-none"
      />

      <div className="flex w-max animate-marquee space-x-12 whitespace-nowrap" aria-hidden="true">
        {items.concat(items).map((text, idx) => (
          <div
            key={idx}
            className={`flex items-center gap-10 text-[11px] font-sans tracking-[0.22em] uppercase font-medium ${
              isDark ? 'text-neutral-300' : 'text-neutral-700'
            }`}
          >
            <span>{text}</span>
            <span className={`text-[9px] ${isDark ? 'text-white/40' : 'text-black/40'}`}>•</span>
          </div>
        ))}
      </div>
    </div>
  );
}
