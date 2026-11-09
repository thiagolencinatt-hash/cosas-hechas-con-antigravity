import { useState } from 'react';
import {
  X,
  RotateCcw,
  ShoppingBag,
  Eye,
  Sparkles,
  Flame,
  Waves,
  Crown,
  Droplets,
  Coffee,
  Zap,
  Flower2,
  Moon,
  Briefcase,
  Gem,
  Landmark,
} from 'lucide-react';
import { useShop } from '../context/ShopContext';
import { PRODUCTS } from '../data/products';
import { Product } from '../types';

export function FragranceQuizModal() {
  const {
    isQuizOpen,
    setIsQuizOpen,
    addToCart,
    setSelectedProductForModal,
    formatPrice,
    globalPricingMode,
  } = useShop();

  const [step, setStep] = useState(1);
  const [answers, setAnswers] = useState({
    atmosphere: '',
    ingredient: '',
    occasion: '',
  });
  const [recommendedProduct, setRecommendedProduct] = useState<Product | null>(null);

  if (!isQuizOpen) return null;

  const handleSelectAnswer = (key: 'atmosphere' | 'ingredient' | 'occasion', value: string) => {
    const updated = { ...answers, [key]: value };
    setAnswers(updated);

    if (step < 3) {
      setStep(step + 1);
    } else {
      // Calculate best matching perfume from real stock
      let match = PRODUCTS[0];

      if (updated.ingredient.includes('Rosas') || updated.ingredient.includes('Dulces')) {
        match = PRODUCTS.find((p) => p.name.includes('Yara') || p.name.includes('Fakhar Rose')) || PRODUCTS[0];
      } else if (updated.ingredient.includes('Cuero') || updated.ingredient.includes('Tabaco')) {
        match = PRODUCTS.find((p) => p.name.includes('Asad') || p.name.includes('Odyssey')) || PRODUCTS[5];
      } else if (updated.ingredient.includes('Especias') || updated.ingredient.includes('Canela')) {
        match = PRODUCTS.find((p) => p.name.includes('Khamrah') || p.name.includes('9PM')) || PRODUCTS[19];
      } else if (updated.atmosphere.includes('Fresco') || updated.occasion.includes('Diario')) {
        match = PRODUCTS.find((p) => p.name.includes('Hawas') || p.name.includes('Aqua')) || PRODUCTS[25];
      } else {
        match = PRODUCTS.find((p) => p.name.includes('Club de Nuit') || p.name.includes('Le Male')) || PRODUCTS[20];
      }

      setRecommendedProduct(match);
      setStep(4);
    }
  };

  const resetQuiz = () => {
    setStep(1);
    setAnswers({ atmosphere: '', ingredient: '', occasion: '' });
    setRecommendedProduct(null);
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto bg-black/80 backdrop-blur-md flex items-center justify-center p-4 sm:p-6 animate-fade-in">
      <div
        className="relative w-full max-w-2xl bg-white dark:bg-[#111111] border border-black/10 dark:border-white/10 rounded-3xl overflow-hidden shadow-2xl p-6 sm:p-8 text-neutral-900 dark:text-white transition-colors duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Close Button */}
        <button
          onClick={() => setIsQuizOpen(false)}
          className="absolute top-4 right-4 w-9 h-9 rounded-full border border-black/10 dark:border-white/10 hover:border-black/30 dark:hover:border-white/30 text-neutral-500 dark:text-neutral-400 hover:text-black dark:hover:text-white flex items-center justify-center transition-colors"
          aria-label="Cerrar test"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Progress Bar */}
        {step <= 3 && (
          <div className="mb-6">
            <div className="flex justify-between items-center text-xs font-sans text-neutral-500 dark:text-neutral-400 mb-2 font-medium">
              <span className="uppercase tracking-widest text-neutral-900 dark:text-white font-semibold">
                Paso {step} de 3
              </span>
              <span>{Math.round((step / 3) * 100)}% Completado</span>
            </div>
            <div className="w-full h-1.5 rounded-full bg-neutral-200 dark:bg-white/10 overflow-hidden">
              <div
                className="h-full bg-black dark:bg-white transition-all duration-300"
                style={{ width: `${(step / 3) * 100}%` }}
              />
            </div>
          </div>
        )}

        {/* Step 1: Atmosphere */}
        {step === 1 && (
          <div className="space-y-6">
            <div className="text-center">
              <span className="text-[10px] font-sans tracking-widest uppercase text-neutral-500 dark:text-neutral-400 font-semibold">
                Perfil Sensorial
              </span>
              <h3 className="font-sans text-2xl font-semibold text-neutral-900 dark:text-white mt-1">
                ¿Qué energía querés proyectar?
              </h3>
              <p className="text-xs text-neutral-500 dark:text-neutral-400 mt-1">
                Elegí la sensación principal que mejor te defina.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {[
                { label: 'Seductor & Magnético', desc: 'Presencia nocturna imponente con halo cálido', Icon: Flame },
                { label: 'Fresco & Energético', desc: 'Vibración marina, cítrica y revitalizante', Icon: Waves },
                { label: 'Elegante & Misterioso', desc: 'Maderas oscuras, especias finas y distinción', Icon: Crown },
                { label: 'Dulce & Envolvente', desc: 'Gourmand cremoso con vainilla y frutas', Icon: Sparkles },
              ].map(({ label, desc, Icon }) => (
                <button
                  key={label}
                  onClick={() => handleSelectAnswer('atmosphere', label)}
                  className="p-4 rounded-2xl bg-neutral-50 dark:bg-white/[0.04] border border-black/5 dark:border-white/10 hover:border-black/20 dark:hover:border-white/30 text-left transition-all active:scale-98 group"
                >
                  <div className="w-10 h-10 rounded-xl bg-white dark:bg-white/10 border border-black/5 dark:border-white/10 flex items-center justify-center text-neutral-800 dark:text-neutral-200 mb-3 group-hover:scale-105 transition-transform">
                    <Icon className="w-5 h-5" />
                  </div>
                  <h4 className="font-sans text-sm font-semibold text-neutral-900 dark:text-white group-hover:opacity-80 transition-opacity">
                    {label}
                  </h4>
                  <p className="text-xs text-neutral-500 dark:text-neutral-400 mt-0.5 font-normal">{desc}</p>
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Step 2: Ingredient */}
        {step === 2 && (
          <div className="space-y-6">
            <div className="text-center">
              <span className="text-[10px] font-sans tracking-widest uppercase text-neutral-500 dark:text-neutral-400 font-semibold">
                Familia Olfativa
              </span>
              <h3 className="font-sans text-2xl font-semibold text-neutral-900 dark:text-white mt-1">
                ¿Qué notas preferís en tu piel?
              </h3>
              <p className="text-xs text-neutral-500 dark:text-neutral-400 mt-1">
                Seleccioná los acordes que más te atraen.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {[
                { label: 'Vainilla, Caramelo & Dulces', desc: 'Acordes adictivos tipo Yara, Khamrah y Eclaire', Icon: Droplets },
                { label: 'Cuero, Café & Tabaco', desc: 'Intensidad árabe como Asad, Odyssey y Wanted', Icon: Coffee },
                { label: 'Canela, Frutas & Especias', desc: 'Carácter seductor como 9PM y Hawas', Icon: Zap },
                { label: 'Rosas, Flores & Almizcle', desc: 'Flores opulentas con fondo limpio y radiante', Icon: Flower2 },
              ].map(({ label, desc, Icon }) => (
                <button
                  key={label}
                  onClick={() => handleSelectAnswer('ingredient', label)}
                  className="p-4 rounded-2xl bg-neutral-50 dark:bg-white/[0.04] border border-black/5 dark:border-white/10 hover:border-black/20 dark:hover:border-white/30 text-left transition-all active:scale-98 group"
                >
                  <div className="w-10 h-10 rounded-xl bg-white dark:bg-white/10 border border-black/5 dark:border-white/10 flex items-center justify-center text-neutral-800 dark:text-neutral-200 mb-3 group-hover:scale-105 transition-transform">
                    <Icon className="w-5 h-5" />
                  </div>
                  <h4 className="font-sans text-sm font-semibold text-neutral-900 dark:text-white group-hover:opacity-80 transition-opacity">
                    {label}
                  </h4>
                  <p className="text-xs text-neutral-500 dark:text-neutral-400 mt-0.5 font-normal">{desc}</p>
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Step 3: Occasion */}
        {step === 3 && (
          <div className="space-y-6">
            <div className="text-center">
              <span className="text-[10px] font-sans tracking-widest uppercase text-neutral-500 dark:text-neutral-400 font-semibold">
                Ocasión de Uso
              </span>
              <h3 className="font-sans text-2xl font-semibold text-neutral-900 dark:text-white mt-1">
                ¿Cuándo lo vas a llevar puesto?
              </h3>
              <p className="text-xs text-neutral-500 dark:text-neutral-400 mt-1">
                Definí el escenario principal para calibrar la proyección.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {[
                { label: 'Noche, Fiestas & Citas', desc: 'Máxima estela y duración para no pasar desapercibido', Icon: Moon },
                { label: 'Uso Diario & Trabajo', desc: 'Versátil, fresco y agradable para todo el día', Icon: Briefcase },
                { label: 'Reventa & Negocio', desc: 'Fragancias virales con altísima demanda en Argentina', Icon: Gem },
                { label: 'Colección Exclusiva', desc: 'Joyas olfativas de alta fijación y calidad nicho', Icon: Landmark },
              ].map(({ label, desc, Icon }) => (
                <button
                  key={label}
                  onClick={() => handleSelectAnswer('occasion', label)}
                  className="p-4 rounded-2xl bg-neutral-50 dark:bg-white/[0.04] border border-black/5 dark:border-white/10 hover:border-black/20 dark:hover:border-white/30 text-left transition-all active:scale-98 group"
                >
                  <div className="w-10 h-10 rounded-xl bg-white dark:bg-white/10 border border-black/5 dark:border-white/10 flex items-center justify-center text-neutral-800 dark:text-neutral-200 mb-3 group-hover:scale-105 transition-transform">
                    <Icon className="w-5 h-5" />
                  </div>
                  <h4 className="font-sans text-sm font-semibold text-neutral-900 dark:text-white group-hover:opacity-80 transition-opacity">
                    {label}
                  </h4>
                  <p className="text-xs text-neutral-500 dark:text-neutral-400 mt-0.5 font-normal">{desc}</p>
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Step 4: Result Recommendation */}
        {step === 4 && recommendedProduct && (
          <div className="text-center space-y-6 animate-fade-in">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-neutral-100 dark:bg-white/10 border border-black/5 dark:border-white/15 text-neutral-900 dark:text-white text-xs font-sans font-semibold uppercase">
              <Sparkles className="w-3.5 h-3.5 text-neutral-700 dark:text-neutral-300" />
              <span>Fragancia Recomendada para Vos</span>
            </div>

            <div className="p-6 rounded-3xl bg-neutral-50 dark:bg-white/[0.03] border border-black/5 dark:border-white/10 max-w-md mx-auto">
              <div className="w-36 h-36 mx-auto mb-4 p-2 rounded-2xl bg-white dark:bg-[#161616] border border-black/5 dark:border-white/10 flex items-center justify-center shadow-md">
                <img
                  src={recommendedProduct.image}
                  alt={recommendedProduct.name}
                  className="w-full h-full object-contain"
                />
              </div>

              <span className="text-xs font-sans text-neutral-500 dark:text-neutral-400 font-semibold uppercase tracking-wider">
                {recommendedProduct.brand}
              </span>
              <h3 className="font-sans text-2xl text-neutral-900 dark:text-white font-semibold mt-0.5">
                {recommendedProduct.name}
              </h3>
              <p className="text-xs text-neutral-600 dark:text-neutral-400 mt-1 max-w-xs mx-auto font-normal">
                {recommendedProduct.description}
              </p>

              <div className="text-xl font-sans font-bold tabular-nums text-neutral-900 dark:text-white mt-3">
                {formatPrice(
                  globalPricingMode === 'mayorista'
                    ? recommendedProduct.price
                    : recommendedProduct.retailPrice
                )}{' '}
                <span className="text-xs font-sans text-neutral-500 dark:text-neutral-400 font-normal">
                  {globalPricingMode === 'mayorista' ? 'por unidad (mín. 3u)' : 'precio final minorista'}
                </span>
              </div>
            </div>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
              <button
                onClick={() => {
                  addToCart(recommendedProduct);
                  setIsQuizOpen(false);
                }}
                className="w-full sm:w-auto px-7 py-3 rounded-full bg-black text-white dark:bg-white dark:text-black hover:opacity-90 font-sans font-bold text-xs uppercase tracking-wider flex items-center justify-center gap-2 transition-all active:scale-95 shadow-md"
              >
                <ShoppingBag className="w-4 h-4" />
                <span>Sumar al pedido</span>
              </button>

              <button
                onClick={() => {
                  setSelectedProductForModal(recommendedProduct);
                  setIsQuizOpen(false);
                }}
                className="w-full sm:w-auto px-5 py-3 rounded-full border border-black/15 dark:border-white/15 hover:border-black/30 dark:hover:border-white/30 text-neutral-900 dark:text-white font-sans font-medium text-xs flex items-center justify-center gap-1.5 transition-colors"
              >
                <Eye className="w-4 h-4" />
                <span>Ver ficha técnica</span>
              </button>

              <button
                onClick={resetQuiz}
                className="p-3 text-neutral-500 dark:text-neutral-400 hover:text-black dark:hover:text-white transition-colors"
                title="Reiniciar test"
              >
                <RotateCcw className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
