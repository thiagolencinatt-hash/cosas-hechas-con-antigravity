import { useState } from 'react';
import { ShopProvider, useShop } from './context/ShopContext';
import { Navbar } from './components/Navbar';
import { BrandBar } from './components/BrandBar';
import { CinematicHero } from './components/CinematicHero';
import { PilaresOlfativos } from './components/PilaresOlfativos';
import { Catalog } from './components/Catalog';
import { MatrizComercialB2B } from './components/MatrizComercialB2B';
import { DiscoverySetShowcase } from './components/DiscoverySetShowcase';
import { Footer } from './components/Footer';
import { ProductModal } from './components/ProductModal';
import { CartDrawer } from './components/CartDrawer';
import { FilterDrawer } from './components/FilterDrawer';
import { WishlistModal } from './components/WishlistModal';
import { FragranceQuizModal } from './components/FragranceQuizModal';
import { WholesalePortalModal } from './components/WholesalePortalModal';
import { CookieBanner } from './components/CookieBanner';
import { Check } from 'lucide-react';

function StoreLayout() {
  const { toastMessage } = useShop();
  const [isWholesaleModalOpen, setIsWholesaleModalOpen] = useState(false);

  return (
    <div id="top" className="min-h-screen bg-neutral-50 dark:bg-[#0B0C10] text-neutral-900 dark:text-[#F5F5F0] selection:bg-neutral-800 selection:text-white dark:selection:bg-white/20 dark:selection:text-white relative transition-colors duration-300">
      
      {/* Top Architectural Navigation */}
      <Navbar onOpenWholesaleModal={() => setIsWholesaleModalOpen(true)} />

      {/* Main Experience Flow */}
      <main>
        {/* 1. Cinematic Scroll Hero (120 FPS Synchronous Canvas with SILLAGE Narrative) */}
        <CinematicHero />

        {/* 2. Sensory Architecture: 4 Olfactory Pillars (Stitch Integration) */}
        <PilaresOlfativos />

        {/* 3. Maison Brand Quick Filter Bar */}
        <BrandBar />

        {/* 4. Complete Catalog (Grid View & B2B Technical Table Switcher) */}
        <Catalog />

        {/* 5. Wholesale Matrix & Volume Procurement (Tier 1, 2, 3) */}
        <MatrizComercialB2B onOpenWholesaleModal={() => setIsWholesaleModalOpen(true)} />

        {/* 6. Caja 20 Perfumes en Tubo (35ml) Showcase */}
        <DiscoverySetShowcase />
      </main>

      {/* Modern Luxury Haute Parfumerie Footer */}
      <Footer />

      {/* Slide-over Drawers & Interactive Modals */}
      <ProductModal />
      <CartDrawer />
      <FilterDrawer />
      <WishlistModal />
      <FragranceQuizModal />
      <WholesalePortalModal
        isOpen={isWholesaleModalOpen}
        onClose={() => setIsWholesaleModalOpen(false)}
      />

      {/* Luxury Privacy & Cookie Consent Banner */}
      <CookieBanner />

      {/* Global Minimalist Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 max-w-sm p-4 bg-[#14161D]/95 border border-white/20 text-white shadow-2xl backdrop-blur-xl flex items-center gap-3 animate-fade-in font-mono text-xs">
          <div className="w-6 h-6 bg-[#c9a24b] text-black flex items-center justify-center flex-shrink-0 shadow-sm">
            <Check className="w-3.5 h-3.5 stroke-[3]" />
          </div>
          <p className="leading-relaxed font-sans">{toastMessage}</p>
        </div>
      )}
    </div>
  );
}

export function App() {
  return (
    <ShopProvider>
      <StoreLayout />
    </ShopProvider>
  );
}

export default App;
