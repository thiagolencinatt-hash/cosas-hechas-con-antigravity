# ECOSISTEMA EDITORIAL Y PRODUCCIÓN DE PRODUCTOS DIGITALES CON IA

Este documento define la arquitectura operativa permanente, las responsabilidades de los agentes y los estándares de calidad del espacio de trabajo.

## 1. Misión del Workspace
Convertir la investigación científica rigurosa y la pedagogía práctica en productos digitales y ebooks de nivel profesional, minimizando la intervención manual y maximizando la autonomía intelectual del lector.

## 2. Marco Metodológico Fundamental (4 Fases)
Todo producto formativo generado en este sistema debe estructurarse obligatoriamente bajo las cuatro fases del aprendizaje acelerado:
1. **FASE 1: PREPARAR** (Metacognición, objetivos SMART/CLEAR, reducción de carga cognitiva intrínseca, mapas de ruta).
2. **FASE 2: COMPRENDER** (Andamiaje pedagógico, método socrático, técnica Feynman, ejemplos trabajados).
3. **FASE 3: CONSOLIDAR** (Recuperación activa / Retrieval Practice, repetición espaciada, práctica intercalada).
4. **FASE 4: DEMOSTRAR** (Práctica deliberada, evaluación formativa libre de sesgos, transferencia de conocimiento a entornos reales).

## 3. Equipo de Agent Skills Integradas
Las directivas especializadas residen en `.agents/skills/`:
- `project-manager`: Dirección editorial, seguimiento de tareas, control de versiones y auditoría de flujo.
- `research-auditor`: Verificación empírica, trazabilidad de citas, detección de sesgos y registro bibliográfico.
- `ebook-author`: Redacción de manuscritos, claridad conceptual, aplicación del ejemplo conductor y tono empático/técnico.
- `learning-designer`: Ingeniería instruccional, diseño de ejercicios aplicados, andamiaje y kit complementario de plantillas.
- `fact-checker`: Auditoría estricta contra alucinaciones, comprobación de cifras numéricas y límites éticos de la IA.
- `ebook-designer`: Estética visual moderna, diagramación editorial, exportación tipográfica (DOCX, PDF) y assets comerciales.

## 4. Reglas Editoriales y Éticas Inquebrantables
1. **Verdad Empírica sobre Sensacionalismo:** Queda terminantemente prohibido inventar DOIs, citas, autores o resultados estadísticos. Si un dato no está verificado en la fuente primaria, se reporta como "NO VERIFICADO" o "EN REVISIÓN".
2. **Autonomía Cognitiva del Lector:** Los prompts y técnicas enseñadas NUNCA deben invitar a la IA a resolver la tarea por el alumno. La IA actúa como tutor socrático, evaluador o generador de ejercicios, forzando la práctica activa y el esfuerzo deseable.
3. **Calidad sobre Volumen:** No se admite relleno, párrafos redundantes ni listas genéricas de prompts descontextualizados. Cada capítulo debe contener procedimiento paso a paso, errores comunes, limitaciones reales y ejercicio de aplicación inmediata.
4. **Preservación Documental:** Los informes de investigación crudos (como `INFORME_NOTEBOOKLM_APRENDIZAJE_IA.txt`) nunca deben ser sobreescritos ni destruidos.
