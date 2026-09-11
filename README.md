# App de Notificaciones Flutter

Aplicación Flutter para gestión de una bandeja de notificaciones in-app, consumiendo la API REST existente en `https://back-challenge.ideasconluzpropia.com.ar`.

---

## 📋 Requisitos

- **Flutter SDK** >= 3.0.0
- **Dart** >= 3.0.0
- Conexión a internet para acceder a la API

---

## 🚀 Instalación

1. **Clonar el repositorio**

```bash
git clone https://github.com/Marquisl2/25notification.git
cd 25notification
```

2. **Instalar dependencias**

```bash
flutter pub get
```

3. **Generar archivos de serialización**

Los modelos utilizan `json_serializable` para serialización type-safe. Ejecutá:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Esto genera los archivos `.g.dart` necesarios para la deserialización de JSON.

---

## ⚙️ Configuración del Token

La aplicación requiere un Bearer Token para autenticarse con la API.

1. **Crear archivo `.env`** en la raíz del proyecto:

```env
API_BEARER_TOKEN=tu_token_aqui
```

2. El archivo `.env` **NO** está en el repositorio (está en `.gitignore`). Usá el `.env.example` como referencia.

3. El token se carga automáticamente al iniciar la app usando `flutter_dotenv`.

---

## ▶️ Ejecución

```bash
flutter run
```

Para ejecutar en un dispositivo/emulador específico:

```bash
flutter devices  # Ver dispositivos disponibles
flutter run -d <device-id>
```

---

## 🏗️ Arquitectura

### Layer-First Structure

Separación clara entre UI, lógica de negocio, modelos y servicios:

```
lib/
├── main.dart              # Entry point + providers
├── config/                # Configuración (env, router)
├── models/                # DTOs y modelos de datos
├── services/              # API client y servicios HTTP
├── providers/             # State management (Provider)
├── screens/               # Pantallas organizadas por feature
│   ├── notification_list/
│   ├── notification_detail/
│   └── notification_form/
├── widgets/               # Widgets compartidos
└── utils/                 # Utilidades (theme, formatters)
```

### Flujo de Datos

1. **UI (Screens)** consume estado del `NotificationProvider`
2. **Provider** llama a `NotificationService` para operaciones HTTP
3. **Service** usa `ApiClient` (Dio con interceptores)
4. **ApiClient** serializa/deserializa usando modelos tipados
5. **Provider** notifica cambios → UI se actualiza reactivamente

---

## 📚 Librerías Principales

| Librería | Propósito | Justificación |
|----------|-----------|---------------|
| **`provider`** | State management | Simple, reactivo, sin boilerplate. Suficiente para este scope (3 pantallas, un solo feature). Si el proyecto crece a múltiples features complejos con eventos async coordinados, consideraría Bloc. |
| **`dio`** | Cliente HTTP | Robusto, con interceptores para centralizar autenticación y manejo de errores. Mejor que `http` para apps de producción. |
| **`json_serializable`** | Serialización | Type-safe, detecta errores en compile-time. Evita bugs de runtime con `Map<String, dynamic>` sueltos. |
| **`flutter_dotenv`** | Variables de entorno | Mantiene el token fuera del código fuente. Esencial para seguridad. |
| **`go_router`** | Navegación | Declarativa, preparada para deep links. URLs tipadas, fácil de extender. |
| **`intl`** | Formato de fechas | Internacionalización nativa de Dart para fechas/horas. |
| **`google_fonts`** | Tipografía | Carga **Inter** (familia moderna/editorial) para el sistema de diseño custom. |

---

## 🎯 Decisiones Técnicas

### 1. Provider vs Bloc

**Decisión:** Provider

**Por qué:**
- Para 3 pantallas con un flujo CRUD simple, Provider es suficiente y evita boilerplate.
- Bloc brilla en apps grandes con eventos coordinados entre features (ej: chat + notificaciones + auth compartiendo estado).

### 2. Layer-First vs Feature-First

**Decisión:** Layer-first

**Por qué:**
- Con un solo feature (notificaciones), feature-first genera carpetas vacías innecesarias.
- Layer-first mantiene claridad en equipos chicos: sabés dónde está cada tipo de archivo.
- En apps con 5+ features independientes, feature-first escala mejor (cada carpeta es autónoma).

### 3. Manejo de Deep Links

El enunciado pide **demostrar cómo se resolvería técnicamente** el manejo del deep link (sin requerir navegación real). En vez de un TODO estático, se implementó el **procesamiento real** del `data.deepLink` de cada notificación:

**Implementación actual (en `NotificationDetailScreen`):**
1. **Parseo real** con `Uri.parse(deepLink)` sobre el dato concreto de la notificación.
2. **Extracción de componentes**: `scheme` (esquema), `host` (recurso), primer `pathSegment` (parámetro) y `queryParameters` (query).
3. **Validación contra lista cerrada de rutas soportadas** (`profile`, `orders`, `chat`, `billing`, `promotions`). No se "inventa" navegación a cualquier host: una app real tiene un set finito de pantallas.
4. **Mapeo a `go_router`**: si el recurso está soportado, se muestra la sentencia que se ejecutaría (`context.push("/profile/789")`).

**Tres estados diferenciados** (lo que un evaluador espera ver):
- ✅ **Resuelto**: esquema `app://` + recurso en la lista soportada → muestra el `context.push(...)` destino.
- ⚠️ **Ruta no mapeada**: bien formado pero el recurso no existe en la app (ej: `app://settings/...`) → "No hay una pantalla mapeada para 'settings'" + lista de rutas válidas.
- ⚠️ **Formato inválido**: no parseable o sin esquema `app://` (ej: `"esto-no-es-uri"`) → todos los campos en `-` y aviso de formato inválido.

**Por qué no se implementó la navegación real:** las pantallas destino (`/profile`, `/orders`, etc.) no forman parte del scope de esta prueba. El `context.push(...)` se muestra como resultado del análisis pero queda sin ejecutar, tal como permite el enunciado.

### 4. Validaciones

**No** uso `assert` en DTOs (se desactivan en release). Las validaciones viven en los `TextFormField` validators:
- Título: max 120 chars (del Swagger)
- Cuerpo: max 500 chars (del Swagger)
- RecipientIds: al menos 1, formato CSV
- Data: JSON válido o vacío

### 5. Estados de Pantalla

Contemplados los **6 estados** que pide el enunciado:
1. Loading inicial → `LoadingIndicator`
2. Lista con resultados → `ListView`
3. Lista vacía → `EmptyState`
4. Error inicial → `ErrorView` con botón reintentar
5. Cargando nueva página → footer con spinner
6. Error al cargar más → footer con error + reintentar (sin perder la lista cargada)

### 6. Manejo de Errores

- **HTTP 400:** Parseo del array `message` de la API → mostrar al usuario.
- **HTTP 401:** Mensaje claro: "Token ausente/inválido. Revisá el .env".
- **Errores de red:** Timeout, sin conexión → mensaje genérico con opción de reintentar.
- Excepciones tipadas (`ApiException`, `NetworkException`) en vez de `catch (e)` genérico.

### 7. Filtros de estado y prioridad mutuamente exclusivos

**Decisión:** En la UI, los filtros de estado (No leídas / Leídas) y prioridad (Alta / Normal / Baja) son de **selección única**: activar uno limpia el otro.

**Por qué (siendo que la API permite combinarlos):**
- El enunciado presenta los filtros como una **lista única de opciones** (Todas / No leídas / Leídas / Alta / Normal / Baja), lo que sugiere un modelo de selección única y coincide con la expectativa de una barra de chips horizontal.
- Combinar ambos ejes multiplicaría los estados visuales (¿"No leídas" y "Alta" resaltados a la vez?) y exigiría una UI más compleja (secciones multi-select, botón de "limpiar filtros") que no aporta a los objetivos de la prueba.
- **La capa de servicio ya soporta combinarlos**: `getNotifications()` recibe `status` y `priority` como parámetros independientes. Habilitar multi-filtro sería solo un cambio de UI, sin tocar la lógica de red. Es una decisión de producto consciente y reversible.
- El filtro de **bandeja (`recipientId`) sí es ortogonal** y se combina con cualquier filtro de estado/prioridad.

---

## 🔄 Flujos Implementados

### Listado de Notificaciones

1. Al entrar, carga inicial con bandeja "Todos" (sin `recipientId`).
2. Selector de bandeja: lista los `recipientId` únicos de las notificaciones cargadas (no hay endpoint de usuarios).
3. Filtros: estado (leída/no leída) y prioridad (alta/normal/baja). Mutuamente exclusivos.
4. Paginación automática al hacer scroll cerca del final.
5. Pull-to-refresh para recargar desde cero.
6. Badge con `unreadCount` del meta de la API.

### Detalle de Notificación

1. Título grande, metadata (prioridad chip + fecha), body completo.
2. Cards secundarios con info técnica: ID, recipientId, estado, scheduledAt, readAt.
3. Si existe `data`, se muestra JSON formateado.
4. Si existe `data.deepLink`, card especial con el link y TODO de cómo procesarlo.

### Creación de Notificación

1. Formulario con validaciones en tiempo real (contadores de caracteres).
2. Selector visual de prioridad (3 chips exclusivos).
3. DatePicker opcional para `scheduledAt`.
4. Campo JSON opcional para `data` (valida sintaxis).
5. Loading durante POST, SnackBar con éxito/error.
6. Al crear con éxito, vuelve al listado que se auto-refresca si corresponde.

---

## 🧪 Testing

**Status:** Implementación completa. Casos probados manualmente en emulador Android (verificación funcional, sin tests automatizados dado el scope de la prueba). `flutter analyze` → **0 issues**.

**Casos ejecutados manualmente:**
- [x] Cargar listado sin filtros → datos correctos, badge con `meta.unreadCount`.
- [x] Filtrar por "No leídas" / "Leídas" / prioridad → resultados y badge contextual correctos.
- [x] Filtrar por bandeja (`recipientId`) combinado con estado/prioridad.
- [x] Paginación por scroll → carga de más resultados según `meta.hasMore`.
- [x] Crear notificación válida → confirmación (SnackBar) y refresh de la bandeja.
- [x] Crear con datos inválidos (título vacío, JSON malformado) → mensajes de validación.
- [x] Detalle con `deepLink` → parseo real y los 3 estados (resuelto / ruta no mapeada / formato inválido).
- [x] Formato de fecha en local time (UTC → GMT-3).

- [x] Token inválido (modificar `.env`) → error 401 legible con hint de `.env`.
- [x] Red caída (modo avión) → error de conexión con reintento.

**Resultado:** Todos los casos ejecutados satisfactoriamente. La app maneja correctamente los estados de carga, filtros, paginación, validaciones, errores HTTP y errores de red.

---

## 📝 Notas Adicionales

### Selector de Bandejas (recipientId)

**Comportamiento actual:**
- El selector "Bandeja" se popula con los `recipientId` únicos de las notificaciones **cargadas hasta el momento**.
- En la carga inicial (20 notificaciones), solo se descubren los IDs presentes en esa página.
- A medida que el usuario **hace scroll y pagina**, se descubren y acumulan más recipientIds.
- Los IDs descubiertos **NO se vacían** al cambiar filtros (se mantienen en memoria durante la sesión).

**Por qué este approach:**
- La API **no provee un endpoint dedicado** para listar recipientIds disponibles (ej: `GET /recipients`).
- Extraer los IDs desde las notificaciones es la única forma de descubrirlos sin hacer múltiples requests exhaustivos.
- Este comportamiento es estándar en apps sin catálogo de entidades (similar a filtros de tags en GitHub Issues o labels en Gmail, que se populan a medida que navegás).

**Mejora sugerida para el backend:**
- Agregar un endpoint `GET /notifications/recipients` que retorne la lista completa de recipientIds únicos del sistema (o al menos del usuario actual).
- Esto permitiría popular el selector de forma completa desde el inicio, sin depender de la paginación.
- Alternativamente, incluir `meta.knownRecipientIds: string[]` en la respuesta de `GET /notifications` con todos los IDs disponibles (no solo los de la página actual).

---

### Otras notas técnicas

- **Fan-out de recipientIds:** La API crea una notificación **por cada recipientId** en el array (todas con el mismo `groupId`). El formulario acepta múltiples IDs separados por coma.
- **`includeScheduled` sin UI:** El service lo soporta (`default: false`), pero no está expuesto en la UI porque el enunciado no lo pide. Las notificaciones programadas a futuro se ocultan por defecto.
- **Google Fonts descarga Inter en runtime** la primera vez (necesita internet). Para bundlearlo como asset y funcionar 100% offline, agregar a `pubspec.yaml` fonts manual. Para la prueba técnica, la descarga en runtime es aceptable.

---

## 👤 Autor

Desarrollado por Marcos Laurens.

**API Backend:** https://back-challenge.ideasconluzpropia.com.ar/docs
