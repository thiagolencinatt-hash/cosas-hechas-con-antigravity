# RECURSO 09: PLANTILLA DE AUTOEVALUACIÓN Y EXAM WRAPPER

> **Kit Complementario:** El Sistema de Aprendizaje Acelerado con IA  
> **Fase del Método:** FASE 4: DEMOSTRAR  
> **Propósito:** Auditar objetivamente el desempeño en simulacros y exámenes, calibrar los Juicios de Aprendizaje (JOL) y extraer lecciones accionables de cada error.

---

## El Concepto del "Exam Wrapper"
Un *Exam Wrapper* es un protocolo reflexivo post-evaluación respaldado por la investigación del EEF y la psicología metacognitiva. No se limita a mirar la nota final; descompone minuciosamente el origen de cada error para ajustar la preparación futura.

---

## Formulario de Auditoría Post-Examen

### 1. DATOS GENERALES
- **Evaluación / Simulacro:** __________________________________________________
- **Fecha:** _____ / _____ / _________  
- **Tiempo límite previsto:** _______ min.  **Tiempo real empleado:** _______ min.
- **Calificación / Puntuación obtenida:** ________ / 10

### 2. CALIBRACIÓN METACOGNITIVA
- **Estimación previa (Antes de ver los resultados):** ¿Qué nota creías que sacarías? [ ______ / 10 ]
- **Discrepancia JOL:**  
  [ ] Sobrestimé mi nivel (creí que sabía más de lo que demostré).  
  [ ] Calibración exacta (mi juicio coincidió con mi resultado).  
  [ ] Subestimé mi nivel (obtuve mejor resultado del esperado).

### 3. CLASIFICACIÓN ANATOMOFISIOLÓGICA DE LOS ERRORES
Analizá cada punto perdido y asignalo a una de las siguientes tres causas raíz:

#### Causa A: Error Conceptual Profundo (No entendí la regla de fondo)
- *Pregunta donde fallé:* _____________________________________________________
- *¿Cuál era la confusión teórica exacta?:* __________________________________
- *Concepto a re-estudiar con el Tutor Socrático:* ___________________________

#### Causa B: Error Procedimental o Descuido (Sabía la regla, fallé en el cálculo/sintaxis)
- *Pregunta donde fallé:* _____________________________________________________
- *¿En qué paso del procedimiento me distraje?:* _____________________________
- *Estrategia de verificación para evitarlo:* ________________________________

#### Causa C: Falta de Tiempo o Bloqueo Emocional
- *Pregunta donde fallé:* _____________________________________________________
- *¿Qué provocó la pérdida de tiempo previa?:* ________________________________

### 4. APLICACIÓN DEL PRINCIPIO ECF (ERROR CARRIED FORWARD)
- ¿Hubo algún problema donde cometí un fallo inicial pero mantuve la lógica correcta en los pasos siguientes?
  * Ejercicio: ________________________________________________________________
  * Razonamiento metodológico válido que rescato: ____________________________

### 5. PLAN ACCIONABLE (FEED-FORWARD)
- Micro-habilidad prioritaria a entrenar en las próximas 48 horas: ______________
- Fecha de la repetición del simulacro para validar la corrección: ___/___/___

---

## Ejemplo Resuelto de Referencia (Caso: Marta - Exam Wrapper de Excel)

* **Evaluación:** Simulacro de Auditoría de Ventas (Planilla de 500 filas con inconsistencias).
* **Calificación:** 8,5 / 10 (Tiempo empleado: 42 minutos de 45 permitidos).
* **Calibración JOL:** Antes de corregir, Marta creía que había obtenido 8/10. Calibración casi exacta (error mínimo de autoeficacia).
* **Anatomía del Error:**
  - *Pregunta fallada:* Al agregar 20 clientes nuevos al final de la planilla, los totales generales no se actualizaron automáticamente.
  - *Causa raíz:* Causa B (Procedimental). Marta usó una fórmula fija `=SUMA(D2:D501)` en lugar de convertir el rango previamente en una Tabla Oficial (`Ctrl + T`) con fórmula estructurada `=SUMA(Ventas[Total])`.
  - *Lógica ECF rescatada:* Marta no fue penalizada por la lógica de cálculo, sino por la arquitectura de datos.
* **Plan Feed-Forward:** 2 sesiones de 15 minutos entrenando creación de Tablas Oficiales y referencias estructuradas.

---

## Prompt de Asistencia con IA para Rellenar esta Plantilla
```text
Actúa como un Auditor Académico y Evaluador Metacognitivo. Acabo de realizar una prueba sobre: [TEMA].
Estos fueron mis errores y dudas durante la prueba:
"[PEGAR DESCRIPCIÓN DE ERRORES O EJERCICIOS FALLADOS]"
1. Ayúdame a descomponer cada error en sus tres dimensiones: ¿Conceptual, Procedimental o Falta de tiempo/Atención?
2. Aplica la lógica ECF (Error Carried Forward): rescata qué partes de mi razonamiento fueron válidas y separa el fallo de origen de la deducción posterior.
3. Redacta el Plan Feed-Forward con 2 ejercicios de corrección inmediata para las próximas 48 horas.
```

