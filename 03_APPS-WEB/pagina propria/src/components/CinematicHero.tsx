import { useEffect, useRef, useState } from 'react';
import { ArrowDown, Sparkles, ShieldCheck } from 'lucide-react';
import { useShop } from '../context/ShopContext';

const TOTAL_FRAMES = 140;

export function CinematicHero() {
  const { setIsQuizOpen } = useShop();

  const containerRef = useRef<HTMLDivElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // Direct DOM refs for zero-re-render 120fps scrubbing
  const band1Ref = useRef<HTMLDivElement>(null);
  const band2Ref = useRef<HTMLDivElement>(null);
  const band3Ref = useRef<HTMLDivElement>(null);
  const band4Ref = useRef<HTMLDivElement>(null);
  const scrollCueRef = useRef<HTMLDivElement>(null);
  const progressRingRef = useRef<SVGCircleElement>(null);

  const [loadedCount, setLoadedCount] = useState(0);
  const [isInitialReady, setIsInitialReady] = useState(false);

  useEffect(() => {
    const container = containerRef.current;
    const canvas = canvasRef.current;
    const b1 = band1Ref.current;
    const b2 = band2Ref.current;
    const b3 = band3Ref.current;
    const b4 = band4Ref.current;
    const cue = scrollCueRef.current;
    const ring = progressRingRef.current;

    if (!container || !canvas) return;
    const ctx = canvas.getContext('2d', { alpha: false });
    if (!ctx) return;

    let target = 0;
    let shown = 0;
    let rafId: number | null = null;
    let lastTick = 0;
    let heroOnScreen = true;
    let isDisposed = false;

    // In-memory cache for all 140 frames
    const frames: (HTMLImageElement | null)[] = new Array(TOTAL_FRAMES).fill(null);
    let framesLoaded = 0;

    // Helper: draw image with object-fit: cover math on canvas
    const drawCover = (img: HTMLImageElement) => {
      const cw = canvas.width;
      const ch = canvas.height;
      const iw = img.naturalWidth || img.width;
      const ih = img.naturalHeight || img.height;
      if (!iw || !ih) return;

      const scale = Math.max(cw / iw, ch / ih);
      const nw = iw * scale;
      const nh = ih * scale;
      const nx = (cw - nw) / 2;
      const ny = (ch - nh) / 2;

      ctx.drawImage(img, nx, ny, nw, nh);
    };

    // Resize canvas with devicePixelRatio
    const handleResize = () => {
      if (!canvas) return;
      const dpr = Math.min(window.devicePixelRatio || 1, 2);
      canvas.width = window.innerWidth * dpr;
      canvas.height = window.innerHeight * dpr;

      // Redraw current frame
      const currentIdx = Math.min(TOTAL_FRAMES - 1, Math.max(0, Math.round(shown * (TOTAL_FRAMES - 1))));
      const img = getBestAvailableFrame(currentIdx);
      if (img && img.complete) {
        drawCover(img);
      }
    };

    // Helper: find nearest loaded frame to guarantee continuous playback without blanks
    const getBestAvailableFrame = (idx: number): HTMLImageElement | null => {
      if (frames[idx]?.complete) return frames[idx];
      for (let offset = 1; offset < TOTAL_FRAMES; offset++) {
        const left = idx - offset;
        const right = idx + offset;
        if (left >= 0 && frames[left]?.complete) return frames[left];
        if (right < TOTAL_FRAMES && frames[right]?.complete) return frames[right];
      }
      return frames[0] || null;
    };

    window.addEventListener('resize', handleResize);
    handleResize();

    // High-performance non-blocking frame loader helper
    const loadSingleFrame = (i: number): Promise<void> => {
      if (i >= TOTAL_FRAMES || frames[i] || isDisposed) return Promise.resolve();
      return new Promise((resolve) => {
        const img = new Image();
        const numStr = String(i).padStart(3, '0');
        img.src = `/assets/frames_webp/f_${numStr}.webp`;
        img.decoding = 'async';
        img.onload = () => {
          if (!isDisposed) {
            frames[i] = img;
            framesLoaded++;
            setLoadedCount(framesLoaded);
            if (ring) {
              const frac = framesLoaded / TOTAL_FRAMES;
              ring.style.strokeDashoffset = `${126 * (1 - frac)}`;
            }
          }
          resolve();
        };
        img.onerror = () => resolve();
      });
    };

    // Phase 1: Critical First Frame (0ms First Meaningful Paint)
    loadSingleFrame(0).then(() => {
      if (isDisposed) return;
      setIsInitialReady(true);
      if (frames[0]) drawCover(frames[0]);

      // Phase 2: Immediate preload of first 15 frames for instant scroll response
      const initialChunk = Array.from({ length: 15 }, (_, i) => i + 1);
      Promise.all(initialChunk.map(loadSingleFrame)).then(() => {
        if (isDisposed) return;

        // Phase 3: Staggered background worker for remaining frames (gentle batches of 8)
        let nextIndex = 16;
        const scheduleNextChunk = () => {
          if (isDisposed || nextIndex >= TOTAL_FRAMES) return;
          const chunk: number[] = [];
          for (let c = 0; c < 8 && nextIndex < TOTAL_FRAMES; c++, nextIndex++) {
            chunk.push(nextIndex);
          }
          Promise.all(chunk.map(loadSingleFrame)).then(() => {
            if (isDisposed) return;
            if ('requestIdleCallback' in window) {
              window.requestIdleCallback(scheduleNextChunk, { timeout: 250 });
            } else {
              setTimeout(scheduleNextChunk, 60);
            }
          });
        };

        if ('requestIdleCallback' in window) {
          window.requestIdleCallback(scheduleNextChunk, { timeout: 250 });
        } else {
          setTimeout(scheduleNextChunk, 60);
        }
      });
    });

    // Smoothstep utility (10k-websites standard)
    const smoothstep = (p: number, e0: number, e1: number) => {
      const t = Math.min(1, Math.max(0, (p - e0) / (e1 - e0)));
      return t * t * (3 - 2 * t);
    };

    // Choreographed SILLAGE Typography Transitions (Direct DOM 120fps)
    const updateCaptions = (p: number) => {
      // Beat 1: [0.00, 0.24] — Amber. (Warm. The first thing they notice.)
      const op1 = 1 - smoothstep(p, 0.16, 0.24);
      if (b1) {
        b1.style.opacity = op1.toFixed(3);
        b1.style.transform = `translate3d(0, ${((1 - op1) * -30).toFixed(1)}px, 0)`;
        b1.style.display = op1 > 0.01 ? 'block' : 'none';
      }

      // Beat 2: [0.26, 0.50] — Oud. (Rare, dark wood. The reason they turn around.)
      const op2 = smoothstep(p, 0.26, 0.32) * (1 - smoothstep(p, 0.44, 0.50));
      if (b2) {
        b2.style.opacity = op2.toFixed(3);
        b2.style.transform = `translate3d(0, ${((1 - op2) * 30).toFixed(1)}px, 0)`;
        b2.style.display = op2 > 0.01 ? 'block' : 'none';
      }

      // Beat 3: [0.52, 0.76] — Smoke. (Faint. The part no one can explain.)
      const op3 = smoothstep(p, 0.52, 0.58) * (1 - smoothstep(p, 0.70, 0.76));
      if (b3) {
        b3.style.opacity = op3.toFixed(3);
        b3.style.transform = `translate3d(0, ${((1 - op3) * -30).toFixed(1)}px, 0)`;
        b3.style.display = op3 > 0.01 ? 'block' : 'none';
      }

      // Beat 4: [0.80, 1.00] — LATHE ESSENCE. Master Arrival & Commercial Action Gate
      const op4 = smoothstep(p, 0.80, 0.87);
      if (b4) {
        b4.style.opacity = op4.toFixed(3);
        b4.style.transform = `translate3d(0, ${((1 - op4) * 30).toFixed(1)}px, 0)`;
        b4.style.pointerEvents = op4 > 0.6 ? 'auto' : 'none';
        b4.style.display = op4 > 0.01 ? 'block' : 'none';
      }

      // Scroll cue indicator
      if (cue) {
        const cueOp = Math.max(0, 1 - p * 6);
        cue.style.opacity = cueOp.toFixed(3);
        cue.style.display = cueOp > 0.01 ? 'flex' : 'none';
      }
    };

    // The rAF Lerp Loop (Frame-Rate Independent with 60fps normalization)
    function tick(now: number) {
      const dt = Math.min(100, now - (lastTick || now));
      lastTick = now;
      const k = 0.2; // responsive crisp convergence
      shown += (target - shown) * (1 - Math.pow(1 - k, dt / 16.667));

      if (Math.abs(target - shown) < 0.0003) {
        shown = target;
        rafId = null;
        lastTick = 0;
      } else {
        rafId = requestAnimationFrame(tick);
      }

      // 1. Draw synchronous canvas frame
      const frameIdx = Math.min(TOTAL_FRAMES - 1, Math.max(0, Math.round(shown * (TOTAL_FRAMES - 1))));
      const img = getBestAvailableFrame(frameIdx);
      if (img && img.complete) {
        drawCover(img);
      }

      // 2. Synchronize typography
      updateCaptions(shown);
    }

    const onScroll = () => {
      const rect = container.getBoundingClientRect();
      const scrollable = container.offsetHeight - window.innerHeight;
      if (scrollable <= 0) return;
      target = Math.min(1, Math.max(0, -rect.top / scrollable));

      if (rafId === null && heroOnScreen) {
        rafId = requestAnimationFrame(tick);
      }
    };

    window.addEventListener('scroll', onScroll, { passive: true });

    const observer = new IntersectionObserver(
      (entries) => {
        heroOnScreen = entries[0].isIntersecting;
        if (heroOnScreen && rafId === null) {
          rafId = requestAnimationFrame(tick);
        }
      },
      { threshold: 0 }
    );
    observer.observe(container);

    // Initial paint
    onScroll();
    updateCaptions(0);

    return () => {
      isDisposed = true;
      window.removeEventListener('resize', handleResize);
      window.removeEventListener('scroll', onScroll);
      observer.disconnect();
      if (rafId !== null) cancelAnimationFrame(rafId);
    };
  }, []);

  const scrollToCatalog = () => {
    const el = document.getElementById('catalogo') || document.getElementById('catalog-section');
    if (el) {
      el.scrollIntoView({ behavior: 'smooth' });
    } else {
      window.scrollBy({ top: window.innerHeight * 1.5, behavior: 'smooth' });
    }
  };

  const scrollToWholesale = () => {
    const el = document.getElementById('b2b-matriz');
    if (el) {
      el.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <section ref={containerRef} className="relative h-[420vh] bg-[#0B0C10] text-white">
      {/* Sticky Fullscreen Luxury Stage */}
      <div className="sticky top-0 h-screen w-full overflow-hidden flex items-center justify-center select-none bg-black">
        
        {/* 1. Underlying Poster Fallback */}
        <div
          className="absolute inset-0 bg-cover bg-center transition-opacity duration-700 pointer-events-none"
          style={{
            backgroundImage: "url('/assets/frames_webp/f_000.webp')",
            opacity: isInitialReady ? 0 : 1,
          }}
          aria-hidden="true"
        />

        {/* 2. Synchronous 120 FPS High-Res Canvas */}
        <canvas
          ref={canvasRef}
          className="absolute inset-0 w-full h-full object-cover pointer-events-none"
          style={{ willChange: 'transform' }}
          aria-hidden="true"
        />

        {/* 3. Deep Obsidian Vignette & Radial Light Focus */}
        <div
          className="absolute inset-0 pointer-events-none"
          style={{
            background:
              'radial-gradient(ellipse 95% 85% at 50% 50%, rgba(11,12,16,0.15) 20%, rgba(5,6,8,0.85) 95%)',
          }}
          aria-hidden="true"
        />

        {/* 4. Streamed Loading Progress Ring (Minimalist Apple/10k Standard) */}
        {loadedCount < TOTAL_FRAMES && (
          <div
            className="absolute top-24 right-6 sm:right-10 z-20 pointer-events-none flex items-center gap-2 opacity-60 hover:opacity-100 transition-opacity"
            title={`Cargando fotogramas HD: ${loadedCount}/${TOTAL_FRAMES}`}
          >
            <svg className="w-5 h-5 -rotate-90" viewBox="0 0 48 48" aria-hidden="true">
              <circle
                cx="24"
                cy="24"
                r="20"
                fill="none"
                stroke="rgba(255,255,255,0.15)"
                strokeWidth="3"
              />
              <circle
                ref={progressRingRef}
                cx="24"
                cy="24"
                r="20"
                fill="none"
                stroke="#c9a24b"
                strokeWidth="3"
                strokeDasharray="126"
                strokeDashoffset="126"
                className="transition-all duration-150"
              />
            </svg>
            <span className="font-mono text-[9px] uppercase tracking-widest text-neutral-400">
              HD {Math.round((loadedCount / TOTAL_FRAMES) * 100)}%
            </span>
          </div>
        )}

        {/* ─── CHOREOGRAPHED SILLAGE EDITORIAL NARRATIVE BANDS ─── */}

        {/* Beat 1: Amber. (Warm. The first thing they notice.) */}
        <div
          ref={band1Ref}
          className="absolute inset-x-4 max-w-4xl mx-auto text-center pointer-events-none transition-transform duration-100 will-change-transform z-10"
          style={{ opacity: 1, transform: 'translate3d(0, 0, 0)' }}
        >
          <h1 className="font-serif text-5xl sm:text-7xl md:text-8xl lg:text-9xl tracking-tight text-[#f8f8f6] leading-none drop-shadow-[0_12px_40px_rgba(0,0,0,0.95)] mb-3 font-normal">
            Amber.
          </h1>
          <p className="font-sans text-sm sm:text-xl md:text-2xl text-[#d4d4d0] max-w-lg mx-auto font-light leading-relaxed tracking-wide drop-shadow-[0_4px_20px_rgba(0,0,0,0.95)]">
            Warm. The first thing they notice.
          </p>
        </div>

        {/* Beat 2: Oud. (Rare, dark wood. The reason they turn around.) */}
        <div
          ref={band2Ref}
          className="absolute inset-x-4 max-w-4xl mx-auto text-center pointer-events-none transition-transform duration-100 will-change-transform z-10"
          style={{ opacity: 0, transform: 'translate3d(0, 30px, 0)', display: 'none' }}
        >
          <h2 className="font-serif text-5xl sm:text-7xl md:text-8xl lg:text-9xl text-[#f8f8f6] tracking-tight leading-none mb-3 drop-shadow-[0_12px_40px_rgba(0,0,0,0.95)] font-normal">
            Oud.
          </h2>
          <p className="font-sans text-sm sm:text-xl md:text-2xl text-[#d4d4d0] max-w-xl mx-auto font-light leading-relaxed drop-shadow-[0_4px_20px_rgba(0,0,0,0.95)]">
            Rare, dark wood. The reason they turn around.
          </p>
        </div>

        {/* Beat 3: Smoke. (Faint. The part no one can explain.) */}
        <div
          ref={band3Ref}
          className="absolute inset-x-4 max-w-4xl mx-auto text-center pointer-events-none transition-transform duration-100 will-change-transform z-10"
          style={{ opacity: 0, transform: 'translate3d(0, -30px, 0)', display: 'none' }}
        >
          <h2 className="font-serif text-5xl sm:text-7xl md:text-8xl lg:text-9xl text-[#f8f8f6] tracking-tight leading-none mb-3 drop-shadow-[0_12px_40px_rgba(0,0,0,0.95)] font-normal">
            Smoke.
          </h2>
          <p className="font-sans text-sm sm:text-xl md:text-2xl text-[#d4d4d0] max-w-xl mx-auto font-light leading-relaxed drop-shadow-[0_4px_20px_rgba(0,0,0,0.95)]">
            Faint. The part no one can explain.
          </p>
        </div>

        {/* Beat 4: LATHE ESSENCE. Master Arrival & Action Plateau */}
        <div
          ref={band4Ref}
          className="absolute inset-x-4 max-w-3xl mx-auto text-center transition-transform duration-100 will-change-transform z-10 px-2"
          style={{ opacity: 0, transform: 'translate3d(0, 30px, 0)', display: 'none', pointerEvents: 'none' }}
        >
          {/* Authentic Brand Logo Image */}
          <div className="mb-3 sm:mb-4 flex justify-center">
            <img
              src="/images/logo/lathe-logo-white.png"
              alt="LATHE ESSENCE"
              className="h-10 sm:h-14 md:h-16 w-auto object-contain filter drop-shadow-[0_8px_30px_rgba(0,0,0,0.95)]"
            />
          </div>

          <div className="inline-flex items-center gap-2 px-3.5 py-1 sm:px-4 sm:py-1.5 rounded-full bg-black/60 border border-white/20 backdrop-blur-md mb-2.5 sm:mb-3 shadow-2xl">
            <Sparkles className="w-3 h-3 sm:w-3.5 sm:h-3.5 text-[#e6cb85]" />
            <span className="text-[10px] sm:text-[11px] font-mono tracking-[0.25em] uppercase text-[#e6cb85] font-semibold">
              ALTA PERFUMERÍA • COLECCIÓN PRIVADA
            </span>
          </div>

          <h2 className="font-serif text-3xl sm:text-5xl md:text-6xl text-white font-normal mb-2 sm:mb-3 drop-shadow-[0_12px_40px_rgba(0,0,0,0.95)] tracking-tight">
            Tu Firma Olfativa
          </h2>

          <p className="font-sans text-xs sm:text-sm md:text-base text-neutral-300 max-w-xl mx-auto mb-5 sm:mb-7 font-light leading-relaxed drop-shadow-[0_4px_16px_rgba(0,0,0,0.9)]">
            La presencia que perdura cuando todo lo demás se desvanece. Fragancias de nicho e importaciones directas desde París y Dubái.
          </p>

          <div className="flex flex-wrap items-center justify-center gap-2.5 sm:gap-3.5">
            <button
              onClick={scrollToCatalog}
              className="px-6 py-3 sm:px-8 sm:py-3.5 rounded-none bg-white text-black font-sans font-semibold text-xs sm:text-sm tracking-wider uppercase hover:bg-neutral-100 transition-all duration-150 ease-out active:scale-[0.97] shadow-2xl cursor-pointer"
            >
              Explorar Colección
            </button>

            <button
              onClick={scrollToWholesale}
              className="flex items-center gap-2 px-5 py-3 sm:px-7 sm:py-3.5 rounded-none bg-white/10 hover:bg-white/20 border border-white/30 text-white font-sans font-medium text-xs sm:text-sm transition-all duration-150 ease-out active:scale-[0.97] backdrop-blur-md cursor-pointer shadow-xl"
            >
              <ShieldCheck className="w-4 h-4 text-[#e6cb85]" />
              <span>Portal Mayorista B2B</span>
            </button>

            <button
              onClick={() => setIsQuizOpen(true)}
              className="flex items-center gap-2 px-5 py-3 sm:px-6 sm:py-3.5 rounded-none bg-black/60 border border-white/15 hover:border-white/40 text-neutral-300 hover:text-white font-sans font-medium text-xs sm:text-sm transition-all duration-150 ease-out active:scale-[0.97] backdrop-blur-md cursor-pointer"
            >
              <Sparkles className="w-4 h-4 text-[#c9a24b]" />
              <span>Descubrí tu Fragancia Ideal</span>
            </button>
          </div>
        </div>

        {/* Bottom Scroll Cue */}
        <div
          ref={scrollCueRef}
          className="absolute bottom-8 inset-x-0 flex flex-col items-center justify-center gap-1.5 pointer-events-none transition-opacity duration-300 z-10"
          aria-hidden="true"
        >
          <span className="text-[10px] uppercase font-mono tracking-[0.28em] text-neutral-400">
            Deslizá para descubrir
          </span>
          <ArrowDown className="w-4 h-4 text-neutral-400 animate-bounce" />
        </div>

      </div>
    </section>
  );
}
