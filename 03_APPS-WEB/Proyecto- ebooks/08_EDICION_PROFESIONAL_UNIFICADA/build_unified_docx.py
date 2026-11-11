import os
import re
from pathlib import Path
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

BASE_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks\08_EDICION_PROFESIONAL_UNIFICADA")
MANUSCRITO_PATH = BASE_DIR / "manuscrito" / "MANUSCRITO_UNIFICADO_DEFINITIVO.md"
ENTREGABLES_DIR = BASE_DIR / "entregables"
DOCX_OUT = ENTREGABLES_DIR / "EL_SISTEMA_DE_APRENDIZAJE_ACELERADO_CON_IA.docx"
COVER_IMAGE = BASE_DIR / "assets" / "portada" / "portada_plana.png"

ENTREGABLES_DIR.mkdir(parents=True, exist_ok=True)

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
    
    if box_type == "evidence":
        fill = "EFF6FF"
        border_color = "2563EB"
        default_title = "EVIDENCIA CIENTÍFICA VERIFICADA"
    elif box_type == "prompt":
        fill = "F8FAFC"
        border_color = "7C3AED"
        default_title = "PROMPT MAESTRO SOCRÁTICO"
    elif box_type == "warning":
        fill = "FEF2F2"
        border_color = "DC2626"
        default_title = "ALERTA Y TRAMPA COGNITIVA"
    elif box_type == "summary":
        fill = "F0FDF4"
        border_color = "16A34A"
        default_title = "MICRO-RETO Y CONSOLIDACIÓN"
    else:
        fill = "F1F5F9"
        border_color = "475569"
        default_title = "INFORMACIÓN CLAVE"
        
    set_cell_background(cell, fill)
    set_cell_margins(cell, top=140, bottom=140, left=200, right=180)
    
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
    r_title.font.size = Pt(9.5)
    
    if border_color == "2563EB":
        r_title.font.color.rgb = RGBColor(37, 99, 235)
    elif border_color == "7C3AED":
        r_title.font.color.rgb = RGBColor(124, 58, 237)
    elif border_color == "DC2626":
        r_title.font.color.rgb = RGBColor(220, 38, 38)
    elif border_color == "16A34A":
        r_title.font.color.rgb = RGBColor(22, 163, 74)
    else:
        r_title.font.color.rgb = RGBColor(71, 85, 105)
        
    for line in text.strip().split("\n"):
        p2 = cell.add_paragraph()
        p2.paragraph_format.space_before = Pt(2)
        p2.paragraph_format.space_after = Pt(2)
        p2.paragraph_format.line_spacing = 1.15
        
        if line.startswith("- ") or line.startswith("* "):
            r = p2.add_run(f"  •  {line[2:]}")
        else:
            r = p2.add_run(line)
            
        r.font.name = "Arial"
        r.font.size = Pt(9.5)
        r.font.color.rgb = RGBColor(30, 41, 59)
        if box_type == "prompt":
            r.font.name = "Consolas"
            r.font.size = Pt(9)
            
    p_spacer = doc.add_paragraph()
    p_spacer.paragraph_format.space_before = Pt(0)
    p_spacer.paragraph_format.space_after = Pt(6)

def format_inline_runs(paragraph, text, base_size=10.5, is_bold_base=False):
    parts = re.split(r'(\*\*.*?\*\*|\*.*?\*|`.*?`)', text)
    for part in parts:
        if not part:
            continue
        if part.startswith('**') and part.endswith('**') and len(part) >= 4:
            r = paragraph.add_run(part[2:-2])
            r.bold = True
        elif part.startswith('*') and part.endswith('*') and len(part) >= 2:
            r = paragraph.add_run(part[1:-1])
            r.italic = True
        elif part.startswith('`') and part.endswith('`') and len(part) >= 2:
            r = paragraph.add_run(part[1:-1])
            r.font.name = "Consolas"
            r.font.size = Pt(base_size - 1)
            r.font.color.rgb = RGBColor(15, 23, 42)
        else:
            r = paragraph.add_run(part)
            if is_bold_base:
                r.bold = True
        r.font.name = "Arial"
        r.font.size = Pt(base_size)

def build_docx():
    print("Iniciando compilación del Ebook DOCX unificado...")
    doc = Document()
    
    # Configurar márgenes de página
    for section in doc.sections:
        section.top_margin = Inches(0.8)
        section.bottom_margin = Inches(0.8)
        section.left_margin = Inches(0.8)
        section.right_margin = Inches(0.8)
        section.different_first_page_header_footer = True
        
        # Header
        header = section.header
        p_head = header.paragraphs[0]
        p_head.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        r_head = p_head.add_run("EL SISTEMA DE APRENDIZAJE ACELERADO CON IA  |  EDICIÓN 14 DÍAS")
        r_head.font.name = "Arial"
        r_head.font.size = Pt(8.5)
        r_head.font.color.rgb = RGBColor(148, 163, 184)
        
        # Footer
        footer = section.footer
        p_foot = footer.paragraphs[0]
        p_foot.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        r_foot = p_foot.add_run("Edición Definitiva 2026 — Antigravity Editorial")
        r_foot.font.name = "Arial"
        r_foot.font.size = Pt(8.5)
        r_foot.font.color.rgb = RGBColor(148, 163, 184)

    # 1. Portada Plana
    if COVER_IMAGE.exists():
        p_cov = doc.add_paragraph()
        p_cov.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run_cov = p_cov.add_run()
        run_cov.add_picture(str(COVER_IMAGE), width=Inches(6.0))
        doc.add_page_break()

    # Leer manuscrito Markdown
    with open(MANUSCRITO_PATH, "r", encoding="utf-8") as f:
        md_text = f.read()

    lines = md_text.splitlines()
    i = 0
    in_code_block = False
    code_lines = []
    
    while i < len(lines):
        line = lines[i].strip()
        
        # Omitir frontmatter
        if line == "---" and i < 20:
            i += 1
            while i < len(lines) and lines[i].strip() != "---":
                i += 1
            i += 1
            continue
            
        # Omitir saltos o etiquetas html
        if line in ["\\newpage", "<div align=\"center\">", "</div>"] or line.startswith("<div"):
            i += 1
            continue
            
        # Bloques de código (Prompts)
        if line.startswith("```"):
            if not in_code_block:
                in_code_block = True
                code_lines = []
            else:
                in_code_block = False
                add_callout_box(doc, "\n".join(code_lines), box_type="prompt", title="PROMPT MAESTRO SOCRÁTICO")
                code_lines = []
            i += 1
            continue
            
        if in_code_block:
            code_lines.append(lines[i])
            i += 1
            continue
            
        # Detección de imágenes Markdown: ![caption](path)
        img_match = re.search(r'!\[(.*?)\]\((.*?)\)', line)
        if img_match:
            caption = img_match.group(1)
            img_rel_path = img_match.group(2).replace("\\", "/")
            img_abs_path = BASE_DIR / img_rel_path
            
            if img_abs_path.exists():
                p_img = doc.add_paragraph()
                p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
                p_img.paragraph_format.space_before = Pt(12)
                p_img.paragraph_format.space_after = Pt(4)
                r_img = p_img.add_run()
                r_img.add_picture(str(img_abs_path), width=Inches(5.8))
                
                # Pie de imagen
                p_cap = doc.add_paragraph()
                p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
                p_cap.paragraph_format.space_after = Pt(12)
                r_cap = p_cap.add_run(caption)
                r_cap.font.name = "Arial"
                r_cap.font.size = Pt(8.5)
                r_cap.italic = True
                r_cap.font.color.rgb = RGBColor(100, 116, 139)
            else:
                print(f"Aviso DOCX: Imagen no encontrada en {img_abs_path}")
            i += 1
            continue
            
        # Omitir líneas de caption en itálica repetidas bajo imagen
        if line.startswith("*Figura") or line.startswith("*Diagrama"):
            i += 1
            continue
            
        # Cajas de Blockquote / Advertencias (>)
        if line.startswith(">"):
            quote_lines = [line.lstrip("> ").strip()]
            while i + 1 < len(lines) and lines[i+1].strip().startswith(">"):
                i += 1
                quote_lines.append(lines[i].lstrip("> ").strip())
            quote_text = " ".join(quote_lines)
            if "Cifras y Límites" in quote_text:
                add_callout_box(doc, quote_text, box_type="warning", title="LÍMITES Y RIGOR CIENTÍFICO")
            elif "Módulo Asociado" in quote_text or "Objetivo:" in quote_text:
                add_callout_box(doc, quote_text, box_type="evidence", title="OBJETIVO PEDAGÓGICO")
            else:
                add_callout_box(doc, quote_text, box_type="info", title="CONSIDERACIÓN CLAVE")
            i += 1
            continue
            
        # Encabezados
        if line.startswith("# "):
            doc.add_page_break()
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(18)
            p.paragraph_format.space_after = Pt(12)
            format_inline_runs(p, line[2:].strip(), base_size=20, is_bold_base=True)
            p.runs[0].font.color.rgb = RGBColor(15, 23, 42)
            i += 1
            continue
            
        if line.startswith("## "):
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(14)
            p.paragraph_format.space_after = Pt(8)
            format_inline_runs(p, line[3:].strip(), base_size=14, is_bold_base=True)
            p.runs[0].font.color.rgb = RGBColor(37, 99, 235)
            i += 1
            continue
            
        if line.startswith("### "):
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(10)
            p.paragraph_format.space_after = Pt(4)
            format_inline_runs(p, line[4:].strip(), base_size=11.5, is_bold_base=True)
            p.runs[0].font.color.rgb = RGBColor(51, 65, 85)
            i += 1
            continue
            
        # Listas
        if line.startswith("- ") or line.startswith("* "):
            p = doc.add_paragraph(style='List Bullet')
            p.paragraph_format.space_before = Pt(1)
            p.paragraph_format.space_after = Pt(2)
            p.paragraph_format.line_spacing = 1.15
            format_inline_runs(p, line[2:].strip(), base_size=10)
            i += 1
            continue
            
        # Párrafos regulares
        if line:
            p = doc.add_paragraph()
            p.paragraph_format.space_before = Pt(2)
            p.paragraph_format.space_after = Pt(5)
            p.paragraph_format.line_spacing = 1.15
            format_inline_runs(p, line, base_size=10.5)
            
        i += 1

    doc.save(str(DOCX_OUT))
    print(f"Ebook DOCX generado con éxito en: {DOCX_OUT}")

if __name__ == "__main__":
    build_docx()
