import { useState } from 'react';
import { Flame, Droplets, Clock, ArrowRight } from 'lucide-react';
import { useShop } from '../context/ShopContext';
import { useReveal } from '../hooks/useReveal';

export function Storytelling() {
  const { setIsQuizOpen } = useShop();
  const [activeStep, setActiveStep] = useState(0);

  const { ref: headerRef, visible: headerVisible } = useReveal(0.15);
  const { ref: imageRef, visible: imageVisible } = useReveal(0.1);
  const { ref: stepsRef, visible: stepsVisible } = useReveal(0.1);

  const steps = [
    {
      title: 'Dark Stone Amphorae Maceration',
      badge: 'Phase I · 180 Days',
      icon: Clock,
      short: 'Six months of unhurried maturation in underground cellars.',
      desc: 'Each small batch rests for six months in custom earthenware amphorae sealed with organic beeswax in the Omani mountains. This deliberate pause allows wild agarwood molecules and frankincense resinoids to bind into a seamless, velvety drydown.',
    },
    {
      title: 'Sacred Cambodian Agarwood',
      badge: 'Phase II · Hydro-Distillation',
      icon: Flame,
      short: 'Ancient resin formed inside centenarian Aquilaria trees.',
      desc: 'True oud cannot be manufactured. It is born when centuries-old Aquilaria trees produce a dark aromatic resin to protect their heartwood. After years of natural transformation, this creates the most complex botanical essence on earth.',
    },
    {
      title: '35% Pure Extrait Concentration',
      badge: 'Phase III · Uncompromised',
      icon: Droplets,
      short: 'Extrait de Parfum with 24-hour enduring skin presence.',
      desc: 'While commercial fragrances dilute aroma-chemicals to 10-15%, AL-KIMIYA crafts every formulation at an uncompromising 35% Extrait concentration. One application leaves an unmistakable aura that lives on skin through the next day.',
    },
  ];

  return (
    <section id="story" className="py-28 sm:py-36 bg-[#0A0A0A] relative overflow-hidden border-t border-white/[0.04]">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Heading */}
        <div
          ref={headerRef as React.RefObject<HTMLDivElement>}
          className={`max-w-3xl mb-16 sm:mb-20 reveal ${headerVisible ? 'visible' : ''}`}
        >
          <span className="text-[10px] font-sans tracking-[0.3em] uppercase text-neutral-500 block mb-3">
            Heritage & Alchemy · The Process
          </span>
          <h2 className="font-sans text-3xl sm:text-4xl md:text-5xl font-extralight text-white tracking-wide uppercase leading-tight">
            The Ritual of Incense
            <br className="hidden sm:block" />
            <span className="font-light">& The Science of Scent</span>
          </h2>
          <p className="mt-4 text-neutral-500 text-sm leading-relaxed font-light max-w-xl">
            Discover why high Oriental perfumery stands as a timeless architectural craft — a quiet reverence for wild botanical raw materials, stone maturation, and natural fire.
          </p>
        </div>

        {/* Two-Column Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-10 lg:gap-16 items-start">
          {/* Left: Visual */}
          <div
            ref={imageRef as React.RefObject<HTMLDivElement>}
            className={`lg:col-span-5 relative reveal-left ${imageVisible ? 'visible' : ''}`}
          >
            <div className="relative aspect-[3/4] rounded-lg overflow-hidden border border-white/[0.06] bg-[#0A0A0A] group">
              <img
                src="/images/bakhoor-ritual.jpg"
                alt="Traditional Bakhoor incense ritual"
                className="w-full h-full object-cover object-center transition-transform duration-700 ease-out group-hover:scale-[1.04] filter contrast-[1.04] brightness-[0.92]"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-[#0A0A0A] via-transparent to-transparent opacity-70" />

              {/* Floating Quote */}
              <div className="absolute bottom-5 left-5 right-5 p-5 rounded-lg bg-[#0A0A0A]/90 backdrop-blur-xl border border-white/[0.08]">
                <span className="text-[9px] font-sans tracking-widest text-neutral-500 uppercase block mb-2">
                  Philosophy
                </span>
                <p className="text-[13px] font-serif italic text-neutral-300 leading-relaxed">
                  &ldquo;Perfume in the East is not a temporary accessory, but an intimate silent prayer that heralds genuine presence.&rdquo;
                </p>
              </div>
            </div>

            {/* Decorative line detail */}
            <div className="hidden lg:block absolute -right-8 top-16 bottom-16 w-px bg-gradient-to-b from-transparent via-white/[0.06] to-transparent" />
          </div>

          {/* Right: Interactive Steps */}
          <div
            ref={stepsRef as React.RefObject<HTMLDivElement>}
            className={`lg:col-span-7 space-y-3 reveal-right ${stepsVisible ? 'visible' : ''}`}
          >
            {steps.map((step, idx) => {
              const Icon = step.icon;
              const isActive = activeStep === idx;
              return (
                <div
                  key={idx}
                  onClick={() => setActiveStep(idx)}
                  className={`p-5 sm:p-6 rounded-lg border cursor-pointer transition-all duration-300 ${
                    isActive
                      ? 'bg-[#0E0E0E] border-white/15'
                      : 'bg-transparent border-white/[0.04] hover:border-white/[0.1] hover:bg-[#0E0E0E]/50'
                  }`}
                >
                  <div className="flex items-start gap-4">
                    <div
                      className={`w-10 h-10 rounded-md flex items-center justify-center flex-shrink-0 transition-all duration-200 ${
                        isActive
                          ? 'bg-white text-[#0A0A0A]'
                          : 'bg-[#141414] border border-white/[0.06] text-neutral-500'
                      }`}
                    >
                      <Icon className="w-4.5 h-4.5" />
                    </div>

                    <div className="flex-1 min-w-0">
                      <span className="text-[10px] font-sans tracking-widest uppercase text-neutral-500 block">
                        {step.badge}
                      </span>
                      <h3 className="text-sm sm:text-base font-medium text-white tracking-wide mt-1">
                        {step.title}
                      </h3>
                      <p className="text-[11px] sm:text-xs text-neutral-500 font-sans mt-1 font-light">
                        {step.short}
                      </p>

                      {isActive && (
                        <p className="text-xs sm:text-sm text-neutral-400 font-light leading-relaxed mt-3 pt-3 border-t border-white/[0.06] animate-fade-in">
                          {step.desc}
                        </p>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}

            {/* CTA Button */}
            <div className="pt-3">
              <button
                onClick={() => setIsQuizOpen(true)}
                className="w-full py-4 rounded-none bg-white hover:bg-neutral-100 text-[#0A0A0A] font-sans text-[11px] uppercase tracking-[0.2em] font-semibold transition-colors flex items-center justify-center gap-3 active:scale-[0.98]"
              >
                Descubrí tu Fragancia Ideal
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
