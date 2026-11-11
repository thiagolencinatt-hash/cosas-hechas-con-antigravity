import { useState, useEffect } from 'react';
import { Download, X, Share } from 'lucide-react';

interface BeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed' }>;
}

export function PWAInstallPrompt() {
  const [deferredPrompt, setDeferredPrompt] = useState<BeforeInstallPromptEvent | null>(null);
  const [showPrompt, setShowPrompt] = useState(false);
  const [isIOS, setIsIOS] = useState(false);
  const [isStandalone, setIsStandalone] = useState(false);

  useEffect(() => {
    // 1. Verificar si ya está corriendo como PWA instalada
    const isApp = window.matchMedia('(display-mode: standalone)').matches ||
      (window.navigator as unknown as { standalone?: boolean }).standalone === true;
    if (isApp) {
      setIsStandalone(true);
      return;
    }

    // 2. Verificar si el usuario ya descartó el aviso en esta sesión
    const isDismissed = localStorage.getItem('lathe_pwa_dismissed');
    if (isDismissed) return;

    // 3. Detección de iOS (Safari)
    const userAgent = window.navigator.userAgent.toLowerCase();
    const isIosDevice = /iphone|ipad|ipod/.test(userAgent);
    setIsIOS(isIosDevice);

    // 4. Capturar evento nativo de instalación en Chrome / Edge / Android
    const handleBeforeInstallPrompt = (e: Event) => {
      e.preventDefault();
      setDeferredPrompt(e as BeforeInstallPromptEvent);
      // Mostrar el aviso con una demora agradable
      setTimeout(() => setShowPrompt(true), 3000);
    };

    window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt);

    // Si es iOS Safari y no está instalada, mostrar sugerencia sutil
    if (isIosDevice && !isApp) {
      const iosShown = sessionStorage.getItem('lathe_ios_pwa_shown');
      if (!iosShown) {
        setTimeout(() => {
          setShowPrompt(true);
          sessionStorage.setItem('lathe_ios_pwa_shown', 'true');
        }, 4000);
      }
    }

    return () => {
      window.removeEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
    };
  }, []);

  const handleInstallClick = async () => {
    if (deferredPrompt) {
      await deferredPrompt.prompt();
      const choice = await deferredPrompt.userChoice;
      if (choice.outcome === 'accepted') {
        setShowPrompt(false);
      }
      setDeferredPrompt(null);
    }
  };

  const handleDismiss = () => {
    setShowPrompt(false);
    try {
      localStorage.setItem('lathe_pwa_dismissed', 'true');
    } catch {}
  };

  if (isStandalone || !showPrompt) return null;

  return (
    <div
      role="dialog"
      aria-label="Instalar aplicación LATHE ESSENCE"
      className="fixed bottom-20 sm:bottom-6 left-4 right-4 sm:left-auto sm:right-6 sm:max-w-md z-40 bg-neutral-900/95 dark:bg-[#0E1015]/95 border border-[#c9a24b]/40 text-white p-4 rounded-2xl shadow-[0_20px_40px_rgba(0,0,0,0.6)] backdrop-blur-xl animate-fade-in"
    >
      <div className="flex items-start gap-3.5">
        {/* App Icon */}
        <div className="w-12 h-12 rounded-xl overflow-hidden shrink-0 border border-white/10 shadow-md bg-black">
          <img
            src="/icons/icon-192.png"
            alt="LATHE ESSENCE Icon"
            className="w-full h-full object-cover"
          />
        </div>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between gap-2">
            <span className="font-mono text-[9px] uppercase tracking-[0.2em] text-[#c9a24b] font-bold">
              APP OFICIAL PWA
            </span>
            <button
              onClick={handleDismiss}
              className="text-neutral-400 hover:text-white p-1 -mr-1 transition-colors"
              aria-label="Cerrar aviso"
            >
              <X className="w-3.5 h-3.5" />
            </button>
          </div>

          <h4 className="font-sans text-sm font-semibold text-white mt-0.5">
            Instalar LATHE ESSENCE
          </h4>

          <p className="font-sans text-xs text-neutral-300 mt-1 leading-relaxed font-light">
            {isIOS
              ? 'Tocá el botón Compartir y seleccioná "Agregar a pantalla de inicio" para tener el catálogo mayorista directo en tu celular.'
              : 'Instalá el catálogo en tu inicio para acceder a precios mayoristas y cotizaciones sin abrir el navegador.'}
          </p>

          {/* Action Button */}
          <div className="mt-3 flex items-center gap-2">
            {!isIOS && deferredPrompt ? (
              <button
                onClick={handleInstallClick}
                className="px-4 py-2 bg-[#c9a24b] hover:bg-[#d8b35c] text-neutral-950 font-sans text-xs uppercase tracking-wider font-semibold rounded-xl flex items-center gap-1.5 transition-all shadow-md active:scale-[0.97] cursor-pointer"
              >
                <Download className="w-3.5 h-3.5" />
                <span>Instalar en el Teléfono</span>
              </button>
            ) : isIOS ? (
              <div className="flex items-center gap-1.5 text-xs text-[#c9a24b] font-medium bg-white/5 px-2.5 py-1.5 rounded-lg border border-white/10">
                <Share className="w-3.5 h-3.5 shrink-0" />
                <span>Compartir → Agregar al inicio</span>
              </div>
            ) : null}

            <button
              onClick={handleDismiss}
              className="px-3 py-2 text-xs text-neutral-400 hover:text-white transition-colors"
            >
              Ahora no
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
