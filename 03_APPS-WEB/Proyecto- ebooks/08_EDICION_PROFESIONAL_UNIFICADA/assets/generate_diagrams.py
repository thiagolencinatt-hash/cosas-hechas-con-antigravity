import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from pathlib import Path
import numpy as np

BASE_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks\08_EDICION_PROFESIONAL_UNIFICADA")
DIAG_DIR = BASE_DIR / "assets" / "diagramas"
DIAG_DIR.mkdir(parents=True, exist_ok=True)

# Paleta editorial
BG_DARK = "#0F172A"       # Azul marino profundo
BLUE_ACCENT = "#2563EB"   # Azul eléctrico
VIOLET_ACCENT = "#7C3AED" # Violeta técnico
CYAN_ACCENT = "#38BDF8"   # Cian brillante
TEXT_LIGHT = "#F8FAFC"    # Blanco puro
TEXT_MUTED = "#94A3B8"    # Gris pizarra suave
CARD_BG = "#1E293B"       # Gris azulado de contenedor
BORDER_COLOR = "#334155"  # Borde sutil
GREEN_ACCENT = "#10B981"  # Éxito / Consolidación
AMBER_ACCENT = "#F59E0B"  # Alerta / Evaluación

def create_diagram_canvas(title, subtitle="", width=12, height=6.75, dpi=200):
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
        
    ax.plot([5, 95], [83, 83], color=BORDER_COLOR, lw=1.2)
    return fig, ax

def draw_rounded_box(ax, x, y, w, h, bg=CARD_BG, border=BLUE_ACCENT, lw=1.5):
    rect = patches.FancyBboxPatch((x, y), w, h, boxstyle="round,pad=1.5", 
                                  facecolor=bg, edgecolor=border, linewidth=lw)
    ax.add_patch(rect)

# 1. Flujo de las cuatro fases
def diag_1():
    fig, ax = create_diagram_canvas("Diagrama 1: Flujo de las Cuatro Fases del Aprendizaje", "Arquitectura Cognitiva del Método de 14 Días")
    phases = [
        ("FASE 1: PREPARAR", "Días 1-2\nDeconstrucción y Filtro", BLUE_ACCENT, 8),
        ("FASE 2: COMPRENDER", "Días 3-7\nSocrático y Feynman", VIOLET_ACCENT, 31),
        ("FASE 3: CONSOLIDAR", "Días 8-12\nSimulador y Recuperación", CYAN_ACCENT, 54),
        ("FASE 4: DEMOSTRAR", "Días 13-14\nArtefacto y Segundo Cerebro", GREEN_ACCENT, 77)
    ]
    for title, desc, col, x in phases:
        draw_rounded_box(ax, x, 30, 15, 38, border=col)
        ax.text(x + 7.5, 60, title, ha='center', va='center', color=col, fontsize=9.5, fontweight='bold')
        ax.plot([x+2, x+13], [52, 52], color=BORDER_COLOR, lw=1)
        ax.text(x + 7.5, 42, desc, ha='center', va='center', color=TEXT_LIGHT, fontsize=9)
        if x < 70:
            ax.annotate("", xy=(x + 21, 49), xytext=(x + 16, 49),
                        arrowprops=dict(arrowstyle="->", color=CYAN_ACCENT, lw=2.5))
            
    # Bucle de retroalimentación
    ax.annotate("", xy=(15.5, 27), xytext=(84.5, 27),
                arrowprops=dict(arrowstyle="->", color=AMBER_ACCENT, lw=1.5, connectionstyle="arc3,rad=-0.2"))
    ax.text(50, 16, "BUCLE DE RETROALIMENTACIÓN Y CALIBRACIÓN CONTINUA", ha='center', color=AMBER_ACCENT, fontsize=8.5, fontweight='bold')
    plt.tight_layout()
    plt.savefig(DIAG_DIR / "diagrama_1_flujo_cuatro_fases.png", facecolor=BG_DARK)
    plt.close()

# 2. Mapa de descomposición de una habilidad
def diag_2():
    fig, ax = create_diagram_canvas("Diagrama 2: Mapa de Descomposición Quirúrgica", "Filtrado del 20% Crítico frente al 80% Accesorio")
    draw_rounded_box(ax, 6, 38, 20, 30, border=BLUE_ACCENT)
    ax.text(16, 57, "HABILIDAD\nCOMPLEJA", ha='center', va='center', color=TEXT_LIGHT, fontsize=12, fontweight='bold')
    ax.text(16, 45, "(Ej. Análisis de Datos)", ha='center', va='center', color=TEXT_MUTED, fontsize=9)
    
    ax.annotate("", xy=(32, 53), xytext=(27, 53), arrowprops=dict(arrowstyle="->", color=CYAN_ACCENT, lw=2))
    
    # 20% Esencial
    draw_rounded_box(ax, 33, 48, 28, 26, border=GREEN_ACCENT, bg="#064E3B")
    ax.text(47, 65, "20% ESENCIAL (CORE)", ha='center', va='center', color="#6EE7B7", fontsize=10, fontweight='bold')
    ax.text(47, 56, "• 5 Micro-competencias de alto impacto\n• Resuelven el 80% de casos reales", ha='center', va='center', color=TEXT_LIGHT, fontsize=8.5)
    
    # 80% Accesorio
    draw_rounded_box(ax, 33, 16, 28, 24, border="#E11D48", bg="#4C0519")
    ax.text(47, 31, "80% ACCESORIO (RUIDO)", ha='center', va='center', color="#FDA4AF", fontsize=10, fontweight='bold')
    ax.text(47, 23, "• Funciones exóticas / sintaxis rara\n• Congeladas durante los 14 días", ha='center', va='center', color=TEXT_LIGHT, fontsize=8.5)
    
    ax.annotate("", xy=(68, 61), xytext=(62, 61), arrowprops=dict(arrowstyle="->", color=CYAN_ACCENT, lw=2))
    
    # Bloques de 45 min
    draw_rounded_box(ax, 69, 32, 25, 42, border=VIOLET_ACCENT)
    ax.text(81.5, 66, "BLOQUES DE 45 MIN", ha='center', va='center', color=CYAN_ACCENT, fontsize=11, fontweight='bold')
    ax.text(81.5, 48, "Micro-competencia 1: 45m\nMicro-competencia 2: 45m\nMicro-competencia 3: 45m\nMicro-competencia 4: 45m", ha='center', va='center', color=TEXT_LIGHT, fontsize=8.5)
    
    plt.tight_layout()
    plt.savefig(DIAG_DIR / "diagrama_2_mapa_descomposicion.png", facecolor=BG_DARK)
    plt.close()

# 3. Arquitectura del prompt socrático
def diag_3():
    fig, ax = create_diagram_canvas("Diagrama 3: Anatomía y Arquitectura del Prompt Socrático", "Los Cuatro Componentes del Tutor Cognitivo Anti-Complaciente")
    blocks = [
        ("1. ROL Y AUTORIDAD", "Tutor socrático doctoral con rigor implacable", BLUE_ACCENT, 20),
        ("2. REGLA NEGATIVA", "PROHIBIDO entregar soluciones directas o código completo", "#E11D48", 40),
        ("3. ANDAMIAJE GRADUAL", "Hacer 1 sola pregunta a la vez adaptada a la respuesta", VIOLET_ACCENT, 60),
        ("4. RÚBRICA Y AUDITORÍA", "Diagnosticar errores lógicos antes de avanzar al siguiente nivel", GREEN_ACCENT, 80)
    ]
    for idx, (title, desc, col, y) in enumerate(reversed(blocks)):
        y_pos = 18 + idx * 15
        draw_rounded_box(ax, 12, y_pos, 76, 11, border=col)
        ax.text(16, y_pos + 5.5, title, va='center', color=col, fontsize=10.5, fontweight='bold')
        ax.text(46, y_pos + 5.5, desc, va='center', color=TEXT_LIGHT, fontsize=9)
        
    plt.tight_layout()
    plt.savefig(DIAG_DIR / "diagrama_3_arquitectura_prompt_socratico.png", facecolor=BG_DARK)
    plt.close()

# 4. Escalera de andamiaje
def diag_4():
    fig, ax = create_diagram_canvas("Diagrama 4: Escalera de Andamiaje Cognitivo", "Transferencia Progresiva de Responsabilidad (Wood & Bruner)")
    steps = [
        ("NIVEL 4: AUTONOMÍA TOTAL", "Resolución independiente en casos ciegos de producción", GREEN_ACCENT, 70, 72),
        ("NIVEL 3: ANDAMIAJE LIGERO", "Problemas semi-estructurados con pistas lógicas mínimas", CYAN_ACCENT, 52, 54),
        ("NIVEL 2: EJEMPLO TRABAJADO", "Desglose guiado de modelo mental paso a paso", VIOLET_ACCENT, 34, 36),
        ("NIVEL 1: ANALOGÍA BASE", "Conexión con conocimiento previo existente", BLUE_ACCENT, 16, 18)
    ]
    for title, desc, col, x_start, y_pos in steps:
        draw_rounded_box(ax, 10, y_pos, x_start + 18, 12, border=col)
        ax.text(14, y_pos + 6, title, va='center', color=col, fontsize=10, fontweight='bold')
        ax.text(x_start + 25, y_pos + 6, desc, va='center', color=TEXT_LIGHT, fontsize=8.5)
        
    plt.tight_layout()
    plt.savefig(DIAG_DIR / "diagrama_4_escalera_andamiaje.png", facecolor=BG_DARK)
    plt.close()

# 5. Proceso Feynman
def diag_5():
    fig, ax = create_diagram_canvas("Diagrama 5: Protocolo Feynman Acelerado con IA", "Ciclo de Claridad Conceptual y Detección de Puntos Ciegos")
    nodes = [
        ("1. EXPLICACIÓN SIMPLE", "Sin jerga técnica\nLenguaje llano", 15, 50, BLUE_ACCENT),
        ("2. AUDITORÍA IA", "Detección de lagunas\ny falsas asunciones", 38, 50, VIOLET_ACCENT),
        ("3. RE-ESTUDIO QUIRÚRGICO", "Revisión focalizada\nde la brecha", 61, 50, CYAN_ACCENT),
        ("4. SÍNTESIS ANALÓGICA", "Analogía validada\ny anclaje mental", 84, 50, GREEN_ACCENT)
    ]
    for title, desc, x, y, col in nodes:
        draw_rounded_box(ax, x - 10, y - 16, 20, 32, border=col)
        ax.text(x, y + 6, title, ha='center', va='center', color=col, fontsize=9.5, fontweight='bold')
        ax.plot([x - 7, x + 7], [y - 1, y - 1], color=BORDER_COLOR, lw=1)
        ax.text(x, y - 8, desc, ha='center', va='center', color=TEXT_LIGHT, fontsize=8.5)
        if x < 80:
            ax.annotate("", xy=(x + 11, y), xytext=(x + 9, y), arrowprops=dict(arrowstyle="->", color=CYAN_ACCENT, lw=2))
            
    # Flecha de iteración
    ax.annotate("", xy=(38, 28), xytext=(61, 28),
                arrowprops=dict(arrowstyle="->", color=AMBER_ACCENT, lw=1.5, connectionstyle="arc3,rad=-0.3"))
    ax.text(49.5, 20, "Re-calibración inmediata", ha='center', color=AMBER_ACCENT, fontsize=8)
    plt.tight_layout()
    plt.savefig(DIAG_DIR / "diagrama_5_proceso_feynman.png", facecolor=BG_DARK)
    plt.close()

# 6. Bucle de retroalimentación
def diag_6():
    fig, ax = create_diagram_canvas("Diagrama 6: Bucle de Retroalimentación en Simulador", "Práctica Deliberada con IA como Evaluador Ciego")
    draw_rounded_box(ax, 10, 45, 22, 28, border=BLUE_ACCENT)
    ax.text(21, 62, "ESCENARIO\nREALISTA", ha='center', color=CYAN_ACCENT, fontsize=10.5, fontweight='bold')
    ax.text(21, 51, "Crisis / Datos sucios /\nPresión temporal", ha='center', color=TEXT_LIGHT, fontsize=8.5)
    
    draw_rounded_box(ax, 40, 45, 22, 28, border=VIOLET_ACCENT)
    ax.text(51, 62, "EJECUCIÓN\nDEL USUARIO", ha='center', color=VIOLET_ACCENT, fontsize=10.5, fontweight='bold')
    ax.text(51, 51, "Sin muletas /\nDecisiones reales", ha='center', color=TEXT_LIGHT, fontsize=8.5)
    
    draw_rounded_box(ax, 70, 45, 22, 28, border=GREEN_ACCENT)
    ax.text(81, 62, "FEEDBACK\nINMEDIATO", ha='center', color=GREEN_ACCENT, fontsize=10.5, fontweight='bold')
    ax.text(81, 51, "Diagnóstico micro /\nPlan de corrección", ha='center', color=TEXT_LIGHT, fontsize=8.5)
    
    ax.annotate("", xy=(39, 59), xytext=(33, 59), arrowprops=dict(arrowstyle="->", color=CYAN_ACCENT, lw=2))
    ax.annotate("", xy=(69, 59), xytext=(63, 59), arrowprops=dict(arrowstyle="->", color=CYAN_ACCENT, lw=2))
    ax.annotate("", xy=(21, 43), xytext=(81, 43),
                arrowprops=dict(arrowstyle="->", color=AMBER_ACCENT, lw=2, connectionstyle="arc3,rad=-0.25"))
    ax.text(51, 25, "INCREMENTO DE DIFICULTAD (+10% COMPLEJIDAD TRAS APROBAR)", ha='center', color=AMBER_ACCENT, fontsize=9, fontweight='bold')
    plt.tight_layout()
    plt.savefig(DIAG_DIR / "diagrama_6_bucle_retroalimentacion.png", facecolor=BG_DARK)
    plt.close()

# 7. Calendario de 14 días
def diag_7():
    fig, ax = create_diagram_canvas("Diagrama 7: Calendario Operativo de 14 Días", "De Cero a Artefacto Mínimo Viable Funcional")
    days_data = [
        ("D1", "Deconstrucción", BLUE_ACCENT), ("D2", "Microcompetencias", BLUE_ACCENT),
        ("D3", "Prompt Socrático", VIOLET_ACCENT), ("D4", "Andamiaje", VIOLET_ACCENT),
        ("D5", "Feynman 1", CYAN_ACCENT), ("D6", "Feynman 2", CYAN_ACCENT), ("D7", "Puntos Ciegos", CYAN_ACCENT),
        ("D8", "Simulador 1", "#10B981"), ("D9", "Simulador 2", "#10B981"), ("D10", "Dificultad +", "#10B981"),
        ("D11", "Examen Ciego", AMBER_ACCENT), ("D12", "Spaced Review", AMBER_ACCENT),
        ("D13", "AMV Pruebas", "#EC4899"), ("D14", "Segundo Cerebro", "#EC4899")
    ]
    for idx, (d, desc, col) in enumerate(days_data):
        x = 5 + (idx % 7) * 13
        y = 48 if idx < 7 else 18
        draw_rounded_box(ax, x, y, 11.5, 24, border=col)
        ax.text(x + 5.75, y + 17, d, ha='center', color=col, fontsize=12, fontweight='bold')
        ax.plot([x + 1.5, x + 10], [y + 12, y + 12], color=BORDER_COLOR, lw=1)
        ax.text(x + 5.75, y + 6, desc, ha='center', color=TEXT_LIGHT, fontsize=7.5, fontweight='bold')
        
    ax.text(50, 77, "SEMANA 1: ADQUISICIÓN Y COMPRENSIÓN (D1-D7)  |  SEMANA 2: APLICACIÓN Y BLINDAJE (D8-D14)", ha='center', color=CYAN_ACCENT, fontsize=9.5, fontweight='bold')
    plt.tight_layout()
    plt.savefig(DIAG_DIR / "diagrama_7_calendario_14_dias.png", facecolor=BG_DARK)
    plt.close()

# 8. Ciclo de recuperación activa
def diag_8():
    fig, ax = create_diagram_canvas("Diagrama 8: Curva del Olvido y Recuperación Espaciada", "Aplanamiento de la Curva de Ebbinghaus mediante Recuperación Activa")
    x = np.linspace(0, 14, 200)
    # Curva sin repaso
    y_decay = 100 * np.exp(-x / 2.5)
    ax.plot(x * 5.8 + 10, y_decay * 0.5 + 20, color="#EF4444", lw=2, linestyle="--", label="Sin repaso (Pérdida 80%)")
    
    # Repasos en D1, D3, D7, D14
    repasos = [1, 3, 7, 14]
    for r in repasos:
        rx = r * 5.8 + 10
        ax.axvline(rx, color=CYAN_ACCENT, lw=1, alpha=0.4, linestyle=":")
        ax.plot([rx], [68], marker='o', markersize=6, color=CYAN_ACCENT)
        ax.text(rx, 72, f"R{repasos.index(r)+1}", ha='center', color=CYAN_ACCENT, fontsize=8.5, fontweight='bold')
        
    # Curva con repaso
    ax.plot([10, 15.8, 27.4, 50.6, 91.2], [70, 68, 69, 70, 71], color=GREEN_ACCENT, lw=2.5, label="Con Recuperación Espaciada (+25% Retención)")
    ax.text(50, 16, "CADA ACTO DE RECUPERACIÓN ESFUERZA LA RECONSOLIDACIÓN MNÉMICA", ha='center', color=TEXT_LIGHT, fontsize=9, fontweight='bold')
    plt.tight_layout()
    plt.savefig(DIAG_DIR / "diagrama_8_ciclo_recuperacion_activa.png", facecolor=BG_DARK)
    plt.close()

# 9. Esquema segundo cerebro
def diag_9():
    fig, ax = create_diagram_canvas("Diagrama 9: Esquema del Segundo Cerebro Funcional", "Arquitectura Integrada: Captura, Destilación Zettelkasten y Mantenimiento")
    steps = [
        ("1. CAPTURAR", "Notas de sesión\nPrompts usados\nErrores y fixes", BLUE_ACCENT, 8),
        ("2. ORGANIZAR", "Estructura P.A.R.A.\nProyectos activos\nRecursos clave", VIOLET_ACCENT, 31),
        ("3. DESTILAR", "Notas atómicas\nZettelkasten técnico\nConexiones", CYAN_ACCENT, 54),
        ("4. EXPRESAR", "Artefacto AMV\nBiblioteca personal\nRetención 30d", GREEN_ACCENT, 77)
    ]
    for title, desc, col, x in steps:
        draw_rounded_box(ax, x, 30, 15, 38, border=col)
        ax.text(x + 7.5, 60, title, ha='center', va='center', color=col, fontsize=10, fontweight='bold')
        ax.plot([x+2, x+13], [52, 52], color=BORDER_COLOR, lw=1)
        ax.text(x + 7.5, 42, desc, ha='center', va='center', color=TEXT_LIGHT, fontsize=8.5)
        if x < 70:
            ax.annotate("", xy=(x + 21, 49), xytext=(x + 16, 49),
                        arrowprops=dict(arrowstyle="->", color=CYAN_ACCENT, lw=2.5))
            
    ax.text(50, 16, "EL CONOCIMIENTO NO MANTENIDO SE DISIPA; EL SEGUNDO CEREBRO LO PERPETÚA", ha='center', color=TEXT_MUTED, fontsize=8.5, fontweight='bold')
    plt.tight_layout()
    plt.savefig(DIAG_DIR / "diagrama_9_esquema_segundo_cerebro.png", facecolor=BG_DARK)
    plt.close()

if __name__ == "__main__":
    print("Generando los 9 diagramas educativos...")
    diag_1()
    diag_2()
    diag_3()
    diag_4()
    diag_5()
    diag_6()
    diag_7()
    diag_8()
    diag_9()
    print("9 diagramas generados con éxito en assets/diagramas!")
