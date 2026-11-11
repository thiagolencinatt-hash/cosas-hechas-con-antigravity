# LATHE ESSENCE — Experiencia de Usuario, Flujos Interactivos y "El Oráculo"

## 1. El Oráculo: Quiz Interactivo Recomendador de Fragancias
Uno de los componentes de mayor diferenciación de Lathe Essence es **"El Oráculo"** (`FragranceQuizModal`), un recomendador interactivo de 4 pasos diseñado para resolver la mayor barrera de compra online de perfumes: *la imposibilidad de oler la fragancia antes de comprar*.

### Flujo de 4 Pasos del Quiz:
1. **Paso 1: ¿Para quién es la fragancia?**  
   Segmentación de destinatario: *Hombre*, *Mujer* o *Unisex*.
2. **Paso 2: ¿En qué momentos del día o año la vas a usar?**  
   Contexto de uso: Climas cálidos/frescos, citas nocturnas, eventos formales o uso diario versátil.
3. **Paso 3: ¿Qué sensaciones o notas olfativas preferís?**  
   Preferencias de acordes: Amaderado y cuero, dulce/gourmand y avainillado, cítrico y fresco, o especiado oriental.
4. **Paso 4: ¿Qué proyección o intensidad buscás?**  
   Firma personal: Discreta y elegante, moderada o estela potente y duradera (*beast mode*).

### Motor de Puntuación:
El algoritmo cruza las respuestas con los metadatos de las 145 fragancias de `products.ts`, asigna puntajes de compatibilidad y devuelve las 3 mejores opciones recomendadas con acceso directo a agregar al carrito o ver la ficha técnica.

---

## 2. Carrito Deslizable y Barra de Progreso Mayorista (`CartDrawer`)
* **Acceso Inmediato:** El carrito se despliega como un slide-over sheet desde el lateral derecho sin abandonar la vista actual.
* **Control de Cantidades:** Stepper de incremento/decremento reactivo en cada producto con actualización optimista de subtotales.
* **Barra de Progreso Mayorista (Meta: 5 unidades):**
  * Cuando el carrito tiene 1 a 4 perfumes, muestra una barra animada con porcentaje de completitud y texto de estímulo.
  * Al llegar a 5 unidades, la barra se completa en tono dorado champagne con un badge de felicitación: *"¡Acceso mayorista desbloqueado!"*.
* **Persistencia:** Todo el contenido del carrito y la lista de deseos (`wishlist`) se sincroniza en `localStorage`, garantizando que el usuario no pierda su selección al recargar o volver al sitio días después.

---

## 3. Filtrado Multifacético y Búsqueda en Tiempo Real
* **Buscador en Navbar:** Filtra de forma instantánea por nombre del perfume, marca o notas olfativas clave.
* **Panel de Filtros (`FilterDrawer`):** Permite combinar múltiples filtros simultáneos:
  * Género (Hombre, Mujer, Unisex).
  * Categoría (Árabes, Diseñador, Nicho, Body splash).
  * Mostrar solo ofertas o productos con stock disponible.
  * Ordenamiento por precio (menor a mayor, mayor a menor), más vendidos o alfabético.
* **Badges Reactivos:** Contador de filtros activos con opción de limpiar todos los filtros en un solo clic.

