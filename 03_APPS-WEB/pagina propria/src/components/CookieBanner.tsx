import { useState, useEffect } from 'react';
import { Shield, Cookie, Check } from 'lucide-react';

const STORAGE_KEY = 'lathe_cookie_consent';

export function CookieBanner() {
  const [isVisible, setIsVisible] = useState(false);
  const [isAnimatingOut, setIsAnimatingOut] = useState(false);

  useEffect(() => {
    // Comprobar si el usuario ya tomó una decisión previa
    try {
      const consent = localStorage.getItem(STORAGE_KEY);
      if (!consent) {
        // Pequeño retardo elegante para no invadir inmediatamente al cargar
        const timer = setTimeout(() => {
          setIsVisible(true);
        }, 1200);
        return () => clearTimeout(timer);
      }
    } catch {
      // Si localStorage no está disponible, no mostramos o manejamos en memoria
    }
  }, []);

  const handleConsent = (decision: 'accepted' | 'rejected') => {
    try {
      localStorage.setItem(STORAGE_KEY, decision);
    } catch {}

    // Animación suave de salida
    setIsAnimatingOut(true);
    setTimeout(() => {
      setIsVisible(false);
    }, 350);
  };

  if (!isVisible) return null;

  return (
    <aside
      role="region"
      aria-label="Consentimiento de Cookies y Privacidad"
      className={`fixed bottom-0 inset-x-0 z-50 p-3 sm:p-5 pointer-events-none transition-all duration-300 ${
        isAnimatingOut
          ? 'opacity-0 translate-y-8'
          : 'opacity-100 translate-y-0'
      }`}
    >
      <div className="max-w-4xl mx-auto pointer-events-auto bg-neutral-900/95 dark:bg-[#0E1015]/95 text-white border border-white/15 dark:border-white/10 shadow-[0_20px_50px_rgba(0,0,0,0.5)] backdrop-blur-xl p-4 sm:p-5 rounded-2xl flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        
        {/* Contenido Informativo y Legal */}
        <div className="flex items-start gap-3.5 flex-1">
          <div className="w-9 h-9 rounded-xl bg-white/10 border border-white/15 flex items-center justify-center shrink-0 text-[#c9a24b] shadow-inner mt-0.5">
            <Cookie className="w-4 h-4" />
          </div>
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <span className="font-mono text-[10px] text-[#c9a24b] uppercase tracking-[0.2em] font-semibold flex items-center gap-1">
                <Shield className="w-3 h-3" />
                Privacidad & Experiencia Sensorial
              </span>
            </div>
            <p className="font-sans text-xs sm:text-[13px] text-neutral-300 leading-relaxed font-light">
              Utilizamos cookies esenciales y analíticas para optimizar tu experiencia en nuestra boutique de alta perfumería, recordar tus preferencias de catálogo y garantizar un proceso de pedido fluido y seguro. Podés aceptar o rechazar las analíticas opcionales en cualquier momento.
            </p>
          </div>
        </div>

        {/* Acciones de Consentimiento */}
        <div className="flex items-center gap-2.5 w-full md:w-auto shrink-0 pt-2 md:pt-0 border-t md:border-t-0 border-white/10">
          <button
            onClick={() => handleConsent('rejected')}
            className="flex-1 md:flex-initial px-4 py-2.5 rounded-xl border border-white/20 hover:border-white/40 text-neutral-300 hover:text-white font-sans text-xs uppercase tracking-wider font-medium transition-colors active:scale-[0.97] cursor-pointer"
          >
            Rechazar
          </button>
          <button
            onClick={() => handleConsent('accepted')}
            className="flex-1 md:flex-initial px-5 py-2.5 rounded-xl bg-[#c9a24b] hover:bg-[#d6af57] text-neutral-950 font-sans text-xs uppercase tracking-wider font-semibold shadow-lg hover:shadow-[#c9a24b]/20 transition-all active:scale-[0.97] cursor-pointer flex items-center justify-center gap-1.5"
          >
            <Check className="w-3.5 h-3.5 stroke-[2.5]" />
            <span>Aceptar</span>
          </button>
        </div>

      </div>
    </aside>
  );
}
