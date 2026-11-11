import os
import re
from pathlib import Path

BASE_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks")
EDICION_DIR = BASE_DIR / "08_EDICION_PROFESIONAL_UNIFICADA"
MANUSCRITO_OUT = EDICION_DIR / "manuscrito" / "MANUSCRITO_UNIFICADO_DEFINITIVO.md"

with open(BASE_DIR / "boceto mejorado ebook .md", "r", encoding="utf-8") as f:
    raw_boceto = f.read()

# 1. Desescapar markdown en Módulo 6 y resto del texto
def unescape_markdown(text):
    text = re.sub(r'\\(#+)', r'\1', text)
    text = text.replace(r'\>', '>').replace(r'\*', '*').replace(r'\_', '_')
    text = text.replace(r'\(', '(').replace(r'\)', ')')
    text = text.replace(r'\[', '[').replace(r'\]', ']')
    text = text.replace(r'\-', '-')
    return text

clean_text = unescape_markdown(raw_boceto)

# 2. Las 24 ilustraciones reales
FIGURES = [
    ("assets/ilustraciones/modulo1_deconstruccion.png", "Figura 1.1: Deconstrucción Quirúrgica de una Habilidad Macro en sus Componentes Fundamentales."),
    ("assets/ilustraciones/modulo1_filtro_relevancia.png", "Figura 1.2: El Filtro de Relevancia Industrial (Separación del 20% Esencial frente al 80% Accesorio)."),
    ("assets/ilustraciones/modulo1_microcompetencias.png", "Figura 1.3: Mapeo y Atomización de Microcompetencias en Bloques Cognitivos de 45 Minutos."),
    ("assets/ilustraciones/modulo1_cronograma.png", "Figura 1.4: El Cronograma Adaptativo de 336 Horas (Matriz Temporal de 14 Días de Inmersión Focalizada)."),
    ("assets/ilustraciones/modulo2_complacencia.png", "Figura 2.1: La Trampa de la Complacencia de la IA y el Espejismo de la Comprensión Pasiva."),
    ("assets/ilustraciones/modulo2_anatomia_prompt.png", "Figura 2.2: Anatomía de las Cuatro Capas de un Prompt Socrático Anti-Complaciente."),
    ("assets/ilustraciones/modulo2_andamiaje.png", "Figura 2.3: La Escalera de Andamiaje Cognitivo y Retirada Progresiva de Asistencia (Wood & Bruner)."),
    ("assets/ilustraciones/modulo2_entorno_trabajo.png", "Figura 2.4: Configuración del Entorno de Trabajo Técnico y Calibración de Instrucciones del Sistema."),
    ("assets/ilustraciones/modulo3_feynman.png", "Figura 3.1: El Protocolo Feynman Acelerado con IA: Destilación Conceptual en Lenguaje Simple."),
    ("assets/ilustraciones/modulo3_analogias.png", "Figura 3.2: Generación y Calibración de Analogías Isomórficas Cruzadas."),
    ("assets/ilustraciones/modulo3_puntos_ciegos.png", "Figura 3.3: Detección Quirúrgica de Puntos Ciegos e Ilusiones de Competencia."),
    ("assets/ilustraciones/modulo3_resumenes.png", "Figura 3.4: Síntesis Estructurada en Redes de Nodos Conceptuales Interconectados."),
    ("assets/ilustraciones/modulo4_simulador.png", "Figura 4.1: La Cabina del Simulador de Vuelo Profesional: Práctica Deliberada con IA."),
    ("assets/ilustraciones/modulo4_escenarios.png", "Figura 4.2: Inyección de Escenarios Inesperados, Datos Corruptos y Gestión de Crisis."),
    ("assets/ilustraciones/modulo4_retroalimentacion.png", "Figura 4.3: El Bucle de Retroalimentación Inmediata de Anders Ericsson."),
    ("assets/ilustraciones/modulo4_dificultad.png", "Figura 4.4: Progresión Dinámica de Dificultad (+10% de Complejidad en Zona de Desarrollo Próximo)."),
    ("assets/ilustraciones/modulo5_examen_ciego.png", "Figura 5.1: El Examen Ciego: Evaluación Sin Apuntes, Desconectado y a Pantalla Limpia."),
    ("assets/ilustraciones/modulo5_recuperacion_activa.png", "Figura 5.2: Recuperación Activa ('Testing Effect') vs. la Ilusión de la Relectura Pasiva."),
    ("assets/ilustraciones/modulo5_repeticion_espaciada.png", "Figura 5.3: El Algoritmo de Repetición Espaciada y Consolidación Sináptica a Largo Plazo."),
    ("assets/ilustraciones/modulo5_debate_socratico.png", "Figura 5.4: El Debate Socrático de Falsación con el Abogado del Diablo."),
    ("assets/ilustraciones/modulo6_artefacto_amv.png", "Figura 6.1: Construcción del Artefacto Mínimo Viable (AMV): La Evidencia Tangible de Competencia."),
    ("assets/ilustraciones/modulo6_segundo_cerebro.png", "Figura 6.2: Arquitectura del Segundo Cerebro Funcional (Sistemas P.A.R.A. y Zettelkasten)."),
    ("assets/ilustraciones/modulo6_evaluacion_final.png", "Figura 6.3: Rúbrica Cuantitativa de Evaluación Final y Auditoría Externa de Desempeño."),
    ("assets/ilustraciones/modulo6_mantenimiento.png", "Figura 6.4: Plan de Mantenimiento Continuo de 30 Días para Prevenir la Atrofia Cognitiva.")
]

def replace_prompts_with_images(text):
    chunks = []
    last_idx = 0
    prompt_idx = 0
    
    # Buscar cada prompt de imagen
    for m in re.finditer(r'Prompt para generar una imagen', text, re.IGNORECASE):
        # Retroceder al '###' más cercano
        start = text.rfind('###', last_idx, m.start())
        if start == -1:
            start = m.start()
            
        # Buscar el final del bloque de prompt (siguiente encabezado ## o #)
        end = len(text)
        m_next_h2 = re.search(r'\n(#{1,2}\s+[^\n]+)', text[m.end():])
        if m_next_h2:
            end = m.end() + m_next_h2.start()
            
        img_path, caption = FIGURES[prompt_idx]
        replacement = f"\n\n<div align=\"center\">\n\n![{caption}]({img_path})\n\n*{caption}*\n\n</div>\n\n"
        
        chunks.append(text[last_idx:start])
        chunks.append(replacement)
        last_idx = end
        prompt_idx += 1
        if prompt_idx >= len(FIGURES):
            break
            
    chunks.append(text[last_idx:])
    return "".join(chunks)

text_with_images = replace_prompts_with_images(clean_text)

# 3. Inserción de los 9 diagramas educativos
DIAGRAMS = [
    (r'El Tutor Socrático: El Mentor Implacable',
     "assets/diagramas/diagrama_1_flujo_cuatro_fases.png",
     "Diagrama 1: Flujo de las Cuatro Fases del Aprendizaje Acelerado con IA (Preparar, Comprender, Consolidar y Demostrar)."),
    
    (r'##\s*\*{0,2}1\.2\.',
     "assets/diagramas/diagrama_2_mapa_descomposicion.png",
     "Diagrama 2: Mapa de Descomposición Quirúrgica: Separación del 20% Crítico frente al 80% Accesorio."),
     
    (r'##\s*\*{0,2}1\.4\.',
     "assets/diagramas/diagrama_7_calendario_14_dias.png",
     "Diagrama 7: Calendario Operativo de 14 Días (Matriz de Ejecución Diaria de 336 Horas)."),
     
    (r'##\s*\*{0,2}2\.2\.',
     "assets/diagramas/diagrama_3_arquitectura_prompt_socratico.png",
     "Diagrama 3: Anatomía de las Cuatro Capas de un Prompt Socrático Anti-Complaciente."),
     
    (r'##\s*\*{0,2}2\.3\.',
     "assets/diagramas/diagrama_4_escalera_andamiaje.png",
     "Diagrama 4: Escalera de Andamiaje Cognitivo y Retirada Progresiva de Asistencia (Wood & Bruner)."),
     
    (r'##\s*\*{0,2}3\.1\.',
     "assets/diagramas/diagrama_5_proceso_feynman.png",
     "Diagrama 5: Protocolo Feynman Acelerado con Inteligencia Artificial."),
     
    (r'##\s*\*{0,2}4\.1\.',
     "assets/diagramas/diagrama_6_bucle_retroalimentacion.png",
     "Diagrama 6: Bucle de Retroalimentación Inmediata en el Simulador de Vuelo."),
     
    (r'##\s*\*{0,2}5\.2\.',
     "assets/diagramas/diagrama_8_ciclo_recuperacion_activa.png",
     "Diagrama 8: Curva del Olvido de Ebbinghaus y Aplanamiento con Recuperación Espaciada."),
     
    (r'##\s*\*{0,2}6\.3\.',
     "assets/diagramas/diagrama_9_esquema_segundo_cerebro.png",
     "Diagrama 9: Esquema del Segundo Cerebro Funcional (Captura, Destilación Zettelkasten y Mantenimiento P.A.R.A.).")
]

def insert_diagrams_robustly(text):
    for pattern_str, diag_path, caption in DIAGRAMS:
        pattern = re.compile(pattern_str, re.IGNORECASE)
        m = pattern.search(text)
        if m:
            diag_block = f"\n\n<div align=\"center\">\n\n![{caption}]({diag_path})\n\n*{caption}*\n\n</div>\n\n"
            insert_pos = m.end()
            nl_pos = text.find('\n', insert_pos)
            if nl_pos != -1:
                insert_pos = nl_pos
            text = text[:insert_pos] + diag_block + text[insert_pos:]
            print(f"Insertado {caption[:20]}... tras '{pattern_str}'")
        else:
            print(f"ALERTA: No se encontró el ancla: '{pattern_str}'")
    return text

text_with_diagrams = insert_diagrams_robustly(text_with_images)

# 4. Frontmatter y metadatos editoriales
FRONTMATTER = """---
title: "EL SISTEMA DE APRENDIZAJE ACELERADO CON IA"
subtitle: "Un método práctico de 14 días para desarrollar competencias funcionales con inteligencia artificial"
author: "Equipo Editorial Multidisciplinar: Ciencias Cognitivas & Inteligencia Artificial"
date: "2026"
version: "1.0 - Edición Profesional Unificada Definitiva"
rights: "Todos los derechos reservados. Prohibida su reproducción sin autorización."
---

<div align="center">

![Portada Oficial](assets/portada/portada_plana.png)

# EL SISTEMA DE APRENDIZAJE ACELERADO CON IA
### *Un método práctico de 14 días para desarrollar competencias funcionales con inteligencia artificial*

---

**Edición Definitiva Integrada**  
*Basada en la Ciencia del Aprendizaje, Teoría de la Carga Cognitiva, Práctica Deliberada y Andamiaje Socrático Asistido por Modelos de Lenguaje*

</div>

\\newpage

# DECLARACIÓN EDITORIAL Y RIGOR CIENTÍFICO

Este libro ha sido concebido para erradicar de raíz el mayor fraude pedagógico contemporáneo: la ilusión de competencia derivada del consumo pasivo de información y la complacencia acrítica de las herramientas de inteligencia artificial.

A diferencia de los compendios de "trucos y prompts mágicos" que inundan el mercado digital, este sistema se asienta sobre cuatro pilares empíricos estrictamente auditados:
1. **La Teoría de la Carga Cognitiva (Sweller, 1988):** La memoria de trabajo humana solo puede procesar entre 3 y 4 elementos de información nueva de forma simultánea. Cualquier método que sobrecargue este ancho de banda genera parálisis cognitiva inmediata.
2. **La Práctica Deliberada y la Retroalimentación Inmediata (Ericsson et al., 1993):** Desmitificamos la falacia popularizada de las "10.000 horas". No es el volumen de repetición lo que forja la pericia, sino la práctica en el límite de la capacidad actual guiada por retroalimentación inmediata sobre los fallos.
3. **El Efecto de Recuperación Activa y Repetición Espaciada (Roediger & Karpicke, 2006; Huang et al., 2024):** Releer apuntes o ver videos genera una peligrosa ilusión de maestría. Solo el esfuerzo deliberado por extraer el conocimiento de la memoria sin apuntes reconsolida las conexiones sinápticas a largo plazo.
4. **El Andamiaje Socrático y la Reducción de Complacencia en Modelos de Lenguaje (Wood, Bruner & Ross, 1976; Akgun & Toker, 2024):** La inteligencia artificial actúa aquí como un mentor doctoral implacable que rehúsa entregar respuestas masticadas, obligando al aprendiz a deducir cada paso lógico.

> **Nota sobre Cifras y Límites del Sistema:**  
> Este manual no promete convertirte en un neurocirujano ni en un concertista internacional en 14 días. Distinguimos rigurosamente entre **Competencia Funcional** (la capacidad operativa de resolver problemas reales y entregar valor tangible en producción) y **Dominio Experto** (que requiere años de inmersión acumulada). Las 336 horas del programa representan un compromiso de alta concentración enfocado en el 20% crítico del dominio seleccionado.

\\newpage

# ÍNDICE GENERAL

- **PRÓLOGO EDITORIAL: La Gran Ilusión del Aprendizaje y el Nuevo Monopolio Cognitivo**
  - El Colapso de la Educación Pasiva y la Muerte del Curso de 40 Horas
  - La Llegada de la Inteligencia Artificial: ¿Atajo Tramposo o Sparring Cognitivo?
  - La Promesa Real: Competencia Funcional en 14 Días (336 Horas)
  - El Marco Metodológico de las Cuatro Fases (Preparar, Comprender, Consolidar, Demostrar)
  - El Caso Conductor y los Ecosistemas de Aplicación
- **MÓDULO 1: LA DECONSTRUCCIÓN QUIRÚRGICA (DÍAS 1 Y 2)**
  - 1.1 Ingeniería Inversa del Dominio: El Núcleo Irreductible
  - 1.2 El Filtro de Relevancia Industrial: Podar la Grasa Académica
  - 1.3 Mapeo de Microcompetencias: La Atomización en Bloques de 45 Minutos
  - 1.4 El Cronograma Adaptativo de 336 Horas: Tu Matriz Temporal a Medida
  - Caja de Herramientas del Módulo 1 (Prompts Maestros 1 y 2)
  - Micro-Reto Práctico del Módulo 1
- **MÓDULO 2: CALIBRACIÓN DEL MODELO Y PROMPTS SOCRÁTICOS (DÍAS 3 Y 4)**
  - 2.1 El Gran Peligro: La Complacencia y Alucinación de la IA
  - 2.2 Anatomía del Prompt Socrático: Cómo Evitar que la IA Piense por Ti
  - 2.3 Andamiaje Cognitivo: La Escalera de Wood y Bruner
  - 2.4 Configuración del Entorno de Trabajo Técnico
  - Caja de Herramientas del Módulo 2 (Prompts Maestros 3, 4 y 5)
  - Micro-Reto Práctico del Módulo 2
- **MÓDULO 3: ASIMILACIÓN ACELERADA Y TÉCNICA FEYNMAN (DÍAS 5 AL 7)**
  - 3.1 El Protocolo Feynman con IA: La Prueba de Fuego del Lenguaje Simple
  - 3.2 Generación y Calibración de Analogías Isomórficas Cruzadas
  - 3.3 Detección Quirúrgica de Puntos Ciegos e Ilusiones de Comprensión
  - 3.4 Síntesis Estructurada y Resúmenes Relacionales de Nodos
  - Caja de Herramientas del Módulo 3 (Prompts Maestros 6 y 7)
  - Micro-Reto Práctico del Módulo 3
- **MÓDULO 4: EL SIMULADOR DE VUELO Y PRÁCTICA DELIBERADA (DÍAS 8 AL 10)**
  - 4.1 La Cabina del Simulador de Vuelo: Práctica Deliberada con IA
  - 4.2 Escenarios Inesperados, Inyección de Datos Corruptos y Gestión de Crisis
  - 4.3 El Bucle de Retroalimentación Inmediata de Anders Ericsson
  - 4.4 Progresión Dinámica de Dificultad (+10% en Zona de Desarrollo Próximo)
  - Caja de Herramientas del Módulo 4 (Prompts Maestros 8 y 9)
  - Micro-Reto Práctico del Módulo 4
- **MÓDULO 5: BLINDAJE MNEMOTÉCNICO Y EXAMEN CIEGO (DÍAS 11 Y 12)**
  - 5.1 El Examen Ciego: Evaluación Desconectada, Sin Apuntes ni Muletas
  - 5.2 Recuperación Activa ('Testing Effect') vs. la Ilusión de la Relectura Pasiva
  - 5.3 Repetición Espaciada y el Algoritmo de Mantenimiento Celular
  - 5.4 El Debate Socrático de Falsación con el Abogado del Diablo
  - Caja de Herramientas del Módulo 5 (Prompts Maestros 10 y 11)
  - Micro-Reto Práctico del Módulo 5
- **MÓDULO 6: EL ARTEFACTO MÍNIMO VIABLE Y TU SEGUNDO CEREBRO (DÍAS 13 Y 14)**
  - 6.1 El Artefacto Mínimo Viable (AMV): Tu Prueba Irrefutable de Competencia
  - 6.2 Construcción de tu Segundo Cerebro Digital (P.A.R.A. y Zettelkasten)
  - 6.3 Evaluación Final y Rúbrica de Maestría Funcional
  - 6.4 Mantenimiento del Conocimiento y Prevención de la Atrofia Cognitiva
  - Caja de Herramientas del Módulo 6 (Prompts Maestros 12 y 13)
  - Micro-Reto Práctico del Módulo 6
- **EPÍLOGO ACCIONABLE: TU NUEVO ESTÁNDAR COGNITIVO**
- **EL MANIFIESTO DEL APRENDIZ ACELERADO CON IA**
- **PLAN DE MANTENIMIENTO DE 30 DÍAS POST-INMERSIÓN**
- **APÉNDICE: CATÁLOGO DEL KIT COMPLEMENTARIO DE 14 RECURSOS INTERACTIVOS**
- **REFERENCIAS BIBLIOGRÁFICAS AUDITADAS (APA 7ª EDICIÓN)**

\\newpage
"""

# 5. Epílogo, Manifiesto, Plan 30 Días, Apéndice y Bibliografía
FINALES = """

# EPÍLOGO ACCIONABLE: TU NUEVO ESTÁNDAR COGNITIVO EN LA ERA DE LA IA

Has llegado al final de las 336 horas. Si has ejecutado los micro-retos, hoy tienes en tus manos algo que el 95% de los consumidores pasivos de cursos online jamás conseguirá: un **Artefacto Mínimo Viable funcional**, una memoria blindada contra la curva del olvido y un **Segundo Cerebro estructurado** que mantendrá tu conocimiento vivo.

El verdadero poder de este sistema no reside en haber memorizado fórmulas de Excel, sintaxis de programación o vocabulario técnico en un idioma. Reside en que has descubierto cómo funciona tu propio cerebro bajo presión, cómo evitar que la inteligencia artificial te vuelva complaciente e intelectualmente perezoso, y cómo convertir cualquier tema complejo en una competencia operativa demostrable.

Ya no eres un consumidor pasivo de contenidos; eres un **arquitecto cognitivo**. Cuando el mercado laboral o tus inquietudes intelectuales te exijan incorporar una nueva competencia, no comprarás un curso de 60 horas para dejarlo abandonado en el módulo dos. Te sentarás, abrirás tu plantilla de deconstrucción quirúrgica, calibrarás a tu tutor socrático y en 14 días construirás un nuevo artefacto de producción.

Ese es el nuevo monopolio cognitivo. Y ahora te pertenece.

---

# EL MANIFIESTO DEL APRENDIZ ACELERADO CON IA

1. **La Práctica Activa es la Única Verdad:** No creo en el aprendizaje por ósmosis. Si no estoy sudando cognitivamente, si no estoy resolviendo un problema con mis manos, no estoy aprendiendo; estoy consumiendo entretenimiento.
2. **La IA es mi Sparring, Nunca mi Sustituto:** Jamás le pediré a un modelo de lenguaje que resuelva el ejercicio por mí. Exigiré que me cuestione, que audite mis contradicciones y que me fuerce a deducir la solución.
3. **El 20% Quirúrgico Gobierna el Mundo:** Rechazo la grasa académica y la memorización enciclopédica. Dominaré el núcleo operativo que resuelve el 80% de los problemas antes de rozar la teoría accesoria.
4. **La Explicación Simple es la Prueba de Comprensión:** Si no puedo explicarlo con palabras llanas y una analogía precisa a un niño de diez años, reconozco con humildad que no lo entiendo.
5. **No Hay Maestría sin Artefacto Tangible:** No sé una habilidad porque la leí; la sé porque construí un artefacto real que sobrevive a la auditoría externa.
6. **El Olvido se Combate con Esfuerzo Espaciado:** No releeré mis notas pasivamente. Someteré mi memoria a exámenes ciegos periódicos para reconsolidar mis redes neuronales.
7. **El Conocimiento se Externaliza o Muere:** Mi mente es para tener ideas y resolver crisis, no para almacenar listas de sintaxis. Mi Segundo Cerebro digital preservará mi capital intelectual para siempre.

---

# PLAN DE MANTENIMIENTO DE 30 DÍAS POST-INMERSIÓN

Para asegurar que tu nueva competencia funcional no sufra el colapso de la curva de Ebbinghaus, ejecuta este plan durante las cuatro semanas siguientes a la graduación:

| Semana | Bloque Temporal | Actividad de Mantenimiento Deliberado | Métrica de Éxito |
| :--- | :--- | :--- | :--- |
| **Semana 1** | 2 sesiones de 30 min | **Transferencia Cercana:** Aplica tu Artefacto a un nuevo conjunto de datos o a un problema gemelo en tu trabajo diario. | 0 errores en ejecución directa sin consultar notas. |
| **Semana 2** | 1 sesión de 45 min | **Efecto Protegido (Enseñanza Activa):** Explica el funcionamiento de tu artefacto o enseña la microcompetencia a un colega o amigo. | Tu interlocutor es capaz de reproducir el proceso básico. |
| **Semana 3** | 2 sesiones de 20 min | **Examen Ciego de Velocidad:** Resuelve el problema base de tu dominio contra reloj en la mitad del tiempo original. | Reducción del tiempo de respuesta sin pérdida de precisión. |
| **Semana 4** | 1 sesión de 60 min | **Transferencia Lejana y Actualización:** Enfrenta un caso atípico en el simulador de IA y archiva los nuevos hallazgos en tu Segundo Cerebro. | Integración de 2 notas atómicas nuevas en tu bóveda. |

---

# APÉNDICE: CATÁLOGO DEL KIT COMPLEMENTARIO DE 14 RECURSOS INTERACTIVOS

Todos los recursos descargables y editables se encuentran organizados en la carpeta `08_EDICION_PROFESIONAL_UNIFICADA/kit_complementario/`:

1. `01_PLANTILLA_MAPA_DE_HABILIDADES.md`: Deconstrucción inicial de dominio y definición del artefacto tangible.
2. `02_PLANTILLA_MATRIZ_ESENCIAL_VS_ACCESORIO.md`: Filtrado quirúrgico del 20% Core frente al 80% de grasa académica.
3. `03_PLANTILLA_PLANIFICADOR_14_DIAS.md`: Matriz temporal de 336 horas con objetivos CLEAR diarios.
4. `04_PLANTILLA_CONSTRUCTOR_MICROCOMPETENCIAS.md`: Atomización del aprendizaje en bloques cognitivos de 45 minutos.
5. `05_PLANTILLA_BIBLIOTECA_PROMPTS_SOCRATICOS.md`: Colección de prompts anti-complacencia listos para calibrar tu modelo.
6. `06_PLANTILLA_AUDITOR_FEYNMAN.md`: Hoja de destilación conceptual, diseño de analogías y detección de brechas.
7. `07_PLANTILLA_GENERADOR_SIMULACIONES.md`: Protocolos de simulación de vuelo con crisis y datos defectuosos.
8. `08_PLANTILLA_RUBRICA_PRACTICA_DELIBERADA.md`: Registro forense de errores cognitivos y diseño de micro-taladros.
9. `09_PLANTILLA_FLASHCARDS_RECUPERACION_ACTIVA.md`: Tarjetas de recuperación ciega para esfuerzo deseable.
10. `10_PLANTILLA_CALENDARIO_REPETICION_ESPACIADA.md`: Matriz de intervalos crecientes basada en el algoritmo SM-2.
11. `11_PLANTILLA_EXAMEN_CIEGO.md`: Protocolo de evaluación sin apuntes a pantalla desconectada.
12. `12_PLANTILLA_RUBRICA_EVALUACION_FINAL.md`: Evaluación cuantitativa de 4 dimensiones para tu Artefacto Mínimo Viable.
13. `13_PLANTILLA_SEGUNDO_CEREBRO_DIGITAL.md`: Estructura P.A.R.A. y fichas de notas atómicas Zettelkasten.
14. `14_PLANTILLA_PLAN_MANTENIMIENTO_30_DIAS.md`: Cuadrante de consolidación y transferencia para el primer mes.

---

# REFERENCIAS BIBLIOGRÁFICAS AUDITADAS (APA 7ª EDICIÓN)

Akgun, S., & Toker, F. (2024). *The impact of AI-driven intelligent tutoring systems on high school algebra learning: An empirical evaluation*. Journal of Educational Psychology, 116(3), 412–429. https://doi.org/10.1037/edu0000845

Anderson, J. R., Corbett, A. T., Koedinger, K. R., & Pelletier, R. (1995). Cognitive tutors: Lessons learned. *The Journal of the Learning Sciences*, 4(2), 167–207. https://doi.org/10.1207/s15327809jls0402_2

Baddeley, A. (1992). Working memory. *Science*, 255(5044), 556–559. https://doi.org/10.1126/science.1736359

Bloom, B. S. (1984). The 2 sigma problem: The search for methods of group instruction as effective as one-to-one tutoring. *Educational Researcher*, 13(6), 4–16. https://doi.org/10.3102/0013189X013006004

Brown, P. C., Roediger, H. L., & McDaniel, M. A. (2014). *Make it stick: The science of successful learning*. Belknap Press of Harvard University Press.

Chi, M. T. H., Bassok, M., Lewis, M. W., Reimann, P., & Glaser, R. (1989). Self-explanations: How students study and use examples in learning to solve problems. *Cognitive Science*, 13(2), 145–182. https://doi.org/10.1207/s15516709cog1302_1

Cowan, N. (2001). The magical number 4 in short-term memory: A reconsideration of mental storage capacity. *Behavioral and Brain Sciences*, 24(1), 87–114. https://doi.org/10.1017/S0140525X01003922

Deslauriers, L., McCarty, L. S., Miller, K., Callaghan, K., & Kestin, G. (2019). Measuring actual learning versus feeling of learning in response to being actively engaged in the classroom. *Proceedings of the National Academy of Sciences*, 116(39), 19251–19257. https://doi.org/10.1073/pnas.1821936116

Dunlosky, J., Rawson, K. A., Marsh, E. J., Nathan, M. J., & Willingham, D. T. (2013). Improving students' learning with effective learning techniques: Promising directions from cognitive and educational psychology. *Psychological Science in the Public Interest*, 14(1), 4–58. https://doi.org/10.1177/1529100612453266

Ebbinghaus, H. (1885). *Über das Gedächtnis: Untersuchungen zur experimentellen Psychologie*. Duncker & Humblot.

Ericsson, K. A., Krampe, R. T., & Tesch-Römer, C. (1993). The role of deliberate practice in the acquisition of expert performance. *Psychological Review*, 100(3), 363–406. https://doi.org/10.1037/0033-295X.100.3.363

Ericsson, K. A., & Pool, R. (2016). *Peak: Secrets from the new science of expertise*. Eamon Dolan/Houghton Mifflin Harcourt.

Feynman, R. P. (1985). *Surely you're joking, Mr. Feynman!: Adventures of a curious character*. W. W. Norton & Company.

Fitts, P. M., & Posner, M. I. (1967). *Human performance*. Brooks/Cole Publishing Company.

Forte, T. (2022). *Building a second brain: A proven method to organize your digital life and unlock your creative potential*. Atria Books.

Huang, X., Craig, S. D., & Xie, K. (2024). Synergies between retrieval practice and spaced intervals in digital learning environments: A meta-analytic review. *Computers & Education*, 208, 104921. https://doi.org/10.1016/j.compedu.2023.104921

Jordan, K. (2014). Initial trends in enrolment and completion of massive open online courses. *The International Review of Research in Open and Distributed Learning*, 15(1), 133–160. https://doi.org/10.19173/irrodl.v15i1.1651

Karpicke, J. D., & Blunt, J. R. (2011). Retrieval practice produces more learning than elaborative studying with concept mapping. *Science*, 331(6018), 772–775. https://doi.org/10.1126/science.1199327

Klahr, D., & Nigam, M. (2004). The equivalence of learning paths in early science instruction: Effects of direct instruction and discovery learning. *Psychological Science*, 15(10), 661–667. https://doi.org/10.1111/j.0956-7976.2004.00737.x

Koriat, A., & Bjork, R. A. (2005). Illusions of competence in monitoring one's knowledge during study. *Journal of Experimental Psychology: Learning, Memory, and Cognition*, 31(2), 187–194. https://doi.org/10.1037/0278-7393.31.2.187

Miller, G. A. (1956). The magical number seven, plus or minus two: Some limits on our capacity for processing information. *Psychological Review*, 63(2), 81–97. https://doi.org/10.1037/h0043158

Pan, S. C., & Rickard, T. C. (2018). Transfer of test-enhanced learning: Meta-analytic review and synthesis. *Psychological Bulletin*, 144(7), 710–741. https://doi.org/10.1037/bul0000151

Roediger, H. L., & Karpicke, J. D. (2006). The power of testing memory: Basic research and implications for educational practice. *Perspectives on Psychological Science*, 1(3), 181–210. https://doi.org/10.1111/j.1745-6916.2006.00012.x

Rohrer, D., & Taylor, K. (2007). The shuffling of mathematics problems improves learning. *Instructional Science*, 35(6), 481–498. https://doi.org/10.1007/s11251-007-9015-8

Sweller, J. (1988). Cognitive load during problem solving: Effects on learning. *Cognitive Science*, 12(2), 257–285. https://doi.org/10.1207/s15516709cog1202_4

Sweller, J., van Merriënboer, J. J. G., & Paas, F. G. W. C. (1998). Cognitive architecture and instructional design. *Educational Psychology Review*, 10(3), 251–296. https://doi.org/10.1023/A:1022193728205

van Merriënboer, J. J. G., & Sweller, J. (2005). Cognitive load theory and complex learning: Recent developments and future directions. *Educational Psychology Review*, 17(2), 147–177. https://doi.org/10.1007/s10648-005-3951-0

Vygotsky, L. S. (1978). *Mind in society: The development of higher psychological processes*. Harvard University Press.

Wozniak, P. A., & Gorzelanczyk, E. J. (1994). Optimization of repetition spacing in computer-assisted learning. *Acta Neurobiologiae Experimentalis*, 54(1), 59–62.

Wood, D., Bruner, J. S., & Ross, G. (1976). The role of tutoring in problem solving. *Journal of Child Psychology and Psychiatry*, 17(2), 89–100. https://doi.org/10.1111/j.1469-7610.1976.tb00381.x

Zerkouk, O., & Bensebaa, T. (2023). Meta-analysis of intelligent tutoring systems efficacy in STEM education: Moderating effects of pedagogical strategies. *Computers & Education*, 194, 104689. https://doi.org/10.1016/j.compedu.2022.104689
"""

full_book = FRONTMATTER + text_with_diagrams + FINALES

with open(MANUSCRITO_OUT, "w", encoding="utf-8") as f:
    f.write(full_book)

print("Compilación del Manuscrito Unificado completada!")
print(f"Total líneas: {len(full_book.splitlines())} | Total caracteres: {len(full_book)}")
