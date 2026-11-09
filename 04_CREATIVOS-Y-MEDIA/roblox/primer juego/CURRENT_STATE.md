# CURRENT STATE — ROBLOX: VAULT BREAKERS (ANIME RELIC TYCOON)

## Concepto Actual y Ciclo de Juego
Juego de Roblox organizado en 10 zonas/países conectados en pasillo lineal (Argentina, Brasil, USA, Japón, México, España, Reino Unido, Francia, Alemania, Egipto).
- **Mecánica Central:** Los jugadores recorren explanadas limpias equipados con instrumentos de asalto temáticos (ganzúas, palancas, mazos, taladros láser). Rompen cajas fuertes distribuidas por el país (~30 por zona, 300 en total).
- **Agresividad Policial Condicional:** La policía de cada país patrulla pacíficamente y **únicamente** inicia la persecución activa con sirenas y alertas cuando el jugador revienta una caja y comienza a transportarla hacia su base (`IsStealing == true`).
- **Entrega & Recompensa:** Al asegurar el botín en la base o escapar de la zona, el botín se acredita en dinero (`leaderstats.Money`) y la caja entra en cuenta regresiva de reaparición.

---

## Logros de la Actualización Integral
1. **Limpieza Espacial de las 10 Zonas:**
   - 508 props y decoraciones en pasillos centrales cambiados a `CanCollide = false`, garantizando carrera y combate 100% fluidos sin atascos.
   - Perímetro visual reforzado y Zona 7 (Reino Unido) completada con fachadas británicas continuas, 9 luces cálidas e iluminación de Big Ben y farolas victorianas.
   - Auditoría de nombres antiguos y modelos flotantes resuelta.
2. **Rediseño Masivo de Cajas Fuertes (300 Cajas en 10 Zonas):**
   - 30 cajas fuertes activas por zona, 300 en total, con modelado temático por país (mármol, arenisca dorada, metal acorazado, torii neón, etc.).
   - 4 categorías rotativas: `Chica`, `Mediana`, `Grande`, `Colosal` con escala física de tamaño, vida (`MaxShellHealth`), multiplicador de botín y auras visuales.
   - Interfaz flotante `BillboardGui` sobre cada caja con título, badge de tier, barra de vida y contador numérico `HP / MaxHP`.
3. **IA Policial Estricta (Server-Authoritative):**
   - Regla de aggro condicionada exclusivamente a `IsStealing == true`.
   - Patrullaje pacífico durante la fase de golpeo o exploración.
   - Clamping estricto por zona ($Z_0 \pm 115$ studs): los oficiales nunca abandonan su país asignado.
4. **Instrumentos de Asalto y Puestos 3D (Referencias Gráficas):**
   - 10 herramientas reales con daño (`BreakPower`), configuradas en `OpeningToolsConfig.luau` y otorgadas por `OpeningToolsServer.luau`.
   - `WeaponCombatController.luau` en `StarterPlayerScripts` para golpe con click/tap, swing procedural, sonidos de impacto, raycast a 20 studs y sacudida de cámara.
   - Puestos físicos 3D en el Lobby (`StandArmas` y `StandRastros`) con toldos a rayas y pads de neón interactivos.
   - Tienda de instrumentos `OpeningToolsFrame` estilo tarjetas de caricatura con encabezado naranja, botón rojo "X", badges de rareza, cápsula de poder `⚡ X Poder` y botones verdes.
5. **HUD Profesional en Pantalla (Tiempo Real):**
   - `ModernHUDClient.luau` en `StarterGui.Money`.
   - Barra y contador de Vida (HP) con corazón pulsante.
   - Contador de Velocidad (WalkSpeed) con zapatilla en tiempo real.
   - Contador de Dinero en tiempo real formateado con comas.
   - Indicador de botín `LootStatusFrame` dinámico.
   - Banner de alerta policial `PoliceAlertBanner` con luces estroboscópicas rojas y azules en persecución.
   - Menú lateral con Tienda, Índice y alternador de Modo Lento (16 WS).
   - Botón rojo de entrega centrado `DropButton` (`📦 DEJAR CAJA FUERTE [CLICK / E]`) y colocación con clic de ratón en el piso de la parcela.
   - Supresión 100% de la viñeta roja y sirenas al ingresar a la Zona Segura ($Z \le -645$).
6. **Animaciones & Game Feel:**
   - Squash & stretch y números de daño flotantes animados (`EggHitFX`).
   - Explosión de puerta blindada con animación hacia afuera (`TweenService.Back`) y lluvia de partículas doradas.
   - Baliza policial sobre el personaje y partículas de polvo al huir con el botín.
   - Notificación cinemática 4K (`ZoneBanner4K`) momentánea (3.5s) con rebote y destello cromado al cruzar a cada país.
   - Cartel de madera de valla lateral en cada parcela con mejora exclusiva de caminadora (`🏃 MEJORA DE CINTA`) de doble cara.
7. **Tienda Unificada Multisección (Master Shop Client & Apartados 100% Funcionales):**
   - 3 apartados interactivos: `🔨 ARMAS DE ASALTO` (10 armas con daño progresivo), `⚡ RASTROS DE VELOCIDAD` (10 estelas con multiplicadores de velocidad) y `🏃 MEJORAS DE CINTA & BASE`.
   - Cada botón y apartado 100% operativo: compra con saldo real (`Money`), equipar/desequipar reactivo, estados dinámicos (`✓ EQUIPADO`, `EQUIPAR`, `🛒 $Precio`) y alertas de saldo insuficiente.
   - Triggers unificados: botón `ShopBtn` en HUD (`ModernHUDClient`), tecla `[B]`, y puestos 3D del Lobby (`StandArmas` y `StandRastros`).
   - Persistencia completa: armas de asalto integradas a `ProfileStore` en `Data.luau`.
8. **Panel de Administrador Operativo y Personalizable (Velocidad & Dinero Libres):**
   - Auto-construcción de UI en `PlayerGui.AdminGui` con botón flotante `🛡️ ADMIN [F2]` y atajo de teclado `[F2]`.
   - Autorización automática en Roblox Studio (`RunService:IsStudio() == true`) y por CreatorId/Whitelist.
   - **Modificación Libre de Dinero:** Cuadro de texto numérico para fijar o sumar cualquier cantidad a voluntad + presets rápidos (`+$50K`, `+$500K`, `+$5M`, `+$50M`, `MAX $1B`).
   - **Modificación Libre de Velocidad:** Cuadro de texto para fijar WalkSpeed físico y Stat permanente de carrera + presets rápidos (`16 Normal`, `50 Rápido`, `100 Sónico`, `250 Flash`, `500 Dios`). Protección contra sobreescritura mediante atributo `AdminWalkSpeed`.
   - **Herramientas de Test:** `🛡️ Modo Dios` (vida infinita), `💥 Romper Caja Cercana` (testeo inmediato de botín y patrulla), `🗡️ Desbloquear Todas las Armas`, `⚡ Desbloquear Todos los Rastros` y teletransportes instantáneos a los 10 países y base.
9. **Corrección Integral de la Caminadora (Treadmill Upgrade):**
   - Resuelto el bloqueo en servidor (`TreadmillSystem.luau`): eliminada la condición limitante `CurrentTreadmill <= 0` e implementada resolución automática de parcela del jugador (`fallback`).
   - Conectado `MejorarCintaPrompt.Triggered` en servidor y cliente (`TreadMillClient.luau`), garantizando que la mejora funcione tanto por ProximityPrompt `[E]` como por clic en el panel SurfaceGui.
   - Corregido el valor por defecto en `Data.luau` de nivel 0 a nivel 1.
10. **Apertura Total de Tienda de Mazos y Música Continua Amigable:**
   - Conectado el puesto físico del Lobby `StandArmas` (`InteractionPad` táctil y `ShopPrompt` `[E]`), atajo `[B]` y botón HUD `ShopBtn` a la pestaña `Armas`.
   - Desacoplado `OpeningToolsFrame` de `FrameBalance` para evitar conflictos de escala a 0.
   - Silenciado el sonido intrusivo (`AreaAppearSound` a volumen 0) al acercarse a las tiendas del Lobby.
   - Implementado `BackgroundMusicClient.luau` con una lista continua de música amigable y relajante oficial de Roblox en `SoundService` (volumen suave 0.22).
   - Sincronizados y validados todos los scripts (12 archivos) directamente en el DataModel activo de Roblox Studio.