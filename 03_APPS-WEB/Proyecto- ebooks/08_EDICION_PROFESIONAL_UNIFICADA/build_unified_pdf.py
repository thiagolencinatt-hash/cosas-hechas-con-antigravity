import os
import re
from pathlib import Path
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Image, KeepTogether
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfgen import canvas

BASE_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks\08_EDICION_PROFESIONAL_UNIFICADA")
MANUSCRITO_PATH = BASE_DIR / "manuscrito" / "MANUSCRITO_UNIFICADO_DEFINITIVO.md"
ENTREGABLES_DIR = BASE_DIR / "entregables"
PDF_OUT = ENTREGABLES_DIR / "EL_SISTEMA_DE_APRENDIZAJE_ACELERADO_CON_IA.pdf"
COVER_IMAGE = BASE_DIR / "assets" / "portada" / "portada_plana.png"

ENTREGABLES_DIR.mkdir(parents=True, exist_ok=True)

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        if self._pageNumber == 1:
            return  # Portada limpia
            
        self.saveState()
        self.setFont("Helvetica-Bold", 7.5)
        self.setFillColor(colors.HexColor("#64748B"))
        
        # Header superior
        self.drawString(54, 750, "EL SISTEMA DE APRENDIZAJE ACELERADO CON IA")
        self.setFont("Helvetica", 7.5)
        self.drawRightString(612 - 54, 750, "PROGRAMA MAESTRO DE 14 DÍAS")
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.6)
        self.line(54, 744, 612 - 54, 744)
        
        # Footer inferior
        self.line(54, 46, 612 - 54, 46)
        self.drawString(54, 34, "Edición Profesional Unificada 2026 — Antigravity Editorial")
        page_str = f"Página {self._pageNumber} de {page_count}"
        self.drawRightString(612 - 54, 34, page_str)
        self.restoreState()

def clean_text_for_xml(text):
    text = text.replace("&", "&amp;")
    text = text.replace("<", "&lt;")
    text = text.replace(">", "&gt;")
    # 1. Negrita
    text = re.sub(r'\*\*(.*?)\*\*', r'<b>\1</b>', text)
    # 2. Cursiva
    text = re.sub(r'(?<!\*)\*(?!\*)(.*?)(?<!\*)\*(?!\*)', r'<i>\1</i>', text)
    # 3. Código en línea
    text = re.sub(r'`(.*?)`', r'<font name="Courier-Bold" size="8" color="#0F172A">\1</font>', text)
    return text

def build_pdf():
    print("Iniciando compilación del Ebook PDF definitivo con ReportLab...")
    
    doc = SimpleDocTemplate(
        str(PDF_OUT),
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )
    
    styles = getSampleStyleSheet()
    
    style_normal = ParagraphStyle(
        'NormalCustom',
        fontName='Helvetica',
        fontSize=9.5,
        leading=14.5,
        textColor=colors.HexColor("#1E293B"),
        alignment=4, # Justified
        spaceAfter=6
    )
    
    style_h1 = ParagraphStyle(
        'H1Custom',
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=colors.HexColor("#0F172A"),
        spaceBefore=18,
        spaceAfter=10,
        keepWithNext=True
    )
    
    style_h2 = ParagraphStyle(
        'H2Custom',
        fontName='Helvetica-Bold',
        fontSize=12.5,
        leading=16,
        textColor=colors.HexColor("#2563EB"),
        spaceBefore=14,
        spaceAfter=6,
        keepWithNext=True
    )
    
    style_h3 = ParagraphStyle(
        'H3Custom',
        fontName='Helvetica-Bold',
        fontSize=10.5,
        leading=14,
        textColor=colors.HexColor("#334155"),
        spaceBefore=10,
        spaceAfter=4,
        keepWithNext=True
    )
    
    style_bullet = ParagraphStyle(
        'BulletCustom',
        fontName='Helvetica',
        fontSize=9.5,
        leading=13.5,
        textColor=colors.HexColor("#1E293B"),
        leftIndent=14,
        firstLineIndent=-10,
        spaceAfter=3
    )
    
    style_caption = ParagraphStyle(
        'CaptionCustom',
        fontName='Helvetica-Oblique',
        fontSize=8,
        leading=11,
        textColor=colors.HexColor("#64748B"),
        alignment=1, # Centered
        spaceAfter=10
    )
    
    style_code = ParagraphStyle(
        'CodeCustom',
        fontName='Courier',
        fontSize=8,
        leading=10.5,
        textColor=colors.HexColor("#0F172A")
    )
    
    story = []
    
    # 1. Portada completa
    if COVER_IMAGE.exists():
        # Portada ajustada a tamaño carta con márgenes
        story.append(Image(str(COVER_IMAGE), width=504, height=672))
        story.append(PageBreak())
        
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
                code_content = "\n".join(code_lines)
                clean_code = clean_text_for_xml(code_content).replace("\n", "<br/>")
                p_code = Paragraph(clean_code, style_code)
                
                t = Table([[p_code]], colWidths=[504])
                t.setStyle(TableStyle([
                    ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#F8FAFC")),
                    ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#CBD5E1")),
                    ('LINELEFT', (0,0), (0,0), 3.5, colors.HexColor("#7C3AED")),
                    ('TOPPADDING', (0,0), (-1,-1), 8),
                    ('BOTTOMPADDING', (0,0), (-1,-1), 8),
                    ('LEFTPADDING', (0,0), (-1,-1), 12),
                    ('RIGHTPADDING', (0,0), (-1,-1), 12),
                ]))
                story.append(Spacer(1, 4))
                story.append(t)
                story.append(Spacer(1, 6))
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
                try:
                    # Ancho máximo 480pt, altura proporcional
                    story.append(Spacer(1, 8))
                    story.append(Image(str(img_abs_path), width=480, height=270))
                    story.append(Spacer(1, 3))
                    story.append(Paragraph(caption, style_caption))
                except Exception as e:
                    print(f"Error insertando imagen {img_abs_path}: {e}")
            i += 1
            continue
            
        if line.startswith("*Figura") or line.startswith("*Diagrama"):
            i += 1
            continue
            
        # Blockquotes (>)
        if line.startswith(">"):
            quote_lines = [line.lstrip("> ").strip()]
            while i + 1 < len(lines) and lines[i+1].strip().startswith(">"):
                i += 1
                quote_lines.append(lines[i].lstrip("> ").strip())
            quote_text = " ".join(quote_lines)
            clean_q = clean_text_for_xml(quote_text)
            
            if "Cifras y Límites" in quote_text:
                border_c = colors.HexColor("#DC2626")
                bg_c = colors.HexColor("#FEF2F2")
            elif "Módulo Asociado" in quote_text:
                border_c = colors.HexColor("#2563EB")
                bg_c = colors.HexColor("#EFF6FF")
            else:
                border_c = colors.HexColor("#3B82F6")
                bg_c = colors.HexColor("#F1F5F9")
                
            p_q = Paragraph(clean_q, style_normal)
            t_q = Table([[p_q]], colWidths=[504])
            t_q.setStyle(TableStyle([
                ('BACKGROUND', (0,0), (-1,-1), bg_c),
                ('LINELEFT', (0,0), (0,0), 3, border_c),
                ('TOPPADDING', (0,0), (-1,-1), 6),
                ('BOTTOMPADDING', (0,0), (-1,-1), 6),
                ('LEFTPADDING', (0,0), (-1,-1), 10),
                ('RIGHTPADDING', (0,0), (-1,-1), 10),
            ]))
            story.append(Spacer(1, 4))
            story.append(t_q)
            story.append(Spacer(1, 6))
            i += 1
            continue
            
        # Tablas Markdown (| ... |)
        if line.startswith("|") and line.endswith("|"):
            table_lines = [line]
            while i + 1 < len(lines) and lines[i+1].strip().startswith("|") and lines[i+1].strip().endswith("|"):
                i += 1
                table_lines.append(lines[i].strip())
                
            # Procesar tabla
            rows_data = []
            for t_line in table_lines:
                if re.match(r'^\|[\s:-]+\|$', t_line):
                    continue  # Separador
                cells = [c.strip() for c in t_line.split("|")[1:-1]]
                row_cells = []
                for c in cells:
                    clean_c = clean_text_for_xml(c)
                    row_cells.append(Paragraph(clean_c, style_normal))
                rows_data.append(row_cells)
                
            if rows_data:
                col_count = len(rows_data[0])
                col_w = 504 / col_count
                rt = Table(rows_data, colWidths=[col_w]*col_count)
                rt.setStyle(TableStyle([
                    ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#1E293B")),
                    ('TEXTCOLOR', (0,0), (-1,0), colors.white),
                    ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#CBD5E1")),
                    ('TOPPADDING', (0,0), (-1,-1), 5),
                    ('BOTTOMPADDING', (0,0), (-1,-1), 5),
                    ('LEFTPADDING', (0,0), (-1,-1), 6),
                    ('RIGHTPADDING', (0,0), (-1,-1), 6),
                ]))
                story.append(Spacer(1, 4))
                story.append(rt)
                story.append(Spacer(1, 6))
            i += 1
            continue

        # Encabezados
        if line.startswith("# "):
            story.append(PageBreak())
            clean_h1 = clean_text_for_xml(line[2:].strip())
            story.append(Paragraph(clean_h1, style_h1))
            i += 1
            continue
            
        if line.startswith("## "):
            clean_h2 = clean_text_for_xml(line[3:].strip())
            story.append(Paragraph(clean_h2, style_h2))
            i += 1
            continue
            
        if line.startswith("### "):
            clean_h3 = clean_text_for_xml(line[4:].strip())
            story.append(Paragraph(clean_h3, style_h3))
            i += 1
            continue
            
        # Listas
        if line.startswith("- ") or line.startswith("* "):
            clean_b = clean_text_for_xml(line[2:].strip())
            story.append(Paragraph(f"• {clean_b}", style_bullet))
            i += 1
            continue
            
        # Párrafos regulares
        if line:
            clean_p = clean_text_for_xml(line)
            story.append(Paragraph(clean_p, style_normal))
            
        i += 1

    print("Construyendo documento PDF con canvas numerado...")
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"Ebook PDF generado con éxito en: {PDF_OUT}")

if __name__ == "__main__":
    build_pdf()
