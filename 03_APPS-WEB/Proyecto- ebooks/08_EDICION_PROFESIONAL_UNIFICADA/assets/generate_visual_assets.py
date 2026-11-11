import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import numpy as np

BASE_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks\08_EDICION_PROFESIONAL_UNIFICADA")
ILUST_DIR = BASE_DIR / "assets" / "ilustraciones"
DIAG_DIR = BASE_DIR / "assets" / "diagramas"
PORT_DIR = BASE_DIR / "assets" / "portada"

ILUST_DIR.mkdir(parents=True, exist_ok=True)
DIAG_DIR.mkdir(parents=True, exist_ok=True)
PORT_DIR.mkdir(parents=True, exist_ok=True)

# Paleta editorial
BG_DARK = "#0F172A"       # Azul marino profundo
BLUE_ACCENT = "#2563EB"   # Azul eléctrico
VIOLET_ACCENT = "#7C3AED" # Violeta técnico
CYAN_ACCENT = "#38BDF8"   # Cian brillante
TEXT_LIGHT = "#F8FAFC"    # Blanco puro
TEXT_MUTED = "#94A3B8"    # Gris pizarra suave
CARD_BG = "#1E293B"       # Gris azulado de contenedor
BORDER_COLOR = "#334155"  # Borde sutil

def create_card_canvas(title, subtitle="", width=12, height=6.75, dpi=200):
    fig, ax = plt.subplots(figsize=(width, height), dpi=dpi)
    fig.patch.set_facecolor(BG_DARK)
    ax.set_facecolor(BG_DARK)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Header minimalista
    ax.text(5, 93, title.upper(), fontsize=15, fontweight='bold', color=CYAN_ACCENT, family='sans-serif')
    if subtitle:
        ax.text(5, 87, subtitle, fontsize=10, color=TEXT_MUTED, family='sans-serif')
        
    # Línea divisoria decorativa
    ax.plot([5, 95], [83, 83], color=BORDER_COLOR, lw=1.2)
    return fig, ax

def draw_rounded_box(ax, x, y, w, h, bg=CARD_BG, border=BLUE_ACCENT, lw=1.5):
    rect = patches.FancyBboxPatch((x, y), w, h, boxstyle="round,pad=1.5", 
                                  facecolor=bg, edgecolor=border, linewidth=lw)
    ax.add_patch(rect)

# -------------------------------------------------------------
# 1. GENERACIÓN DE ILUSTRACIONES VECTORIALES (3 a 24)
# -------------------------------------------------------------

def gen_ilust_03():
    fig, ax = create_card_canvas("1.3 Mapeo de Micro-Competencias", "Descomposición del Caos en Bloques de 45 Minutos")
    draw_rounded_box(ax, 8, 20, 24, 52, border=VIOLET_ACCENT)
    ax.text(20, 65, "CAOS\nTEÓRICO", ha='center', va='center', color="#F43F5E", fontsize=11, fontweight='bold')
    ax.text(20, 42, "• 500 páginas\n• Jerga difusa\n• Cursos de 40h\n• Fatiga cognitiva", ha='center', va='center', color=TEXT_MUTED, fontsize=9)
    
    # Flecha procesador
    ax.annotate("", xy=(42, 46), xytext=(34, 46), arrowprops=dict(arrowstyle="->", color=CYAN_ACCENT, lw=2.5))
    
    # Procesador
    draw_rounded_box(ax, 43, 28, 16, 36, bg="#1E1B4B", border=CYAN_ACCENT)
    ax.text(51, 49, "FILTRO DE\nATOMIZACIÓN", ha='center', va='center', color=TEXT_LIGHT, fontsize=10, fontweight='bold')
    ax.text(51, 35, "Límite CLT\n(Sweller)", ha='center', va='center', color=CYAN_ACCENT, fontsize=8)
    
    # Flecha salida
    ax.annotate("", xy=(68, 46), xytext=(61, 46), arrowprops=dict(arrowstyle="->", color=CYAN_ACCENT, lw=2.5))
    
    # Bloques de 45 min
    draw_rounded_box(ax, 70, 20, 24, 52, border=BLUE_ACCENT)
    ax.text(82, 65, "BLOQUES 45 MIN\n(MICRO-TAREAS)", ha='center', va='center', color=CYAN_ACCENT, fontsize=11, fontweight='bold')
    ax.text(82, 42, "• Submeta 1 (45m)\n• Submeta 2 (45m)\n• Submeta 3 (45m)\n• Rúbrica de éxito", ha='center', va='center', color=TEXT_LIGHT, fontsize=9)
    
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo1_microcompetencias.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_04():
    fig, ax = create_card_canvas("1.4 El Cronograma Adaptativo de 336 Horas", "Ruta de Inmersión Focalizada en 14 Días")
    days = [f"D{i}" for i in range(1, 15)]
    phases = ["PREPARAR", "PREPARAR", "SOCRÁTICO", "SOCRÁTICO", "FEYNMAN", "FEYNMAN", "FEYNMAN", 
              "SIMULADOR", "SIMULADOR", "SIMULADOR", "BLINDAJE", "BLINDAJE", "ARTEFACTO", "DEMOSTRAR"]
    colors_p = [BLUE_ACCENT, BLUE_ACCENT, VIOLET_ACCENT, VIOLET_ACCENT, CYAN_ACCENT, CYAN_ACCENT, CYAN_ACCENT,
                "#10B981", "#10B981", "#10B981", "#F59E0B", "#F59E0B", "#EC4899", "#EC4899"]
    
    for idx, (d, ph, col) in enumerate(zip(days, phases, colors_p)):
        x = 6 + idx * 6.3
        draw_rounded_box(ax, x, 25, 5.5, 45, bg=CARD_BG, border=col, lw=1.2)
        ax.text(x + 2.75, 62, d, ha='center', color=TEXT_LIGHT, fontsize=11, fontweight='bold')
        ax.plot([x + 0.5, x + 5], [54, 54], color=BORDER_COLOR, lw=1)
        ax.text(x + 2.75, 40, ph[:6], ha='center', color=col, fontsize=7.5, fontweight='bold', rotation=90)
        
    ax.text(50, 15, "CICLO DE 336 HORAS: CERO PÉRDIDA DE CONTEXTO ENTRE SESIONES DIARIAS", ha='center', color=TEXT_MUTED, fontsize=9, fontweight='bold')
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo1_cronograma.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_05():
    fig, ax = create_card_canvas("2.1 El Peligro de la Complacencia Algorítmica", "Bloqueando el Sesgo de Adulación para Forzar el Aprendizaje")
    # Columna izquierda: Complacencia
    draw_rounded_box(ax, 10, 20, 36, 52, border="#F43F5E")
    ax.text(28, 65, "IA COMPLACIENTE (CHATBOT PASIVO)", ha='center', color="#F43F5E", fontsize=11, fontweight='bold')
    ax.text(28, 43, "• Da respuestas directas prefabricadas\n• Adula al alumno ('¡Excelente idea!')\n• Atrofia el esfuerzo deseable\n• Resultado: Ilusión de competencia (d ≈ 0)", ha='center', color=TEXT_MUTED, fontsize=9.5)
    
    # VS
    ax.text(50, 46, "VS", ha='center', va='center', color=CYAN_ACCENT, fontsize=16, fontweight='bold')
    
    # Columna derecha: Tutor Socrático
    draw_rounded_box(ax, 54, 20, 36, 52, border=CYAN_ACCENT)
    ax.text(72, 65, "TUTOR SOCRÁTICO ESTRICTO", ha='center', color=CYAN_ACCENT, fontsize=11, fontweight='bold')
    ax.text(72, 43, "• Prohibición de solución directa\n• Preguntas de situación y contra-ejemplos\n• Pretesting forzado (Akgun & Toker, d = 1.54)\n• Resultado: Transferencia real a largo plazo", ha='center', color=TEXT_LIGHT, fontsize=9.5)
    
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo2_complacencia.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_06():
    fig, ax = create_card_canvas("2.2 Anatomía del Prompt Socrático Perfecto", "Los 4 Cuadrantes de Activación Metodológica")
    draw_rounded_box(ax, 10, 48, 38, 26, border=BLUE_ACCENT)
    ax.text(29, 66, "1. ROL IMPLACABLE", ha='center', color=CYAN_ACCENT, fontsize=11, fontweight='bold')
    ax.text(29, 56, "Profesor socrático exigente sin concesiones", ha='center', color=TEXT_MUTED, fontsize=9)
    
    draw_rounded_box(ax, 52, 48, 38, 26, border="#F43F5E")
    ax.text(71, 66, "2. RESTRICCIÓN DE ORO", ha='center', color="#F43F5E", fontsize=11, fontweight='bold')
    ax.text(71, 56, "Prohibido dar código o soluciones directas", ha='center', color=TEXT_MUTED, fontsize=9)
    
    draw_rounded_box(ax, 10, 18, 38, 26, border=VIOLET_ACCENT)
    ax.text(29, 36, "3. PREGUNTA DIAGNÓSTICA", ha='center', color=VIOLET_ACCENT, fontsize=11, fontweight='bold')
    ax.text(29, 26, "Un solo desafío a la vez basado en casos reales", ha='center', color=TEXT_MUTED, fontsize=9)
    
    draw_rounded_box(ax, 52, 18, 38, 26, border="#10B981")
    ax.text(71, 36, "4. CONTROL DE RITMO", ha='center', color="#10B981", fontsize=11, fontweight='bold')
    ax.text(71, 26, "Espera obligatoria de respuesta antes de avanzar", ha='center', color=TEXT_MUTED, fontsize=9)
    
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo2_anatomia_prompt.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_07():
    fig, ax = create_card_canvas("2.3 Andamiaje Cognitivo Dinámico", "El Desvanecimiento Progresivo de la Ayuda (Scaffolding & Fading)")
    steps = [
        ("NIVEL 1: 100% GUIADO", "Ejemplo completamente resuelto\ncon justificación de cada submeta.", BLUE_ACCENT),
        ("NIVEL 2: 70% GUIADO", "La IA resuelve pasos iniciales;\nel alumno completa el cierre.", CYAN_ACCENT),
        ("NIVEL 3: 30% GUIADO", "La IA da solo contexto inicial;\nel alumno resuelve el 70%.", VIOLET_ACCENT),
        ("NIVEL 4: AUTONOMÍA TOTAL", "Resolución 100% independiente\nsin ninguna pista ni soporte.", "#10B981")
    ]
    for idx, (title, desc, col) in enumerate(steps):
        y = 66 - idx * 16
        draw_rounded_box(ax, 10 + idx * 4, y, 76 - idx * 4, 13, border=col)
        ax.text(12 + idx * 4, y + 6.5, title, color=col, fontsize=9.5, fontweight='bold', va='center')
        ax.text(48 + idx * 2, y + 6.5, desc, color=TEXT_LIGHT, fontsize=8.5, va='center')
        
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo2_andamiaje.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_08():
    fig, ax = create_card_canvas("2.4 Creación del Entorno de Trabajo", "Configuración de Instrucciones de Sistema (System Prompts)")
    draw_rounded_box(ax, 12, 18, 76, 55, border=CYAN_ACCENT)
    ax.text(50, 64, "TERMINAL DE TRABAJO INTELIGENTE (NOTEBOOKLM / CHATGPT)", ha='center', color=CYAN_ACCENT, fontsize=11, fontweight='bold')
    ax.plot([16, 84], [58, 58], color=BORDER_COLOR, lw=1)
    
    code_text = (
        "[SYSTEM PROMPT PERSISTENTE]\n"
        "> Rol: Auditor Pedagógico y Entrenador Deliberado Senior.\n"
        "> Objetivo: Guiar al aprendiz mediante el método socrático.\n"
        "> Directiva 1: Nunca dar respuestas directas; usar preguntas guía.\n"
        "> Directiva 2: Detectar discrepancias lógicas y aplicar lógica ECF.\n"
        "> Directiva 3: Cerrar cada sesión con 1 caso límite de verificación."
    )
    ax.text(18, 36, code_text, color=TEXT_LIGHT, fontsize=9.5, family='monospace', va='center')
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo2_entorno_trabajo.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_09():
    fig, ax = create_card_canvas("3.1 El Protocolo Feynman con IA", "La Autopsia de Explicaciones y Eliminación de Ilusiones de Comprensión")
    draw_rounded_box(ax, 8, 22, 25, 48, border=BLUE_ACCENT)
    ax.text(20.5, 62, "PASO 1: TU EXPLICACIÓN", ha='center', color=CYAN_ACCENT, fontsize=9.5, fontweight='bold')
    ax.text(20.5, 42, "Explicás el concepto en\nlenguaje llano (12 años)\nsin usar palabras técnicas.", ha='center', color=TEXT_LIGHT, fontsize=8.5)
    
    ax.annotate("", xy=(39, 46), xytext=(34, 46), arrowprops=dict(arrowstyle="->", color=CYAN_ACCENT, lw=2))
    
    draw_rounded_box(ax, 40, 22, 25, 48, border=VIOLET_ACCENT)
    ax.text(52.5, 62, "PASO 2: AUTOPSIA IA", ha='center', color=VIOLET_ACCENT, fontsize=9.5, fontweight='bold')
    ax.text(52.5, 42, "La IA audita:\n• Jerga injustificada\n• Saltos mágicos\n• Vacíos de causa-efecto", ha='center', color=TEXT_LIGHT, fontsize=8.5)
    
    ax.annotate("", xy=(71, 46), xytext=(66, 46), arrowprops=dict(arrowstyle="->", color=CYAN_ACCENT, lw=2))
    
    draw_rounded_box(ax, 72, 22, 25, 48, border="#10B981")
    ax.text(84.5, 62, "PASO 3: RE-CALIBRACIÓN", ha='center', color="#10B981", fontsize=9.5, fontweight='bold')
    ax.text(84.5, 42, "Corregís el vacío mental\ny defendés el concepto\nen un caso límite real.", ha='center', color=TEXT_LIGHT, fontsize=8.5)
    
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo3_feynman.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_10():
    fig, ax = create_card_canvas("3.2 Fábrica de Analogías Ancladas", "Conectando Conceptos Abstractos con Modelos Mentales Previos")
    draw_rounded_box(ax, 10, 25, 30, 42, border=BLUE_ACCENT)
    ax.text(25, 58, "ISLA FAMILIAR\n(CONOCIMIENTO PREVIO)", ha='center', color=CYAN_ACCENT, fontsize=10, fontweight='bold')
    ax.text(25, 38, "Cocina, carpintería,\njuegos, deportes, música.", ha='center', color=TEXT_MUTED, fontsize=9)
    
    # Puente
    draw_rounded_box(ax, 43, 36, 14, 20, bg="#312E81", border=CYAN_ACCENT)
    ax.text(50, 46, "PUENTE\nMETAFÓRICO", ha='center', va='center', color=TEXT_LIGHT, fontsize=8.5, fontweight='bold')
    
    draw_rounded_box(ax, 60, 25, 30, 42, border=VIOLET_ACCENT)
    ax.text(75, 58, "ISLA ABSTRACTA\n(NUEVA DISCIPLINA)", ha='center', color=VIOLET_ACCENT, fontsize=10, fontweight='bold')
    ax.text(75, 38, "BUSCARX, punteros C++,\nmodelos macroeconómicos.", ha='center', color=TEXT_MUTED, fontsize=9)
    
    ax.text(50, 14, "ADVERTENCIA EDITORIAL: LA IA SIEMPRE DEBE EXPLICAR DÓNDE SE ROMPE LA ANALOGÍA", ha='center', color="#F59E0B", fontsize=8.5, fontweight='bold')
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo3_analogias.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_11():
    fig, ax = create_card_canvas("3.3 Detección de Puntos Ciegos", "El Interrogatorio Cruzado de la IA sobre Premisas Ocultas")
    draw_rounded_box(ax, 15, 20, 70, 50, border=VIOLET_ACCENT)
    ax.text(50, 61, "DIAGNÓSTICO ÓPTICO DE COGNICIÓN", ha='center', color=VIOLET_ACCENT, fontsize=11, fontweight='bold')
    ax.text(50, 48, "El aprendiz afirma: 'Entendí las referencias relativas y absolutas'", ha='center', color=TEXT_MUTED, fontsize=9.5, style='italic')
    ax.plot([20, 80], [42, 42], color=BORDER_COLOR, lw=1)
    
    ax.text(50, 31, "RAYO LÁSER SOCRÁTICO:\n'¿Qué sucede exactamente si arrastras una fórmula con $A1 hacia la derecha\nfrente a arrastrarla hacia abajo? Demuéstralo con 2 valores.'", ha='center', color=CYAN_ACCENT, fontsize=9.5, fontweight='bold')
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo3_puntos_ciegos.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_12():
    fig, ax = create_card_canvas("3.4 Resúmenes de Compresión Máxima", "De la Prosa Difusa a las Matrices Relacionales de Decisión")
    headers = ["CONCEPTO", "REGLA DE ORO", "CUÁNDO USARLO", "ERROR COMÚN"]
    rows = [
        ["BUSCARX", "=BUSCARX(val; busq; dev)", "Cruces matriciales dinámicos", "Columnas de distinto largo"],
        ["SI ANIDADO", "=SI(Y(c1; c2); v; f)", "Comisiones multidimensionales", "Olvidar cerrar paréntesis de Y"],
        ["TABLA CTRL+T", "Estructura estructurada", "Datos que crecen con el tiempo", "Usar rangos estáticos A2:D500"]
    ]
    draw_rounded_box(ax, 8, 18, 84, 55, border=CYAN_ACCENT)
    for c_idx, h in enumerate(headers):
        ax.text(12 + c_idx * 21, 65, h, color=CYAN_ACCENT, fontsize=9, fontweight='bold')
    ax.plot([10, 90], [60, 60], color=BORDER_COLOR, lw=1.2)
    
    for r_idx, row in enumerate(rows):
        y = 50 - r_idx * 12
        for c_idx, val in enumerate(row):
            ax.text(12 + c_idx * 21, y, val, color=TEXT_LIGHT, fontsize=8)
            
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo3_compresion.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_13():
    fig, ax = create_card_canvas("4.1 Entornos de Simulación Interactiva", "La Cabina de Vuelo para el Desarrollo de Habilidades")
    draw_rounded_box(ax, 10, 20, 80, 52, border=BLUE_ACCENT)
    ax.text(50, 63, "EL BUCLE DE SIMULACIÓN DE ALTA PRESIÓN", ha='center', color=CYAN_ACCENT, fontsize=11, fontweight='bold')
    ax.text(50, 48, "[1. CASO HOSTIL REAL] ──> [2. EJECUCIÓN ACTIVA DEL ALUMNO] ──> [3. AUDITORÍA INMEDIATA]\n       ↑                                                                   │\n       └──────────────────── [4. RE-EJECUCIÓN EN CALIENTE] ───────────────┘", ha='center', color=TEXT_LIGHT, fontsize=9.5, family='monospace')
    ax.text(50, 28, "Entrenamiento en la Zona de Incomodidad Cognitiva (K. Anders Ericsson)", ha='center', color=TEXT_MUTED, fontsize=9)
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo4_simulador.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_14():
    fig, ax = create_card_canvas("4.2 Inyección de Casos Límite (Edge Cases)", "Entrenando la Resiliencia ante Datos Sucios y Situaciones Atípicas")
    draw_rounded_box(ax, 10, 20, 37, 50, border=BORDER_COLOR)
    ax.text(28.5, 62, "TUTORIAL IDEALIZADO\n(LA MENTIRA DE YOUTUBE)", ha='center', color=TEXT_MUTED, fontsize=10, fontweight='bold')
    ax.text(28.5, 40, "• Datos limpios y perfectos\n• Fórmulas sin errores\n• Clientes comprensivos\n• Falsa sensación de maestría", ha='center', color=TEXT_MUTED, fontsize=9)
    
    draw_rounded_box(ax, 53, 20, 37, 50, border="#F43F5E")
    ax.text(71.5, 62, "CASO LÍMITE INYECTADO\n(EL MUNDO REAL)", ha='center', color="#F43F5E", fontsize=10, fontweight='bold')
    ax.text(71.5, 40, "• Fechas con formatos corruptos\n• Celdas vacías y duplicadas\n• Excepciones imprevistas\n• Robustez procedimental real", ha='center', color=TEXT_LIGHT, fontsize=9)
    
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo4_casos_limite.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_15():
    fig, ax = create_card_canvas("4.3 Bucle de Retroalimentación Inmediata", "Lógica ECF (Error Carried Forward) y High-Information Feedback")
    draw_rounded_box(ax, 12, 18, 76, 54, border="#10B981")
    ax.text(50, 63, "ANATOMÍA DE LA CORRECCIÓN FORMATIVA (Wisniewski et al., d = 0.99)", ha='center', color="#10B981", fontsize=10.5, fontweight='bold')
    ax.plot([16, 84], [57, 57], color=BORDER_COLOR, lw=1)
    
    ecf_text = (
        "• Diagnóstico de Causa Raíz: ¿Error Conceptual, Procedimental o de Lectura?\n"
        "• Aplicación del Principio ECF: Si el Paso 1 tuvo un error de tipeo pero el Paso 2\n"
        "  y el Paso 3 aplicaron la lógica correcta, se premia el razonamiento metodológico.\n"
        "• Latencia Cero: Corrección en menos de 10 segundos para no consolidar el mal hábito."
    )
    ax.text(18, 37, ecf_text, color=TEXT_LIGHT, fontsize=9, va='center')
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo4_feedback_loop.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_16():
    fig, ax = create_card_canvas("4.4 Progresión Escalonada de Dificultad", "El Canal de Flujo (Flow State) de Mihaly Csikszentmihalyi")
    # Diagrama de flujo
    draw_rounded_box(ax, 15, 20, 70, 52, border=VIOLET_ACCENT)
    ax.plot([25, 75], [30, 65], color=CYAN_ACCENT, lw=4) # Canal de flujo
    ax.text(50, 52, "CANAL DE FLUJO (+10% INCOMODIDAD)", ha='center', color=CYAN_ACCENT, fontsize=9.5, fontweight='bold', rotation=32)
    ax.text(28, 55, "ZONA DE ANSIEDAD\n(Dificultad excesiva)", ha='center', color="#F43F5E", fontsize=8.5)
    ax.text(72, 32, "ZONA DE ABURRIMIENTO\n(Práctica rutinaria / estancamiento)", ha='center', color=TEXT_MUTED, fontsize=8.5)
    
    ax.text(50, 24, "LA IA CALIBRA DINÁMICAMENTE LA FRICCIÓN PARA MANTENERTE EN FLUJO", ha='center', color=TEXT_LIGHT, fontsize=8.5, fontweight='bold')
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo4_canal_flujo.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_17():
    fig, ax = create_card_canvas("5.1 El Examen Ciego Anti-Trampas", "Recuperación Activa de Producción Abierta (Testing Effect, d = 1.26)")
    draw_rounded_box(ax, 10, 20, 36, 50, border="#F43F5E")
    ax.text(28, 62, "EXAMEN DE MULTIPLE CHOICE\n(ILUSIÓN DE RECONOCIMIENTO)", ha='center', color="#F43F5E", fontsize=9.5, fontweight='bold')
    ax.text(28, 40, "• Opciones visibles en pantalla\n• Deducción por descarte\n• El cerebro reconoce, no produce\n• Retención a 7 días: < 30%", ha='center', color=TEXT_MUTED, fontsize=8.5)
    
    draw_rounded_box(ax, 54, 20, 36, 50, border="#10B981")
    ax.text(72, 62, "EXAMEN CIEGO DE PRODUCCIÓN\n(RECUPERACIÓN ACTIVA)", ha='center', color="#10B981", fontsize=9.5, fontweight='bold')
    ax.text(72, 40, "• Pantalla / papel en blanco\n• Producción motriz y lógica\n• Fortalece la huella neuronal\n• Retención a largo plazo: > 75%", ha='center', color=TEXT_LIGHT, fontsize=8.5)
    
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo5_examen_ciego.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_18():
    fig, ax = create_card_canvas("5.2 Conversión a Repetición Espaciada", "Aplanando la Curva del Olvido de Ebbinghaus mediante el Modelo 1-3-7-21")
    # Curva olvido
    draw_rounded_box(ax, 12, 20, 76, 52, border=CYAN_ACCENT)
    ax.text(50, 63, "LOS 4 CONTACTOS DE RECUPERACIÓN DISTRIBUIDA (Huang, 2025; Latimier, g = 0.74)", ha='center', color=CYAN_ACCENT, fontsize=9.5, fontweight='bold')
    
    contacts = [
        ("Día 0", "Aprendizaje inicial"),
        ("Día 1 (+24h)", "Contacto 1 (Salva 60% olvido)"),
        ("Día 4 (+72h)", "Contacto 2 (Práctica intercalada)"),
        ("Día 11 (+7d)", "Contacto 3 (Test ciego rápido)"),
        ("Día 30 (+21d)", "Contacto 4 (Consolidación total)")
    ]
    for idx, (d, desc) in enumerate(contacts):
        x = 16 + idx * 14.5
        draw_rounded_box(ax, x, 26, 13.5, 26, bg="#1E1B4B", border=VIOLET_ACCENT)
        ax.text(x + 6.75, 45, d, ha='center', color=TEXT_LIGHT, fontsize=8.5, fontweight='bold')
        ax.text(x + 6.75, 33, desc, ha='center', color=CYAN_ACCENT, fontsize=7)
        
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo5_repeticion_espaciada.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_19():
    fig, ax = create_card_canvas("5.3 El Juicio Técnico (Inversión Socrática)", "La IA como Abogado del Diablo para Blindar tus Criterios")
    draw_rounded_box(ax, 15, 20, 70, 50, border="#F59E0B")
    ax.text(50, 61, "EL DUELO ARGUMENTATIVO TÉCNICO", ha='center', color="#F59E0B", fontsize=11, fontweight='bold')
    ax.plot([20, 80], [54, 54], color=BORDER_COLOR, lw=1)
    
    ax.text(50, 42, "TÚ: 'He decidido estructurar el modelo con fórmulas dinámicas en vez de VBA.'", ha='center', color=CYAN_ACCENT, fontsize=9, style='italic')
    ax.text(50, 30, "IA (Abogado del Diablo): 'Tu elección colapsará si un usuario abre el archivo en Excel 2016.\nDefiende por qué tu decisión es superior asumiendo ese riesgo de compatibilidad.'", ha='center', color=TEXT_LIGHT, fontsize=8.5, fontweight='bold')
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo5_abogado_diablo.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_20():
    fig, ax = create_card_canvas("5.4 Auditoría de Retención Sin Soporte", "El Salto al Vacío del Recuerdo Libre (Free Recall)")
    draw_rounded_box(ax, 10, 20, 80, 52, border=TEXT_LIGHT)
    ax.text(50, 62, "PROTOCOLO DE LA HOJA EN BLANCO", ha='center', color=TEXT_LIGHT, fontsize=11, fontweight='bold')
    ax.text(50, 42, "1. Cerrar internet, ChatGPT y notas de estudio.\n2. Tomar un lápiz y papel o abrir un bloc de notas vacío.\n3. Escribir de memoria la arquitectura completa, sintaxis y reglas de decisión.\n4. Comparar contra el modelo experto para medir con exactitud tu Calibración JOL.", ha='center', color=TEXT_MUTED, fontsize=9.5)
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo5_auditoria_soporte.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_21():
    fig, ax = create_card_canvas("6.1 El Artefacto Mínimo Viable (AMV)", "El Entregable Tangible que Certifica tu Competencia Funcional")
    draw_rounded_box(ax, 15, 20, 70, 52, border="#10B981")
    ax.text(50, 63, "DE LA TEORÍA AL ENTREGABLE DEL MUNDO REAL", ha='center', color="#10B981", fontsize=11, fontweight='bold')
    ax.text(50, 43, "• Un reporte gerencial automatizado con segmentadores dinámicos.\n• Un script de scraping funcional testeado y documentado.\n• Una propuesta de valoración financiera defendida paso a paso.\n• Una guía de arquitectura de software para producción.", ha='center', color=TEXT_LIGHT, fontsize=9.5)
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo6_artefacto_amv.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_22():
    fig, ax = create_card_canvas("6.2 Co-creación y Revisión Experta", "Usando a la IA como Colega Senior para Auditar la Entrega")
    draw_rounded_box(ax, 15, 20, 70, 50, border=BLUE_ACCENT)
    ax.text(50, 61, "RÚBRICA DE AUDITORÍA PROFESIONAL DE NIVEL SENIOR", ha='center', color=CYAN_ACCENT, fontsize=11, fontweight='bold')
    ax.plot([20, 80], [54, 54], color=BORDER_COLOR, lw=1)
    ax.text(50, 36, "1. Robustez ante fallos: ¿Qué ocurre si un input viene corrupto?\n2. Elegancia y simplicidad: ¿Se puede lograr lo mismo con un 30% menos de complejidad?\n3. Documentación y transferencia: ¿Puede un tercero entenderlo sin consultarte?", ha='center', color=TEXT_LIGHT, fontsize=9)
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo6_revision_experta.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_23():
    fig, ax = create_card_canvas("6.3 Construcción del Segundo Cerebro", "Base de Conocimiento Interconectada en Obsidian o Notion (PARA + Zettelkasten)")
    pillars = [
        ("1. PROYECTOS", "Metas de 14 días activas"),
        ("2. ÁREAS", "Habilidades en mantenimiento"),
        ("3. RECURSOS", "Prompts maestros y plantillas"),
        ("4. ARCHIVO", "Artefactos completados")
    ]
    for idx, (title, desc) in enumerate(pillars):
        x = 9 + idx * 21
        draw_rounded_box(ax, x, 24, 19, 44, border=VIOLET_ACCENT)
        ax.text(x + 9.5, 56, title, ha='center', color=CYAN_ACCENT, fontsize=9.5, fontweight='bold')
        ax.text(x + 9.5, 38, desc, ha='center', color=TEXT_LIGHT, fontsize=8)
        
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo6_segundo_cerebro.png", facecolor=BG_DARK)
    plt.close()

def gen_ilust_24():
    fig, ax = create_card_canvas("6.4 El Mapa de Mantenimiento Cognitivo", "El Protocolo de 15 Minutos Semanales y el Ciclo Infinito de Aprendizaje")
    draw_rounded_box(ax, 12, 20, 76, 52, border=CYAN_ACCENT)
    ax.text(50, 63, "EL CICLO VITAL DEL APRENDIZ AUTÓNOMO", ha='center', color=CYAN_ACCENT, fontsize=11, fontweight='bold')
    ax.text(50, 44, "• Semana 1 a 4 post-programa: Repaso activo de 15 minutos de flashcards Anki.\n• Mes 2: Resolución de un caso límite nuevo sin asistencia de IA.\n• Mes 3 en adelante: La competencia funcional se vuelve un hábito arraigado.\n• Iniciar el siguiente sprint de 14 días para una nueva competencia estratégica.", ha='center', color=TEXT_LIGHT, fontsize=9)
    plt.tight_layout()
    plt.savefig(ILUST_DIR / "modulo6_mantenimiento.png", facecolor=BG_DARK)
    plt.close()

# -------------------------------------------------------------
# 2. GENERACIÓN DE PORTADA PLANA PROFESIONAL (portada_plana.png)
# -------------------------------------------------------------
def gen_portada_plana():
    # 1800 x 2400 px vertical
    fig, ax = plt.subplots(figsize=(9, 12), dpi=200)
    fig.patch.set_facecolor(BG_DARK)
    ax.set_facecolor(BG_DARK)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.axis('off')
    
    # Decoración de fondo (red geométrica sutil)
    for i in range(12):
        x1 = np.random.uniform(5, 95)
        y1 = np.random.uniform(25, 75)
        x2 = np.random.uniform(5, 95)
        y2 = np.random.uniform(25, 75)
        ax.plot([x1, x2], [y1, y2], color="#1E293B", lw=0.6, alpha=0.7)
        
    # Elemento central luminoso
    draw_rounded_box(ax, 20, 36, 60, 28, bg="#1E1B4B", border=CYAN_ACCENT, lw=2)
    ax.text(50, 52, "14 DÍAS", ha='center', color=CYAN_ACCENT, fontsize=32, fontweight='bold')
    ax.text(50, 43, "336 HORAS DE INMERSIÓN COGNITIVA", ha='center', color=TEXT_LIGHT, fontsize=11, fontweight='bold')
    
    # Textos superiores
    ax.text(50, 89, "MANUAL OFICIAL DE ADQUISICIÓN DE COMPETENCIAS", ha='center', color=CYAN_ACCENT, fontsize=9, fontweight='bold')
    ax.text(50, 81, "EL SISTEMA DE", ha='center', color=TEXT_LIGHT, fontsize=20, fontweight='bold')
    ax.text(50, 73, "APRENDIZAJE ACELERADO", ha='center', color=TEXT_LIGHT, fontsize=24, fontweight='bold')
    ax.text(50, 67, "CON INTELIGENCIA ARTIFICIAL", ha='center', color=CYAN_ACCENT, fontsize=18, fontweight='bold')
    
    # Subtítulo inferior
    ax.text(50, 26, "Un método práctico de 14 días para desarrollar\ncompetencias funcionales con inteligencia artificial", ha='center', color=TEXT_MUTED, fontsize=12, style='italic')
    
    # Footer de autoría
    ax.plot([25, 75], [14, 14], color=BORDER_COLOR, lw=1)
    ax.text(50, 9, "EQUIPO EDITORIAL INTELIGENTE & PROYECTO EBOOKS\nPRIMERA EDICIÓN PROFESIONAL — 2026", ha='center', color=TEXT_MUTED, fontsize=8.5)
    
    plt.tight_layout()
    plt.savefig(PORT_DIR / "portada_plana.png", facecolor=BG_DARK)
    plt.close()
    print("Portada plana generada en assets/portada/portada_plana.png")

# Ejecutar todo
def run_all():
    print("Generando ilustraciones técnicas 03 a 24...")
    gen_ilust_03()
    gen_ilust_04()
    gen_ilust_05()
    gen_ilust_06()
    gen_ilust_07()
    gen_ilust_08()
    gen_ilust_09()
    gen_ilust_10()
    gen_ilust_11()
    gen_ilust_12()
    gen_ilust_13()
    gen_ilust_14()
    gen_ilust_15()
    gen_ilust_16()
    gen_ilust_17()
    gen_ilust_18()
    gen_ilust_19()
    gen_ilust_20()
    gen_ilust_21()
    gen_ilust_22()
    gen_ilust_23()
    gen_ilust_24()
    print("Ilustraciones 03 a 24 generadas con éxito!")
    gen_portada_plana()

if __name__ == "__main__":
    run_all()
