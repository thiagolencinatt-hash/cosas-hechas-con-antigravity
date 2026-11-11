import os
import re
from pathlib import Path

BASE_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks")
EDICION_DIR = BASE_DIR / "08_EDICION_PROFESIONAL_UNIFICADA"
MANUSCRITO_OUT = EDICION_DIR / "manuscrito" / "MANUSCRITO_UNIFICADO_DEFINITIVO.md"

# Cargar fuentes
with open(BASE_DIR / "boceto mejorado ebook .md", "r", encoding="utf-8") as f:
    boceto2_text = f.read()

with open(BASE_DIR / "03_MANUSCRITO" / "MANUSCRITO_COMPLETO.md", "r", encoding="utf-8") as f:
    manuscrito_ant_text = f.read()

with open(EDICION_DIR / "REGISTRO_DE_FUENTES.md", "r", encoding="utf-8") as f:
    fuentes_text = f.read()

print("Fuentes cargadas con éxito.")
print(f"Boceto 2: {len(boceto2_text)} caracteres | Manuscrito Antigravity: {len(manuscrito_ant_text)} caracteres")
