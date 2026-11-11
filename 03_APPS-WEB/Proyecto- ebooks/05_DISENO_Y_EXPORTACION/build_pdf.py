import os
from pathlib import Path
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Image, KeepTogether
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfgen import canvas

BASE_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks")
MANUSCRITO_DIR = BASE_DIR / "03_MANUSCRITO"
OUTPUT_DIR = BASE_DIR / "06_ENTREGABLES"
COVER_IMAGE = OUTPUT_DIR / "portada_mockup_3d.jpg"
PDF_PATH = OUTPUT_DIR / "EL_SISTEMA_DE_APRENDIZAJE_ACELERADO_CON_IA.pdf"

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
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#64748B"))
        
        # Header (Top)
        self.drawString(54, 750, "EL SISTEMA DE APRENDIZAJE ACELERADO CON IA")
        self.drawRightString(612 - 54, 750, "METODOLOGÍA DE 4 FASES")
        self.setStrokeColor(colors.HexColor("#CBD5E1"))
        self.setLineWidth(0.5)
        self.line(54, 744, 612 - 54, 744)
        
        # Footer (Bottom)
        self.line(54, 48, 612 - 54, 48)
        self.drawString(54, 36, "Primera Edición 2026 — Guía Maestra para Autodidactas")
        page_str = f"Página {self._pageNumber} de {page_count}"
        self.drawRightString(612 - 54, 36, page_str)
        self.restoreState()

import re

def clean_text_for_xml(text):
    # Primero escapar entidades básicas
    text = text.replace("&", "&amp;")
    text = text.replace("<", "&lt;")
    text = text.replace(">", "&gt;")
    
    # Transformar markdown inline en tags XML compatibles con ReportLab
    # 1. Negrita (**texto**)
    text = re.sub(r'\*\*(.*?)\*\*', r'<b>\1</b>', text)
    # 2. Cursiva (*texto*)
    text = re.sub(r'(?<!\*)\*(?!\*)(.*?)(?<!\*)\*(?!\*)', r'<i>\1</i>', text)
    # 3. Código en línea (`codigo`)
    text = re.sub(r'`(.*?)`', r'<font name="Courier" size="8.5" color="#0F172A"><b>\1</b></font>', text)
    
    return text


def build_pdf():
    doc = SimpleDocTemplate(
        str(PDF_PATH),
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )
    
    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=24,
        leading=28,
        textColor=colors.HexColor('#0F172A'),
        alignment=1, # Center
        spaceAfter=10
    )
    
    subtitle_style = ParagraphStyle(
        'CoverSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=14,
        leading=18,
        textColor=colors.HexColor('#2563EB'),
        alignment=1,
        spaceAfter=15
    )
    
    h1_style = ParagraphStyle(
        'Heading1_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=16,
        leading=20,
        textColor=colors.HexColor('#0F172A'),
        spaceBefore=22,
        spaceAfter=10,
        keepWithNext=True
    )
    
    h2_style = ParagraphStyle(
        'Heading2_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=colors.HexColor('#2563EB'),
        spaceBefore=14,
        spaceAfter=6,
        keepWithNext=True
    )
    
    h3_style = ParagraphStyle(
        'Heading3_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=14,
        textColor=colors.HexColor('#7C3AED'),
        spaceBefore=10,
        spaceAfter=4,
        keepWithNext=True
    )
    
    body_style = ParagraphStyle(
        'Body_Custom',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=13.5,
        textColor=colors.HexColor('#334155'),
        spaceBefore=0,
        spaceAfter=6
    )
    
    code_style = ParagraphStyle(
        'Code_Custom',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=8,
        leading=10.5,
        textColor=colors.HexColor('#1E293B')
    )
    
    callout_style = ParagraphStyle(
        'Callout_Text',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=colors.HexColor('#1E293B')
    )

    story = []
    
    # 1. PORTADA
    story.append(Spacer(1, 10))
    story.append(Paragraph("MANUAL DEFINITIVO DE PRODUCTIVIDAD COGNITIVA", ParagraphStyle('PreTitle', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=10, leading=12, textColor=colors.HexColor('#2563EB'), alignment=1, spaceAfter=8)))
    story.append(Paragraph("EL SISTEMA DE APRENDIZAJE ACELERADO CON IA", title_style))
    story.append(Paragraph("Cómo Dominar Cualquier Tema en Tiempo Récord", subtitle_style))
    
    if COVER_IMAGE.exists():
        img = Image(str(COVER_IMAGE), width=3.0*inch, height=4.0*inch)
        img.hAlign = 'CENTER'
        story.append(img)
        story.append(Spacer(1, 15))
        
    story.append(Paragraph("Equipo Editorial Inteligente &amp; Proyecto Ebooks<br/>Primera Edición — 2026", ParagraphStyle('CoverMeta', parent=styles['Normal'], fontName='Helvetica', fontSize=9, leading=13, textColor=colors.HexColor('#64748B'), alignment=1)))
    story.append(PageBreak())
    
    # 2. FICHA LEGAL
    story.append(Spacer(1, 20))
    story.append(Paragraph("Ficha Técnica y Declaración de Rigor Científico", h1_style))
    legal_text = (
        "<b>Título:</b> El Sistema de Aprendizaje Acelerado con IA: Cómo Dominar Cualquier Tema en Tiempo Récord.<br/>"
        "<b>Edición:</b> Primera Edición Oficial, 2026.<br/>"
        "<b>Marco Epistemológico:</b> Psicología Cognitiva Contemporánea, Metaanálisis de Efectos Aleatorios y Ciencia del Aprendizaje Autorregulado (SRL).<br/>"
        "<b>Referencias Bibliográficas:</b> Normas APA 7ª Edición.<br/><br/>"
        "<b>Declaración de Principios:</b> Este manual rechaza explícitamente las promesas fraudulentas de 'maestría sin esfuerzo' o dominio universal en pocas horas. "
        "El cerebro humano requiere un esfuerzo cognitivo deliberado y deseable para consolidar esquemas neuronales profundos. La inteligencia artificial se "
        "implementa aquí como un andamiaje socrático, generador de simulaciones y evaluador ciego, preservando siempre la autonomía intelectual del lector."
    )
    story.append(Paragraph(legal_text, body_style))
    story.append(Spacer(1, 15))
    story.append(PageBreak())
    
    # 3. PROCESAR MANUSCRITO CON PARSER POR BLOQUES
    manuscrito_file = MANUSCRITO_DIR / "MANUSCRITO_COMPLETO.md"
    raw_lines = manuscrito_file.read_text(encoding="utf-8").splitlines()
    
    i = 0
    n = len(raw_lines)
    
    while i < n:
        line = raw_lines[i]
        stripped = line.strip()
        
        # Ignorar líneas vacías y separadores
        if not stripped or stripped == "---":
            i += 1
            continue
            
        # 1. BLOQUE DE CITAS / PROMPTS INDENTADOS (Comienza con >)
        if stripped.startswith(">"):
            quote_lines = []
            while i < n:
                curr_stripped = raw_lines[i].strip()
                if curr_stripped.startswith(">"):
                    # Quitar el '> ' inicial
                    content = curr_stripped[1:].strip()
                    quote_lines.append(content)
                    i += 1
                elif curr_stripped == "":
                    # Verificar si la siguiente línea continúa la cita
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
                # Extraer objetivo y código
                parts = full_quote.split("```")
                pre_code = parts[0].strip()
                code_body = ""
                if len(parts) > 1:
                    code_raw = parts[1]
                    # Remover identificador de lenguaje (ej. text, python)
                    code_lines = code_raw.splitlines()
                    if code_lines and code_lines[0].strip() in ["text", "python", "markdown", "excel"]:
                        code_lines = code_lines[1:]
                    code_body = "\n".join(code_lines).strip()
                    
                obj_html = f"<i>{clean_text_for_xml(pre_code)}</i><br/><br/>" if pre_code else ""
                code_html = "<br/>".join([clean_text_for_xml(cl) for cl in code_body.splitlines()])
                
                prompt_content = f"<b>PROMPT / PLANTILLA LISTA PARA COPIAR:</b><br/>{obj_html}<font name='Courier' size='8' color='#1E293B'>{code_html}</font>"
                p_prompt = Paragraph(prompt_content, code_style)
                
                tbl = Table([[p_prompt]], colWidths=[504])
                tbl.setStyle(TableStyle([
                    ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#F8FAFC')),
                    ('LEFTPADDING', (0,0), (-1,-1), 12),
                    ('RIGHTPADDING', (0,0), (-1,-1), 12),
                    ('TOPPADDING', (0,0), (-1,-1), 8),
                    ('BOTTOMPADDING', (0,0), (-1,-1), 8),
                    ('LINELEFT', (0,0), (0,0), 3.5, colors.HexColor('#7C3AED')),
                    ('BOX', (0,0), (-1,-1), 0.5, colors.HexColor('#CBD5E1')),
                ]))
                story.append(Spacer(1, 4))
                story.append(tbl)
                story.append(Spacer(1, 8))
            else:
                # Cita o concepto clave normal
                clean_quote = "<br/>".join([clean_text_for_xml(ql) for ql in quote_lines if ql])
                p_quote = Paragraph(f"<b>CONCEPTO CLAVE:</b><br/>{clean_quote}", callout_style)
                tbl = Table([[p_quote]], colWidths=[504])
                tbl.setStyle(TableStyle([
                    ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#EFF6FF')),
                    ('LEFTPADDING', (0,0), (-1,-1), 10),
                    ('RIGHTPADDING', (0,0), (-1,-1), 10),
                    ('TOPPADDING', (0,0), (-1,-1), 6),
                    ('BOTTOMPADDING', (0,0), (-1,-1), 6),
                    ('LINELEFT', (0,0), (0,0), 3.5, colors.HexColor('#2563EB')),
                    ('BOX', (0,0), (-1,-1), 0.5, colors.HexColor('#BFDBFE')),
                ]))
                story.append(Spacer(1, 4))
                story.append(tbl)
                story.append(Spacer(1, 8))
            continue
            
        # 2. BLOQUE DE CÓDIGO DIRECTO (```)
        if stripped.startswith("```"):
            i += 1
            code_lines = []
            while i < n and not raw_lines[i].strip().startswith("```"):
                code_lines.append(raw_lines[i])
                i += 1
            if i < n and raw_lines[i].strip().startswith("```"):
                i += 1
                
            code_html = "<br/>".join([clean_text_for_xml(cl) for cl in code_lines])
            p_code = Paragraph(f"<b>CÓDIGO / ESTRUCTURA DE APLICACIÓN:</b><br/><br/><font name='Courier' size='8' color='#1E293B'>{code_html}</font>", code_style)
            tbl = Table([[p_code]], colWidths=[504])
            tbl.setStyle(TableStyle([
                ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#F8FAFC')),
                ('LEFTPADDING', (0,0), (-1,-1), 12),
                ('RIGHTPADDING', (0,0), (-1,-1), 12),
                ('TOPPADDING', (0,0), (-1,-1), 8),
                ('BOTTOMPADDING', (0,0), (-1,-1), 8),
                ('LINELEFT', (0,0), (0,0), 3.5, colors.HexColor('#7C3AED')),
                ('BOX', (0,0), (-1,-1), 0.5, colors.HexColor('#CBD5E1')),
            ]))
            story.append(Spacer(1, 4))
            story.append(tbl)
            story.append(Spacer(1, 8))
            continue
            
        # 3. TÍTULOS H1
        if stripped.startswith("# "):
            title = clean_text_for_xml(stripped[2:].strip())
            story.append(Spacer(1, 14))
            story.append(Paragraph(title, h1_style))
            i += 1
            continue
            
        # 4. SUBTÍTULOS H2
        if stripped.startswith("## "):
            h2 = clean_text_for_xml(stripped[3:].strip())
            story.append(Spacer(1, 8))
            story.append(Paragraph(h2, h2_style))
            i += 1
            continue
            
        # 5. SUBTÍTULOS H3
        if stripped.startswith("### "):
            h3 = clean_text_for_xml(stripped[4:].strip())
            story.append(Spacer(1, 4))
            story.append(Paragraph(h3, h3_style))
            i += 1
            continue
            
        # 6. PÁRRAFOS NORMALES
        clean_p = clean_text_for_xml(stripped)
        story.append(Paragraph(clean_p, body_style))
        i += 1
            
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF generado con éxito en: {PDF_PATH}")

if __name__ == "__main__":
    build_pdf()
