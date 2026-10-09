# FinanzApp Ultra — Project Checkpoint (LARI Level 17)

**Última actualización:** 25 de Septiembre de 2026
**Estado del Proyecto:** Estable (LARI Nivel 17 completado — GEL-021 resuelto)

## Arquitectura y Stack Tecnológico
- **Framework Core:** Next.js 16.3.3 (App Router)
- **UI & Componentes:** React 19, Tailwind CSS v4, Lucide Icons, UI Components (shadcn/ui style), Glassmorphism/3D Depth UI.
- **Base de Datos & Backend:** Supabase (PostgreSQL), DDL inicializado, RLS (Row Level Security) configurado.
- **Hosting / Deploy:** Vercel
- **Inteligencia Artificial:** Google GenAI SDK (Gemini) integrado vía API Routes (`/api/ai-assistant`).

## Módulos Estabilizados y Operativos
Se ha completado el ciclo de estabilización profunda (LARI Level 17), con blindaje total contra colapso del dashboard:

- **Autenticación:** Sistema de login seguro y operativo.
- **Arquitectura Local-First:** Implementación de persistencia híbrida (Supabase Cloud-First + Optimistic LocalStorage). Si Supabase falla, la app sobrevive en estado local previniendo pérdida de datos (Zero-Data-Loss).
- **Auto-Seed de Cuentas:** Se garantiza la creación automática de la cuenta "Efectivo" si el usuario registra movimientos y no tiene cuentas pre-existentes, evitando fallos de _Foreign Key_.
- **Recálculo Dinámico de Balances:** Eliminación definitiva del "Bug del Balance $0". Los saldos se recalculan correctamente en base a las transacciones confirmadas.
- **Exportación Segura:** Exportaciones a Excel JSON y chequeos de salud operando en modo estrictamente *Read-Only* (`type="button"`).
- **Asistente IA (Gemini):** *Function calling* operativo para registrar transacciones (`create_transaction`). Las mutaciones respetan el esquema de base de datos.
- **Historial Consistente:** Sincronización instantánea de transacciones mediante eventos del DOM (`finance-refresh`).
- **Gestión de Cuentas:** CRUD completo con transferencias atómicas bidireccionales.
- **Presupuestos Mensuales:** CRUD con consumo dinámico calculado sobre transacciones reales.
- **Metas de Ahorro:** Planificación, aportes híbridos y asignación salarial.
- **Analíticas Avanzadas:** Gráficos con Recharts, filtros temporales y métricas cruzadas.

## LARI Level 17 — Blindaje Anti-Colapso del Dashboard (GEL-021)
### Problema
Al registrar un movimiento (formulario, modal rápido o IA), el dashboard se vaciaba intermitentemente.

### Causas Raíz Identificadas
1. **Crash de date-fns**: `format(new Date(t.date + "T12:00:00"), ...)` explotaba con fechas ISO completas o undefined.
2. **Race condition en SyncEngine**: Eventos Realtime sin debounce causaban refetch de datos vacíos.
3. **Acceso inseguro a propiedades anidadas**: `t.category?.name` fallaba con datos parciales.

### Solución Implementada
1. **Error Boundaries** (`components/ui/ErrorBoundary.tsx`): Cada sección del dashboard está envuelta independientemente.
2. **Normalización** (`lib/utils/normalize-transaction.ts`): Toda transacción pasa por validación de tipos antes de entrar al estado.
3. **safeFormatDate**: Wrapper que nunca crashea sobre `date-fns`.
4. **Debounced SyncEngine**: 1500ms mínimo entre refreshes realtime.
5. **Anti-reset en loadSummary**: Bloqueo de sobrescrituras con datos vacíos sobre estados válidos.
6. **Auditoría type="button"**: Todos los botones de acción verificados.

### Archivos Clave
- `components/ui/ErrorBoundary.tsx` (NUEVO)
- `lib/utils/normalize-transaction.ts` (NUEVO)
- `app/(dashboard)/page.tsx` (refactorizado)
- `components/dashboard/RecentTransactions.tsx` (refactorizado)
- `components/sync/SyncEngine.tsx` (refactorizado)

## 🚀 Instrucciones de Arranque (Para retomar el contexto)
Si estás abriendo un **nuevo chat** o sesión con el asistente de IA, debes:
1. **LEER ESTE ARCHIVO (`PROJECT_CHECKPOINT.md`) PRIMERO** para entender en qué punto arquitectónico y funcional se encuentra el proyecto.
2. Revisar `.skills/lari/global-error-ledger.md` si encuentras un error recurrente, para saber cómo se solucionó en el pasado y no repetir regresiones.
3. El frontend reside en `finance-app/`. Ejecutar `npm run dev` para arrancar el servidor local. Todos los scripts de inicialización de Supabase están en `finance-app/scripts/`.
