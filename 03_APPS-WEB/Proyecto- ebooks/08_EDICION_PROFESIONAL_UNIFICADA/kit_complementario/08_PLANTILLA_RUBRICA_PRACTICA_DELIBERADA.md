# Plantilla 08: Rúbrica de Práctica Deliberada y Registro de Errores

> **Módulo Asociado:** Módulo 4: El Simulador de Vuelo y Práctica Deliberada (Días 8 al 10)  
> **Objetivo:** Facilitar la aplicación inmediata y deliberada de la metodología.

---

## 1. Instrucciones de Uso
Anders Ericsson demostró que la repetición ciega no genera pericia; solo la práctica deliberada en el límite de tu capacidad actual produce mejoras medibles. Utiliza esta rúbrica para documentar tus fallos, clasificar su origen (conceptual, procedimental o por descuido) y diseñar un ejercicio específico para erradicarlos.

---

## 2. Ejemplo Resuelto en un Entorno Real
### Ejemplo Resuelto: Registro de Errores de Marta
- **Error Cometido:** En la fórmula de proyección de flujo de caja, olvidó bloquear con `$` la celda de la tasa de inflación en la fila 3, lo que arrastró un valor cero en las columnas posteriores.
- **Tipo de Error:** Procedimental / Mecánico (atención dividida).
- **Causa Raíz:** Arrastró la fórmula hacia la derecha antes de verificar con la tecla `F4` las referencias absolutas.
- **Micro-Práctica Deliberada de Corrección:** Escribir a mano 10 fórmulas consecutivas que alternen referencias relativas, mixtas (`$A1` vs `A$1`) y absolutas (`$A$1`) en menos de 2 minutos sin cometer ni un solo desvío.

---

## 3. Hoja de Trabajo y Campos para Completar
### Cuaderno de Auditoría de Errores Cognitivos

| Fecha / Bloque | Descripción Exacta del Error | Clasificación (Conceptual / Procedimental / Descuido) | Causa Raíz Detectada | Micro-Ejercicio de Corrección Inmediata |
| :--- | :--- | :--- | :--- | :--- |
| `[Día X]` | `[Qué falló exactamente]` | `[Tipo]` | `[Por qué ocurrió]` | `[Cómo lo vas a taladrar]` |
| `[Día Y]` | `[Qué falló exactamente]` | `[Tipo]` | `[Por qué ocurrió]` | `[Cómo lo vas a taladrar]` |

---

## 4. Prompt de Asistencia con Inteligencia Artificial
Copia y pega este prompt en tu modelo de lenguaje (ChatGPT, Claude o Gemini) para que actúe como tu tutor o auditor en esta etapa:

```markdown
Actúa como un Diseñador de Práctica Deliberada (Metodología Anders Ericsson).
Acabo de cometer el siguiente error al intentar resolver un problema en [INSERTAR DOMINIO]:
"""
[DESCRIBIR EL ERROR QUE COMETISTE Y QUÉ INTENTABAS HACER]
"""

Tu tarea:
1. Diagnostica la causa raíz profunda del error (¿falta de base teórica, asunción falsa o hábito procedimental defectuoso?).
2. Crea un 'micro-taladro' de 3 ejercicios progresivos diseñados específicamente para sobre-corregir este error en menos de 10 minutos.
```
