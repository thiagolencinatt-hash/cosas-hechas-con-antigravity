import { ShieldCheck, Truck, Sparkles, MessageCircle, Instagram } from 'lucide-react';
import { DEFAULT_WHATSAPP_NUMBER } from '../context/ShopContext';

export function Footer() {
  return (
    <footer className="border-t border-black/10 dark:border-white/10 bg-neutral-900 dark:bg-[#070707] text-neutral-400 pt-12 pb-16 font-sans transition-colors duration-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

        {/* Trust Badges */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 pb-12 border-b border-black/10 dark:border-white/10">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-black/5 dark:bg-white/10 border border-black/10 dark:border-white/15 flex items-center justify-center text-neutral-800 dark:text-white">
              <Truck className="w-5 h-5" />
            </div>
            <div>
              <h4 className="text-neutral-900 dark:text-white text-xs font-semibold uppercase tracking-wider">Envíos a Todo el País</h4>
              <p className="text-[11px] text-neutral-500 dark:text-neutral-400 mt-0.5">Despachos rápidos por correo y expresos.</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-black/5 dark:bg-white/10 border border-black/10 dark:border-white/15 flex items-center justify-center text-neutral-800 dark:text-white">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <div>
              <h4 className="text-neutral-900 dark:text-white text-xs font-semibold uppercase tracking-wider">100% Originales & Sellados</h4>
              <p className="text-[11px] text-neutral-500 dark:text-neutral-400 mt-0.5">Cajas cerradas de fábrica con sello de origen.</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-black/5 dark:bg-white/10 border border-black/10 dark:border-white/15 flex items-center justify-center text-neutral-800 dark:text-white">
              <Sparkles className="w-5 h-5" />
            </div>
            <div>
              <h4 className="text-neutral-900 dark:text-white text-xs font-semibold uppercase tracking-wider">Venta Minorista & Mayorista</h4>
              <p className="text-[11px] text-neutral-500 dark:text-neutral-400 mt-0.5">Minorista desde 1 unidad y Mayorista desde 3 unidades.</p>
            </div>
          </div>
        </div>

        {/* Brand & Links */}
        <div className="py-10 flex flex-col md:flex-row items-center justify-between gap-6">
          <div className="flex flex-col items-center md:items-start text-center md:text-left">
            <div className="flex items-center gap-2">
              <img
                src="/images/logo/lathe-logo-white.png"
                alt="LATHE ESSENCE"
                className="h-10 w-auto object-contain hidden dark:block"
              />
              <img
                src="/images/logo/lathe-logo-black.png"
                alt="LATHE ESSENCE"
                className="h-10 w-auto object-contain dark:hidden"
              />
            </div>
            <p className="text-xs text-neutral-500 dark:text-neutral-400 mt-2 max-w-sm font-normal">
              Alta Perfumería Selección Exclusiva. Fragancias Importadas, Árabes, Diseñador y Nicho.
            </p>
          </div>

          {/* Social & Contact */}
          <div className="flex items-center gap-3">
            <a
              href={`https://wa.me/${DEFAULT_WHATSAPP_NUMBER}`}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 px-4 py-2 rounded-full border border-black/10 dark:border-white/15 hover:border-black/30 dark:hover:border-white/30 text-neutral-800 dark:text-white text-xs font-medium transition-colors"
            >
              <MessageCircle className="w-4 h-4 text-emerald-500" />
              <span>WhatsApp Mayorista</span>
            </a>

            <a
              href="https://instagram.com"
              target="_blank"
              rel="noopener noreferrer"
              className="w-9 h-9 rounded-full border border-black/10 dark:border-white/15 hover:border-black/30 dark:hover:border-white/30 text-neutral-800 dark:text-white flex items-center justify-center transition-colors"
              aria-label="Instagram"
            >
              <Instagram className="w-4 h-4" />
            </a>
          </div>
        </div>

        {/* Copyright */}
        <div className="pt-6 border-t border-black/5 dark:border-white/5 flex flex-col sm:flex-row items-center justify-between text-[11px] text-neutral-500 gap-2">
          <p>© {new Date().getFullYear()} LATHE ESSENCE. Todos los derechos reservados.</p>
          <p className="text-neutral-500">Venta minorista y mayorista para toda la Argentina.</p>
        </div>

      </div>
    </footer>
  );
}
