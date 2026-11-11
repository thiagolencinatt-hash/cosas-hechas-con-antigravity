import os
import re
from pathlib import Path

BASE_DIR = Path(r"c:\Users\thiago\Desktop\inteligencia artificial\antigravity\cosas hechas con antigravity\03_APPS-WEB\Proyecto- ebooks")
EDICION_DIR = BASE_DIR / "08_EDICION_PROFESIONAL_UNIFICADA"
MANUSCRITO_FILE = EDICION_DIR / "manuscrito" / "MANUSCRITO_UNIFICADO_DEFINITIVO.md"

with open(BASE_DIR / "boceto mejorado ebook .md", "r", encoding="utf-8") as f:
    boceto2_text = f.read()

with open(BASE_DIR / "03_MANUSCRITO" / "MANUSCRITO_COMPLETO.md", "r", encoding="utf-8") as f:
    antigravity_text = f.read()

# Mapeo de reemplazos de imágenes:
# En boceto 2, cada sección contiene "### **Prompt para generar una imagen ilustrativa**"
# seguido de una descripción entre comillas o bloque de texto.
# Reemplazaremos cada bloque de prompt con la imagen real ya generada.

IMAGE_REPLACEMENTS = [
    # MÓDULO 1
    (1, "assets/ilustraciones/modulo1_deconstruccion.png", 
     "Figura 1.1: Deconstrucción Quirúrgica de una Habilidad Macro en sus Componentes Fundamentales."),
    (2, "assets/ilustraciones/modulo1_filtro_relevancia.png", 
     "Figura 1.2: El Filtro de Relevancia Industrial (Separación del 20% Esencial frente al 80% Accesorio)."),
    (3, "assets/ilustraciones/modulo1_microcompetencias.png", 
     "Figura 1.3: Mapeo y Atomización de Microcompetencias en Bloques Cognitivos de 45 Minutos."),
    (4, "assets/ilustraciones/modulo1_cronograma.png", 
     "Figura 1.4: El Cronograma Adaptativo de 336 Horas (Matriz Temporal de 14 Días de Inmersión Focalizada)."),
    
    # MÓDULO 2
    (5, "assets/ilustraciones/modulo2_complacencia.png", 
     "Figura 2.1: La Trampa de la Complacencia de la IA y el Espejismo de la Comprensión Pasiva."),
    (6, "assets/ilustraciones/modulo2_anatomia_prompt.png", 
     "Figura 2.2: Anatomía de las Cuatro Capas de un Prompt Socrático Anti-Complaciente."),
    (7, "assets/ilustraciones/modulo2_andamiaje.png", 
     "Figura 2.3: La Escalera de Andamiaje Cognitivo y Retirada Progresiva de Asistencia (Wood & Bruner)."),
    (8, "assets/ilustraciones/modulo2_entorno_trabajo.png", 
     "Figura 2.4: Configuración del Entorno de Trabajo Técnico y Calibración de Instrucciones del Sistema."),
    
    # MÓDULO 3
    (9, "assets/ilustraciones/modulo3_feynman.png", 
     "Figura 3.1: El Protocolo Feynman Acelerado con IA: Destilación Conceptual en Lenguaje Simple."),
    (10, "assets/ilustraciones/modulo3_analogias.png", 
     "Figura 3.2: Generación y Calibración de Analogías Isomórficas Cruzadas."),
    (11, "assets/ilustraciones/modulo3_puntos_ciegos.png", 
     "Figura 3.3: Detección Quirúrgica de Puntos Ciegos e Ilusiones de Competencia."),
    (12, "assets/ilustraciones/modulo3_resumenes.png", 
     "Figura 3.4: Síntesis Estructurada en Redes de Nodos Conceptuales Interconectados."),
    
    # MÓDULO 4
    (13, "assets/ilustraciones/modulo4_simulador.png", 
     "Figura 4.1: La Cabina del Simulador de Vuelo Profesional: Práctica Deliberada con IA."),
    (14, "assets/ilustraciones/modulo4_escenarios.png", 
     "Figura 4.2: Inyección de Escenarios Inesperados, Datos Corruptos y Gestión de Crisis."),
    (15, "assets/ilustraciones/modulo4_retroalimentacion.png", 
     "Figura 4.3: El Bucle de Retroalimentación Inmediata de Anders Ericsson."),
    (16, "assets/ilustraciones/modulo4_dificultad.png", 
     "Figura 4.4: Progresión Dinámica de Dificultad (+10% de Complejidad en Zona de Desarrollo Próximo)."),
    
    # MÓDULO 5
    (17, "assets/ilustraciones/modulo5_examen_ciego.png", 
     "Figura 5.1: El Examen Ciego: Evaluación Sin Apuntes, Desconectado y a Pantalla Limpia."),
    (18, "assets/ilustraciones/modulo5_recuperacion_activa.png", 
     "Figura 5.2: Recuperación Activa ('Testing Effect') vs. la Ilusión de la Relectura Pasiva."),
    (19, "assets/ilustraciones/modulo5_repeticion_espaciada.png", 
     "Figura 5.3: El Algoritmo de Repetición Espaciada y Consolidación Sináptica a Largo Plazo."),
    (20, "assets/ilustraciones/modulo5_debate_socratico.png", 
     "Figura 5.4: El Debate Socrático de Falsación con el Abogado del Diablo."),
    
    # MÓDULO 6
    (21, "assets/ilustraciones/modulo6_artefacto_amv.png", 
     "Figura 6.1: Construcción del Artefacto Mínimo Viable (AMV): La Evidencia Tangible de Competencia."),
    (22, "assets/ilustraciones/modulo6_segundo_cerebro.png", 
     "Figura 6.2: Arquitectura del Segundo Cerebro Funcional (Sistemas P.A.R.A. y Zettelkasten)."),
    (23, "assets/ilustraciones/modulo6_evaluacion_final.png", 
     "Figura 6.3: Rúbrica Cuantitativa de Evaluación Final y Auditoría Externa de Desempeño."),
    (24, "assets/ilustraciones/modulo6_mantenimiento.png", 
     "Figura 6.4: Plan de Mantenimiento Continuo de 30 Días para Prevenir la Atrofia Cognitiva.")
]

# Diagramas que se intercalan estratégicamente:
DIAGRAM_INSERTS = {
    "diagrama_1": ("assets/diagramas/diagrama_1_flujo_cuatro_fases.png", 
                   "Diagrama 1: Flujo de las Cuatro Fases del Aprendizaje Acelerado con IA."),
    "diagrama_2": ("assets/diagramas/diagrama_2_mapa_descomposicion.png", 
                   "Diagrama 2: Mapa de Descomposición Quirúrgica: Separación del 20% Crítico."),
    "diagrama_3": ("assets/diagramas/diagrama_3_arquitectura_prompt_socratico.png", 
                   "Diagrama 3: Anatomía y Arquitectura del Prompt Socrático de Cuatro Capas."),
    "diagrama_4": ("assets/diagramas/diagrama_4_escalera_andamiaje.png", 
                   "Diagrama 4: Escalera de Andamiaje Cognitivo y Transferencia de Responsabilidad."),
    "diagrama_5": ("assets/diagramas/diagrama_5_proceso_feynman.png", 
                   "Diagrama 5: Protocolo Feynman Acelerado con Inteligencia Artificial."),
    "diagrama_6": ("assets/diagramas/diagrama_6_bucle_retroalimentacion.png", 
                   "Diagrama 6: Bucle de Retroalimentación en Simulador de Vuelo."),
    "diagrama_7": ("assets/diagramas/diagrama_7_calendario_14_dias.png", 
                   "Diagrama 7: Calendario Operativo de 14 Días (Matriz de Ejecución Diaria)."),
    "diagrama_8": ("assets/diagramas/diagrama_8_ciclo_recuperacion_activa.png", 
                   "Diagrama 8: Curva del Olvido de Ebbinghaus y Aplanamiento con Recuperación Espaciada."),
    "diagrama_9": ("assets/diagramas/diagrama_9_esquema_segundo_cerebro.png", 
                   "Diagrama 9: Esquema del Segundo Cerebro Funcional (Captura, Destilación y Expresión).")
}

print("Configuración de imágenes y diagramas lista.")
