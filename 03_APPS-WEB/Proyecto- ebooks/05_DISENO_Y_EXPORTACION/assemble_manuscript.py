import os
from pathlib import Path

BASE_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks")
MANUSCRITO_DIR = BASE_DIR / "03_MANUSCRITO"
FUENTES_DIR = BASE_DIR / "02_FUENTES"

front_matter = """# EL SISTEMA DE APRENDIZAJE ACELERADO CON IA
## Cómo Dominar Cualquier Tema en Tiempo Récord

**Autoría:** Equipo Editorial Inteligente & Proyecto Ebooks  
**Edición:** Primera Edición Definitiva (2026)  
**Marco Pedagógico:** Metodología de las Cuatro Fases (Preparar, Comprender, Consolidar, Demostrar)  
**Clasificación:** Educación, Psicología Cognitiva, Inteligencia Artificial Aplicada, Productividad Intelectual

---

### Declaración de Rigor Científico y Ética Editorial
Este libro está fundamentado exclusivamente en la psicología cognitiva contemporánea, metaanálisis cuantitativos de efectos aleatorios y la ciencia del aprendizaje autorregulado. No promete milagros pedagógicos ni "maestría sin esfuerzo": el cerebro humano requiere esfuerzo deseable para consolidar esquemas en la memoria a largo plazo. Las herramientas de inteligencia artificial presentadas (ChatGPT, Gemini, NotebookLM) se enfocan como andamiajes socráticos y sparring cognitivo, garantizando siempre la autonomía intelectual del lector.

---

## ÍNDICE GENERAL

- **INTRODUCCIÓN GENERAL:** La Gran Ilusión del Aprendizaje y el Nuevo Paradigma
- **FASE 1: PREPARAR**
  - **Capítulo 1:** De la sobrecarga al enfoque: construí tu ruta de aprendizaje
  - **Capítulo 2:** Aprendé lo importante primero: dominá el mapa del conocimiento
- **FASE 2: COMPRENDER**
  - **Capítulo 3:** Tu tutor personal con IA: comprendé hasta lo que parecía imposible
  - **Capítulo 4:** Aprendé haciendo: transformá la información en habilidades reales
- **FASE 3: CONSOLIDAR**
  - **Capítulo 5:** Recordá lo que aprendés: el sistema de retención inteligente
- **FASE 4: DEMOSTRAR**
  - **Capítulo 6:** Comprobá si realmente aprendiste: evaluaciones sin trampas
  - **Capítulo 7:** Convertí el aprendizaje en un sistema: tu plan de dominio de 30 días
- **CONCLUSIÓN FINAL:** Tu Mente Aumentada: De Aprendiz a Maestro Autónomo
- **BIBLIOGRAFÍA Y REFERENCIAS:** Formato APA 7ª Edición

---
"""

def assemble():
    content = [front_matter]
    
    # Intro
    intro_file = MANUSCRITO_DIR / "INTRODUCCION.md"
    if intro_file.exists():
        content.append(intro_file.read_text(encoding="utf-8"))
        content.append("\n\n---\n\n")
    
    # Chapters 1 to 7
    for i in range(1, 8):
        cap_file = MANUSCRITO_DIR / f"CAPITULO_{i:02d}.md"
        if cap_file.exists():
            content.append(cap_file.read_text(encoding="utf-8"))
            content.append("\n\n---\n\n")
        else:
            print(f"Warning: {cap_file} missing")
            
    # Conclusion
    conc_file = MANUSCRITO_DIR / "CONCLUSION.md"
    if conc_file.exists():
        content.append(conc_file.read_text(encoding="utf-8"))
        content.append("\n\n---\n\n")
        
    # Bibliography
    bib_file = FUENTES_DIR / "REFERENCIAS_BIBLIOGRAFICAS.md"
    if bib_file.exists():
        content.append(bib_file.read_text(encoding="utf-8"))
        
    full_text = "\n".join(content)
    output_path = MANUSCRITO_DIR / "MANUSCRITO_COMPLETO.md"
    output_path.write_text(full_text, encoding="utf-8")
    print(f"Manuscrito completo compilado exitosamente en: {output_path}")
    print(f"Tamaño total: {len(full_text)} caracteres, {len(full_text.splitlines())} líneas.")

if __name__ == "__main__":
    assemble()
