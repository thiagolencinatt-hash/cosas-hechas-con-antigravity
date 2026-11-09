import { ShopProvider, useShop } from './context/ShopContext';
import { Navbar } from './components/Navbar';
import { BrandBar } from './components/BrandBar';
import { Hero } from './components/Hero';
import { Catalog } from './components/Catalog';
import { Footer } from './components/Footer';
import { ProductModal } from './components/ProductModal';
import { CartDrawer } from './components/CartDrawer';
import { FilterDrawer } from './components/FilterDrawer';
import { WishlistModal } from './components/WishlistModal';
import { FragranceQuizModal } from './components/FragranceQuizModal';
import { Check } from 'lucide-react';

function StoreLayout() {
  const { toastMessage } = useShop();

  return (
    <div className="min-h-screen bg-white dark:bg-[#000000] text-neutral-900 dark:text-white selection:bg-white/20 selection:text-white relative transition-colors duration-200">
      
      {/* Top Navigation */}
      <Navbar />

      {/* Brand Filter Bar */}
      <BrandBar />

      {/* Main Content */}
      <main>
        {/* 3D Hero Carousel */}
        <Hero />

        {/* Catalog Grid */}
        <Catalog />
      </main>

      {/* Modern Luxury Wholesale Footer */}
      <Footer />

      {/* Slide-over & Global Modals */}
      <ProductModal />
      <CartDrawer />
      <FilterDrawer />
      <WishlistModal />
      <FragranceQuizModal />

      {/* Global Minimalist Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 max-w-sm p-4 rounded-2xl bg-black/95 dark:bg-[#141414]/95 border border-black/10 dark:border-white/15 text-white shadow-2xl backdrop-blur-xl flex items-center gap-3 animate-fade-in">
          <div className="w-7 h-7 rounded-full bg-white text-black flex items-center justify-center flex-shrink-0 shadow-sm">
            <Check className="w-3.5 h-3.5 stroke-[3]" />
          </div>
          <p className="text-xs font-sans font-semibold leading-relaxed">{toastMessage}</p>
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
