import { useState, useRef, MouseEvent } from 'react';
import {
  X,
  RotateCcw,
  ShoppingBag,
  Eye,
  Sparkles,
  ArrowRight,
  ArrowLeft,
  Check,
  Crown,
  Flame,
  Waves,
  Moon,
  Briefcase,
  Heart,
  Sun,
  ShieldCheck,
  Sparkle,
  Compass,
  Zap,
  MessageCircle,
} from 'lucide-react';
import { useShop, DEFAULT_WHATSAPP_NUMBER } from '../context/ShopContext';
import { PRODUCTS } from '../data/products';
import { Product } from '../types';

interface QuizAnswers {
  gender: 'Hombre' | 'Mujer' | 'Unisex' | '';
  categories: string[]; // 'Arabes' | 'Diseñador' | 'Nicho' | 'Tubos 35ml'
  families: string[]; // 'gourmand' | 'maderas' | 'citricos' | 'especias' | 'florales'
  intensity: 'beast' | 'moderate' | 'fresh' | '';
  occasions: string[]; // 'noche' | 'citas' | 'diario' | 'formal' | 'casual'
}

interface MatchResult {
  product: Product;
  matchScore: number;
  occasionText: string;
  notesSummary: string[];
}

// 3D Tilt Wrapper for Cards
function TiltCard({
  children,
  className = '',
  onClick,
}: {
  children: React.ReactNode;
  className?: string;
  selected?: boolean;
  onClick?: () => void;
}) {
  const cardRef = useRef<HTMLDivElement>(null);
  const [tilt, setTilt] = useState({ rotateX: 0, rotateY: 0 });

  const handleMouseMove = (e: MouseEvent<HTMLDivElement>) => {
    if (!cardRef.current) return;
    const rect = cardRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    const centerX = rect.width / 2;
    const centerY = rect.height / 2;

    const rotateX = -((y - centerY) / centerY) * 4;
    const rotateY = ((x - centerX) / centerX) * 4;

    setTilt({ rotateX, rotateY });
  };

  const handleMouseLeave = () => {
    setTilt({ rotateX: 0, rotateY: 0 });
  };

  return (
    <div
      ref={cardRef}
      onClick={onClick}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      style={{
        transform: `perspective(800px) rotateX(${tilt.rotateX}deg) rotateY(${tilt.rotateY}deg)`,
        transition: 'transform 180ms cubic-bezier(0.16, 1, 0.3, 1), border-color 150ms ease, background-color 150ms ease',
      }}
      className={`relative select-none cursor-pointer transition-all duration-150 ${className}`}
    >
      {children}
    </div>
  );
}

export function FragranceQuizModal() {
  const {
    isQuizOpen,
    setIsQuizOpen,
    addToCart,
    setSelectedProductForModal,
    formatPrice,
    globalPricingMode,
    showToast,
  } = useShop();

  const [step, setStep] = useState<number>(1);
  const [answers, setAnswers] = useState<QuizAnswers>({
    gender: '',
    categories: [],
    families: [],
    intensity: '',
    occasions: [],
  });
  const [results, setResults] = useState<MatchResult[]>([]);

  if (!isQuizOpen) return null;

  // Toggle helper for multi-select
  const toggleMultiSelect = (key: 'categories' | 'families' | 'occasions', value: string) => {
    setAnswers((prev) => {
      const current = prev[key];
      const exists = current.includes(value);
      const updated = exists ? current.filter((item) => item !== value) : [...current, value];
      return { ...prev, [key]: updated };
    });
  };

  // Single select helper
  const handleSingleSelect = (key: 'gender' | 'intensity', value: any) => {
    setAnswers((prev) => ({ ...prev, [key]: value }));
  };

  // Calculate 3 recommended perfumes
  const calculateResults = () => {
    // Discovery set product reference if tubos selected
    const discoveryProduct: Product = {
      id: 9999,
      name: 'Caja 20 Perfumes en Tubo (35ml)',
      brand: 'LATHE ESSENCE',
      gender: 'Unisex',
      category: 'Tubos 35ml',
      price: 43000,
      retailPrice: 48000,
      image: '/images/tubos/caja-tubos-set-a.jpg',
      inStock: true,
      rating: 5,
      reviewsCount: 42,
      family: 'Variadas a Elección',
      description:
        'Caja con 20 perfumes en tubo de 35ml armadas 100% a tu elección por nosotros. Ultra prácticos para bolso y auto.',
      pyramid: {
        top: ['Fragancias a Elección'],
        heart: ['Armadas por Nosotros'],
        base: ['20 Tubos de 35ml'],
      },
      keyNotePills: ['20 Fragancias', '35ml Atomizador', 'A Elección'],
    };

    const candidatePool: Product[] = [discoveryProduct, ...PRODUCTS];

    const scored = candidatePool.map((p) => {
      let score = 40;

      // 1. Gender match
      if (answers.gender === 'Hombre') {
        if (p.gender === 'Hombre') score += 35;
        else if (p.gender === 'Unisex') score += 20;
        else score -= 30;
      } else if (answers.gender === 'Mujer') {
        if (p.gender === 'Mujer') score += 35;
        else if (p.gender === 'Unisex') score += 20;
        else score -= 30;
      } else {
        score += 25; // Unisex or Indistinto
      }

      // 2. Category / Type match (Arabes, Diseñador, Nicho, Tubos 35ml)
      if (answers.categories.length > 0) {
        if (answers.categories.includes(p.category)) {
          score += 45;
        }
      }

      // 3. Olfactory families / Notes
      const pText = `${p.family || ''} ${p.tag || ''} ${(p.keyNotePills || []).join(' ')} ${(p.pyramid?.top || []).join(' ')} ${(p.pyramid?.heart || []).join(' ')} ${(p.pyramid?.base || []).join(' ')} ${p.description || ''}`.toLowerCase();

      if (answers.families.length > 0) {
        answers.families.forEach((fam) => {
          if (fam === 'gourmand' && (pText.includes('vainilla') || pText.includes('dulce') || pText.includes('gourmand') || pText.includes('caramelo') || pText.includes('dátil') || pText.includes('chocolate') || pText.includes('coco'))) {
            score += 30;
          }
          if (fam === 'maderas' && (pText.includes('oud') || pText.includes('madera') || pText.includes('cedro') || pText.includes('cuero') || pText.includes('sándalo') || pText.includes('tabaco'))) {
            score += 30;
          }
          if (fam === 'citricos' && (pText.includes('cítrico') || pText.includes('fresco') || pText.includes('bergamota') || pText.includes('limón') || pText.includes('marino') || pText.includes('acuático') || pText.includes('menta'))) {
            score += 30;
          }
          if (fam === 'especias' && (pText.includes('ámbar') || pText.includes('canela') || pText.includes('especi') || pText.includes('cardamomo') || pText.includes('tonka') || pText.includes('resina'))) {
            score += 30;
          }
          if (fam === 'florales' && (pText.includes('floral') || pText.includes('jazmín') || pText.includes('rosa') || pText.includes('azahar') || pText.includes('neroli') || pText.includes('nardo'))) {
            score += 30;
          }
        });
      }

      // 4. Intensity match
      if (answers.intensity === 'beast') {
        if ((p.intensity && p.intensity >= 3) || (p.performance?.longevity || '').includes('12')) score += 20;
      } else if (answers.intensity === 'moderate') {
        score += 15;
      } else if (answers.intensity === 'fresh') {
        if (pText.includes('fresco') || pText.includes('cítrico') || pText.includes('marino')) score += 20;
      }

      // 5. Occasions match
      if (answers.occasions.length > 0) {
        answers.occasions.forEach((occ) => {
          if (occ === 'noche' && (pText.includes('noche') || pText.includes('salidas') || pText.includes('magnético') || pText.includes('seductor'))) score += 20;
          if (occ === 'citas' && (pText.includes('adictiv') || pText.includes('envolvente') || pText.includes('cálid') || pText.includes('vainilla'))) score += 20;
          if (occ === 'diario' && (pText.includes('año') || pText.includes('versátil') || pText.includes('fresco') || pText.includes('limpio'))) score += 20;
          if (occ === 'formal' && (pText.includes('imperial') || pText.includes('elegante') || pText.includes('noble') || pText.includes('lujo'))) score += 20;
          if (occ === 'casual' && (pText.includes('marina') || pText.includes('acuático') || pText.includes('limón') || pText.includes('ice'))) score += 20;
        });
      }

      // Occasion description tailored to answers
      let occasionText = 'Ideal para: Salidas nocturnas, eventos especiales y destacar';
      if (answers.occasions.includes('citas')) {
        occasionText = 'Ideal para: Citas románticas, encuentros íntimos y magnetismo de cerca';
      } else if (answers.occasions.includes('diario')) {
        occasionText = 'Ideal para: Uso diario, oficina y reuniones profesionales con pulcritud';
      } else if (answers.occasions.includes('formal')) {
        occasionText = 'Ideal para: Eventos formales, galas y presencia distinguida de autor';
      } else if (answers.occasions.includes('casual')) {
        occasionText = 'Ideal para: Días de calor, salidas casuales y sensación refrescante duradera';
      }

      // Extract 3 prominent notes for chips
      const notesSummary: string[] = [];
      if (p.keyNotePills && p.keyNotePills.length > 0) {
        notesSummary.push(...p.keyNotePills.slice(0, 3));
      } else if (p.pyramid) {
        if (p.pyramid.top[0]) notesSummary.push(p.pyramid.top[0]);
        if (p.pyramid.heart[0]) notesSummary.push(p.pyramid.heart[0]);
        if (p.pyramid.base[0]) notesSummary.push(p.pyramid.base[0]);
      } else {
        notesSummary.push('Extracto Puro', 'Alta Concentración', 'Larga Fijación');
      }

      return {
        product: p,
        score,
        occasionText,
        notesSummary,
      };
    });

    // Sort descending
    scored.sort((a, b) => b.score - a.score);

    // Pick top 3 diverse candidates
    const top3: MatchResult[] = [];
    const usedNames = new Set<string>();

    for (const item of scored) {
      if (top3.length === 3) break;
      if (!usedNames.has(item.product.name)) {
        const matchScore = Math.min(99, Math.max(90, Math.round((item.score / 175) * 100)));
        top3.push({
          product: item.product,
          matchScore: matchScore - top3.length * 2, // 98%, 96%, 94%
          occasionText: item.occasionText,
          notesSummary: item.notesSummary,
        });
        usedNames.add(item.product.name);
      }
    }

    setResults(top3);
    setStep(6); // Step 6 = Results screen
  };

  const handleNextStep = () => {
    if (step < 5) {
      setStep((prev) => prev + 1);
    } else {
      calculateResults();
    }
  };

  const handlePrevStep = () => {
    if (step > 1) {
      setStep((prev) => prev - 1);
    }
  };

  const resetQuiz = () => {
    setStep(1);
    setAnswers({
      gender: '',
      categories: [],
      families: [],
      intensity: '',
      occasions: [],
    });
    setResults([]);
  };

  const handleWhatsAppConsult = () => {
    const names = results.map((r) => r.product.name).join(', ');
    const msg = encodeURIComponent(
      `¡Hola! Hice el Test de Fragancias en LATHE ESSENCE y me recomendó estos 3 perfumes: ${names}. ¿Me podrían asesorar para armar mi pedido o darme más información?`
    );
    window.open(`https://wa.me/${DEFAULT_WHATSAPP_NUMBER}?text=${msg}`, '_blank');
  };

  // Validation to enable Next button
  const canProceed = () => {
    if (step === 1) return answers.gender !== '';
    if (step === 2) return answers.categories.length > 0;
    if (step === 3) return answers.families.length > 0;
    if (step === 4) return answers.intensity !== '';
    if (step === 5) return answers.occasions.length > 0;
    return true;
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto bg-black/85 backdrop-blur-md flex items-center justify-center p-3 sm:p-6 animate-fade-in">
      {/* Click outside backdrop */}
      <div className="fixed inset-0" onClick={() => setIsQuizOpen(false)} />

      {/* Main Quiz Modal Container */}
      <div
        className="relative w-full max-w-4xl bg-white dark:bg-[#0E1015] border border-black/10 dark:border-white/10 rounded-none shadow-2xl overflow-hidden text-neutral-900 dark:text-white transition-colors duration-200 z-10 flex flex-col my-auto"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Top Header Bar */}
        <div className="px-5 sm:px-8 py-4 border-b border-black/10 dark:border-white/10 flex items-center justify-between bg-neutral-50 dark:bg-[#13161F]">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-[#c9a24b]/15 border border-[#c9a24b]/30 flex items-center justify-center text-[#c9a24b]">
              <Sparkles className="w-4 h-4" />
            </div>
            <div>
              <span className="font-mono text-[10px] text-[#c9a24b] uppercase tracking-widest block font-bold">
                TEST OLFATIVO PERSONALIZADO
              </span>
              <h2 className="font-sans text-base sm:text-lg font-bold tracking-tight text-neutral-900 dark:text-white">
                Descubrí tu Fragancia Ideal
              </h2>
            </div>
          </div>

          <div className="flex items-center gap-2">
            {step > 1 && (
              <button
                onClick={resetQuiz}
                className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 text-[11px] font-mono uppercase font-semibold text-neutral-600 dark:text-neutral-400 hover:text-black dark:hover:text-white transition-colors cursor-pointer"
                title="Volver a empezar desde el paso 1"
              >
                <RotateCcw className="w-3.5 h-3.5" />
                <span>Reiniciar</span>
              </button>
            )}

            <button
              onClick={() => setIsQuizOpen(false)}
              className="p-2 text-neutral-500 hover:text-black dark:text-neutral-400 dark:hover:text-white bg-black/5 dark:bg-white/5 hover:bg-black/10 dark:hover:bg-white/10 transition-colors cursor-pointer"
              aria-label="Cerrar test"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Progress Bar & Step Indicator (Steps 1 to 5) */}
        {step <= 5 && (
          <div className="px-5 sm:px-8 pt-4 pb-1 bg-white dark:bg-[#0E1015]">
            <div className="flex justify-between items-center text-xs font-mono text-neutral-500 dark:text-neutral-400 mb-2 font-medium">
              <span className="uppercase tracking-widest text-[#c9a24b] font-bold">
                Paso {step} de 5
              </span>
              <span>{step * 20}% Completado</span>
            </div>
            <div className="w-full h-1.5 bg-neutral-200 dark:bg-white/10 overflow-hidden">
              <div
                className="h-full bg-[#c9a24b] transition-[width] duration-300 ease-out"
                style={{ width: `${step * 20}%` }}
              />
            </div>
          </div>
        )}

        {/* Main Content Body */}
        <div className="p-5 sm:p-8 max-h-[78vh] overflow-y-auto">
          
          {/* STEP 1: GÉNERO / PERFIL */}
          {step === 1 && (
            <div className="space-y-6 animate-fade-in">
              <div className="text-center max-w-lg mx-auto">
                <span className="text-[11px] font-mono tracking-widest uppercase text-[#c9a24b] font-bold block mb-1">
                  01 // PERFIL DESTINATARIO
                </span>
                <h3 className="font-sans text-2xl sm:text-3xl font-bold tracking-tight text-neutral-900 dark:text-white">
                  ¿Para quién estás buscando la fragancia?
                </h3>
                <p className="font-sans text-xs sm:text-sm text-neutral-600 dark:text-neutral-400 mt-2 font-normal">
                  Elegí el perfil para calibrar la selección inicial del catálogo.
                </p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-2">
                {[
                  {
                    id: 'Hombre',
                    label: 'Para Hombre',
                    badge: 'Masculino',
                    desc: 'Aromas amaderados, especiados, oscuros o cítricos de alta proyección y carácter.',
                    icon: ShieldCheck,
                  },
                  {
                    id: 'Mujer',
                    label: 'Para Mujer',
                    badge: 'Femenino',
                    desc: 'Composiciones dulces, florales blancas, gourmand adictivas o frutales sofisticadas.',
                    icon: Sparkle,
                  },
                  {
                    id: 'Unisex',
                    label: 'Unisex / Compartir',
                    badge: 'Sin Género',
                    desc: 'Extractos puros de autor y nicho pensados para fusionarse con la química de cualquier piel.',
                    icon: Compass,
                  },
                ].map((item) => {
                  const isSelected = answers.gender === item.id;
                  const Icon = item.icon;
                  return (
                    <TiltCard
                      key={item.id}
                      selected={isSelected}
                      onClick={() => handleSingleSelect('gender', item.id)}
                      className={`p-5 sm:p-6 border flex flex-col justify-between ${
                        isSelected
                          ? 'border-[#c9a24b] bg-[#c9a24b]/10 dark:bg-[#c9a24b]/15 shadow-[0_10px_30px_rgba(201,162,75,0.18)]'
                          : 'border-black/10 dark:border-white/10 bg-neutral-50 dark:bg-[#141720] hover:border-black/30 dark:hover:border-white/25'
                      }`}
                    >
                      <div>
                        <div className="flex items-center justify-between mb-3">
                          <span className="font-mono text-[9px] uppercase px-2 py-0.5 bg-black/5 dark:bg-white/10 text-[#c9a24b] font-bold">
                            {item.badge}
                          </span>
                          <div
                            className={`w-5 h-5 rounded-full border flex items-center justify-center ${
                              isSelected
                                ? 'bg-[#c9a24b] border-[#c9a24b] text-black'
                                : 'border-neutral-400 dark:border-white/20'
                            }`}
                          >
                            {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
                          </div>
                        </div>

                        <div className="w-10 h-10 rounded-none bg-white dark:bg-black/40 border border-black/10 dark:border-white/10 flex items-center justify-center text-[#c9a24b] mb-3">
                          <Icon className="w-5 h-5" />
                        </div>

                        <h4 className="font-sans text-base font-bold text-neutral-900 dark:text-white">
                          {item.label}
                        </h4>
                        <p className="font-sans text-xs text-neutral-600 dark:text-neutral-400 mt-1 leading-relaxed">
                          {item.desc}
                        </p>
                      </div>
                    </TiltCard>
                  );
                })}
              </div>
            </div>
          )}

          {/* STEP 2: TIPO DE PERFUMERÍA (Árabes, Diseñador, Nicho, Tubos) - SELECCIÓN MÚLTIPLE */}
          {step === 2 && (
            <div className="space-y-6 animate-fade-in">
              <div className="text-center max-w-xl mx-auto">
                <span className="text-[11px] font-mono tracking-widest uppercase text-[#c9a24b] font-bold block mb-1">
                  02 // TIPO DE PERFUMERÍA & LÍNEAS
                </span>
                <h3 className="font-sans text-2xl sm:text-3xl font-bold tracking-tight text-neutral-900 dark:text-white">
                  ¿Qué líneas o estilos querés explorar?
                </h3>
                <p className="font-sans text-xs sm:text-sm text-neutral-600 dark:text-neutral-400 mt-2 font-normal">
                  <strong className="text-[#c9a24b]">Podés elegir más de una opción</strong> para combinar catálogos según tu gusto.
                </p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-2">
                {[
                  {
                    id: 'Arabes',
                    title: 'Perfumes Árabes',
                    origin: 'Dubái & Oriente',
                    desc: 'Lattafa, Armaf, Rasasi. Proyección atronadora, fijación extrema (+12h) y lujo accesible.',
                    icon: Crown,
                  },
                  {
                    id: 'Diseñador',
                    title: 'Perfumes de Diseñador',
                    origin: 'Tendencia Global',
                    desc: 'Jean Paul Gaultier, Azzaro, Carolina Herrera. Aromas masivos de gran aprobación y elegancia.',
                    icon: Zap,
                  },
                  {
                    id: 'Nicho',
                    title: 'Perfumes Nicho',
                    origin: 'Alta Gama de Autor',
                    desc: 'Creed, Tom Ford, Bharara. Formulación exclusiva, materias primas puras y exclusividad total.',
                    icon: Sparkles,
                  },
                  {
                    id: 'Tubos 35ml',
                    title: 'Caja 20 Tubos (35ml)',
                    origin: 'Formato Práctico',
                    desc: 'Caja de 20 viales de 35ml a elección. Ideales para bolso, auto y probar múltiples fragancias.',
                    icon: Briefcase,
                  },
                ].map((cat) => {
                  const isSelected = answers.categories.includes(cat.id);
                  const Icon = cat.icon;
                  return (
                    <TiltCard
                      key={cat.id}
                      selected={isSelected}
                      onClick={() => toggleMultiSelect('categories', cat.id)}
                      className={`p-5 border flex flex-col justify-between ${
                        isSelected
                          ? 'border-[#c9a24b] bg-[#c9a24b]/10 dark:bg-[#c9a24b]/15 shadow-[0_10px_30px_rgba(201,162,75,0.18)]'
                          : 'border-black/10 dark:border-white/10 bg-neutral-50 dark:bg-[#141720] hover:border-black/30 dark:hover:border-white/25'
                      }`}
                    >
                      <div>
                        <div className="flex items-center justify-between mb-3">
                          <span className="font-mono text-[9px] uppercase px-2 py-0.5 bg-black/5 dark:bg-white/10 text-[#c9a24b] font-bold">
                            {cat.origin}
                          </span>
                          <div
                            className={`w-5 h-5 rounded-none border flex items-center justify-center ${
                              isSelected
                                ? 'bg-[#c9a24b] border-[#c9a24b] text-black'
                                : 'border-neutral-400 dark:border-white/20'
                            }`}
                          >
                            {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
                          </div>
                        </div>

                        <div className="w-9 h-9 rounded-none bg-white dark:bg-black/40 border border-black/10 dark:border-white/10 flex items-center justify-center text-[#c9a24b] mb-2.5">
                          <Icon className="w-4 h-4" />
                        </div>

                        <h4 className="font-sans text-sm font-bold text-neutral-900 dark:text-white">
                          {cat.title}
                        </h4>
                        <p className="font-sans text-[11px] text-neutral-600 dark:text-neutral-400 mt-1 leading-relaxed">
                          {cat.desc}
                        </p>
                      </div>
                    </TiltCard>
                  );
                })}
              </div>
            </div>
          )}

          {/* STEP 3: FAMILIAS OLFATIVAS & NOTAS - SELECCIÓN MÚLTIPLE */}
          {step === 3 && (
            <div className="space-y-6 animate-fade-in">
              <div className="text-center max-w-xl mx-auto">
                <span className="text-[11px] font-mono tracking-widest uppercase text-[#c9a24b] font-bold block mb-1">
                  03 // ACORDES & NOTAS SENSORIALES
                </span>
                <h3 className="font-sans text-2xl sm:text-3xl font-bold tracking-tight text-neutral-900 dark:text-white">
                  ¿Cuáles son tus notas favoritas?
                </h3>
                <p className="font-sans text-xs sm:text-sm text-neutral-600 dark:text-neutral-400 mt-2 font-normal">
                  <strong className="text-[#c9a24b]">Seleccioná una o varias</strong> para afinar el acorde olfativo exacto.
                </p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 pt-2">
                {[
                  {
                    id: 'gourmand',
                    title: 'Gourmand & Dulces Adictivos',
                    notes: 'Vainilla Bourbon, Caramelo, Malvavisco, Dátiles y Coco.',
                    desc: 'Cremosos, cálidos, súper atractivos y con fijación inolvidable.',
                    icon: Flame,
                  },
                  {
                    id: 'maderas',
                    title: 'Maderas Nobles, Cuero & Oud',
                    notes: 'Oud negro, Cuero curtido, Cedro del Atlas y Sándalo.',
                    desc: 'Oscuros, maduros, imponentes y con presencia ejecutiva.',
                    icon: Crown,
                  },
                  {
                    id: 'citricos',
                    title: 'Cítricos & Acuáticos Glaciales',
                    notes: 'Brisa marina, Bergamota italiana, Limón de Sicilia y Menta.',
                    desc: 'Ultra energizantes, limpios, versátiles e ideales para el calor.',
                    icon: Waves,
                  },
                  {
                    id: 'especias',
                    title: 'Ámbar & Especias Cálidas',
                    notes: 'Canela dulce, Cardamomo, Haba Tonka tostada y Resinas.',
                    desc: 'Seductores, misteriosos y envolventes para la noche.',
                    icon: Sparkles,
                  },
                  {
                    id: 'florales',
                    title: 'Florales Blancos & Sofisticados',
                    notes: 'Jazmín Sambac, Rosa de Mayo, Azahar y Nardos.',
                    desc: 'Elegancia refinada, luminosa y con distinción de alta alcurnia.',
                    icon: Sparkle,
                  },
                ].map((fam) => {
                  const isSelected = answers.families.includes(fam.id);
                  const Icon = fam.icon;
                  return (
                    <TiltCard
                      key={fam.id}
                      selected={isSelected}
                      onClick={() => toggleMultiSelect('families', fam.id)}
                      className={`p-5 border flex flex-col justify-between ${
                        isSelected
                          ? 'border-[#c9a24b] bg-[#c9a24b]/10 dark:bg-[#c9a24b]/15 shadow-[0_10px_30px_rgba(201,162,75,0.18)]'
                          : 'border-black/10 dark:border-white/10 bg-neutral-50 dark:bg-[#141720] hover:border-black/30 dark:hover:border-white/25'
                      }`}
                    >
                      <div>
                        <div className="flex items-center justify-between mb-2.5">
                          <div className="w-8 h-8 rounded-none bg-white dark:bg-black/40 border border-black/10 dark:border-white/10 flex items-center justify-center text-[#c9a24b]">
                            <Icon className="w-4 h-4" />
                          </div>
                          <div
                            className={`w-5 h-5 rounded-none border flex items-center justify-center ${
                              isSelected
                                ? 'bg-[#c9a24b] border-[#c9a24b] text-black'
                                : 'border-neutral-400 dark:border-white/20'
                            }`}
                          >
                            {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
                          </div>
                        </div>

                        <h4 className="font-sans text-sm font-bold text-neutral-900 dark:text-white">
                          {fam.title}
                        </h4>
                        <span className="font-mono text-[10px] text-[#c9a24b] block mt-1">
                          {fam.notes}
                        </span>
                        <p className="font-sans text-[11px] text-neutral-600 dark:text-neutral-400 mt-1 leading-relaxed">
                          {fam.desc}
                        </p>
                      </div>
                    </TiltCard>
                  );
                })}
              </div>
            </div>
          )}

          {/* STEP 4: INTENSIDAD & PROYECCIÓN */}
          {step === 4 && (
            <div className="space-y-6 animate-fade-in">
              <div className="text-center max-w-lg mx-auto">
                <span className="text-[11px] font-mono tracking-widest uppercase text-[#c9a24b] font-bold block mb-1">
                  04 // PROYECCIÓN & ESTELA EN PIEL
                </span>
                <h3 className="font-sans text-2xl sm:text-3xl font-bold tracking-tight text-neutral-900 dark:text-white">
                  ¿Qué nivel de presencia buscás?
                </h3>
                <p className="font-sans text-xs sm:text-sm text-neutral-600 dark:text-neutral-400 mt-2 font-normal">
                  Elegí cómo querés que se perciba tu fragancia en el entorno.
                </p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-2">
                {[
                  {
                    id: 'beast',
                    title: 'Bomba Olfativa (Modo Bestia)',
                    hours: '+12 a 18 Horas',
                    desc: 'Estela gigante (>2 metros). Que se sienta al entrar a un lugar y no pase desapercibida.',
                    icon: Zap,
                  },
                  {
                    id: 'moderate',
                    title: 'Elegante & Magnética',
                    hours: '8 a 12 Horas',
                    desc: 'Estela media (1 metro). Seduce cuando se acercan a saludarte sin llegar a ser invasiva.',
                    icon: Sparkles,
                  },
                  {
                    id: 'fresh',
                    title: 'Fresca, Limpia & Versátil',
                    hours: '6 a 8 Horas',
                    desc: 'Aura limpia y confortable. Para no saturar en días calurosos, oficinas o el gimnasio.',
                    icon: Waves,
                  },
                ].map((item) => {
                  const isSelected = answers.intensity === item.id;
                  const Icon = item.icon;
                  return (
                    <TiltCard
                      key={item.id}
                      selected={isSelected}
                      onClick={() => handleSingleSelect('intensity', item.id)}
                      className={`p-5 sm:p-6 border flex flex-col justify-between ${
                        isSelected
                          ? 'border-[#c9a24b] bg-[#c9a24b]/10 dark:bg-[#c9a24b]/15 shadow-[0_10px_30px_rgba(201,162,75,0.18)]'
                          : 'border-black/10 dark:border-white/10 bg-neutral-50 dark:bg-[#141720] hover:border-black/30 dark:hover:border-white/25'
                      }`}
                    >
                      <div>
                        <div className="flex items-center justify-between mb-3">
                          <span className="font-mono text-[9px] uppercase px-2 py-0.5 bg-black/5 dark:bg-white/10 text-[#c9a24b] font-bold">
                            {item.hours}
                          </span>
                          <div
                            className={`w-5 h-5 rounded-full border flex items-center justify-center ${
                              isSelected
                                ? 'bg-[#c9a24b] border-[#c9a24b] text-black'
                                : 'border-neutral-400 dark:border-white/20'
                            }`}
                          >
                            {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
                          </div>
                        </div>

                        <div className="w-10 h-10 rounded-none bg-white dark:bg-black/40 border border-black/10 dark:border-white/10 flex items-center justify-center text-[#c9a24b] mb-3">
                          <Icon className="w-5 h-5" />
                        </div>

                        <h4 className="font-sans text-base font-bold text-neutral-900 dark:text-white">
                          {item.title}
                        </h4>
                        <p className="font-sans text-xs text-neutral-600 dark:text-neutral-400 mt-1 leading-relaxed">
                          {item.desc}
                        </p>
                      </div>
                    </TiltCard>
                  );
                })}
              </div>
            </div>
          )}

          {/* STEP 5: OCASIÓN DE USO - SELECCIÓN MÚLTIPLE */}
          {step === 5 && (
            <div className="space-y-6 animate-fade-in">
              <div className="text-center max-w-xl mx-auto">
                <span className="text-[11px] font-mono tracking-widest uppercase text-[#c9a24b] font-bold block mb-1">
                  05 // OCASIÓN & CONTEXTO DE USO
                </span>
                <h3 className="font-sans text-2xl sm:text-3xl font-bold tracking-tight text-neutral-900 dark:text-white">
                  ¿Para qué momentos querés tu perfume?
                </h3>
                <p className="font-sans text-xs sm:text-sm text-neutral-600 dark:text-neutral-400 mt-2 font-normal">
                  <strong className="text-[#c9a24b]">Elegí una o varias ocasiones</strong> para finalizar tu perfil olfativo.
                </p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 pt-2">
                {[
                  {
                    id: 'noche',
                    title: 'Salidas Nocturnas & Fiestas',
                    desc: 'Para llamar la atención en boliches, bares o eventos donde quieras destacar.',
                    icon: Moon,
                  },
                  {
                    id: 'citas',
                    title: 'Citas Románticas & Pareja',
                    desc: 'Calidez envolvente, notas adictivas para cautivar en la cercanía.',
                    icon: Heart,
                  },
                  {
                    id: 'diario',
                    title: 'Uso Diario & Oficina',
                    desc: 'Pulcritud ejecutiva, agradable para estar horas en el trabajo sin agotar.',
                    icon: Briefcase,
                  },
                  {
                    id: 'formal',
                    title: 'Eventos Formales & Galas',
                    desc: 'Elegancia sobria, sofisticación y presencia de alta alcurnia.',
                    icon: Crown,
                  },
                  {
                    id: 'casual',
                    title: 'Días de Calor & Gimnasio',
                    desc: 'Frescura vibrante y limpia para sentirte revitalizado todo el día.',
                    icon: Sun,
                  },
                ].map((occ) => {
                  const isSelected = answers.occasions.includes(occ.id);
                  const Icon = occ.icon;
                  return (
                    <TiltCard
                      key={occ.id}
                      selected={isSelected}
                      onClick={() => toggleMultiSelect('occasions', occ.id)}
                      className={`p-5 border flex flex-col justify-between ${
                        isSelected
                          ? 'border-[#c9a24b] bg-[#c9a24b]/10 dark:bg-[#c9a24b]/15 shadow-[0_10px_30px_rgba(201,162,75,0.18)]'
                          : 'border-black/10 dark:border-white/10 bg-neutral-50 dark:bg-[#141720] hover:border-black/30 dark:hover:border-white/25'
                      }`}
                    >
                      <div>
                        <div className="flex items-center justify-between mb-2.5">
                          <div className="w-8 h-8 rounded-none bg-white dark:bg-black/40 border border-black/10 dark:border-white/10 flex items-center justify-center text-[#c9a24b]">
                            <Icon className="w-4 h-4" />
                          </div>
                          <div
                            className={`w-5 h-5 rounded-none border flex items-center justify-center ${
                              isSelected
                                ? 'bg-[#c9a24b] border-[#c9a24b] text-black'
                                : 'border-neutral-400 dark:border-white/20'
                            }`}
                          >
                            {isSelected && <Check className="w-3 h-3 stroke-[3]" />}
                          </div>
                        </div>

                        <h4 className="font-sans text-sm font-bold text-neutral-900 dark:text-white">
                          {occ.title}
                        </h4>
                        <p className="font-sans text-[11px] text-neutral-600 dark:text-neutral-400 mt-1 leading-relaxed">
                          {occ.desc}
                        </p>
                      </div>
                    </TiltCard>
                  );
                })}
              </div>
            </div>
          )}

          {/* STEP 6: RESULTADOS (TOP 3 PERFUMES RECOMENDADOS) */}
          {step === 6 && (
            <div className="space-y-8 animate-fade-in">
              <div className="text-center max-w-2xl mx-auto">
                <div className="inline-flex items-center gap-2 px-3 py-1 bg-[#c9a24b]/15 border border-[#c9a24b]/30 text-[#c9a24b] text-xs font-mono font-bold uppercase tracking-wider mb-2">
                  <Sparkles className="w-3.5 h-3.5" />
                  <span>TU CURADURÍA PERSONALIZADA // TOP 3 RECOMENDADOS</span>
                </div>
                <h3 className="font-sans text-2xl sm:text-3xl font-bold tracking-tight text-neutral-900 dark:text-white">
                  Las 3 Fragancias que Hacen Match con Vos
                </h3>
                <p className="font-sans text-xs sm:text-sm text-neutral-600 dark:text-neutral-400 mt-2 font-normal">
                  Basado en tus preferencias de notas, estilo, intensidad y ocasiones elegidas.
                </p>
              </div>

              {/* Grid of the 3 Recommended Perfumes */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
                {results.map((res, index) => {
                  const p = res.product;
                  const priceToDisplay =
                    globalPricingMode === 'mayorista' ? p.price : p.retailPrice;

                  return (
                    <div
                      key={p.id}
                      className="group relative bg-neutral-50 dark:bg-[#12141A] border border-black/10 dark:border-white/10 p-5 flex flex-col justify-between shadow-xl transition-all hover:border-[#c9a24b]"
                    >
                      {/* Top Match Tag */}
                      <div className="flex items-center justify-between mb-3">
                        <span className="font-mono text-[10px] bg-[#c9a24b] text-black font-bold px-2 py-0.5 tracking-wider uppercase">
                          TOP #{index + 1} • {res.matchScore}% MATCH
                        </span>
                        <span className="font-mono text-[9px] text-neutral-500 dark:text-neutral-400 uppercase">
                          {p.category}
                        </span>
                      </div>

                      {/* Product Image */}
                      <div className="w-full h-44 sm:h-48 bg-white dark:bg-[#161822] border border-black/5 dark:border-white/5 flex items-center justify-center p-3 overflow-hidden relative mb-4">
                        <img
                          src={p.image}
                          alt={p.name}
                          className="max-h-full max-w-full object-contain transition-transform duration-300 group-hover:scale-105"
                          loading="lazy"
                        />
                      </div>

                      {/* Info & Occasion */}
                      <div className="flex-1 flex flex-col">
                        <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400 uppercase tracking-widest font-semibold">
                          {p.brand}
                        </span>
                        <h4 className="font-sans text-lg font-bold text-neutral-900 dark:text-white mt-0.5 leading-snug">
                          {p.name}
                        </h4>

                        {/* Occasion description requested by user */}
                        <div className="p-2.5 my-3 bg-neutral-200/60 dark:bg-black/40 border border-black/5 dark:border-white/5">
                          <span className="font-mono text-[9px] uppercase text-[#c9a24b] font-bold block mb-0.5">
                            Ocasión & Momento:
                          </span>
                          <p className="font-sans text-xs text-neutral-700 dark:text-neutral-300 leading-relaxed font-normal">
                            {res.occasionText}
                          </p>
                        </div>

                        {/* Notes Pills */}
                        <div className="flex flex-wrap gap-1.5 mb-4">
                          {res.notesSummary.map((n, i) => (
                            <span
                              key={i}
                              className="font-mono text-[9px] bg-neutral-200 dark:bg-white/10 text-neutral-800 dark:text-neutral-200 px-2 py-0.5"
                            >
                              {n}
                            </span>
                          ))}
                        </div>
                      </div>

                      {/* Pricing & Actions */}
                      <div className="pt-3 border-t border-black/10 dark:border-white/10">
                        <div className="flex items-baseline justify-between mb-3">
                          <span className="font-sans text-xl font-bold text-neutral-900 dark:text-white">
                            {formatPrice(priceToDisplay)}
                          </span>
                          <span className="font-mono text-[10px] text-neutral-500 dark:text-neutral-400">
                            {globalPricingMode === 'mayorista' ? 'Mayorista (mín 3u)' : 'PVP Minorista'}
                          </span>
                        </div>

                        <div className="flex flex-col gap-2">
                          <button
                            onClick={() => {
                              addToCart(p, 1, globalPricingMode);
                              showToast(`Añadido "${p.name}" al carrito.`);
                            }}
                            className="w-full py-2.5 bg-black dark:bg-white text-white dark:text-black hover:opacity-90 font-sans text-xs font-bold uppercase tracking-wider flex items-center justify-center gap-1.5 transition-opacity cursor-pointer shadow-md active:scale-[0.98]"
                          >
                            <ShoppingBag className="w-3.5 h-3.5" />
                            <span>Sumar al Pedido</span>
                          </button>

                          <button
                            onClick={() => {
                              setSelectedProductForModal(p);
                              setIsQuizOpen(false);
                            }}
                            className="w-full py-2 bg-neutral-200 dark:bg-white/10 hover:bg-neutral-300 dark:hover:bg-white/15 text-neutral-900 dark:text-white font-sans text-xs font-semibold flex items-center justify-center gap-1.5 transition-colors cursor-pointer"
                          >
                            <Eye className="w-3.5 h-3.5 text-[#c9a24b]" />
                            <span>Ver Ficha Técnica</span>
                          </button>
                        </div>
                      </div>

                    </div>
                  );
                })}
              </div>

              {/* Bottom Actions after results */}
              <div className="p-4 sm:p-5 bg-neutral-100 dark:bg-[#151821] border border-black/10 dark:border-white/10 flex flex-col sm:flex-row items-center justify-between gap-4">
                <button
                  onClick={resetQuiz}
                  className="w-full sm:w-auto px-5 py-2.5 bg-white dark:bg-white/10 border border-black/15 dark:border-white/15 hover:border-black/30 text-neutral-900 dark:text-white font-sans text-xs font-semibold uppercase tracking-wider flex items-center justify-center gap-2 transition-all cursor-pointer"
                >
                  <RotateCcw className="w-3.5 h-3.5" />
                  <span>Probar con Otros Gustos (Reiniciar)</span>
                </button>

                <button
                  onClick={handleWhatsAppConsult}
                  className="w-full sm:w-auto px-6 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-sans text-xs font-bold uppercase tracking-wider flex items-center justify-center gap-2 transition-colors cursor-pointer shadow-md"
                >
                  <MessageCircle className="w-4 h-4" />
                  <span>Asesoramiento Personalizado por WhatsApp</span>
                </button>
              </div>
            </div>
          )}

        </div>

        {/* Footer Navigation Bar (Steps 1 to 5) */}
        {step <= 5 && (
          <div className="px-5 sm:px-8 py-4 border-t border-black/10 dark:border-white/10 bg-neutral-50 dark:bg-[#13161F] flex items-center justify-between">
            {step > 1 ? (
              <button
                onClick={handlePrevStep}
                className="px-4 py-2 border border-black/15 dark:border-white/15 hover:border-black/30 dark:hover:border-white/30 text-neutral-800 dark:text-neutral-200 font-sans text-xs font-semibold uppercase tracking-wider flex items-center gap-1.5 transition-colors cursor-pointer active:scale-[0.98]"
              >
                <ArrowLeft className="w-3.5 h-3.5" />
                <span>Volver Atrás</span>
              </button>
            ) : (
              <div />
            )}

            <button
              onClick={handleNextStep}
              disabled={!canProceed()}
              className={`px-6 sm:px-8 py-2.5 font-sans text-xs font-bold uppercase tracking-wider flex items-center gap-2 transition-all cursor-pointer shadow-lg active:scale-[0.98] ${
                canProceed()
                  ? 'bg-[#c9a24b] hover:bg-[#d8b35c] text-black cursor-pointer'
                  : 'bg-neutral-300 dark:bg-white/10 text-neutral-500 cursor-not-allowed opacity-50'
              }`}
            >
              <span>
                {step === 5 ? 'Descubrir Mis 3 Perfumes' : 'Siguiente Paso'}
              </span>
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        )}

      </div>
    </div>
  );
}
