import { useEffect, useRef, useState, useCallback } from 'react';

/**
 * Lightweight scroll-reveal hook using IntersectionObserver.
 * Returns a ref to attach to the container + a boolean `visible`.
 * Once triggered the element stays visible (no flicker on re-enter).
 */
export function useReveal(threshold = 0.15) {
  const ref = useRef<HTMLElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setVisible(true);
          observer.unobserve(el);
        }
      },
      { threshold, rootMargin: '0px 0px -60px 0px' }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, [threshold]);

  return { ref, visible };
}

/**
 * Hook that observes all children matching `[data-reveal]` inside a container.
 * Adds `.visible` class when they scroll into view.
 * Great for staggered lists (product grids, pillar strips).
 */
export function useRevealChildren() {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const children = container.querySelectorAll('[data-reveal]');
    if (children.length === 0) return;

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.1, rootMargin: '0px 0px -40px 0px' }
    );

    children.forEach((child) => observer.observe(child));
    return () => observer.disconnect();
  }, []);

  return containerRef;
}

/**
 * Scroll-linked navbar state: returns whether the page has been scrolled
 * past a given offset (default 60px).
 */
export function useScrolled(offset = 60) {
  const [scrolled, setScrolled] = useState(false);

  const handleScroll = useCallback(() => {
    setScrolled(window.scrollY > offset);
  }, [offset]);

  useEffect(() => {
    handleScroll();
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, [handleScroll]);

  return scrolled;
}
