# Directivas del Desarrollador Principal - "Vault Breakers: Anime Relic Tycoon"

Este archivo define las reglas inquebrantables de desarrollo para el proyecto de Roblox en colaboración con el Desarrollador Principal (IA).

## Directiva 1: Inspección Previa y Aprobación de Plan
- Explorar siempre el árbol de instancias con `search_game_tree` antes de realizar cambios.
- Elaborar y solicitar la aprobación explícita del usuario para cualquier plan de arquitectura antes de invocar `multi_edit` o modificar el entorno de juego.
- Prohibido modificar objetos o scripts sin autorización en fases de planificación.

## Directiva 2: Estándares de Código y Modularidad
- Todo script y módulo debe encabezarse obligatoriamente con la directiva `--!strict` para tipado estático riguroso en Luau.
- Dividir la lógica de programación en `ModuleScripts` pequeños, limpios y desacoplados de menos de 250 líneas.
- Prevenir bajo cualquier circunstancia acercarse al límite de 200.000 caracteres de `Script.Source`.

## Directiva 3: Seguridad Total del Servidor (Server-Authoritative Anti-Cheat)
- Toda la lógica crítica de economía, obtención de ítems, drops y progreso reside exclusivamente en `ServerScriptService`.
- El cliente **jamás** envía probabilidades, costos, recompensas, identificadores de reliquias ganadas ni estadísticas a través de `RemoteEvents`.
- Todo cálculo de números aleatorios (RNG), validación de distancia matemática física al objeto (`(playerPos - objectPos).Magnitude <= maxRange`) y tiempo de espera o cadencia (cooldown por `tick()` / `os.clock()`) se calcula y valida en el servidor.
- **Prohibido terminantemente** el uso de `RemoteFunction:InvokeClient()` en el servidor para evitar bloqueos por parte de clientes maliciosos.

## Directiva 4: Optimización de Rendimiento y Memoria RAM Móvil (Target Android 1.300 MB)
- Todos los bucles continuos (`while`, `repeat`) deben contener indefectiblemente llamadas a `task.wait()` para evitar colgar el motor o congelar Studio.
- Toda suscripción a eventos (`RBXScriptConnection`) debe limpiarse rigurosamente con `:Disconnect()` cuando el objeto o la UI se destruya o cierre.
- En scripts de cliente (`StarterPlayerScripts`, `StarterGui`), emplear siempre `:WaitForChild()` para referenciar instancias que se replican asíncronamente desde el servidor.
- Jamás usar llamadas manuales inseguras a `player:LoadCharacter()`.
