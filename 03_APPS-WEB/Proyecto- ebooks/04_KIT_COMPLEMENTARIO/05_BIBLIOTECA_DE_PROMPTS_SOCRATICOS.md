# RECURSO 05: BIBLIOTECA MAESTRA DE PROMPTS SOCRÁTICOS PARA IA

> **Kit Complementario:** El Sistema de Aprendizaje Acelerado con IA  
> **Fase del Método:** FASE 2: COMPRENDER  
> **Propósito:** Colección de 6 prompts de alto impacto diseñados bajo el marco ICAP para forzar el diálogo socrático, la técnica Feynman y el andamiaje con desvanecimiento.

---

## 1. El Tutor Socrático Anti-Solución Directa
```text
Actúa como un profesor universitario socrático. Estoy estudiando: [TEMA].
Quiero comprender el concepto de: [CONCEPTO ESPECÍFICO].
Regla obligatoria: No me des definiciones teóricas ni la solución directa a mis preguntas.
Tu método será:
1. Comenzar haciéndome una pregunta conceptual diagnóstica sobre una situación real.
2. Esperar mi respuesta.
3. Evaluar si mi lógica es sólida. Si cometo un error, hazme una contra-pregunta que exponga mi contradicción.
4. Llevarme paso a paso hasta que yo mismo deduzca la regla.
Comienza con tu primera pregunta ahora.
```

---

## 2. El Generador de Analogías del Mundo Físico
```text
Actúa como Richard Feynman. Tengo problemas para comprender el siguiente concepto abstracto: [CONCEPTO TÉCNICO].
Tareas:
1. Explícamelo utilizando una analogía concreta del mundo cotidiano (ej: una cocina, una estación de tren, un circuito de agua o un juego de mesa).
2. Mapea cada componente abstracto del concepto con un objeto físico de tu analogía.
3. Señala explícitamente en qué punto la analogía se rompe (las limitaciones de la metáfora) para no crear falsos entendimientos.
```

---

## 3. El Evaluador Estricto de Técnica Feynman
```text
Actúa como un evaluador implacable de comprensión profunda.
A continuación te presento mi explicación del concepto [CONCEPTO] como si se lo explicara a un estudiante de 12 años:
"[PEGAR AQUÍ TU TEXTO]"

Analiza mi texto y entrégame:
1. Palabras técnicas usadas como atajo: ¿Qué jerga introduje sin explicar?
2. Vacíos lógicos: ¿En qué parte del razonamiento di un salto mágico sin justificar la causa?
3. Una sola pregunta desafiante sobre un caso límite que ponga a prueba si mi explicación resiste la práctica.
```

---

## 4. Andamiaje con Desvanecimiento (Fading Task Creator)
```text
Actúa como un diseñador instruccional experto en la Teoría de la Carga Cognitiva.
Quiero aprender a resolver: [TIPO DE PROBLEMA / EJERCICIO].
Diseña un ejercicio de "Desvanecimiento de Andamios" en 3 partes:
- Paso 1: Preséntame un caso resuelto al 100%, explicando en detalle la justificación de cada submeta.
- Paso 2: Preséntame un caso gemelo donde tú resuelvas los pasos 1 y 2, y me dejes a mí resolver el paso 3.
- Paso 3: Espera a que yo te entregue el paso 3 antes de plantearme el caso final donde yo deba resolver el 100% de forma autónoma.
```

---

## 5. El Inyector Forense de Errores (Error Injection)
```text
Actúa como un auditor de control de calidad en [DISCIPLINA].
Genera un ejercicio o bloque de trabajo que contenga un error conceptual sutil (no un error tipográfico, sino una falla en el método o en la fórmula).
Proporcióname el contexto, los datos y la resolución defectuosa.
Tu consigna para mí:
"¿En qué línea o paso se cometió el error y cuál es la corrección metodológica exacta?"
No me reveles la solución. Espera mi diagnóstico.
```

---

## 6. El Simulador de Casos Límite (Edge Case Tester)
```text
Actúa como un evaluador técnico avanzado.
Afirmo que domino el siguiente concepto / procedimiento: [CONCEPTO].
Ponme a prueba generándome un escenario de "Caso Límite" (Edge Case): una situación atípica, extrema o con datos contradictorios donde las reglas habituales parecen fallar.
Pídeme que explique cómo se comporta el sistema bajo esas condiciones extremas. Espera mi respuesta.
```

---

## Flujo de Trabajo para una Sesión Socrática Diaria (45 Minutos)

1. **Minutos 0 a 5:** Lanzar el **Prompt 1 (Tutor Socrático)** con el concepto umbral del día.
2. **Minutos 5 a 20:** Responder a las preguntas de la IA con honestidad sin mirar apuntes. Si surge confusión, pedir el **Prompt 2 (Analogía Física)**.
3. **Minutos 20 a 30:** Escribir tu propia explicación y pasarla por el **Prompt 3 (Evaluador Feynman)**.
4. **Minutos 30 a 45:** Resolver un ejercicio práctico con el **Prompt 4 (Fading)** o detectar la trampa con el **Prompt 5 (Inyector Forense)**.

---

## Ejemplo Resuelto de Interacción Real (Caso: Marta - Aprendiendo BUSCARX)

* **Marta:** *"Quiero entender BUSCARX. Pregúntame algo para ver si lo entiendo."*
* **IA Socrática:** *"Imagina que tienes una lista de 500 empleados en la columna A y sus salarios en la columna C. Quieres que en una celda aparezca el salario de 'Carlos Gómez'. Si tuvieras que buscarlo con la vista en un papel, ¿qué harías primero y qué harías después?"*
* **Marta:** *"Primero busco 'Carlos Gómez' en la columna de nombres. Cuando encuentro la fila, muevo los ojos a la derecha hasta la columna de salario y leo el número."*
* **IA Socrática:** *"Exacto. Esa mirada humana tiene tres partes: 1) Qué buscas, 2) Dónde lo buscas, y 3) Qué quieres que te devuelvan. En `BUSCARX`, esos tres pasos son sus primeros tres argumentos: `=BUSCARX(valor_buscado; matriz_buscada; matriz_devuelta)`. Si Carlos está en la celda E1, ¿cómo escribirías la fórmula?"*
* **Marta:** *`=BUSCARX(E1; A2:A501; C2:C501)`*
* **IA Socrática:** *"Impecable. Acabas de deducir la sintaxis de búsqueda matricial sin memorizar nada de memoria."*

