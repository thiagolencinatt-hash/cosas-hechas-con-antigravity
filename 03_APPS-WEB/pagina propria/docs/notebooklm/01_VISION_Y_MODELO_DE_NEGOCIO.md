# LATHE ESSENCE — Visión General, Propuesta de Valor y Modelo de Negocio

## 1. Identidad de Marca y Concepto
**Lathe Essence** es una plataforma de comercio electrónico de alta perfumería de lujo especializada en fragancias árabes, perfumes de diseñador de alta gama y perfumería nicho. 

La marca se posiciona en el segmento *Dark Luxury / Amouage Standard*, combinando una estética visual minimalista y opulenta con una experiencia de compra fluida y personalizada para el mercado argentino y latinoamericano.

### Pilares de Marca:
* **Autenticidad y Exclusividad:** Curaduría rigurosa de fragancias importadas originales, con especial foco en la perfumería oriental y de Medio Oriente (Lattafa, Armaf, Afnan, Al Haramain, Maison Alhambra, Zimaya, Rasasi).
* **Transparencia Olfativa:** Cada fragancia expone su pirámide olfativa completa (salida, corazón, fondo), rendimiento en horas, proyección y ocasiones de uso recomendadas.
* **Experiencia de Lujo sin Fricción:** Navegación ultra-rápida, feedback táctil reactivo, conversión multimoneda en tiempo real y asesoramiento automatizado.

---

## 2. Modelo de Negocio y Reglas Comerciales

### Venta Mayorista Exclusiva:
* **Umbral Mínimo:** La tienda opera con una regla comercial de **mínimo 5 unidades** para acceder al catálogo mayorista.
* **Barra de Progreso Reactiva:** El carrito de compras (`CartDrawer`) incorpora una barra dinámica en tiempo real que indica cuántas unidades faltan para alcanzar el umbral mayorista (ej. *"Te faltan 2 perfumes para habilitar el pedido mayorista"*).
* **Bloqueo Inteligente de Checkout:** El botón de finalización de compra permanece desactivado con feedback visual hasta que se alcanza la cantidad mínima requerida.

### Política de Monedas y Conversión:
* **Multimoneda Dinámica:** Soporte para **ARS (Pesos Argentinos)**, **USD (Dólares)** y **EUR (Euros)** con conversión instantánea en toda la interfaz sin recargar la página.
* **Precios Base:** Los precios se administran de forma normalizada en la moneda principal y se convierten automáticamente utilizando factores de cambio calculados en el contexto global (`ShopContext`).

---

## 3. Cobertura Logística y Checkout Conversacional

### Cobertura Nacional (Argentina):
* Sistema de despacho con alcance a las **24 provincias de la República Argentina** (Buenos Aires, CABA, Catamarca, Chaco, Chubut, Córdoba, Corrientes, Entre Ríos, Formosa, Jujuy, La Pampa, La Rioja, Mendoza, Misiones, Neuquén, Río Negro, Salta, San Juan, San Luis, Santa Cruz, Santa Fe, Santiago del Estero, Tierra del Fuego, Tucumán).
* Validación de código postal, localidad, dirección y número de contacto en el formulario de pedido.

### Flujo de Checkout por WhatsApp:
Para maximizar la tasa de conversión y eliminar la desconfianza en pasarelas de pago impersonales, Lathe Essence utiliza un **checkout conversacional directo a WhatsApp Business**:
1. El usuario completa sus datos de entrega en un modal modalizado de un solo paso.
2. El sistema compila y formatea un mensaje estructurado con:
   * Lista detallada de productos y cantidades seleccionadas.
   * Moneda seleccionada y precio total calculado.
   * Datos completos de envío y contacto del cliente.
3. Al presionar *"Enviar Pedido por WhatsApp"*, se abre WhatsApp con el mensaje precargado, listo para que un asesor comercial confirme el stock y coordine el pago y despacho.

