import os
from pathlib import Path
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

BASE_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks")
MANUSCRITO_DIR = BASE_DIR / "03_MANUSCRITO"
OUTPUT_DIR = BASE_DIR / "06_ENTREGABLES"
COVER_IMAGE = OUTPUT_DIR / "portada_mockup_3d.jpg"

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    tcPr.append(parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>'))

def set_cell_margins(cell, top=140, bottom=140, left=180, right=180):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def add_callout_box(doc, text, box_type="info", title=""):
    table = doc.add_table(rows=1, cols=1)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    
    cell = table.cell(0, 0)
    cell.width = Inches(6.5)
    
    # Colors
    if box_type == "evidence":
        fill = "EFF6FF"
        border_color = "2563EB" # Blue
        default_title = "EVIDENCIA CIENTÍFICA VERIFICADA"
    elif box_type == "prompt":
        fill = "F8FAFC"
        border_color = "7C3AED" # Purple
        default_title = "PROMPT LISTO PARA COPIAR"
    elif box_type == "warning":
        fill = "FEF2F2"
        border_color = "DC2626" # Red
        default_title = "ALERTA Y TRAMPA COGNITIVA"
    elif box_type == "summary":
        fill = "F0FDF4"
        border_color = "16A34A" # Green
        default_title = "PARA RECORDAR EN 60 SEGUNDOS"
    else:
        fill = "F1F5F9"
        border_color = "475569" # Slate
        default_title = "INFORMACIÓN CLAVE"
        
    set_cell_background(cell, fill)
    set_cell_margins(cell, top=140, bottom=140, left=200, right=180)
    
    # Left border only
    tcPr = cell._tc.get_or_add_tcPr()
    borders = parse_xml(f'''
        <w:tcBorders {nsdecls("w")}>
            <w:top w:val="none"/>
            <w:left w:val="single" w:sz="36" w:space="0" w:color="{border_color}"/>
            <w:bottom w:val="none"/>
            <w:right w:val="none"/>
        </w:tcBorders>
    ''')
    tcPr.append(borders)
    
    p = cell.paragraphs[0]
    p.paragraph_format.space_before = Pt(4)
    p.paragraph_format.space_after = Pt(4)
    p.paragraph_format.line_spacing = 1.15
    
    actual_title = title if title else default_title
    r_title = p.add_run(f"■ {actual_title}\n")
    r_title.bold = True
    r_title.font.name = "Arial"
    r_title.font.size = Pt(10)
    if box_type == "evidence":
        r_title.font.color.rgb = RGBColor(37, 99, 235)
    elif box_type == "prompt":
        r_title.font.color.rgb = RGBColor(124, 58, 237)
    elif box_type == "warning":
        r_title.font.color.rgb = RGBColor(220, 38, 38)
    elif box_type == "summary":
        r_title.font.color.rgb = RGBColor(22, 163, 74)
        
    r_body = p.add_run(text.strip())
    r_body.font.name = "Consolas" if box_type == "prompt" else "Calibri"
    r_body.font.size = Pt(9.5) if box_type == "prompt" else Pt(10)
    r_body.font.color.rgb = RGBColor(30, 41, 59)
    
    doc.add_paragraph().paragraph_format.space_after = Pt(6)

def build_docx():
    doc = Document()
    
    # Page setup (Letter, 1 inch margins)
    for section in doc.sections:
        section.top_margin = Inches(1)
        section.bottom_margin = Inches(1)
        section.left_margin = Inches(1)
        section.right_margin = Inches(1)
        section.different_first_page_header_footer = True
        
        # Header / Footer
        header = section.header
        hp = header.paragraphs[0]
        hp.text = "El Sistema de Aprendizaje Acelerado con IA | Guía Maestra"
        hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        hp.runs[0].font.name = "Arial"
        hp.runs[0].font.size = Pt(8.5)
        hp.runs[0].font.color.rgb = RGBColor(148, 163, 184)
        
        footer = section.footer
        fp = footer.paragraphs[0]
        fp.text = "Primera Edición 2026 — Edición Oficial para Autodidactas y Profesionales"
        fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
        fp.runs[0].font.name = "Arial"
        fp.runs[0].font.size = Pt(8.5)
        fp.runs[0].font.color.rgb = RGBColor(148, 163, 184)

    # 1. PORTADA
    p_title_top = doc.add_paragraph()
    p_title_top.paragraph_format.space_before = Pt(36)
    p_title_top.paragraph_format.space_after = Pt(12)
    p_title_top.alignment = WD_ALIGN_PARAGRAPH.CENTER
    
    r_super = p_title_top.add_run("MANUAL DEFINITIVO DE PRODUCTIVIDAD COGNITIVA\n")
    r_super.font.name = "Arial"
    r_super.font.size = Pt(11)
    r_super.font.bold = True
    r_super.font.color.rgb = RGBColor(37, 99, 235) # Electric Blue
    
    r_title = p_title_top.add_run("EL SISTEMA DE APRENDIZAJE ACELERADO CON IA\n")
    r_title.font.name = "Arial"
    r_title.font.size = Pt(26)
    r_title.font.bold = True
    r_title.font.color.rgb = RGBColor(15, 23, 42) # Dark Navy
    
    r_sub = p_title_top.add_run("Cómo Dominar Cualquier Tema en Tiempo Récord")
    r_sub.font.name = "Arial"
    r_sub.font.size = Pt(16)
    r_sub.font.color.rgb = RGBColor(124, 58, 237) # Violet
    
    if COVER_IMAGE.exists():
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(18)
        p_img.paragraph_format.space_after = Pt(24)
        doc.add_picture(str(COVER_IMAGE), width=Inches(3.4))
        p_img = doc.paragraphs[-1]
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        
    p_meta = doc.add_paragraph()
    p_meta.paragraph_format.space_before = Pt(18)
    p_meta.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r_meta = p_meta.add_run("Equipo Editorial Inteligente & Proyecto Ebooks\nPrimera Edición — 2026")
    r_meta.font.name = "Arial"
    r_meta.font.size = Pt(10)
    r_meta.font.color.rgb = RGBColor(100, 116, 139)
    
    doc.add_page_break()

    # 2. FICHA LEGAL Y DECLARACIÓN
    p_legal = doc.add_paragraph()
    p_legal.paragraph_format.space_before = Pt(24)
    r_leg_title = p_legal.add_run("Ficha Técnica y Ética Editorial\n")
    r_leg_title.bold = True
    r_leg_title.font.name = "Arial"
    r_leg_title.font.size = Pt(13)
    r_leg_title.font.color.rgb = RGBColor(15, 23, 42)
    
    p_leg_body = doc.add_paragraph()
    p_leg_body.paragraph_format.line_spacing = 1.2
    r_leg_body = p_leg_body.add_run(
        "Título: El Sistema de Aprendizaje Acelerado con IA: Cómo Dominar Cualquier Tema en Tiempo Récord.\n"
        "Edición: 1ª Edición Definitiva, 2026.\n"
        "Marco Pedagógico: Cuatro Fases (Preparar, Comprender, Consolidar, Demostrar).\n"
        "Auditoría Epistemológica: Verificación estricta de fuentes científicas (APA 7ª Ed.).\n\n"
        "Declaración de Responsabilidad: Este libro combina hallazgos empíricos de psicología cognitiva y "
        "diseño instruccional con las capacidades contemporáneas de la inteligencia artificial generativa. "
        "No promete 'maestría sin esfuerzo': la biología cerebral exige un 'esfuerzo deseable' para construir esquemas duraderos. "
        "El objetivo es maximizar la eficiencia y la autonomía del estudiante."
    )
    r_leg_body.font.name = "Calibri"
    r_leg_body.font.size = Pt(10)
    r_leg_body.font.color.rgb = RGBColor(71, 85, 105)
    
    doc.add_page_break()

    # 3. LEER MANUSCRITO Y GENERAR CAPÍTULOS CON PARSER POR BLOQUES
    manuscrito_file = MANUSCRITO_DIR / "MANUSCRITO_COMPLETO.md"
    raw_lines = manuscrito_file.read_text(encoding="utf-8").splitlines()
    
    i = 0
    n = len(raw_lines)
    
    while i < n:
        line = raw_lines[i]
        stripped = line.strip()
        
        # Ignorar líneas vacías y saltos de sección markdown
        if not stripped or stripped == "---":
            i += 1
            continue
            
        # 1. BLOQUES DE CITAS / PROMPTS INDENTADOS (> ...)
        if stripped.startswith(">"):
            quote_lines = []
            while i < n:
                curr_stripped = raw_lines[i].strip()
                if curr_stripped.startswith(">"):
                    content = curr_stripped[1:].strip()
                    quote_lines.append(content)
                    i += 1
                elif curr_stripped == "":
                    if i + 1 < n and raw_lines[i+1].strip().startswith(">"):
                        quote_lines.append("")
                        i += 1
                    else:
                        break
                else:
                    break
                    
            full_quote = "\n".join(quote_lines).strip()
            
            # Detectar si contiene un prompt / bloque de código
            if "```" in full_quote:
                parts = full_quote.split("```")
                pre_code = parts[0].strip()
                code_body = ""
                if len(parts) > 1:
                    code_raw = parts[1]
                    code_lines = code_raw.splitlines()
                    if code_lines and code_lines[0].strip() in ["text", "python", "markdown", "excel"]:
                        code_lines = code_lines[1:]
                    code_body = "\n".join(code_lines).strip()
                    
                obj_text = f"{pre_code}\n\n" if pre_code else ""
                combined_prompt_text = f"{obj_text}{code_body}"
                add_callout_box(doc, combined_prompt_text, box_type="prompt", title="PROMPT / PLANTILLA DE APLICACIÓN")
            else:
                # Cita o concepto clave normal
                clean_quote = "\n".join([ql for ql in quote_lines if ql])
                add_callout_box(doc, clean_quote, box_type="evidence", title="CONCEPTO Y ENFOQUE CIENTÍFICO")
            continue
            
        # 2. BLOQUES DE CÓDIGO DIRECTO (```)
        if stripped.startswith("```"):
            i += 1
            code_lines = []
            while i < n and not raw_lines[i].strip().startswith("```"):
                code_lines.append(raw_lines[i])
                i += 1
            if i < n and raw_lines[i].strip().startswith("```"):
                i += 1
                
            code_text = "\n".join(code_lines).strip()
            add_callout_box(doc, code_text, box_type="prompt", title="CÓDIGO / ESTRUCTURA DE APLICACIÓN")
            continue
            
        # 3. TÍTULOS H1 (Capítulos)
        if stripped.startswith("# "):
            title_text = stripped[2:].strip()
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(28)
            p.paragraph_format.space_after = Pt(12)
            p.paragraph_format.keep_with_next = True
            
            run = p.add_run(title_text)
            run.font.name = "Arial"
            run.font.size = Pt(18)
            run.font.bold = True
            run.font.color.rgb = RGBColor(15, 23, 42)
            i += 1
            continue
            
        # 4. SUBTÍTULOS H2
        if stripped.startswith("## "):
            sub_text = stripped[3:].strip()
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(16)
            p.paragraph_format.space_after = Pt(6)
            p.paragraph_format.keep_with_next = True
            
            run = p.add_run(sub_text)
            run.font.name = "Arial"
            run.font.size = Pt(13)
            run.font.bold = True
            run.font.color.rgb = RGBColor(37, 99, 235)
            i += 1
            continue
            
        # 5. SUBTÍTULOS H3
        if stripped.startswith("### "):
            h3_text = stripped[4:].strip()
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(12)
            p.paragraph_format.space_after = Pt(4)
            p.paragraph_format.keep_with_next = True
            
            run = p.add_run(h3_text)
            run.font.name = "Arial"
            run.font.size = Pt(11)
            run.font.bold = True
            run.font.color.rgb = RGBColor(124, 58, 237)
            i += 1
            continue
            
        # 6. PÁRRAFOS NORMALES
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.line_spacing = 1.15
        
        run = p.add_run(stripped)
        run.font.name = "Calibri"
        run.font.size = Pt(10.5)
        run.font.color.rgb = RGBColor(51, 65, 85)
        i += 1
            
    out_docx_path = OUTPUT_DIR / "EL_SISTEMA_DE_APRENDIZAJE_ACELERADO_CON_IA.docx"
    doc.save(str(out_docx_path))
    print(f"Documento DOCX compilado exitosamente en: {out_docx_path}")
    print(f"Documento DOCX compilado exitosamente en: {out_docx_path}")

if __name__ == "__main__":
    build_docx()
