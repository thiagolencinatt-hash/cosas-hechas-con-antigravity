# RECURSO 07: TARJETAS DE RECUPERACIÓN ACTIVA (FLASHCARDS ATÓMICAS)

> **Kit Complementario:** El Sistema de Aprendizaje Acelerado con IA  
> **Fase del Método:** FASE 3: CONSOLIDAR  
> **Propósito:** Plantilla y guía de diseño de tarjetas de memoria atómicas basadas en el Efecto del Examen (Roediger & Karpicke, 2006).

---

## Reglas de Diseño de Tarjetas de Alta Retención
1. **Un solo átomo de conocimiento por tarjeta:** Si una tarjeta contiene dos preguntas, dividila en dos tarjetas.
2. **Preguntas de producción, no de reconocimiento:** Evitá *"¿Es X verdadero o falso?"*. Preguntá *"¿Qué sucede cuando ocurre X y por qué?"*.
3. **El reverso debe ser conciso:** Máximo 3 líneas. Las tarjetas largas fatigan la memoria de trabajo y no se pueden evaluar con rigor.
4. **Respuesta verbal antes de mirar:** Debés pronunciar en voz alta o escribir la respuesta antes de voltear la tarjeta.

---

## Banco de Tarjetas Rellenable (Para Imprimir o Exportar a Anki)

| ID | Anverso (Pregunta Conceptual / Desafío) | Reverso (Respuesta Atómica con Submeta) | Fecha Creación | Nivel Dominio (1-5) |
|---|---|---|---|---|
| **T01** | | | ___/___/___ | [ ] |
| **T02** | | | ___/___/___ | [ ] |
| **T03** | | | ___/___/___ | [ ] |
| **T04** | | | ___/___/___ | [ ] |
| **T05** | | | ___/___/___ | [ ] |
| **T06** | | | ___/___/___ | [ ] |
| **T07** | | | ___/___/___ | [ ] |
| **T08** | | | ___/___/___ | [ ] |
| **T09** | | | ___/___/___ | [ ] |
| **T10** | | | ___/___/___ | [ ] |
| **T11** | | | ___/___/___ | [ ] |
| **T12** | | | ___/___/___ | [ ] |

---

## Formato de Exportación Rápida a CSV / Anki
*(Copia y pega este bloque en el bloc de notas para importar directamente a Anki)*

```text
# Separador: Tabulación
# Campo 1: Pregunta (Anverso)	Campo 2: Respuesta (Reverso)
¿Pregunta conceptual 1?	Respuesta atómica breve 1
¿Pregunta conceptual 2?	Respuesta atómica breve 2
¿Pregunta conceptual 3?	Respuesta atómica breve 3
```

---

## Ejemplo Resuelto de Referencia (Caso: Marta - Mazo de Excel en Anki)

```text
¿Cuál es la ventaja fundamental de BUSCARX sobre BUSCARV?	BUSCARX busca hacia la izquierda y derecha indistintamente, y no se rompe si se insertan nuevas columnas.
¿Qué atajo de teclado transforma un rango ordinario en una Tabla Oficial de Excel?	Ctrl + T (o Ctrl + L según la configuración de idioma).
¿Cómo se bloquea únicamente la fila manteniendo la columna relativa en una fórmula?	Colocando el signo $ antes del número de fila (ejemplo: A$1).
¿Cuál es la función del cuarto argumento opcional en BUSCARX [si_no_se_encuentra]?	Devuelve un valor personalizado (como "No encontrado" o 0) en lugar del error #N/D.
¿Qué operador lógico exige que todas las condiciones evaluadas sean verdaderas?	La función Y(cond1; cond2; ...).
¿Por qué se deben evitar las referencias de celdas fijas en planillas dinámicas?	Porque impiden que la fórmula se ajuste automáticamente cuando se agregan nuevos registros o clientes.
```

---

## Prompt de Asistencia con IA para Rellenar esta Plantilla
```text
Actúa como un Especialista en Memoria de Trabajo y Retrieval Practice. Estoy estudiando: [TEMA O RESUMEN].
1. Extrae los 10 conceptos o reglas procedimentales más críticos.
2. Redacta 10 tarjetas de memoria atómicas en formato Anverso/Reverso.
3. Reglas estrictas: anversos basados en preguntas de producción activa (no reconocimiento pasivo); reversos de máximo 2 líneas sin texto superfluo.
4. Entrega el resultado en un bloque de código separado por tabulaciones listo para importar en Anki.
```

