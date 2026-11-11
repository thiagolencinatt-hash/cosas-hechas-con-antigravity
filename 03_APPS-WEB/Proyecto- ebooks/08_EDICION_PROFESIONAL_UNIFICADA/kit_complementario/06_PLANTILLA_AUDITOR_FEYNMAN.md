# Plantilla 06: Auditor Feynman de Claridad Conceptual y Brechas

> **Módulo Asociado:** Módulo 3: Asimilación Acelerada y Técnica Feynman (Días 5 al 7)  
> **Objetivo:** Facilitar la aplicación inmediata y deliberada de la metodología.

---

## 1. Instrucciones de Uso
El método de Richard Feynman establece que si no puedes explicar un concepto con palabras sencillas y sin jerga a un profano, en realidad no lo has comprendido. Utiliza esta plantilla para redactar tu explicación con lenguaje llano y auditarla mediante la IA para encontrar baches lógicos y falsas ilusiones de competencia.

---

## 2. Ejemplo Resuelto en un Entorno Real
### Ejemplo Resuelto: Marta explicando 'Power Query'
- **Explicación de Marta:** "Power Query es como una cinta transportadora en una cocina industrial. Tomas verduras sucias de diferentes camiones (archivos Excel desordenados), las lavas, pelas las partes podridas (eliminas columnas vacías y espacios) y las entregas limpias y picadas al chef (el modelo de reporte). Cada vez que llega un camión nuevo, solo aprietas un botón y la máquina repite exactamente los mismos pasos sin que tengas que picar nada a mano."
- **Auditoría de la IA:** "Excelente analogía culinaria. Sin embargo, omitiste un detalle crítico: ¿qué ocurre si el camión llega con una verdura que la máquina no reconoce (un cambio en el nombre de una columna del CSV)? Ahí tu cinta transportadora se traba con un error de esquema."
- **Calibración de Marta:** Marta añade el paso de manejo de excepciones y columnas dinámicas.

---

## 3. Hoja de Trabajo y Campos para Completar
### Campos de Trabajo: Hoja de Auditoría Feynman

1. **Concepto Clave a Explicar:**
   `[Nombre del concepto técnico complejo]`

2. **Mi Explicación en Lenguaje Simple (Prohibida la Jerga):**
   `[Escribe tu explicación como si se la contaras a un joven de 14 años o a un familiar sin formación técnica]`

3. **Analogía Utilizada:**
   `[¿A qué objeto, proceso cotidiano o fenómeno del mundo real se parece este concepto?]`

4. **Brechas Identificadas por la IA:**
   - Brecha 1: `[Bache conceptual detectado]`
   - Brecha 2: `[Asunción errónea corregida]`

5. **Explicación Refinada y Definitiva:**
   `[Reescritura final integrando la corrección de las brechas]`

---

## 4. Prompt de Asistencia con Inteligencia Artificial
Copia y pega este prompt en tu modelo de lenguaje (ChatGPT, Claude o Gemini) para que actúe como tu tutor o auditor en esta etapa:

```markdown
Actúa como un Auditor Lógico de la Técnica Feynman.
He redactado la siguiente explicación para un concepto que estoy aprendiendo: [INSERTAR CONCEPTO].
Aquí está mi explicación:
"""
[INSERTAR TU EXPLICACIÓN]
"""

Tu misión:
1. Detecta cualquier palabra técnica o jerga que haya usado para 'disfrazar' una falta de comprensión real.
2. Identifica el punto ciego o salto lógico más evidente en mi explicación.
3. Evalúa mi analogía: ¿es precisa o genera confusiones conceptuales colaterales?
4. Hazme una sola pregunta capciosa sobre una situación extrema donde mi modelo mental fallaría.
```
