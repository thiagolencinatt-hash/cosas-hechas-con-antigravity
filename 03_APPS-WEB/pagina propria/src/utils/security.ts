/**
 * LATHE ESSENCE — Módulo de Sanitización y Seguridad Frontend
 * Prevención de Ataques XSS (Cross-Site Scripting) e Inyección de Contenido Malicioso
 */

/**
 * Limpia y sanitiza cadenas de texto en formularios antes de procesarlas,
 * eliminando etiquetas HTML, vectores de scripts, manejadores de eventos y caracteres nulos.
 *
 * @param raw Texto crudo ingresado por el usuario
 * @param maxLength Longitud máxima permitida (por defecto 250 caracteres)
 * @returns Cadena sanitizada segura
 */
export function sanitizeInput(raw: string, maxLength: number = 250): string {
  if (typeof raw !== 'string') return '';

  // 1. Recortar espacios en blanco exteriores
  let clean = raw.trim();

  // 2. Eliminar bytes nulos y caracteres de control ASCII
  clean = clean.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '');

  // 3. Eliminar etiquetas de script, style, iframe, object, embed y su contenido completo
  clean = clean.replace(/<\s*(script|style|iframe|object|embed|applet|form|svg|base)[^>]*>[\s\S]*?<\s*\/\s*\1\s*>/gi, '');

  // 4. Eliminar cualquier otra etiqueta HTML remanente (<tag ...>)
  clean = clean.replace(/<[^>]+>/g, '');

  // 5. Desarmar pseudo-protocolos ejecutables (javascript:, vbscript:, data:)
  clean = clean.replace(/(javascript|vbscript|data):/gi, '');

  // 6. Eliminar manejadores de eventos inline (onerror=, onclick=, onload=, etc.)
  clean = clean.replace(/on\w+\s*=/gi, '');

  // 7. Limitar longitud máxima para mitigar ataques de desbordamiento de búfer / DoS
  if (clean.length > maxLength) {
    clean = clean.slice(0, maxLength);
  }

  return clean;
}

/**
 * Escapa caracteres especiales a entidades HTML seguras para representación visual.
 */
export function escapeHTML(str: string): string {
  if (typeof str !== 'string') return '';
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

/**
 * Sanitiza números telefónicos o de WhatsApp, permitiendo únicamente dígitos, +, -, parentesis y espacios.
 */
export function sanitizePhone(raw: string, maxLength: number = 30): string {
  if (typeof raw !== 'string') return '';
  const clean = raw.replace(/[^\d+\-\s()]/g, '').trim();
  return clean.slice(0, maxLength);
}

/**
 * Sanitiza correos electrónicos eliminando caracteres prohibidos y normalizando el formato.
 */
export function sanitizeEmail(raw: string, maxLength: number = 100): string {
  if (typeof raw !== 'string') return '';
  const clean = raw.trim().replace(/[<>"'`;\\$\s]/g, '');
  return clean.slice(0, maxLength);
}
