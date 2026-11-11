# HANDOFF TÉCNICO — LATHE ESSENCE

## 1. Stack Tecnológico & Dependencias
- **Framework & Runtime**: React 19.0.0, ReactDOM 19.0.0, Vite 6.1.0, TypeScript 5.7.2.
- **Estilos**: Tailwind CSS 3.4.17 (`darkMode: "class"`), PostCSS 8.5.2, Autoprefixer 10.4.20.
- **Utilidades CSS**: `clsx` 2.1.1, `tailwind-merge` 3.0.1, `class-variance-authority` 0.7.1.
- **Animaciones**: `framer-motion` 12.43.0 (resortes, drawers y modales).
- **Iconografía**: `lucide-react` 0.475.0.

## 2. Estructura de Directorios & Archivos Clave
- `index.html`: Punto de entrada HTML con viewport, precargas y metadatos.
- `src/main.tsx`: Montaje de React sobre el DOM (`#root`).
- `src/App.tsx`: Layout principal del store, contenedor de proveedores y modales globales.
- `src/index.css`: Tokens globales, reset, scrollbar personalizada, film grain y microinteracciones Emil Kowalski.
- `src/context/ShopContext.tsx`: Store global unificado (carrito, filtros, precios, monedas ARS/USD/EUR, WhatsApp checkout, temas, wishlist).
- `src/types/index.ts`: Definición estricta de interfaces (`Product`, `CartItem`, `Currency`, `CustomerOrderData`, etc.).
- `src/data/products.ts`: Base de datos estática de 145 fragancias con notas olfativas, precios y rutas locales a imágenes.
- `src/data/joaco_products.json`: Dataset crudo original de productos importados.
- `src/hooks/useReveal.ts`: Hook para animaciones de intersección y visibilidad en scroll.
- `src/lib/utils.ts`: Helper `cn()` combinando `clsx` y `tailwind-merge`.
- `src/components/Navbar.tsx`: Barra de navegación superior con buscador en tiempo real, selector de moneda, toggles de wishlist y carrito.
- `src/components/BrandBar.tsx`: Barra horizontal deslizable para filtrado rápido por marca (Lattafa, Armaf, etc.).
- `src/components/Hero.tsx`: Carrusel 3D automatizado de perfumes destacados con CTA y pricing.
- `src/components/Catalog.tsx`: Grid de productos con conteo reactivo, badges de filtros activos y triggers de drawer.
- `src/components/ProductCard.tsx`: Tarjeta de perfume con stepper de cantidad `+`/`-`, botón wishlist y trigger de modal detallado.
- `src/components/ProductModal.tsx`: Modal con ficha técnica extendida, pirámide olfativa (salida, corazón, fondo) y rendimiento.
- `src/components/CartDrawer.tsx`: Drawer lateral deslizable con barra de progreso mayorista (mínimo 5 unidades) y checkout WhatsApp.
- `src/components/FilterDrawer.tsx`: Panel lateral con filtros por género, rango de precio, notas y ordenamiento.
- `src/components/WishlistModal.tsx`: Modal con lista de perfumes guardados y acción de mover directo al carrito.
- `src/components/FragranceQuizModal.tsx`: Quiz interactivo de 4 pasos ("El Oráculo") para recomendación personalizada de fragancias.
- `src/components/Footer.tsx`: Pie de página con información de compra mayorista, políticas y contacto comercial.
- `src/components/FloatingThemeToggle.tsx`: Botón flotante alternador Dark/Light mode.
- `src/components/Marquee.tsx`: Cintillo animado infinito con propuestas de valor (componente desacoplado).
- `src/components/PromoSection.tsx`: Sección promocional de combos (componente desacoplado).
- `src/components/Storytelling.tsx`: Sección de historia de marca (desacoplada temporalmente).
- `src/components/CartSheet.tsx`: Re-export backward compatibility de `CartDrawer`.

## 3. Sistema de Diseño
- **Estilo**: Lujo oscuro minimalista (Dark Luxury / Amouage Standard) con modo claro alternativo.
- **Paleta de Colores**:
  - Obsidiana / Fondo: `#0A0A0A` (default), `#000000` (pure dark), `#111111` (charcoal), `#141414` (card), `#181818` (elevated).
  - Acentos Oro / Champagne: `#c9a24b` (oro principal), `#e6cb85` (oro claro), `#9b937f` (oro envejecido).
  - Neutros / Hueso: `#F5F5F0` (bone), `#ECE8E1` (alabaster), `#C5BFB6` (sand), `#8E8E93` (muted).
  - Micro-bordes: `rgba(255,255,255,0.08)` a `0.15` en dark; `rgba(0,0,0,0.08)` en light.
- **Tipografías**:
  - Serif (Títulos/Elegancia): `'Cormorant Garamond'`, `'Playfair Display'`, `Georgia`.
  - Display (Acentos): `'Cinzel'`.
  - Sans (Lectura/UI): `'Plus Jakarta Sans'`, system-ui.
- **Microinteracciones (Emil Kowalski)**:
  - Botones y enlaces: `:active { transform: scale(0.97); }`.
  - Tiempos de transición: 150ms-250ms con curvas reactivas `cubic-bezier(0.16, 1, 0.3, 1)`.
  - Modales: animación desde `scale(0.95)` y `opacity: 0` a `scale(1)` y `opacity: 1`.

## 4. Estado Actual del Proyecto
- **100% Terminados & Validados**:
  - Catálogo de 145 perfumes con 143 imágenes locales en `public/images/perfumes/`.
  - Carrito deslizable (`CartDrawer`) con regla estricta de 5 unidades mínimas para venta mayorista y barra de progreso.
  - Flujo de checkout con formulario completo (24 provincias argentinas) y generador de mensaje formateado para WhatsApp.
  - Conversión multimoneda instantánea (ARS, USD, EUR) en toda la UI.
  - Búsqueda en vivo + filtrado multifacético + BrandBar.
  - Ficha técnica completa de perfume con pirámide olfativa (`ProductModal`).
  - Persistencia local de carrito y favoritos (`localStorage`).
  - Quiz recomendador de fragancias (`FragranceQuizModal`).
  - Compilación TypeScript limpia (`tsc -b`) y Vite build exitoso.
- **Incompletos / Desacoplados / Roadmap**:
  - `PromoSection.tsx`, `Storytelling.tsx` y `Marquee.tsx` existen como componentes terminados pero actualmente no están montados en `App.tsx`.
  - El bundle JS supera los 500kB debido a los datasets estáticos en `products.ts` (posible code-splitting con `React.lazy` para modales).

## 5. Reglas de Arquitectura & Conexión de Estado
- **Fuente Única de Verdad**: Todo el estado reside en `src/context/ShopContext.tsx`. Ningún componente debe duplicar estado local de carrito, wishlist o filtros.
- **Mutaciones del Carrito**: Usar siempre `addToCart(product, qty)`, `removeFromCart(id)` y `updateQuantity(id, delta)`. Manejan internamente la validación optimista y el toast feedback.
- **Modales Globales**: Controlados por booleanos y setters en `ShopContext` (`isCartOpen`, `isWishlistOpen`, `isFilterDrawerOpen`, `isQuizOpen`, `selectedProductForModal`). Montados en el nivel raíz de `App.tsx` para evitar problemas de z-index y stacking context.
- **Formateo de Precios**: Usar exclusivamente `formatPrice(product.price)` del contexto; calcula tasa de conversión según moneda seleccionada (ARS, USD, EUR).
- **Consistencia de Tipos**: Toda modificación a productos o variantes debe reflejarse en `src/types/index.ts`.
- **Rendimiento**: No importar directamente imágenes con rutas dinámicas no controladas; utilizar las rutas relativas existentes en `public/images/perfumes/`.
