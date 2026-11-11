# RECURSO 06: PLANTILLA DE PRÁCTICA DELIBERADA Y REGISTRO FORENSE DE ERRORES

> **Kit Complementario:** El Sistema de Aprendizaje Acelerado con IA  
> **Fase del Método:** FASE 2: COMPRENDER / FASE 3: CONSOLIDAR  
> **Propósito:** Aislar micro-habilidades débiles, forzar el pretesting independiente y realizar análisis forense de discrepancias para romper la meseta de la automatización.

---

## Protocolo de Sesión de Práctica Deliberada (45 Minutos)
1. **Aislamiento (5 min):** Elegí una sola micro-habilidad donde hoy sentís torpeza.
2. **Pretesting Ciego (3 min):** Intentá resolver un ejercicio nuevo sin consultar apuntes ni IA.
3. **Análisis de Discrepancias (10 min):** Compará tu solución contra el modelo experto. Identificá la causa raíz del fallo.
4. **Re-ejecución en Caliente (25 min):** Resolvé 3 variantes seguidas del mismo ejercicio hasta lograr cero errores.

---

## Ficha de Registro de Práctica

### 1. DATOS DE LA SESIÓN
- **Fecha:** _____ / _____ / _________  
- **Micro-Habilidad Aislada:** _________________________________________________
- **Nivel de Dificultad Subjetivo (1 al 10):** [ _____ ]

### 2. EL INTENTO CIEGO (PRETESTING)
- **Enunciado del problema / desafío:**
  ______________________________________________________________________________
- **Mi intento inicial (escrito sin consultar ninguna ayuda):**
  ______________________________________________________________________________
  ______________________________________________________________________________
- **Tiempo que resistí pensando antes de mirar la solución:** _______ minutos.

### 3. ANÁLISIS FORENSE DE DISCREPANCIA
*(Completar únicamente si hubo error o titubeo)*
- **¿Cuál fue la diferencia exacta entre mi respuesta y la solución correcta?:**
  ______________________________________________________________________________
- **Clasificación del Error:**
  [ ] Error Conceptual (no entendí la regla de fondo)
  [ ] Error Procedimental (me equivoqué en la sintaxis, orden o cálculo)
  [ ] Error de Interpretación (leí mal el enunciado del problema)
- **La regla que olvidé y que debo recordar es:**
  ______________________________________________________________________________

### 4. RACHA DE MAESTRÍA (3 RE-EJECUCIONES EN CALIENTE)
- [ ] **Variante 1:** Resuelta en ______ minutos. Resultado: [ ÉXITO / FALLO ]
- [ ] **Variante 2:** Resuelta en ______ minutos. Resultado: [ ÉXITO / FALLO ]
- [ ] **Variante 3:** Resuelta en ______ minutos. Resultado: [ ÉXITO / FALLO ]

*Veredicto de la sesión:*  
[ ] MICRO-HABILIDAD AUTOMATIZADA (Lista para espaciamiento).  
[ ] REQUIERE OTRA SESIÓN DE PRÁCTICA DELIBERADA MAÑANA.

---

## Ejemplo Resuelto de Referencia (Caso: Marta - Práctica Deliberada en Excel)

* **Micro-Habilidad Aislada:** Fórmulas condicionales dobles con `SI(Y(...))` para comisiones comerciales.
* **Intento Ciego (Pretesting):** Marta intentó escribir:  
  `=SI(ventas>100000; "Comision 10%"; SI(pago_a_tiempo="SI"; "Comision 10%"; "Comision 3%"))`
* **Análisis Forense:**  
  - *Diferencia:* Marta anidó dos `SI` independientes en vez de usar el operador lógico de conjunción `Y()`.
  - *Clasificación:* Error Procedimental y de Elegancia de Sintaxis.
  - *Regla aprendida:* "Cuando ambas condiciones deben cumplirse a la vez, se coloca `Y(cond1; cond2)` dentro del primer argumento de un único `SI`".
* **Racha de Maestría (3 Re-ejecuciones en caliente):**
  - Variante 1 (Ventas > $50.000 y Zona Norte): Resuelta en 40s -> ÉXITO.
  - Variante 2 (Antigüedad > 5 años y Sin reclamos): Resuelta en 35s -> ÉXITO.
  - Variante 3 (Caso límite: Cliente nuevo sin historial de pago): Resuelta en 45s -> ÉXITO.
* **Veredicto:** MICRO-HABILIDAD AUTOMATIZADA.

---

## Prompt de Asistencia con IA para Rellenar esta Plantilla
```text
Actúa como un Entrenador de Práctica Deliberada. Estoy practicando: [HABILIDAD].
1. Dame un ejercicio desafiante sobre [MICRO-HABILIDAD].
2. No me des pistas ni la respuesta. Espera a que yo te pegue mi intento.
3. Cuando te envíe mi solución, compárala contra la ejecución óptima.
4. Si fallé, clasifica mi error (conceptual, procedimental o de interpretación) y genera 3 variantes inmediatas para mi Racha de Maestría.
```

