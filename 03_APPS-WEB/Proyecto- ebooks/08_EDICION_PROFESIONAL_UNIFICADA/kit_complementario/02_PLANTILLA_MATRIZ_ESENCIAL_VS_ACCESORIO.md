# Plantilla 02: Matriz Esencial vs. Accesorio (Regla 80/20 Auditada)

> **Módulo Asociado:** Módulo 1: La Deconstrucción Quirúrgica (Día 1)  
> **Objetivo:** Facilitar la aplicación inmediata y deliberada de la metodología.

---

## 1. Instrucciones de Uso
Separa quirúrgicamente el 20% de las funciones o conceptos que resuelven el 80% de los problemas reales en el entorno de producción, del 80% de tecnicismos accesorios que debes congelar durante las dos semanas. Si un concepto no se va a usar directamente en tu Artefacto Mínimo Viable, debe ir a la lista de 'Congelado'.

---

## 2. Ejemplo Resuelto en un Entorno Real
### Ejemplo Resuelto: Marta (Modelado en Excel)
- **20% Esencial (Foco Absoluto):**
  1. `XLOOKUP` bidireccional y anidado.
  2. Tablas Dinámicas con campos calculados.
  3. Power Query: Unificar carpetas con archivos CSV y limpiar nulos.
  4. Lógica de Flujo de Caja Descontado (NPV, IRR).
- **80% Accesorio (Congelado para Después de los 14 Días):**
  1. Macros avanzadas en VBA y scripts en Office Script.
  2. Gráficos 3D o animaciones de dashboard.
  3. Fórmulas estadísticas obsoletas (`LOOKUP` clásico, `VLOOKUP` con coincidencia aproximada).
  4. Modelado probabilístico Monte Carlo.

---

## 3. Hoja de Trabajo y Campos para Completar
### Campos de Trabajo para tu Proyecto

| Categoría | Elementos Técnicos / Tareas | Criterio de Inclusión / Justificación |
| :--- | :--- | :--- |
| **ESENCIAL (20% Core)** | 1. `[Concepto/Función 1]`<br>2. `[Concepto/Función 2]`<br>3. `[Concepto/Función 3]`<br>4. `[Concepto/Función 4]` | Resuelven las operaciones diarias básicas del artefacto final. |
| **ACCESORIO (80% Ruido)** | 1. `[Función avanzada no crítica]`<br>2. `[Jerga teórica o historia]`<br>3. `[Herramientas secundarias]` | Interrumpen la adquisición de fluidez básica; se congelan. |

**Regla de Oro:** Si dudas si algo es esencial o accesorio, pregúntate: *¿Puedo entregar el artefacto del Día 14 sin dominar esto?* Si la respuesta es sí, es accesorio.

---

## 4. Prompt de Asistencia con Inteligencia Artificial
Copia y pega este prompt en tu modelo de lenguaje (ChatGPT, Claude o Gemini) para que actúe como tu tutor o auditor en esta etapa:

```markdown
Actúa como un Ingeniero Senior y Filtro de Relevancia Cognitiva. 
Estoy deconstruyendo la habilidad: [INSERTAR HABILIDAD].
Tengo esta lista preliminar de temas que planeaba estudiar:
[INSERTAR LISTA DE TEMAS O ÍNDICE DE CURSO]

Aplica un filtro implacable:
1. Clasifica cada tema en: 'NÚCLEO CRÍTICO (20%)' o 'ACCESORIO SECUNDARIO (80%)'.
2. Justifica qué temas de la lista son trampas de procrastinación teórica que los cursos tradicionales enseñan pero casi nunca se usan en el trabajo diario.
3. Dame la lista purgada de máximo 5 conceptos sobre los que debo construir mi fluidez inicial en 14 días.
```
