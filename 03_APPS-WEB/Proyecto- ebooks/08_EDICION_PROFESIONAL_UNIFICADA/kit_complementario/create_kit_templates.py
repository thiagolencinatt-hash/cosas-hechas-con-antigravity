import os
from pathlib import Path

OUT_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks\08_EDICION_PROFESIONAL_UNIFICADA\kit_complementario")
OUT_DIR.mkdir(parents=True, exist_ok=True)

TEMPLATES = [
    {
        "filename": "01_PLANTILLA_MAPA_DE_HABILIDADES.md",
        "title": "Plantilla 01: Mapa de Habilidades y Deconstrucción de Dominio",
        "modulo": "Módulo 1: La Deconstrucción Quirúrgica (Día 1)",
        "instrucciones": "Utiliza esta plantilla durante las primeras dos horas del Día 1. El objetivo no es mapear una enciclopedia, sino identificar las ramas maestras de la competencia funcional que vas a adquirir. Define el objetivo final con verbos de desempeño demostrable, divide el dominio en 3 a 5 sub-áreas y establece la métrica tangible de aprobación.",
        "ejemplo": """### Ejemplo Resuelto: Marta (Modelado Financiero y Automatización en Excel)
- **Habilidad Macro:** Creación de Modelos Financieros de Flujo de Caja y Automatización de Reportes Gerenciales en Microsoft Excel.
- **Sub-área 1:** Lógica de Fórmulas Dinámicas (XLOOKUP, FILTER, INDEX-MATCH).
- **Sub-área 2:** Consolidación de Datos y Power Query (ETL básico, unificación de libros contables).
- **Sub-área 3:** Modelado de Estados Financieros (Proyecciones de Balance y P&L a 3 años).
- **Sub-área 4:** Tableros de Control Ejecutivos (Tablas Dinámicas avanzadas y segmentación de datos).
- **Resultado Demostrable en Día 14:** Un libro de Excel completamente automatizado que cargue extractos crudos, proyecte el flujo de caja a 12 meses y genere alertas automáticas de liquidez.""",
        "campos": """### Campos de Trabajo para tu Proyecto

1. **Habilidad Macro Seleccionada:**
   `[Escribe aquí la habilidad específica. Evita generalidades como 'Aprender Programación'; escribe 'Construcción de APIs REST en Python con FastAPI']`

2. **Propósito Práctico y Caso de Uso Real:**
   `[¿Para qué necesitas esta competencia en el mundo real? ¿Qué problema profesional o académico resuelve?]`

3. **Sub-áreas Principales del Dominio (3 a 5 áreas):**
   - **Área 1:** `[Nombre del bloque y foco técnico]`
   - **Área 2:** `[Nombre del bloque y foco técnico]`
   - **Área 3:** `[Nombre del bloque y foco técnico]`
   - **Área 4:** `[Nombre del bloque y foco técnico]`

4. **Entregable Tangible del Día 14 (AMV):**
   `[Describe con exactitud el artefacto terminado que evaluará un tercero o usarás en tu trabajo]`""",
        "prompt_ia": """```markdown
Actúa como un Auditor de Competencias Profesionales y Diseñador Instruccional Senior. 
Quiero aprender la siguiente habilidad funcional en un programa de inmersión de 14 días:
[INSERTAR HABILIDAD: ej. Programación backend en Python]

Tu tarea:
1. Divide este dominio en un máximo de 4 sub-áreas críticas que representen el núcleo operativo de la habilidad.
2. Identifica el error más común que cometen los principiantes al perderse en la teoría de este dominio.
3. Proponme un artefacto tangible mínimo y verificable (AMV) que demuestre competencia operativa al finalizar los 14 días.
Hazme 2 preguntas para precisar mi nivel de partida antes de cerrar el mapa.
```"""
    },
    {
        "filename": "02_PLANTILLA_MATRIZ_ESENCIAL_VS_ACCESORIO.md",
        "title": "Plantilla 02: Matriz Esencial vs. Accesorio (Regla 80/20 Auditada)",
        "modulo": "Módulo 1: La Deconstrucción Quirúrgica (Día 1)",
        "instrucciones": "Separa quirúrgicamente el 20% de las funciones o conceptos que resuelven el 80% de los problemas reales en el entorno de producción, del 80% de tecnicismos accesorios que debes congelar durante las dos semanas. Si un concepto no se va a usar directamente en tu Artefacto Mínimo Viable, debe ir a la lista de 'Congelado'.",
        "ejemplo": """### Ejemplo Resuelto: Marta (Modelado en Excel)
- **20% Esencial (Foco Absoluto):**
  1. `XLOOKUP` bidireccional y anidado.
  2. Tablas Dinámicas con campos calculados.
  3. Power Query: Unificar carpetas con archivos CSV y limpiar nulos.
  4. Lógica de Flujo de Caja Descontado (NPV, IRR).
- **80% Accesorio (Congelado para Después de los 14 Días):**
  1. Macros avanzadas en VBA y scripts en Office Script.
  2. Gráficos 3D o animaciones de dashboard.
  3. Fórmulas estadísticas obsoletas (`LOOKUP` clásico, `VLOOKUP` con coincidencia aproximada).
  4. Modelado probabilístico Monte Carlo.""",
        "campos": """### Campos de Trabajo para tu Proyecto

| Categoría | Elementos Técnicos / Tareas | Criterio de Inclusión / Justificación |
| :--- | :--- | :--- |
| **ESENCIAL (20% Core)** | 1. `[Concepto/Función 1]`<br>2. `[Concepto/Función 2]`<br>3. `[Concepto/Función 3]`<br>4. `[Concepto/Función 4]` | Resuelven las operaciones diarias básicas del artefacto final. |
| **ACCESORIO (80% Ruido)** | 1. `[Función avanzada no crítica]`<br>2. `[Jerga teórica o historia]`<br>3. `[Herramientas secundarias]` | Interrumpen la adquisición de fluidez básica; se congelan. |

**Regla de Oro:** Si dudas si algo es esencial o accesorio, pregúntate: *¿Puedo entregar el artefacto del Día 14 sin dominar esto?* Si la respuesta es sí, es accesorio.""",
        "prompt_ia": """```markdown
Actúa como un Ingeniero Senior y Filtro de Relevancia Cognitiva. 
Estoy deconstruyendo la habilidad: [INSERTAR HABILIDAD].
Tengo esta lista preliminar de temas que planeaba estudiar:
[INSERTAR LISTA DE TEMAS O ÍNDICE DE CURSO]

Aplica un filtro implacable:
1. Clasifica cada tema en: 'NÚCLEO CRÍTICO (20%)' o 'ACCESORIO SECUNDARIO (80%)'.
2. Justifica qué temas de la lista son trampas de procrastinación teórica que los cursos tradicionales enseñan pero casi nunca se usan en el trabajo diario.
3. Dame la lista purgada de máximo 5 conceptos sobre los que debo construir mi fluidez inicial en 14 días.
```"""
    },
    {
        "filename": "03_PLANTILLA_PLANIFICADOR_14_DIAS.md",
        "title": "Plantilla 03: Cronograma Adaptativo de 14 Días (336 Horas de Inmersión)",
        "modulo": "Módulo 1: La Deconstrucción Quirúrgica (Día 2)",
        "instrucciones": "Planifica tus bloques diarios de aprendizaje en ventanas óptimas de 45 a 90 minutos de esfuerzo deliberado, evitando maratones pasivas de fin de semana. Asigna a cada jornada una microcompetencia específica, la técnica cognitiva a utilizar y el criterio exacto de superación antes de dar el día por concluido.",
        "ejemplo": """### Ejemplo Resuelto: Marta (Cronograma de 14 Días)
- **Día 1-2 (Deconstrucción):** Auditoría de libros contables de su empresa, mapa de 4 microcompetencias, configuración de ChatGPT y Claude como tutores socráticos.
- **Día 3-4 (Socrático y Andamiaje):** Desentrañar sintaxis de `XLOOKUP` múltiple y Power Query mediante preguntas graduadas; resolución guiada de errores de formato de fecha.
- **Día 5-7 (Feynman y Puntos Ciegos):** Explicar el modelo de flujo de caja a la IA como si fuera un estudiante de secundaria; auditoría de errores lógicos en la amortización de deuda.
- **Día 8-10 (Simulador de Vuelo):** Ensayar 3 crisis financieras simuladas (retraso en cobranzas, caída del 30% en ventas, cambio de divisa).
- **Día 11-12 (Blindaje Mnemotécnico):** Examen ciego de fórmulas sin mirar notas en 20 minutos; creación de flashcards activas.
- **Día 13-14 (Artefacto y Demostración):** Construcción del modelo financiero real de su empresa en Excel y defensa técnica ante un colega senior.""",
        "campos": """### Campos de Trabajo: Calendario Diario de Ejecución

- **Día 1 (Deconstrucción del Dominio):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 2 (Filtro 80/20 y Microcompetencias):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 3 (Calibración Socrática - Concepto 1):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 4 (Andamiaje Gradual - Concepto 2):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 5 (Técnica Feynman - Modelos Mentales):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 6 (Analogías y Puntos Ciegos):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 7 (Resumen Relacional y Nodos):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 8 (Simulador de Vuelo - Escenario Base):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 9 (Simulador de Vuelo - Escenario con Fallos):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 10 (Simulador de Vuelo - Presión de Tiempo):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 11 (Examen Ciego Sin Apuntes):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 12 (Recuperación Espaciada y Debate):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 13 (Construcción del Artefacto AMV):** `[Foco del día]` | Meta de superación: `[Rúbrica]`
- **Día 14 (Auditoría Final y Segundo Cerebro):** `[Foco del día]` | Meta de superación: `[Rúbrica]`""",
        "prompt_ia": """```markdown
Actúa como un Diseñador Curricular y Cronometrador de Alto Rendimiento. 
Quiero ejecutar un programa de 14 días para dominar la competencia operativa de: [INSERTAR HABILIDAD].
Tengo disponible [INSERTAR HORAS/DÍA: ej. 90 minutos diarios].

Diseña mi cronograma día a día:
1. Divide las 14 jornadas siguiendo estrictamente las 4 fases: Días 1-2 (Preparar), Días 3-7 (Comprender), Días 8-10 (Consolidar/Simulador), Días 11-12 (Blindaje), Días 13-14 (Demostrar/AMV).
2. Para cada día, redacta un micro-objetivo CLEAR (específico, medible y ejecutable en 60-90 minutos).
3. Agrega una 'Regla de Corte' para cada día: qué debo haber logrado exactamente para cerrar la computadora y descansar.
```"""
    },
    {
        "filename": "04_PLANTILLA_CONSTRUCTOR_MICROCOMPETENCIAS.md",
        "title": "Plantilla 04: Constructor de Microcompetencias y Bloques de 45 Minutos",
        "modulo": "Módulo 1: La Deconstrucción Quirúrgica (Día 2)",
        "instrucciones": "La teoría de la Carga Cognitiva (Sweller, 1988) demuestra que la memoria de trabajo colapsa cuando se enfrenta a más de 3 o 4 elementos nuevos simultáneos. Utiliza este constructor para atomizar una habilidad compleja en unidades moleculares de exactamente 45 minutos de ejecución enfocada.",
        "ejemplo": """### Ejemplo Resuelto: Marta (Atomización de Power Query)
- **Habilidad Macro:** Transformación y limpieza de datos en Power Query.
- **Microcompetencia 1 (Bloque 45 min):** Importar 3 archivos CSV de distintas carpetas y unificarlos en una sola tabla continua sin duplicar encabezados.
- **Microcompetencia 2 (Bloque 45 min):** Detectar y corregir automáticamente formatos mixtos de fechas (DD/MM/AAAA vs MM/DD/AAAA) mediante columnas condicionales.
- **Microcompetencia 3 (Bloque 45 min):** Crear una clave foránea combinada (ID de cliente + fecha de compra) para cruzar datos con el maestro de clientes.
- **Microcompetencia 4 (Bloque 45 min):** Automatizar la actualización automática del modelo cada vez que se agregue un nuevo archivo a la carpeta de origen.""",
        "campos": """### Campos de Trabajo para tus Microcompetencias

#### Bloque de Ejecución 1
- **Nombre de la Microcompetencia:** `[Nombre conciso]`
- **Carga Cognitiva Focal:** `[¿Qué único concepto nuevo se aprende?]`
- **Condición de Entrada:** `[¿Qué se necesita saber antes de empezar?]`
- **Ejercicio Práctico Inmediato:** `[Acción concreta a ejecutar con teclado]`
- **Prueba de Autonomía (3 minutos):** `[¿Cómo demuestras que lo dominas sin mirar tutoriales?]`

#### Bloque de Ejecución 2
- **Nombre de la Microcompetencia:** `[Nombre conciso]`
- **Carga Cognitiva Focal:** `[¿Qué único concepto nuevo se aprende?]`
- **Condición de Entrada:** `[¿Qué se necesita saber antes de empezar?]`
- **Ejercicio Práctico Inmediato:** `[Acción concreta a ejecutar con teclado]`
- **Prueba de Autonomía (3 minutos):** `[¿Cómo demuestras que lo dominas sin mirar tutoriales?]`""",
        "prompt_ia": """```markdown
Actúa como un Diseñador Instruccional especializado en Teoría de la Carga Cognitiva.
Tengo este tema de estudio: [INSERTAR TEMA: ej. Gestión de estado en React con Zustand].

Descompón este tema en 3 microcompetencias independientes de exactamente 45 minutos cada una:
1. Cada microcompetencia debe tener un único objetivo cognitivo (reducir la carga intrínseca).
2. Proporciona una instrucción de práctica paso a paso.
3. Diseña una prueba ciega de 3 minutos para evaluar si el estudiante puede aplicarlo sin muletas.
```"""
    },
    {
        "filename": "05_PLANTILLA_BIBLIOTECA_PROMPTS_SOCRATICOS.md",
        "title": "Plantilla 05: Biblioteca de Prompts Socráticos Anti-Complacencia",
        "modulo": "Módulo 2: Calibración del Modelo y Prompts Socráticos (Días 3 y 4)",
        "instrucciones": "Los modelos de lenguaje tienden naturalmente a la complacencia pasiva y a entregar respuestas prefabricadas, lo que destruye el aprendizaje profundo. Utiliza esta colección de prompts calibrados para transformar a la IA en un profesor socrático que te fuerce a razonar cada paso antes de recibir validación.",
        "ejemplo": """### Ejemplo Resuelto: Sesión Socrática de Marta con la IA
- **Entrada de Marta:** "Tengo que vincular dos tablas pero XLOOKUP me da error #N/A. ¿Cuál es la fórmula correcta?"
- **Respuesta de la IA Calibrada:** 
  *"No te daré la fórmula todavía, Marta. Observa el código de error: #N/A significa 'No Disponible'. ¿Qué tipo de dato tiene la celda que estás buscando (texto o número) y qué tipo de dato tiene la columna en la tabla de destino? Revisa los formatos y dime qué observas en los primeros tres dígitos."*
- **Resultado:** Marta detecta que un código venía como texto con un espacio invisible al final y lo resuelve por sí misma, fijando el aprendizaje para siempre.""",
        "campos": """### Catálogo de Prompts Socráticos Listos para Copiar y Personalizar

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
```""",
        "prompt_ia": """```markdown
Actúa como un Evaluador de Sesgos de Complacencia en Modelos de Lenguaje.
Voy a interactuar contigo para aprender: [INSERTAR TEMA].
Quiero que evalúes mis respuestas con un nivel de exigencia equivalente al de un examen de certificación profesional. 
No me elogies ni me digas '¡Excelente trabajo!' a menos que mi respuesta sea 100% impecable. Si hay una imprecisión técnica de un 5%, identifícala y pídeme que la corrija.
Comienza con tu primera pregunta sobre el concepto fundamental.
```"""
    },
    {
        "filename": "06_PLANTILLA_AUDITOR_FEYNMAN.md",
        "title": "Plantilla 06: Auditor Feynman de Claridad Conceptual y Brechas",
        "modulo": "Módulo 3: Asimilación Acelerada y Técnica Feynman (Días 5 al 7)",
        "instrucciones": "El método de Richard Feynman establece que si no puedes explicar un concepto con palabras sencillas y sin jerga a un profano, en realidad no lo has comprendido. Utiliza esta plantilla para redactar tu explicación con lenguaje llano y auditarla mediante la IA para encontrar baches lógicos y falsas ilusiones de competencia.",
        "ejemplo": """### Ejemplo Resuelto: Marta explicando 'Power Query'
- **Explicación de Marta:** "Power Query es como una cinta transportadora en una cocina industrial. Tomas verduras sucias de diferentes camiones (archivos Excel desordenados), las lavas, pelas las partes podridas (eliminas columnas vacías y espacios) y las entregas limpias y picadas al chef (el modelo de reporte). Cada vez que llega un camión nuevo, solo aprietas un botón y la máquina repite exactamente los mismos pasos sin que tengas que picar nada a mano."
- **Auditoría de la IA:** "Excelente analogía culinaria. Sin embargo, omitiste un detalle crítico: ¿qué ocurre si el camión llega con una verdura que la máquina no reconoce (un cambio en el nombre de una columna del CSV)? Ahí tu cinta transportadora se traba con un error de esquema."
- **Calibración de Marta:** Marta añade el paso de manejo de excepciones y columnas dinámicas.""",
        "campos": """### Campos de Trabajo: Hoja de Auditoría Feynman

1. **Concepto Clave a Explicar:**
   `[Nombre del concepto técnico complejo]`

2. **Mi Explicación en Lenguaje Simple (Prohibida la Jerga):**
   `[Escribe tu explicación como si se la contaras a un joven de 14 años o a un familiar sin formación técnica]`

3. **Analogía Utilizada:**
   `[¿A qué objeto, proceso cotidiano o fenómeno del mundo real se parece este concepto?]`

4. **Brechas Identificadas por la IA:**
   - Brecha 1: `[Bache conceptual detectado]`
   - Brecha 2: `[Asunción errónea corregida]`

5. **Explicación Refinada y Definitiva:**
   `[Reescritura final integrando la corrección de las brechas]`""",
        "prompt_ia": """```markdown
Actúa como un Auditor Lógico de la Técnica Feynman.
He redactado la siguiente explicación para un concepto que estoy aprendiendo: [INSERTAR CONCEPTO].
Aquí está mi explicación:
\"\"\"
[INSERTAR TU EXPLICACIÓN]
\"\"\"

Tu misión:
1. Detecta cualquier palabra técnica o jerga que haya usado para 'disfrazar' una falta de comprensión real.
2. Identifica el punto ciego o salto lógico más evidente en mi explicación.
3. Evalúa mi analogía: ¿es precisa o genera confusiones conceptuales colaterales?
4. Hazme una sola pregunta capciosa sobre una situación extrema donde mi modelo mental fallaría.
```"""
    },
    {
        "filename": "07_PLANTILLA_GENERADOR_SIMULACIONES.md",
        "title": "Plantilla 07: Generador de Simulaciones y Escenarios de Crisis",
        "modulo": "Módulo 4: El Simulador de Vuelo y Práctica Deliberada (Días 8 al 10)",
        "instrucciones": "Aprender teoría sin someterse a la fricción de un entorno realista genera una falsa sensación de maestría. Utiliza esta plantilla para instruir a la IA como un 'Simulador de Vuelo' que cree escenarios profesionales imprevistos, datos defectuosos o situaciones de alta presión donde debas aplicar tu habilidad.",
        "ejemplo": """### Ejemplo Resuelto: Simulador de Crisis para Marta
- **Escenario:** El Director Financiero entra a la oficina a las 18:30. La empresa debe cerrar un crédito bancario a primera hora de mañana y acaban de descubrir que las ventas de una subsidiaria se contabilizaron dos veces en el libro de Excel, distorsionando el flujo de caja en 200.000 USD.
- **Misión de Marta en la Simulación:** Localizar el error de duplicación en menos de 20 minutos usando fórmulas lógicas, reajustar las proyecciones de liquidez y redactar un correo ejecutivo explicando la corrección sin generar pánico.
- **Resultado:** Marta ejecuta el protocolo en el simulador, comete dos errores en la tasa impositiva y la IA le retroalimenta de inmediato para corregir su procedimiento.""",
        "campos": """### Campos de Trabajo: Ficha de Simulación de Vuelo

1. **Habilidad a Simular:** `[Habilidad técnica específica]`
2. **Rol que Asumes en la Simulación:** `[Ej. Consultor Senior / Desarrollador Backend / Director de Operaciones]`
3. **Restricción Crítica del Escenario:** `[Ej. Presión temporal de 15 minutos / Datos con errores / Cliente hostil]`
4. **Respuesta o Solución Ejecutada:** `[Escribe exactamente qué hiciste o qué comando aplicaste]`
5. **Veredicto y Feedback del Simulador IA:** `[Copia los aciertos y las fallas señaladas]`""",
        "prompt_ia": """```markdown
Actúa como el Simulador de Vuelo Profesional más exigente en [INSERTAR DOMINIO].
Quiero poner a prueba mi competencia operativa en: [INSERTAR TEMA].

REGLAS DE LA SIMULACIÓN:
1. Plantéame un escenario real de crisis laboral donde deba tomar decisiones técnicas inmediatas.
2. Incluye datos incompletos o errores sutiles para comprobar si presto atención al detalle.
3. Espera mi respuesta.
4. Cuando yo responda, NO me digas inmediatamente si está bien. Simula la consecuencia operativa de mi decisión (ej. si el sistema colapsó, si el cliente rechazó la propuesta o si el cálculo cuadró).
5. Dame un puntaje sobre 10 y una retroalimentación forense de mis errores.
Lanza el primer escenario de crisis ahora.
```"""
    },
    {
        "filename": "08_PLANTILLA_RUBRICA_PRACTICA_DELIBERADA.md",
        "title": "Plantilla 08: Rúbrica de Práctica Deliberada y Registro de Errores",
        "modulo": "Módulo 4: El Simulador de Vuelo y Práctica Deliberada (Días 8 al 10)",
        "instrucciones": "Anders Ericsson demostró que la repetición ciega no genera pericia; solo la práctica deliberada en el límite de tu capacidad actual produce mejoras medibles. Utiliza esta rúbrica para documentar tus fallos, clasificar su origen (conceptual, procedimental o por descuido) y diseñar un ejercicio específico para erradicarlos.",
        "ejemplo": """### Ejemplo Resuelto: Registro de Errores de Marta
- **Error Cometido:** En la fórmula de proyección de flujo de caja, olvidó bloquear con `$` la celda de la tasa de inflación en la fila 3, lo que arrastró un valor cero en las columnas posteriores.
- **Tipo de Error:** Procedimental / Mecánico (atención dividida).
- **Causa Raíz:** Arrastró la fórmula hacia la derecha antes de verificar con la tecla `F4` las referencias absolutas.
- **Micro-Práctica Deliberada de Corrección:** Escribir a mano 10 fórmulas consecutivas que alternen referencias relativas, mixtas (`$A1` vs `A$1`) y absolutas (`$A$1`) en menos de 2 minutos sin cometer ni un solo desvío.""",
        "campos": """### Cuaderno de Auditoría de Errores Cognitivos

| Fecha / Bloque | Descripción Exacta del Error | Clasificación (Conceptual / Procedimental / Descuido) | Causa Raíz Detectada | Micro-Ejercicio de Corrección Inmediata |
| :--- | :--- | :--- | :--- | :--- |
| `[Día X]` | `[Qué falló exactamente]` | `[Tipo]` | `[Por qué ocurrió]` | `[Cómo lo vas a taladrar]` |
| `[Día Y]` | `[Qué falló exactamente]` | `[Tipo]` | `[Por qué ocurrió]` | `[Cómo lo vas a taladrar]` |""",
        "prompt_ia": """```markdown
Actúa como un Diseñador de Práctica Deliberada (Metodología Anders Ericsson).
Acabo de cometer el siguiente error al intentar resolver un problema en [INSERTAR DOMINIO]:
\"\"\"
[DESCRIBIR EL ERROR QUE COMETISTE Y QUÉ INTENTABAS HACER]
\"\"\"

Tu tarea:
1. Diagnostica la causa raíz profunda del error (¿falta de base teórica, asunción falsa o hábito procedimental defectuoso?).
2. Crea un 'micro-taladro' de 3 ejercicios progresivos diseñados específicamente para sobre-corregir este error en menos de 10 minutos.
```"""
    },
    {
        "filename": "09_PLANTILLA_FLASHCARDS_RECUPERACION_ACTIVA.md",
        "title": "Plantilla 09: Flashcards de Recuperación Activa (Preguntas Ciega)",
        "modulo": "Módulo 5: Blindaje Mnemotécnico y Examen Ciego (Días 11 y 12)",
        "instrucciones": "El 'Testing Effect' (Roediger & Karpicke, 2006) demuestra que evaluar activamente la memoria produce una retención mucho más duradera que releer apuntes. Utiliza este formato de flashcards de doble cara donde el anverso plantee una pregunta operativa o un problema ciego y el reverso contenga el razonamiento lógico.",
        "ejemplo": """### Ejemplo Resuelto: Flashcard Operativa de Marta
- **Anverso (Pregunta Ciega):** "¿Por qué `XLOOKUP` es superior a `VLOOKUP` ante la inserción de una columna a la izquierda en la base de datos?"
- **Reverso (Respuesta Lógica):** "`VLOOKUP` requiere un índice numérico estático de columna (ej. columna 3). Si insertas una columna, el índice 3 apunta a otro dato y la fórmula se rompe. `XLOOKUP` almacena referencias a rangos de celdas independientes (vector de búsqueda y vector de retorno), por lo que Excel ajusta la referencia dinámicamente sin importar cuántas columnas se añadan o muevan."
- **Condición de Éxito:** Responder en voz alta sin titubear en menos de 15 segundos.""",
        "campos": """### Colección de Flashcards Operativas

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
- **Intervalo de Repaso:** `[Día 1 / Día 3 / Día 7 / Día 14]`""",
        "prompt_ia": """```markdown
Actúa como un Especialista en Evaluación Formativa y Retrieval Practice.
He estado estudiando los siguientes temas de [INSERTAR HABILIDAD]:
[INSERTAR LISTA DE TEMAS]

Genera un set de 6 flashcards de recuperación activa de alta fricción:
- Prohibidas preguntas de memoria trivial o definiciones de diccionario.
- Cada tarjeta debe plantear: un caso hipotético, un error de código para diagnosticar o una comparación de rendimiento entre dos alternativas.
- Formato: 
  **ANVERSO:** [Pregunta desafiante]
  **REVERSO:** [Respuesta lógica y concisa]
```"""
    },
    {
        "filename": "10_PLANTILLA_CALENDARIO_REPETICION_ESPACIADA.md",
        "title": "Plantilla 10: Calendario de Repetición Espaciada (Algoritmo SM-2 Adaptado)",
        "modulo": "Módulo 5: Blindaje Mnemotécnico y Examen Ciego (Días 11 y 12)",
        "instrucciones": "Para evitar el colapso de la retención tras finalizar el programa, organiza los repasos en intervalos geométricamente crecientes. Cada repaso debe ser un acto de recuperación ciega (sin mirar el libro antes de empezar). Si recuerdas el concepto con facilidad, doblas el intervalo; si fallas, regresas al día 1.",
        "ejemplo": """### Ejemplo Resuelto: Calendario de Marta
- **Sesión de Repaso 1 (Día +1 tras terminar):** Examen ciego de 10 minutos sobre sintaxis de fórmulas dinámicas -> Retención 100% -> Próximo repaso: Día +3.
- **Sesión de Repaso 2 (Día +4):** Reconstruir la tabla de Power Query sin notas -> Retención 90% -> Próximo repaso: Día +10.
- **Sesión de Repaso 3 (Día +14):** Auditoría del libro financiero de la empresa -> Retención 95% -> Próximo repaso: Día +30.
- **Sesión de Repaso 4 (Día +44):** Mantenimiento mensual consolidado.""",
        "campos": """### Matriz de Repasos Espaciados

| Concepto / Módulo | Repaso R1 (+1 día) | Repaso R2 (+3 días) | Repaso R3 (+7 días) | Repaso R4 (+14 días) | Estado de Consolidación |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `[Módulo 1: Deconstrucción]` | `[Fecha / Estado]` | `[Fecha / Estado]` | `[Fecha / Estado]` | `[Fecha / Estado]` | `[Dominado / En riesgo]` |
| `[Módulo 2: Socrático]` | `[Fecha / Estado]` | `[Fecha / Estado]` | `[Fecha / Estado]` | `[Fecha / Estado]` | `[Dominado / En riesgo]` |
| `[Módulo 3: Feynman]` | `[Fecha / Estado]` | `[Fecha / Estado]` | `[Fecha / Estado]` | `[Fecha / Estado]` | `[Dominado / En riesgo]` |
| `[Módulo 4: Simulador]` | `[Fecha / Estado]` | `[Fecha / Estado]` | `[Fecha / Estado]` | `[Fecha / Estado]` | `[Dominado / En riesgo]` |""",
        "prompt_ia": """```markdown
Actúa como un Optimizador de Memoria Espaciada (Algoritmo SM-2).
Tengo los siguientes 4 bloques de conocimiento que adquirí en mi programa de 14 días:
[INSERTAR BLOQUES]

Genera para mí un calendario de mantenimiento de 30 días con fechas e instrucciones específicas para cada día de repaso, indicándome qué micro-prueba ciega debo realizar en cada intervalo para asegurar la fijación en la memoria a largo plazo.
```"""
    },
    {
        "filename": "11_PLANTILLA_EXAMEN_CIEGO.md",
        "title": "Plantilla 11: Protocolo de Examen Ciego Sin Apuntes",
        "modulo": "Módulo 5: Blindaje Mnemotécnico y Examen Ciego (Día 11)",
        "instrucciones": "El Día 11 debes someterte al examen ciego: una evaluación de 45 a 60 minutos con la computadora desconectada de internet, sin notas, sin apuntes y sin IA abierta. Solo tú, el problema en blanco y tu memoria de trabajo. La IA entra en juego únicamente al final para corregir implacablemente tu entrega.",
        "ejemplo": """### Ejemplo Resuelto: Examen Ciego de Marta
- **Prueba:** Recibir un archivo CSV crudo con 5.000 filas de transacciones bancarias desordenadas y construir un P&L en una hoja limpia de Excel en 35 minutos sin consultar internet.
- **Resultado en Vivo:** Marta logra estructurar el 90% de las fórmulas en 28 minutos. Duda durante 3 minutos en el argumento de ordenación de una fórmula matricial, pero deduce la solución por lógica interna.
- **Auditoría Post-Examen:** La IA confirma que el resultado final coincide exactamente con el balance auditado.""",
        "campos": """### Hoja de Registro del Examen Ciego

1. **Condiciones del Examen:**
   - Hora de inicio: `[HH:MM]` | Hora límite: `[HH:MM]`
   - Materiales permitidos: Ninguno (pantalla en blanco, teclado y memoria)
2. **Desafío Técnico Asignado:**
   `[Enunciado del problema completo que debes resolver]`
3. **Solución Implementada:**
   `[Copia tu código, fórmula, solución o ensayo]`
4. **Puntos de Duda o Vacilación durante la Prueba:**
   `[¿En qué parte sentiste inseguridad o tentación de mirar apuntes?]`
5. **Calificación Final Auditada:** `[Puntaje / 100]`""",
        "prompt_ia": """```markdown
Actúa como un Examinador Ciego de Certificación Técnica Internacional en [INSERTAR DOMINIO].
Diseña un examen práctico de 45 minutos para evaluar si realmente domino: [INSERTAR TEMA].
ESTRUCTURA DEL EXAMEN:
- 3 problemas prácticos de complejidad creciente.
- Cada problema debe requerir la combinación de al menos 2 conceptos distintos.
- Dame los enunciados y los criterios de evaluación, pero NO reveles las soluciones hasta que yo te envíe mis respuestas completas.
```"""
    },
    {
        "filename": "12_PLANTILLA_RUBRICA_EVALUACION_FINAL.md",
        "title": "Plantilla 12: Rúbrica de Evaluación Final del Artefacto Mínimo Viable",
        "modulo": "Módulo 6: El Artefacto Mínimo Viable y Tu Segundo Cerebro (Día 13 y 14)",
        "instrucciones": "No eres competente hasta que no puedes demostrarlo frente a la realidad externa. Utiliza esta rúbrica de 4 dimensiones (Corrección Técnica, Robustez, Transferencia y Autonomía) para calificar tu Artefacto Mínimo Viable y recibir una auditoría objetiva antes de darte por graduado.",
        "ejemplo": """### Ejemplo Resuelto: Rúbrica del Modelo Financiero de Marta
- **Dimensión 1 (Corrección Técnica - 25%):** Las fórmulas matemáticas y balances cuadran al centavo (25/25).
- **Dimensión 2 (Robustez - 25%):** El modelo soporta datos corruptos en el CSV sin arrojar errores no controlados (23/25).
- **Dimensión 3 (Transferencia - 25%):** Un compañero de trabajo pudo usar el archivo sin que Marta tuviera que explicarle nada en persona (24/25).
- **Dimensión 4 (Autonomía de Ejecución - 25%):** Construido 100% de memoria sin ayuda de tutoriales externos (25/25).
- **Puntaje Total:** 97/100 (Aprobación Sobresaliente).""",
        "campos": """### Rúbrica de Evaluación Cuantitativa del AMV

| Dimensión de Maestría | Criterio de Excelencia (25 pts) | Mi Puntaje | Observaciones de la Auditoría Externa |
| :--- | :--- | :--- | :--- |
| **1. Corrección Técnica** | Resuelve el 100% de los requerimientos operativos sin errores lógicos ni sintácticos. | `[ /25]` | `[Detalles]` |
| **2. Robustez y Resiliencia** | No se rompe ante entradas inesperadas, casos extremos o datos imperfectos. | `[ /25]` | `[Detalles]` |
| **3. Transferencia Real** | Funciona en el entorno de producción real y puede ser operado por un tercero. | `[ /25]` | `[Detalles]` |
| **4. Autonomía Demostrada** | El autor puede defender cada línea, decisión y fórmula sin consultar guías. | `[ /25]` | `[Detalles]` |
| **TOTAL CONSOLIDADO** | **Meta de Aprobación Mínima: 80 / 100** | `[ /100]` | **Veredicto: [Aprobado / Re-entrenar]** |""",
        "prompt_ia": """```markdown
Actúa como un Auditor de Calidad de Producto de Nivel Senior.
Voy a presentarte el Artefacto Mínimo Viable que construí en mi programa de 14 días para dominar [INSERTAR HABILIDAD].
Aquí está el artefacto / código / modelo:
\"\"\"
[INSERTAR ARTEFACTO O DESCRIPCIÓN DETALLADA]
\"\"\"

Evalúa mi entregable con la siguiente rúbrica de 4 dimensiones (0 a 25 puntos cada una):
1. Corrección Técnica y Lógica interna.
2. Robustez ante casos extremos y fallas.
3. Usabilidad y transferencia para un usuario final.
4. Nivel de profesionalismo editorial y arquitectónico.
Sé implacable. Dime exactamente qué le falta para ser de grado de producción comercial.
```"""
    },
    {
        "filename": "13_PLANTILLA_SEGUNDO_CEREBRO_DIGITAL.md",
        "title": "Plantilla 13: Arquitectura del Segundo Cerebro (Sistema P.A.R.A. y Zettelkasten)",
        "modulo": "Módulo 6: El Artefacto Mínimo Viable y Tu Segundo Cerebro (Día 14)",
        "instrucciones": "El conocimiento que no se externaliza en un sistema digital estructurado se degrada con el paso de los meses. Organiza tus notas de aprendizaje bajo el método P.A.R.A. (Proyectos, Áreas, Recursos, Archivos) de Tiago Forte y el sistema Zettelkasten de notas atómicas conectadas en tu herramienta favorita (Obsidian, Notion o Markdown local).",
        "ejemplo": """### Ejemplo Resuelto: Bóveda de Obsidian de Marta
- **01_PROYECTOS/Modelo_Financiero_2026:** El proyecto activo con su AMV, cronograma y entregables.
- **02_AREAS/Finanzas_Corporativas:** Notas permanentes sobre normas contables y flujos de caja.
- **03_RECURSOS/CheatSheets_Excel:** Sintaxis atómica de fórmulas dinámicas, trucos de Power Query y atajos de teclado.
- **04_ARCHIVOS/Historial_Sesiones_IA:** Transcripciones crudas de los debates socráticos y prompts guardados para consultas futuras.""",
        "campos": """### Estructura de Carpetas de tu Bóveda de Conocimiento

```text
📁 SEGUNDO_CEREBRO_[HABILIDAD]/
├── 📁 01_PROYECTO_ACTIVO/
│   ├── AMV_Entregable_Final.md
│   └── Cronograma_14_Dias.md
├── 📁 02_AREAS_DE_RESPONSABILIDAD/
│   └── Estandares_Calidad.md
├── 📁 03_RECURSOS_Y_NOTAS_ATOMICAS/
│   ├── [[Nota_Atomica_Concepto_1]].md
│   ├── [[Nota_Atomica_Concepto_2]].md
│   └── Biblioteca_Prompts_Calibrados.md
└── 📁 04_ARCHIVOS_HISTORICOS/
    └── Bitacora_Sesiones_Socraticas.md
```

#### Ficha de Nota Atómica (Zettelkasten)
- **Título de la Nota:** `[[Nombre del concepto atómico]]`
- **Tesis Central (1 párrafo):** `[Qué es y para qué sirve sin jerga]`
- **Ejemplo Mínimo Funcional:** `[Código o caso de uso]`
- **Notas Relacionadas:** `[[Concepto A]]`, `[[Concepto B]]`""",
        "prompt_ia": """```markdown
Actúa como un Arquitecto de Gestión del Conocimiento Personal (Metodologías P.A.R.A. y Zettelkasten).
He completado 14 días aprendiendo: [INSERTAR HABILIDAD].
Tengo estas notas desordenadas de mis sesiones de estudio:
[INSERTAR APUNTES O TEMAS]

Tu tarea:
1. Sintetiza esta información en 3 notas atómicas Zettelkasten interconectadas con enlaces `[[bidireccionales]]`.
2. Asigna cada nota a su carpeta correspondiente del sistema P.A.R.A.
3. Escribe un resumen ejecutivo permanente de 150 palabras que sirva de mapa de navegación para mi Segundo Cerebro.
```"""
    },
    {
        "filename": "14_PLANTILLA_PLAN_MANTENIMIENTO_30_DIAS.md",
        "title": "Plantilla 14: Plan de Mantenimiento de 30 Días Post-Inmersión",
        "modulo": "Módulo 6: El Artefacto Mínimo Viable y Tu Segundo Cerebro (Día 14)",
        "instrucciones": "Completar los 14 días te otorga una competencia funcional sólida, pero la fluidez experta se consolida en las 4 semanas posteriores. Utiliza este plan de mantenimiento para programar 2 sesiones semanales de 30 minutos orientadas a expandir tu artefacto, resolver nuevos casos y blindar tu memoria contra la atrofia cognitiva.",
        "ejemplo": """### Ejemplo Resuelto: Mantenimiento de Marta
- **Semana 1 (Días 15-21):** Extender el modelo de Excel a una segunda empresa del grupo con catálogo de cuentas diferente (Transferencia cercana).
- **Semana 2 (Días 22-28):** Enseñar a un analista junior a usar el modelo durante una sesión de 45 minutos (Efecto Protegido / Docencia activa).
- **Semana 3 (Días 29-35):** Auditoría de velocidad: reconstruir el tablero gerencial en menos de 15 minutos (Automatización fittsiana).
- **Semana 4 (Días 36-44):** Evaluación con la IA sobre un caso de fusión corporativa compleja (Transferencia lejana).""",
        "campos": """### Cuadrante de Mantenimiento de 30 Días

- **Semana 1 (Refuerzo de Transferencia Cercana):**
  - Tarea operativa: `[Aplicar el AMV a un problema gemelo]`
  - Fecha límite: `[Día +7]` | Estado: `[Pendiente / Hecho]`
- **Semana 2 (Enseñanza a Terceros o Documentación):**
  - Tarea operativa: `[Explicar el modelo o escribir un tutorial para un colega]`
  - Fecha límite: `[Día +14]` | Estado: `[Pendiente / Hecho]`
- **Semana 3 (Desafío de Velocidad y Eficiencia):**
  - Tarea operativa: `[Resolver un problema base en la mitad de tiempo]`
  - Fecha límite: `[Día +21]` | Estado: `[Pendiente / Hecho]`
- **Semana 4 (Transferencia Lejana y Casos Atípicos):**
  - Tarea operativa: `[Enfrentar un problema con reglas completamente diferentes]`
  - Fecha límite: `[Día +30]` | Estado: `[Pendiente / Hecho]`""",
        "prompt_ia": """```markdown
Actúa como un Diseñador de Hábitos y Rendimiento Cognitivo a Largo Plazo.
He completado mi inmersión de 14 días en [INSERTAR HABILIDAD].
Quiero evitar a toda costa la curva de atrofia del conocimiento durante el próximo mes dedicando solo 60 minutos por semana.

Diseña mi protocolo de mantenimiento para las semanas 1, 2, 3 y 4:
- 1 desafío semanal de 45 minutos.
- 1 micro-repaso de 15 minutos de recuperación activa.
- Un indicador clave de rendimiento (KPI) semanal para medir si mi fluidez aumentó o decayó.
```"""
    }
]

def generate_kit():
    print(f"Generando las {len(TEMPLATES)} plantillas del Kit Complementario...")
    index_content = ["# KIT COMPLEMENTARIO DE PLANTILLAS Y HERRAMIENTAS INTERACTIVAS\\n\\n",
                     "Este kit forma parte integral de **El Sistema de Aprendizaje Acelerado con IA**. Cada plantilla está diseñada para transformar los principios cognitivos en ejecución práctica inmediata durante tu programa de 14 días.\\n\\n",
                     "## Índice del Kit de 14 Recursos\\n\\n"]
    
    for t in TEMPLATES:
        filepath = OUT_DIR / t["filename"]
        content = f"""# {t["title"]}

> **Módulo Asociado:** {t["modulo"]}  
> **Objetivo:** Facilitar la aplicación inmediata y deliberada de la metodología.

---

## 1. Instrucciones de Uso
{t["instrucciones"]}

---

## 2. Ejemplo Resuelto en un Entorno Real
{t["ejemplo"]}

---

## 3. Hoja de Trabajo y Campos para Completar
{t["campos"]}

---

## 4. Prompt de Asistencia con Inteligencia Artificial
Copia y pega este prompt en tu modelo de lenguaje (ChatGPT, Claude o Gemini) para que actúe como tu tutor o auditor en esta etapa:

{t["prompt_ia"]}
"""
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)
            
        index_content.append(f"- [{t['title']}]({t['filename']}): {t['modulo']}\\n")
        print(f"Creada: {t['filename']}")
        
    # Escribir índice maestro
    with open(OUT_DIR / "README_KIT_COMPLEMENTARIO.md", "w", encoding="utf-8") as f:
        f.writelines(index_content)
    print("Índice README_KIT_COMPLEMENTARIO.md generado con éxito!")

if __name__ == "__main__":
    generate_kit()
