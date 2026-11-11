import pymupdf # fitz
import os
from pathlib import Path

BASE_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks\08_EDICION_PROFESIONAL_UNIFICADA")
PDF_PATH = BASE_DIR / "entregables" / "EL_SISTEMA_DE_APRENDIZAJE_ACELERADO_CON_IA.pdf"
PREVIEW_DIR = BASE_DIR / "preview_pages"
PREVIEW_DIR.mkdir(parents=True, exist_ok=True)

def inspect_pdf():
    print(f"Abriendo PDF: {PDF_PATH}")
    doc = pymupdf.open(str(PDF_PATH))
    total_pages = len(doc)
    print(f"Total de páginas en el PDF generado: {total_pages}")
    
    # Comprobar páginas vacías o con muy poco texto
    empty_pages = []
    for idx, page in enumerate(doc):
        text = page.get_text().strip()
        img_list = page.get_images()
        if len(text) == 0 and len(img_list) == 0:
            empty_pages.append(idx + 1)
            
    if empty_pages:
        print(f"Aviso: Páginas potencialmente vacías: {empty_pages}")
    else:
        print("Auditoría: Cero páginas vacías detectadas en todo el documento.")

    # Selección de páginas clave para generar vistas previas PNG de alta resolución
    # Seleccionaremos: Portada (1), Declaración (2), Índice (3), Prólogo (4),
    # y varias páginas intermedias representativas con diagramas e ilustraciones, más las finales
    sample_pages = [1, 2, 3, 4, 6, 8, 12, 16, 20, 24, 28, 32, 36, 40, total_pages - 2, total_pages]
    sample_pages = sorted(list(set([p for p in sample_pages if 1 <= p <= total_pages])))
    
    print(f"Renderizando {len(sample_pages)} páginas de muestra para revisión visual...")
    for p_num in sample_pages:
        page = doc[p_num - 1]
        pix = page.get_pixmap(dpi=150)
        out_img = PREVIEW_DIR / f"pagina_{p_num:02d}_preview.png"
        pix.save(str(out_img))
        print(f"Guardada vista previa: {out_img.name}")
        
    doc.close()
    print("Inspección visual completada!")

if __name__ == "__main__":
    inspect_pdf()
