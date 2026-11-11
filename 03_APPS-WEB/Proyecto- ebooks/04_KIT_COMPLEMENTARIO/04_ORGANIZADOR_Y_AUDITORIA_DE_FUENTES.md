# RECURSO 04: ORGANIZADOR Y AUDITORÍA DE FUENTES DE ESTUDIO

> **Kit Complementario:** El Sistema de Aprendizaje Acelerado con IA  
> **Fase del Método:** FASE 1: PREPARAR  
> **Propósito:** Curar críticamente un repositorio documental limpio (Regla de 2 Fuentes) para alimentar a asistentes como NotebookLM y erradicar alucinaciones.

---

## La Regla de Oro: Máximo 2 Fuentes Maestras
* **Fuente A (Fundamento Teórico/Técnico):** Manual canónico oficial o libro de referencia.
* **Fuente B (Laboratorio de Casos Prácticos):** Guía de ejercicios resueltos o documentación de código/casos reales.
* *Todo lo demás:* Se descarta temporalmente para evitar la sobrecarga extrínseca.

---

## Matriz de Evaluación de Fuentes

| Criterio de Selección | Fuente Candidata 1 | Fuente Candidata 2 | Fuente Candidata 3 |
|---|---|---|---|
| **Nombre del Libro / Documento:** | | | |
| **Autor / Institución Emisora:** | | | |
| **Año de Publicación / Versión:** | | | |
| **¿Es fuente primaria o secundaria?:** | [ ] Primaria  [ ] Secundaria | [ ] Primaria  [ ] Secundaria | [ ] Primaria  [ ] Secundaria |
| **¿Contiene ejemplos resueltos paso a paso?:** | [ ] SÍ  [ ] NO | [ ] SÍ  [ ] NO | [ ] SÍ  [ ] NO |
| **¿Está actualizada a la versión vigente?:** | [ ] SÍ  [ ] NO | [ ] SÍ  [ ] NO | [ ] SÍ  [ ] NO |
| **Veredicto:** | [ ] SELECCIONADA  [ ] DESCARTADA | [ ] SELECCIONADA  [ ] DESCARTADA | [ ] SELECCIONADA  [ ] DESCARTADA |

---

## Repositorio Oficial del Proyecto (Para Cargar en NotebookLM)

1. **FUENTE MAESTRA 1 (Técnica):**
   - Título: __________________________________________________________________
   - Ubicación del archivo / URL: _____________________________________________
   - Capítulos o módulos específicos a utilizar: ______________________________

2. **FUENTE MAESTRA 2 (Práctica):**
   - Título: __________________________________________________________________
   - Ubicación del archivo / URL: _____________________________________________
   - Ejercicios o casos seleccionados: _______________________________________

### Registro de Alucinaciones o Discrepancias Detectadas
*(Anotar aquí si la IA genera alguna respuesta que contradiga estas dos fuentes maestras)*
- [Fecha: ___/___/___] -> Concepto: __________________________________________
  * Lo que dijo la IA: _______________________________________________________
  * Lo que dice la Fuente Oficial: ___________________________________________
  * Corrección aprendida: ____________________________________________________

---

## Ejemplo Resuelto de Referencia (Caso: Marta - Fuentes de Excel)

* **Fuente Maestra 1 (Técnica Oficial):** Documentación oficial de Microsoft Support / Learn sobre funciones de matriz dinámica y `BUSCARX`.
* **Fuente Maestra 2 (Práctica Aplicada):** Guía práctica de modelado financiero y casos de auditoría de planillas administrativas de Harvard Business Review / editorial profesional.
* **Fuentes descartadas por Marta:** 30 tutoriales dispersos de TikTok/YouTube con fórmulas desactualizadas (`BUSCARV` obsoleto) y hilos de foros sin validar.
* **Registro de Discrepancia real auditada por Marta:**
  - *Afirmación de la IA genérica:* Dijo que `BUSCARX` requería ordenar las columnas alfabéticamente de menor a mayor.
  - *Fuente oficial Microsoft:* Demostró que `BUSCARX` no requiere ordenamiento previo (a diferencia de `BUSCARV` en coincidencia aproximada).
  - *Corrección aprendida:* `BUSCARX` busca por defecto de arriba hacia abajo sin importar el orden de los datos.

---

## Prompt de Asistencia con IA para Rellenar esta Plantilla
```text
Actúa como un Bibliógrafo Académico y Curador de Contenidos. Estoy aprendiendo: [TEMA].
1. Recomiéndame las 2 Fuentes Maestras canónicas (una de fundamento técnico riguroso y otra de ejercicios prácticos reales).
2. Justifica por qué descartamos otras fuentes populares superficiales.
3. Enumera los 3 errores técnicos o mitos más comunes que suelen propagarse en internet sobre este tema para que esté alerta y los audite en mis lecturas.
```

