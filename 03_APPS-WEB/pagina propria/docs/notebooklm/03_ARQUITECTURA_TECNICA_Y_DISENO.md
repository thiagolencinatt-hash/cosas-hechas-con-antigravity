# LATHE ESSENCE — Arquitectura Técnica, Stack Frontend y Sistema de Diseño

## 1. Stack Tecnológico de Vanguardia
La aplicación está construida sobre una arquitectura Single Page Application (SPA) ultra-reactiva, diseñada para lograr tiempos de carga instantáneos y un rendimiento gráfico de 60/120fps sostenidos:

* **Core Framework:** React 19.0.0 & React-DOM 19.0.0.
* **Build Tooling:** Vite 6.1.0 con soporte HMR ultrarrápido y compilador TypeScript 5.7.2.
* **Estilizado:** Tailwind CSS 3.4.17 configurado con estrategia `darkMode: "class"`, PostCSS y Autoprefixer.
* **Animaciones e Interacciones:** `framer-motion` 12.43.0 para orquestación de resortes, sheets y drawers.
* **Iconografía Vectorial:** `lucide-react` 0.475.0 optimizada con tree-shaking.
* **Manejo de Clases Dinámicas:** `clsx`, `tailwind-merge` y `class-variance-authority`.

---

## 2. Sistema de Diseño (Dark Luxury / Amouage Standard)
La identidad visual erradica los clichés genéricos de software de IA y sigue un lenguaje de diseño editorial de alta costura inspirado en marcas como *Amouage*, *Kilian* y galerías de vanguardia (*Godly.website*, *Awwwards*):

### Paleta Cromática:
* **Fondos Profundos / Obsidiana:** `#0A0A0A` (fondo principal default), `#000000` (negro absoluto), `#111111` (charcoal), `#141414` (superficie de tarjetas) y `#181818` (elementos elevados).
* **Acentos Oro & Champagne:** `#c9a24b` (oro noble distintivo), `#e6cb85` (oro claro brillante para hover) y `#9b937f` (oro envejecido sutil).
* **Neutros Cálidos:** `#F5F5F0` (bone/hueso para tipografía principal), `#ECE8E1` (alabastro) y `#8E8E93` (gris atenuado para metadatos).
* **Micro-bordes Translúcidos:** `border-white/[0.08]` a `border-white/[0.15]` en dark mode, y `border-black/[0.08]` en light mode.

### Jerarquía Tipográfica Editorial:
* **Serif de Lujo (Títulos y Acentos):** `'Cormorant Garamond'` y `'Playfair Display'`, evocando la perfumería clásica europea y las botellas de cristal facetado.
* **Display Arábigo/Monumental:** `'Cinzel'` para detalles de marca y badges de colección.
* **Sans-Serif Técnica (Lectura y UI):** `'Plus Jakarta Sans'`, garantizando legibilidad impecable de precios, notas olfativas y botones interactivos.

---

## 3. Filosofía de Microinteracciones (Emil Kowalski)
El código de la interfaz sigue directivas estrictas de artesanía frontend:
1. **Feedback Táctil Inmediato:** Todo botón e interactivo cuenta con estado reactivo `:active { transform: scale(0.97); }` que emula la respuesta física de un botón real.
2. **Curvas y Easing Reactivo:** 
   * Tiempos de entrada rápidos (< 250ms) con curvas `ease-out` o resortes reactivos (`cubic-bezier(0.16, 1, 0.3, 1)`).
   * Nunca se utiliza `transition: all`; se declaran propiedades explícitas (`transform`, `opacity`) para garantizar aceleración pura por hardware en GPU.
3. **Aparición Natural:** Los modales y drawers nunca emergen desde `scale(0)`; inician en `scale(0.95)` con transición simultánea de opacidad de 0 a 1.

