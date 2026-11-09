# Workspace Rules: Pagina Propia & Web Engineering Excellence

Este proyecto está gobernado por pilares de diseño, comercio electrónico e ingeniería frontend de clase mundial y sincronización continua en Obsidian:

## 1. Emil Kowalski — Artesanía de Animación y Detalles Invisibles
- **Feedback Táctil:** Todo botón e interactivo debe contar con un estado `:active` que proporcione respuesta (`transform: scale(0.97)`).
- **Curvas y Easing:**
  - Entrada: `ease-out` con tiempos reactivos (< 300ms, típicamente 150-250ms).
  - Salida: `ease-in`.
  - Nunca usar `transition: all`. Nombrar propiedades explícitas (`transform`, `opacity`).
- **Aparición Realista:** Nunca animar desde `scale(0)`; usar `scale(0.95)` con transición de `opacity: 0 -> 1`.
- **Rendimiento GPU:** Solo animar `transform` y `opacity` para garantizar 60/120fps sostenidos.

## 2. Impeccable Design — Cero "AI Slop"
- Erradicar los clichés visuales de la IA (texto con degradado púrpura a azul, 3 tarjetas centradas genéricas, fuentes por defecto sin personalidad).
- Jerarquía tipográfica definida con contraste intencional.
- Comandos disponibles: `/impeccable shape`, `craft`, `critique`, `audit`, `polish`.

## 3. Visual Benchmarks & Taste Skill — Dirección de Arte de Vanguardia
- Inspiración y benchmarks basados en galerías élite: **Godly.website**, **Awwwards**, **Dribbble** y **Behance**.
- Fondos profundos con micro-bordes finos (`border-neutral-800`), tipografía con fuerte carácter (*Plus Jakarta Sans* / *Space Grotesk*) y fotografía auténtica.
- Verificación visual estricta en anchos desktop, tablet y mobile.

## 4. E-Commerce Architecture (Skateshop, Vercel Commerce, Medusa)
- Carrito deslizable (Slide-over Sheet) con actualización optimista inmediata.
- Tarjetas de producto interactivas con zoom suave y badge de precio visible.
- Filtros por facetas y flujo de checkout con mínima fricción.

## 5. Sincronización en Obsidian
- Toda decisión, tarea y cambio de estado se sincroniza en el Vault:
  `C:/Users/thiago/Desktop/inteligencia artificial/antigravity/antigravity/01_PROYECTOS/pagina_propia/`
