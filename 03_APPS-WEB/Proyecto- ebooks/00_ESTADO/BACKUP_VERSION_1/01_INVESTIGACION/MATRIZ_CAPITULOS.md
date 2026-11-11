# MATRIZ DE CORRESPONDENCIA INVESTIGACIÓN <-> CAPÍTULOS DEL EBOOK

Esta matriz traduce los 7 ejes científicos del informe base al índice editorial definitivo de 7 capítulos organizado bajo las 4 Fases del Aprendizaje Acelerado.

---

## FASE 1: PREPARAR

### CAPÍTULO 1: De la sobrecarga al enfoque: construí tu ruta de aprendizaje
- **Fase del Método:** FASE 1: PREPARAR
- **Conceptos Fundamentales:**
  - Diagnóstico de conocimientos previos y reducción de la carga cognitiva intrínseca.
  - Descomposición jerárquica de habilidades complejas en submetas asimilables.
  - Formulación de objetivos de maestría (Metacognición: Fase de Previsión de Zimmerman).
  - Superación de la "falacia de la planificación" (*planning fallacy*).
- **Fuentes Científicas:**
  - Zimmerman, B. J. (2002) - *Fase de Previsión y Análisis de Tareas*.
  - EEF (2025) - *Pasos 1 y 2: Activación de conocimiento previo y fijación de metas*.
  - Sweller, J. (1988, 2011) - *Límites de la memoria de trabajo (4-7 chunks)*.
  - Buehler, Griffin & Peetz (2010) - *Falacia de la planificación y estimación temporal*.
- **Ejemplo Conductor (Excel):**
  - Marta (novata total) necesita aprender Excel para su trabajo contable. En lugar de mirar un curso de 40 horas sin rumbo, descompone la meta en 4 bloques: (1) Navegación y celdas, (2) Fórmulas básicas (SUMA, PROMEDIO, SI), (3) Búsquedas y tablas dinámicas, (4) Modelos y macros.
- **Riesgo y Sobredependencia IA:**
  - Pedirle a la IA una lista interminable de 100 temas que aumenta la parálisis por análisis.
- **Solución con IA:**
  - Prompt de "Descomposición Taxonómica Inversa" para acotar un temario realista de 15 días.

---

### CAPÍTULO 2: Aprendé lo importante primero: dominá el mapa del conocimiento
- **Fase del Método:** FASE 1: PREPARAR
- **Conceptos Fundamentales:**
  - El Principio de Pareto del Conocimiento (Conceptos Umbral y Núcleo 20/80).
  - Mapas conceptuales y arquitectura de esquemas en la memoria a largo plazo.
  - Curaduría crítica y filtrado de fuentes para evitar la "ilusión de fluidez".
  - Organización de la biblioteca inteligente de estudio.
- **Fuentes Científicas:**
  - Catrambone, R. (1998) - *Subgoal Learning Model e identificación de principios organizadores*.
  - Sweller, Ayres & Kalyuga (2011) - *Construcción de esquemas y automatización*.
  - Atkinson et al. (2000) - *Aislamiento de principios estructurales vs. detalles superficiales*.
- **Ejemplo Conductor (Excel):**
  - Marta identifica los 5 conceptos umbral de Excel: Celdas absolutas vs. relativas ($A$1 vs A1), sintaxis de funciones, tipos de datos (texto, número, fecha), lógica condicional booleana y estructura de tablas.
- **Riesgo y Sobredependencia IA:**
  - Usar la IA como motor de búsqueda indiscriminado que mezcla información obsoleta o fórmulas incompatibles.
- **Solución con IA:**
  - Creación de un proyecto en NotebookLM cargando documentación oficial de Microsoft Excel y manuales seleccionados para consultas *grounded* (libres de alucinaciones).

---

## FASE 2: COMPRENDER

### CAPÍTULO 3: Tu tutor personal con IA: comprendé hasta lo que parecía imposible
- **Fase del Método:** FASE 2: COMPRENDER
- **Conceptos Fundamentales:**
  - El Método Socrático asistido por modelos de lenguaje.
  - La Técnica Feynman validada empíricamente (explicación en lenguaje simple y detección de vacíos).
  - El Efecto del Ejemplo Resuelto (*Worked Example Effect*) y andamiaje con desvanecimiento (*Fading*).
  - Efecto de modalidad y eliminación de la atención dividida (*Split-Attention*).
- **Fuentes Científicas:**
  - Mattox, Hutchins & Jirout (2025) - *Técnica Feynman con IA y marco ICAP de Chi*.
  - Sweller et al. (2011) & Atkinson et al. (2000) - *Worked Example Effect en novatos*.
  - Mousavi, Low & Sweller (1995) - *Efecto de modalidad visual/verbal*.
  - Kestin et al. (Harvard, 2025) - *Tutor interactivo de IA duplicando aprendizaje*.
- **Ejemplo Conductor (Excel):**
  - Marta no comprende cómo funciona `BUSCARV` (`VLOOKUP`) o `BUSCARX` (`XLOOKUP`). En lugar de pedirle a la IA que le resuelva el cálculo, le pide que actúe como un bibliotecario que le explica con la analogía de un archivador físico, forzando a Marta a explicar con sus palabras qué representa el argumento `indicador_columnas`.
- **Riesgo y Sobredependencia IA:**
  - Descarga cognitiva pasiva (*cognitive offloading*): aceptar la explicación de la IA sin procesarla, creyendo falsamente que se ha comprendido.
- **Solución con IA:**
  - Prompt del "Tutor Socrático Inquisitivo" que prohíbe dar respuestas directas y evalúa la explicación del usuario según la Técnica Feynman.

---

### CAPÍTULO 4: Aprendé haciendo: transformá la información en habilidades reales
- **Fase del Método:** FASE 2: COMPRENDER -> FASE 3: CONSOLIDAR
- **Conceptos Fundamentales:**
  - Práctica Deliberada vs. Práctica Rutinaria (Desmitificación de las 10.000 horas).
  - Evitar el estancamiento de la automatización prematura (*arrested development* tras ~50 horas).
  - Tareas de completamiento (*Completion tasks*) y resolución de casos límite.
  - El efecto del Pretesting (*pretesting effect*) y fallo productivo.
- **Fuentes Científicas:**
  - Ericsson, Krampe & Tesch-Römer (1993, 2006, 2008) - *Condiciones de la Práctica Deliberada*.
  - Akgun & Toker (2024) - *Efecto del pretesting previo a consultar la IA*.
  - Renkl, A. (2014) - *Estrategia de desvanecimiento (Fading)*.
  - Fitts & Posner (1967) - *Etapas cognitiva, asociativa y autónoma*.
- **Ejemplo Conductor (Excel):**
  - Marta deja de ver tutoriales de YouTube pasivamente. Abre un archivo CSV real con datos desordenados de ventas. Antes de consultar a la IA, intenta escribir la fórmula condicional `SI(Y(...))` por sí misma durante 3 minutos (pretesting). Luego compara su intento con el modelo del tutor.
- **Riesgo y Sobredependencia IA:**
  - Copiar y pegar fórmulas generadas por IA directamente en la hoja de cálculo sin entender la sintaxis interna.
- **Solución con IA:**
  - Prompt "Generador de Casos y Desafíos Progresivos" que proporciona datasets ficticios con errores intencionales para que el estudiante los diagnostique.

---

## FASE 3: CONSOLIDAR

### CAPÍTULO 5: Recordá lo que aprendés: el sistema de retención inteligente
- **Fase del Método:** FASE 3: CONSOLIDAR
- **Conceptos Fundamentales:**
  - Efecto del Examen y Práctica de Recuperación (*Retrieval Practice*).
  - Efecto de Distribución y Repetición Espaciada (*Spacing Effect*).
  - Sinergia de Recuperación Espaciada (*Spaced Retrieval* +25% retención).
  - Práctica Intercalada (*Interleaving*) vs. Práctica Bloqueada (*Cramming*).
  - La Curva del Olvido de Ebbinghaus y algoritmos modernos (FSRS / Leitner).
- **Fuentes Científicas:**
  - Roediger & Karpicke (2006) - *Test-enhanced learning a 1 semana ($d = 1.26$)*.
  - Schwieren, Barenberg & Dutke (2017) - *Metaanálisis de práctica de recuperación ($d = 0.56$)*.
  - Latimier, Peyre & Ramus (2020) - *Metaanálisis de práctica espaciada ($g = 0.74$)*.
  - Huang, M. (2025) - *Sinergia de recuperación espaciada y modelos adaptativos neuronales*.
- **Ejemplo Conductor (Excel):**
  - Marta no relee sus apuntes de atajos y funciones. Utiliza un mazo de tarjetas en Anki o NotebookLM. Al ver la tarjeta "¿Qué combinación fija una referencia de celda?", debe evocar mentalmente `F4` antes de dar la vuelta. Alterna ejercicios de tablas dinámicas con fórmulas de texto para no mecanizar.
- **Riesgo y Sobredependencia IA:**
  - Dejar que la IA revise las tarjetas o evaluar las respuestas con excesiva benevolencia.
- **Solución con IA:**
  - Prompt "Constructor de Tarjetas Atómicas de Recuperación" a partir de apuntes o textos del estudiante.

---

## FASE 4: DEMOSTRAR

### CAPÍTULO 6: Comprobá si realmente aprendiste: evaluaciones sin trampas
- **Fase del Método:** FASE 4: DEMOSTRAR
- **Conceptos Fundamentales:**
  - Retroalimentación Educativa de Alta Información (*High-Information Feedback*).
  - Lógica de Error Continuado (*Error Carried Forward - ECF*).
  - Los 4 niveles del feedback de Hattie & Timperley (evitar el elogio personal).
  - Autoevaluaciones sin sesgo (*Exam Wrappers*) y calibración de Juicios de Aprendizaje (JOL).
- **Fuentes Científicas:**
  - Wisniewski, Zierer & Hattie (2020) - *Metaanálisis de feedback ($d = 0.48$; High-Info $d = 0.99$)*.
  - Hattie & Timperley (2007) - *Niveles: Tarea, Proceso, Autorregulación y Persona*.
  - Yordanov, Bychkov & Kuchma (2026) - *Inmediatez del feedback en Cortex Global y principio ECF*.
  - Kluger & DeNisi (1996) - *Efectos negativos del feedback centrado en el ego*.
- **Ejemplo Conductor (Excel):**
  - Marta se somete a un examen sorpresa generado por IA: auditar una hoja contable desbalanceada con 5 errores ocultos. La IA analiza su informe y le da feedback específico sobre su método de auditoría (proceso), sin limitarse a decirle "aprobado" o "reprobado".
- **Riesgo y Sobredependencia IA:**
  - Tomar exámenes con preguntas de opción múltiple demasiado obvias creadas por la IA que generan falsa confianza.
- **Solución con IA:**
  - Prompt "Examinador Ciego y Riguroso" con rúbrica analítica y detección de errores procedimentales.

---

### CAPÍTULO 7: Convertí el aprendizaje en un sistema: tu plan de dominio de 30 días
- **Fase del Método:** FASE 4: DEMOSTRAR
- **Conceptos Fundamentales:**
  - El ciclo permanente de Autorregulación (Planificar -> Monitorear -> Evaluar).
  - Transferencia lejana del conocimiento (*Far Transfer*) a proyectos laborales o vitales reales.
  - Creación de un sistema de aprendizaje perpetuo independiente de la tecnología.
  - Plan de acción estructurado día a día para 30 días.
- **Fuentes Científicas:**
  - Zimmerman, B. J. (2002) - *El modelo cíclico de autorregulación*.
  - EEF (2025) - *Instrucción de los 7 pasos de autorregulación y metacognición*.
  - Chairunnisa & Rahmadani (2023) - *Sostenibilidad del aprendizaje autorregulado*.
- **Ejemplo Conductor (Excel):**
  - Día 30: Marta no solo aprobó su evaluación; diseñó desde cero para su empresa un cuadro de mando financiero automatizado con tablas dinámicas y validación de datos. Ha interiorizado el sistema de 4 fases y ahora lo replica para aprender SQL.
- **Riesgo y Sobredependencia IA:**
  - Creer que se ha convertido en experto cuando solo se ha memorizado una herramienta.
- **Solución con IA:**
  - Protocolo semanal de "Auditoría de Autonomía Cognitiva" para verificar que el usuario puede ejecutar tareas complejas con la computadora desconectada de la IA.
