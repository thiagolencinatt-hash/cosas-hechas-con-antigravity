# Plantilla 09: Flashcards de Recuperación Activa (Preguntas Ciega)

> **Módulo Asociado:** Módulo 5: Blindaje Mnemotécnico y Examen Ciego (Días 11 y 12)  
> **Objetivo:** Facilitar la aplicación inmediata y deliberada de la metodología.

---

## 1. Instrucciones de Uso
El 'Testing Effect' (Roediger & Karpicke, 2006) demuestra que evaluar activamente la memoria produce una retención mucho más duradera que releer apuntes. Utiliza este formato de flashcards de doble cara donde el anverso plantee una pregunta operativa o un problema ciego y el reverso contenga el razonamiento lógico.

---

## 2. Ejemplo Resuelto en un Entorno Real
### Ejemplo Resuelto: Flashcard Operativa de Marta
- **Anverso (Pregunta Ciega):** "¿Por qué `XLOOKUP` es superior a `VLOOKUP` ante la inserción de una columna a la izquierda en la base de datos?"
- **Reverso (Respuesta Lógica):** "`VLOOKUP` requiere un índice numérico estático de columna (ej. columna 3). Si insertas una columna, el índice 3 apunta a otro dato y la fórmula se rompe. `XLOOKUP` almacena referencias a rangos de celdas independientes (vector de búsqueda y vector de retorno), por lo que Excel ajusta la referencia dinámicamente sin importar cuántas columnas se añadan o muevan."
- **Condición de Éxito:** Responder en voz alta sin titubear en menos de 15 segundos.

---

## 3. Hoja de Trabajo y Campos para Completar
### Colección de Flashcards Operativas

#### Tarjeta 1
- **Anverso (Pregunta / Desafío Mental):**
  `[Pregunta que no se responda con sí/no, sino con una explicación funcional o sintáctica]`
- **Reverso (Modelo Mental y Respuesta Precisa):**
  `[Respuesta en 2 o 3 oraciones explicando el porqué]`
- **Intervalo de Repaso:** `[Día 1 / Día 3 / Día 7 / Día 14]`

#### Tarjeta 2
- **Anverso (Pregunta / Desafío Mental):**
  `[Pregunta operativa]`
- **Reverso (Modelo Mental y Respuesta Precisa):**
  `[Explicación]`
- **Intervalo de Repaso:** `[Día 1 / Día 3 / Día 7 / Día 14]`

---

## 4. Prompt de Asistencia con Inteligencia Artificial
Copia y pega este prompt en tu modelo de lenguaje (ChatGPT, Claude o Gemini) para que actúe como tu tutor o auditor en esta etapa:

```markdown
Actúa como un Especialista en Evaluación Formativa y Retrieval Practice.
He estado estudiando los siguientes temas de [INSERTAR HABILIDAD]:
[INSERTAR LISTA DE TEMAS]

Genera un set de 6 flashcards de recuperación activa de alta fricción:
- Prohibidas preguntas de memoria trivial o definiciones de diccionario.
- Cada tarjeta debe plantear: un caso hipotético, un error de código para diagnosticar o una comparación de rendimiento entre dos alternativas.
- Formato: 
  **ANVERSO:** [Pregunta desafiante]
  **REVERSO:** [Respuesta lógica y concisa]
```
