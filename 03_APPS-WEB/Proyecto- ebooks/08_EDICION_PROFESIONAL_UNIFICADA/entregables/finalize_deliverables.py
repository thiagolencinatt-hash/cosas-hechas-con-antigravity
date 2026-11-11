import shutil
from pathlib import Path

BASE_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks")
EDICION_DIR = BASE_DIR / "08_EDICION_PROFESIONAL_UNIFICADA"
ENTREGABLES_DIR = EDICION_DIR / "entregables"

ENTREGABLES_DIR.mkdir(parents=True, exist_ok=True)

# 1. Copiar Manuscrito Markdown
shutil.copy(EDICION_DIR / "manuscrito" / "MANUSCRITO_UNIFICADO_DEFINITIVO.md", 
            ENTREGABLES_DIR / "EL_SISTEMA_DE_APRENDIZAJE_ACELERADO_CON_IA.md")
print("Copiado: Manuscrito Markdown a entregables/")

# 2. Copiar Portada Plana
shutil.copy(EDICION_DIR / "assets" / "portada" / "portada_plana.png",
            ENTREGABLES_DIR / "portada_plana.png")
print("Copiado: Portada plana PNG a entregables/")

# 3. Copiar Mockup 3D
mockup_src = BASE_DIR / "06_ENTREGABLES" / "portada_mockup_3d.jpg"
if mockup_src.exists():
    shutil.copy(mockup_src, ENTREGABLES_DIR / "portada_mockup_3d.jpg")
    print("Copiado: Mockup 3D a entregables/")

# 4. Copiar Bibliografía Completa
shutil.copy(EDICION_DIR / "REGISTRO_DE_FUENTES.md",
            ENTREGABLES_DIR / "REFERENCIAS_BIBLIOGRAFICAS_APA7.md")
print("Copiado: Bibliografía APA 7ª Edición a entregables/")

# 5. Redactar Dossier Comercial Definitivo
dossier_content = """# DOSSIER COMERCIAL Y ESTRATEGIA DE LANZAMIENTO
## EL SISTEMA DE APRENDIZAJE ACELERADO CON IA
### *Un método práctico de 14 días para desarrollar competencias funcionales con inteligencia artificial*

---

## 1. Ficha Técnica del Producto Editorial

- **Título Oficial:** EL SISTEMA DE APRENDIZAJE ACELERADO CON IA
- **Subtítulo Oficial:** Un método práctico de 14 días para desarrollar competencias funcionales con inteligencia artificial
- **Autoría:** Equipo Editorial Multidisciplinar (Ciencias Cognitivas, Pedagogía e Inteligencia Artificial)
- **Formato:** Paquete Digital Multi-formato (PDF de Alta Definición de 59 páginas, DOCX editable con estilos completos, Manuscrito Markdown maestro)
- **Activos Visuales Integrados:** 24 Ilustraciones técnicas originales a color + 9 Diagramas conceptuales vectoriales
- **Kit Complementario:** 14 Plantillas y herramientas de trabajo interactivo (con instrucciones, ejemplos resueltos y prompts de asistencia)
- **Material de Portada:** Portada plana vertical en PNG de alta resolución + Mockup 3D comercial para campañas publicitarias

---

## 2. Propuesta de Valor Única (UVP)

> *"El único sistema editorial y práctico que transforma la inteligencia artificial en un mentor doctoral socrático y sparring de práctica deliberada. En 14 días (336 horas de inmersión focalizada), adquieres una competencia funcional demostrable mediante un Artefacto Mínimo Viable, blindando tu memoria contra el olvido sin trampas, sin cursos pasivos de 40 horas y sin atrofia cognitiva."*

---

## 3. Público Objetivo y Problemas Críticos que Resuelve

### Segmentos Clave de Mercado:
1. **Profesionales en Reconversión y Ascenso:** Empleados y mandos intermedios que necesitan dominar herramientas técnicas (Excel avanzado, Python, Power BI, análisis de datos, finanzas corporativas) en semanas para acceder a promociones laborales o liderar proyectos.
2. **Estudiantes Universitarios y de Oposiciones:** Alumnos desbordados por programas académicos densos (derecho, medicina, ingeniería, economía) que necesitan retener conceptos abstractos y aprobar evaluaciones de alta exigencia sin quemarse (*burnout*).
3. **Autodidactas, Emprendedores y Creadores:** Personas que aprenden de forma autónoma en internet pero sufren el síndrome de abandono crónico en los primeros días debido a la sobrecarga informativa y la falta de evaluación estructurada.

### Los 5 Grandes Dolores Erradicados:
1. **La Parálisis por Infoxicación:** Erradica el consumo errático de decenas de tutoriales desarticulados mediante la deconstrucción quirúrgica del 20% esencial.
2. **El Espejismo de la Relectura Pasiva:** Termina con la ilusión de competencia de quien subraya libros creyendo que sabe; entrena la mente mediante recuperación activa incondicional.
3. **La Complacencia y Adulación de la IA:** Configura a los modelos de lenguaje para que rehúsen dar respuestas directas, forzando el esfuerzo deductivo del estudiante.
4. **La Curva del Olvido de Ebbinghaus:** Evita la evaporación del 80% del conocimiento tras 48 horas mediante algoritmos espaciados de recuperación forzada.
5. **La Falta de Evidencia Tangible:** Garantiza que el aprendizaje culmine en un artefacto real que sobrevive a la auditoría externa en el mercado de trabajo.

---

## 4. Política de Precios Honesta y Benchmarks de Mercado

En estricta observancia del código de ética editorial, este producto no infla su valor percibido con cifras fantasiosas (tales como *"Valor real: $297 USD"*). Presentamos una diferenciación técnica transparente:

### A. Categorías de Fijación de Precios:
1. **Precio Hipotético de Entrada:** **$19,00 a $27,00 USD**  
   Estimación técnica basada en el paquete completo: manual de 6 módulos (59 páginas diagramadas), 24 ilustraciones, 9 diagramas, 14 plantillas interactivas y 13 prompts maestros.
2. **Benchmarks Reales de la Industria:**
   - *Ebooks técnicos convencionales (Amazon Kindle / Leanpub):* $9,99 a $14,99 USD (sin plantillas interactivas ni frameworks de prompts).
   - *Kits de productividad profesional (Gumroad / Lemon Squeezy):* $19,00 a $29,00 USD (estándar para guías con plantillas de Notion/Markdown).
   - *Micro-cursos en video (Udemy / Hotmart):* $29,00 a $49,00 USD (con soporte básico en comunidad).
3. **Precio de Prelanzamiento Recomendado:** **$14,99 USD** (Venta piloto para recolectar métricas de finalización y testimonios reales antes de escalar).

---

## 5. Copywriting para Páginas de Venta y Redes Sociales

### Titulares de Alto Impacto:
- *“Deja de coleccionar cursos de 40 horas que jamás vas a terminar. Construye tu competencia funcional en 14 días.”*
- *“La inteligencia artificial no vino a pensar por ti; vino a ser el profesor más implacable que jamás tuviste.”*
- *“No sabes una habilidad porque la leíste. La sabes porque construiste un artefacto que sobrevive a la realidad.”*

### Estructura de la Oferta (Lo que recibe el cliente):
1. **Ebook Oficial en PDF:** Diagramación editorial comercial a doble cara, tipografía optimizada para lectura prolongada, con 24 ilustraciones a color y 9 diagramas conceptuales.
2. **Ebook Editable en DOCX:** Para profesionales que deseen personalizar el texto, tomar notas o adaptar el método a sus equipos.
3. **Manuscrito Fuente en Markdown:** Totalmente compatible con Obsidian, Notion y sistemas de notas de texto plano.
4. **Kit Complementario de 14 Herramientas:** Plantillas completas en Markdown listas para rellenar, con ejemplos resueltos (caso Marta en Excel, programación y finanzas) y prompts de calibración.
5. **Licencia de Uso Personal Vitalicia:** Actualizaciones perpetuas de los frameworks y prompts conforme evolucionen los modelos de lenguaje.
"""

with open(ENTREGABLES_DIR / "DOSSIER_COMERCIAL.md", "w", encoding="utf-8") as f:
    f.write(dossier_content)
print("Generado: DOSSIER_COMERCIAL.md en entregables/")

