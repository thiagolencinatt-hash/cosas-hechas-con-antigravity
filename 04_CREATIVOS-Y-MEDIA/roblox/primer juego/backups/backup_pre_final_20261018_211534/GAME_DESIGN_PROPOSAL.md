# VAULT POP! — Propuesta de Diseño de Juego (GDD)
**Evolución: Simulador de Exploración, Extracción de Huevos, Crianza y Batallas de Criaturas (Beast Battles)**

- **Documento:** `GAME_DESIGN_PROPOSAL.md`
- **Estado:** Propuesta Técnica y de Game Design (Pre-implementación)
- **Fecha:** Octubre 2026
- **Entorno Base:** Roblox Studio (`Experiencia sin título` | ID: 87965587462014)

---

## 1. Visión General y Loop Principal (Core Loop)

El juego evoluciona desde un simulador de entrenamiento hacia una experiencia híbrida de **Extracción & Colección de Criaturas (Creature Collector / Extraction Tycoon)** con combate táctico en arenas:

$$\mathbf{Explorar\ Bioma} \longrightarrow \mathbf{Obtener\ Huevo} \longrightarrow \mathbf{Escapar\ del\ Jefe} \longrightarrow \mathbf{Incubar\ en\ Base} \longrightarrow \mathbf{Criar\ Criatura} \longrightarrow \mathbf{Monedas\ o\ Combate} \longrightarrow \mathbf{Desbloquear\ Bioma\ Superior}$$

### Principio de Diseño Fundamental: Fuerza Centrada en la Criatura
> [!IMPORTANT]
> **La fuerza de combate depende al 100% de las criaturas** (su especie, rareza, nivel, habilidades activas e IVs), **no del nivel o entrenamiento físico del personaje jugador**.
> Las estadísticas del jugador (`Velocidad` y `Fuerza`) actúan exclusivamente como **facilitadores de exploración y logística**:
> - **🏃 Velocidad (Cinta de Correr):** Aumenta la velocidad de desplazamiento para esquivar ataques, huir de los jefes en persecución y recorrer biomas lejanos en menor tiempo.
> - **💪 Fuerza (Pesas de Entrenamiento):** Aumenta el aguante de carga, la capacidad de transportar huevos más pesados/raros simultáneamente sin sufrir penalización de lentitud, y la resistencia al derribo o aturdimiento durante la fuga.

---

## 2. Los 20 Biomas y Enfrentamiento con los Jefes

El mapa mundial cuenta con 20 biomas lineales escalonados en dificultad y ambientación:

| # | Bioma | Jefe Guardián | Nido / Origen del Huevo | Comportamiento del Jefe |
| :---: | :--- | :--- | :--- | :--- |
| **01** | Bosque Encantado | Guardián del Bosque | Árbol Ancestral | Patrulla lenta, lanzamiento de raíces |
| **02** | Cueva de Piedra | Golem de Roca | Caverna de Cuarzo | Pisada sísmica, rodar rocoso |
| **03** | Tundra Helada | Bruja de Hielo | Glaciar Eterno | Ventiscas ralentizantes |
| **04** | Volcán Ardiente | Dragón de Fuego | Cráter de Magma | Carga ígnea, charcos de lava |
| **05** | Desierto Infinito | Escorpión de Arena | Dunas Prohibidas | Hundimiento en arena, emboscada |
| **06** | Meseta de Tormentas | Titán del Trueno | Cúspide de Relámpagos | Rayos de área de impacto |
| **07** | Mazmorra Oscura | Asesino de Sombras | Cripta Olvidada | Teletransportación corta, sigilo |
| **08** | Pantano Venenoso | Serpiente Tóxica | Fangales Ácidos | Rastro venenoso que drena aguante |
| **09** | Caverna de Cristal | Espectro de Cristal | Geoda Prismática | Proyectiles reflectantes |
| **10** | Cementerio Antiguo | Rey No-Muerto | Mausoleo Real | Invocación de secuaces huesudos |
| **11** | Abismo Acuático | Leviatán Marino | Arrecife Profundo | Olas de choque hidrodinámicas |
| **12** | Templo Celestial | Sílfide del Viento | Altar de las Nubes | Ráfagas que empujan al vacío |
| **13** | Cámara de Lava | Behemoth de Lava | Foso de Basalto | Grietas de lava ascendente |
| **14** | Arboleda Sagrada | Druida de Naturaleza | Corazón Silvestre | Espinas y auras de contención |
| **15** | Forja Infernal | Coloso de Metal | Horno Gigante | Martillazos de compresión |
| **16** | Ruptura del Vacío | Caminante del Vacío | Vórtice Dimensional | Zonas de gravedad invertida |
| **17** | Arena Celestial | Paladín de Luz | Sanctum Dorado | Haces de luz solar purificadora |
| **18** | Ciudadela de Hueso | Nigromante Oscuro | Trono Nigromántico | Rayos de maldición que ralentizan |
| **19** | Grieta Infernal | Demonio del Caos | Abismo Carmesí | Tormenta de meteoros |
| **20** | Trono Final | Dios Antiguo | Núcleo Cósmico | Alteración temporal y cataclismos |

---

## 3. Mecánica de Extracción de Huevos y Persecución (Boss Chase)

### 3.1 Obtención del Huevo
- En el centro de cada zona (o tras dejar al jefe en un umbral de fatiga/aturdimiento), se genera el **Nido Elemental**.
- Al interactuar con el nido, el jugador obtiene un huevo correspondiente al bioma.
- El huevo se equipa visiblemente sobre las manos o la espalda del jugador (`CarryingEgg`).

### 3.2 Tensión de Fuga: Estado de Persecución
- En cuanto el huevo es extraído del nido, se desata una alarma visual y sonora: **¡EL JEFE SE DESPIERTA Y TE PERSIGUE!**
- El jefe entra en modo persecución agresiva hacia el portador del huevo hasta el límite de su zona o hasta la entrada de la SafeZone.
- **Peso del Huevo y Resistencia Física (Fuerza):**
  - Un jugador sin fuerza sufre una penalización de lentitud del `-35%` al cargar un huevo raro o mítico.
  - Al entrenar **💪 STRENGTH**, la penalización se reduce progresivamente hasta convertirse en `0%`, permitiendo además desbloquear una mochila reforzada para cargar hasta 2 o 3 huevos en viajes avanzados.
- **Evasión y Reflejos (Velocidad):**
  - Al entrenar **🏃 TREADMILL**, la velocidad base del jugador (`WalkSpeed`) supera la velocidad de carrera del jefe, permitiendo sortear obstáculos, curvas y proyectiles de la zona sin ser alcanzado.
- Si el jefe alcanza al jugador y le inflige suficiente daño como para agotarlo, el huevo cae al suelo y regresa al nido tras 10 segundos, obligando al jugador a reintentar la extracción.

---

## 4. Incubación en la Base y Sistema de Eclosión

Cada jugador en su base asignada (`Base_1` a `Base_5`) dispone de un área dedicada a la crianza en su patio:

1. **Incubadoras de Base (Hatchers):**
   - Espacio inicial: 2 incubadoras gratuitas.
   - Espacios desbloqueables mediante mejoras con monedas del juego (hasta 6 incubadoras simultáneas).
2. **Proceso de Incubación:**
   - Colocar un huevo inicia un temporizador visible sobre la incubadora con barra de progreso.
3. **Aceleradores de Crianza Natural:**
   - La presencia activa del jugador en su base genera una bonificación de calidez (`+20%` velocidad de incubación).
4. **Animación de Eclosión (Pop Animation):**
   - Cuando el temporizador llega a cero, el huevo tiembla elásticamente, emite partículas doradas y estalla en un efecto "POP!", revelando la criatura 3D con su nombre, rareza, estadísticas y sonido característico.

---

## 5. Tabla de Rarezas, Probabilidades y Tiempos de Incubación

Cada bioma posee su propio catálogo de criaturas clasificadas por niveles de rareza:

| Rareza | Probabilidad por Huevo | Tiempo de Incubación Base | Factor de Monedas / seg | Escalamiento de Combate |
| :--- | :---: | :---: | :---: | :---: |
| **Común (Gris)** | $58.0\%$ | $45\text{ s}$ | $1.0\times$ | Vida: $100$ \| Daño: $15$ |
| **Poco Común (Verde)** | $26.0\%$ | $2\text{ min}$ | $2.2\times$ | Vida: $180$ \| Daño: $28$ |
| **Raro (Azul)** | $11.0\%$ | $5\text{ min}$ | $5.0\times$ | Vida: $320$ \| Daño: $52$ |
| **Épico (Púrpura)** | $4.0\%$ | $12\text{ min}$ | $12.0\times$ | Vida: $600$ \| Daño: $105$ |
| **Legendario (Dorado)** | $0.9\%$ | $30\text{ min}$ | $30.0\times$ | Vida: $1\,200$ \| Daño: $220$ |
| **Mítico / Cósmico (Rojo/Arcoíris)** | $0.1\%$ | $60\text{ min}$ | $80.0\times$ | Vida: $2\,500$ \| Daño: $480$ |

---

## 6. Economía Pasiva: Espacios de Colección en la Base

Dentro de la parcela de la base (`BasePlots`), se conserva y potencia la zona central (`CollectionZone`):
- Los jugadores pueden asignar hasta **8 criaturas activas** en su hábitat o pedestal de base.
- Cada criatura colocada en el pedestal genera **Monedas Pasivas por Segundo** según su rareza, nivel y bioma de origen.
- Un recolector central almacena las monedas generadas automáticamente hasta que el jugador las recoge con un toque.
- **Ciclo Económico Saludable:**
  - Las monedas generadas se reinvierten en:
    1. Subir de nivel las estaciones de entrenamiento (`Treadmill` y `Strength`).
    2. Comprar mejoras en la `UPGRADES SHOP`.
    3. Comprar más ranuras de incubadoras en la base.
    4. Pagar el costo de evolución o subida de nivel de las criaturas.

---

## 7. Sistema de Combate: BEAST BATTLES — CREATURE COMBAT ARENA

Ubicado en el cuadrilátero monumental unificado (`UnifiedCombatArena`, $100\times 80\text{ studs}$):

### 7.1 Formato de Combate
- **Duelo 1v1 o 2v2 de Criaturas:**
  - Los jugadores ingresan por las escaleras opuestas (Este y Oeste).
  - Cada jugador selecciona a su **Criatura Campeona** de su inventario.
  - La criatura aparece en el centro de la lona de combate frente al rival.
- **Acción Táctica en Tiempo Real con Selección de Habilidades:**
  - El jugador no golpea directamente; actúa como entrenador emitiendo órdenes mediante una interfaz táctica en pantalla:
    - **Habilidad 1 (Básica):** Ataque rápido con bajo enfriamiento (ej. *Garra Ígnea*, *Mordisco Venenoso*).
    - **Habilidad 2 (Especial):** Ataque elemental fuerte con efecto secundario (aturdimiento, quemadura, ralentización).
    - **Habilidad Defensiva / Esquive:** Bloqueo de caparazón o paso etéreo con tiempo de reacción.
    - **Habilidad Definitiva (Ultimate):** Cinemática breve de gran impacto cargada con daño recibido/infligido.

### 7.2 Protección contra Abusos y Matchmaking Equilibrado
Para evitar que los jugadores veteranos aplasten a los novatos:
1. **Ligas por Nivel de Criatura (Tier Brackets):**
   - **Liga Novato (Bronze):** Solo criaturas Comunes / Poco Comunes (Nivel 1 - 10).
   - **Liga Avanzada (Silver):** Criaturas Raras / Épicas (Nivel 11 - 25).
   - **Liga Campeones (Gold/Master):** Criaturas Legendarias / Míticas (Nivel 26 - 50).
2. **Escalado de Estadísticas Normalizado en Modos Clasificatorios:**
   - En combates amistosos o igualados, las criaturas compiten con estadísticas ajustadas proporcionalmente para premiar la habilidad estratégica del entrenador en lugar de la pura ventaja numérica.

---

## 8. Diferenciación Estricta: Economía Gratuita vs Tienda Premium (Robux)

Siguiendo las mejores directivas de Roblox y evitando prácticas abusivas o Pay-to-Win:

### Tienda Normal: `UPGRADES SHOP` (100% Monedas de Juego)
- Se compra exclusivamente con monedas obtenidas jugando (entrenamiento, jefes, colección de criaturas).
- Ofrece:
  - Mejoras de velocidad de movimiento del personaje.
  - Eficiencia de entrenamiento en cinta y pesas.
  - Desbloqueo de ranuras adicionales de incubación.
  - Mejoras de capacidad de almacenamiento del banco de monedas.

### Tienda Premium: `PREMIUM SHOP` (Robux)
- Orientada **únicamente a cosméticos, comodidades de tiempo y prestigio visual**:
  - **Auras Elementales:** Llamas celestiales, relámpagos dorados o pétalos mágicos que siguen al jugador.
  - **Skins y Variantes Cromáticas (Shiny/Neon):** Aspectos alternativos para las criaturas criadas sin alterar sus números de daño.
  - **Sonidos de Eclosión Exclusivos y Títulos de Chat:** (ej. `[CRIADOR MAESTRO]`).
  - **Aceleradores de Incubación (Opcional):** Reducción de tiempo sin bloquear el acceso gratuito.
  - **Pase VIP:** Acceso a palco de honor en gradas de Beast Battles y estatua de bronce personalizada en la plaza.
- **Regla Inquebrantable:** Ninguna criatura legendaria ni ventaja de combate invencible puede comprarse directamente con Robux. Todo éxito en la arena se gana explorando, evadiendo jefes y entrenando.

---

## 9. Hoja de Ruta de Implementación Técnica (Fases Futuras)

1. **Sprint 1 — Módulo de Datos de Criaturas (`BeastDataModule`):**
   - Definición de tablas de especies Luau tipadas (`--!strict`), rarezas, modelos base y habilidades.
2. **Sprint 2 — Modelo Físico y Lógica de Incubadoras (`IncubationService`):**
   - Modelado de incubadoras en `BasePlots`, temporizadores autoritativos en servidor y animación de eclosión.
3. **Sprint 3 — IA de Persecución de Jefes (`BossChaseController`):**
   - Sistema de pathfinding de Roblox (`PathfindingService`) activado únicamente cuando el jugador porta un huevo fuera del nido.
4. **Sprint 4 — Controlador de Combate Beast Battles (`BeastCombatService`):**
   - Spawners en esquinas de la arena unificada, barra de salud dual en pantalla y sistema de turnos/tiempo real para criaturas.
