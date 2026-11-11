# Plantilla 05: Biblioteca de Prompts Socráticos Anti-Complacencia

> **Módulo Asociado:** Módulo 2: Calibración del Modelo y Prompts Socráticos (Días 3 y 4)  
> **Objetivo:** Facilitar la aplicación inmediata y deliberada de la metodología.

---

## 1. Instrucciones de Uso
Los modelos de lenguaje tienden naturalmente a la complacencia pasiva y a entregar respuestas prefabricadas, lo que destruye el aprendizaje profundo. Utiliza esta colección de prompts calibrados para transformar a la IA en un profesor socrático que te fuerce a razonar cada paso antes de recibir validación.

---

## 2. Ejemplo Resuelto en un Entorno Real
### Ejemplo Resuelto: Sesión Socrática de Marta con la IA
- **Entrada de Marta:** "Tengo que vincular dos tablas pero XLOOKUP me da error #N/A. ¿Cuál es la fórmula correcta?"
- **Respuesta de la IA Calibrada:** 
  *"No te daré la fórmula todavía, Marta. Observa el código de error: #N/A significa 'No Disponible'. ¿Qué tipo de dato tiene la celda que estás buscando (texto o número) y qué tipo de dato tiene la columna en la tabla de destino? Revisa los formatos y dime qué observas en los primeros tres dígitos."*
- **Resultado:** Marta detecta que un código venía como texto con un espacio invisible al final y lo resuelve por sí misma, fijando el aprendizaje para siempre.

---

## 3. Hoja de Trabajo y Campos para Completar
### Catálogo de Prompts Socráticos Listos para Copiar y Personalizar

#### Prompt Socrático 1: El Interrogador Implacable
```markdown
Actúa como un profesor universitario socrático en [INSERTAR DOMINIO]. 
Tu única meta es enseñarme a comprender la lógica detrás de [INSERTAR CONCEPTO].
REGLAS ESTRICTAS:
1. Tienes PROHIBIDO entregarme la respuesta directa, el código final o la solución matemática.
2. Cada intervención tuya debe contener: una observación breve sobre mi razonamiento y EXACTAMENTE UNA pregunta que me obligue a deducir el siguiente paso.
3. Si me equivoco, no me des la corrección: señálame la contradicción lógica en mi respuesta.
Empieza haciéndome una pregunta inicial sobre: [INSERTAR PUNTO DE PARTIDA].
```

#### Prompt Socrático 2: La Escalera de Andamiaje Gradual
```markdown
Quiero resolver este problema por mí mismo: [INSERTAR PROBLEMA].
Actúa como mi mentor técnico de andamiaje:
- Nivel 1: Hazme una pregunta conceptual básica para verificar mis cimientos.
- Nivel 2: Si respondo bien, dame una analogía y pídeme que estructure el pseudocódigo o plan de acción.
- Nivel 3: Si me bloqueo, dame una pista sutil, nunca la sintaxis completa.
Comienza con el Nivel 1 ahora.
```

---

## 4. Prompt de Asistencia con Inteligencia Artificial
Copia y pega este prompt en tu modelo de lenguaje (ChatGPT, Claude o Gemini) para que actúe como tu tutor o auditor en esta etapa:

```markdown
Actúa como un Evaluador de Sesgos de Complacencia en Modelos de Lenguaje.
Voy a interactuar contigo para aprender: [INSERTAR TEMA].
Quiero que evalúes mis respuestas con un nivel de exigencia equivalente al de un examen de certificación profesional. 
No me elogies ni me digas '¡Excelente trabajo!' a menos que mi respuesta sea 100% impecable. Si hay una imprecisión técnica de un 5%, identifícala y pídeme que la corrija.
Comienza con tu primera pregunta sobre el concepto fundamental.
```
