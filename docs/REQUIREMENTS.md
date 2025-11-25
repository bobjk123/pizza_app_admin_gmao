````markdown
# Requisitos del proyecto — Pizza Admin

Fecha: 2025-11-25

Este documento describe los requisitos funcionales y no funcionales del proyecto "Pizza Admin" (aplicación Flutter para administración de menú de pizzas). Está pensado para desarrolladores, QA y responsables de producto.

**Resumen corto**
- Aplicación Flutter (web + desktop) para administrar pizzas: crear, listar, editar y eliminar entradas. Cada pizza incluye nombre, descripción, precio, macros y una imagen.
- Autenticación: Firebase Auth (email/password).
- Metadatos: Cloud Firestore.
- Almacenamiento de imágenes: Supabase Storage (preferido) o simulación local (fallback) para desarrollo.

---

**1. Requisitos funcionales (RF)**

- RF1 — Inicio de sesión
  - Los usuarios deben autenticarse mediante email y contraseña usando Firebase Auth.
  - Al iniciar sesión correctamente, la app debe navegar a `/home` una sola vez (sin requerir reintentos).

- RF2 — Gestión de pizzas (CRUD)
  - Crear pizza: formulario con campos `name`, `description`, `price`, `macros` y `picture`.
  - Leer/listar pizzas: la pantalla `HomeScreen` muestra las pizzas desde Firestore.
  - Editar pizza: la app permite actualizar campos y reemplazar la imagen.
  - Eliminar pizza: permite borrar una entrada de Firestore (y opcionalmente su imagen).

- RF3 — Subida y manejo de imágenes
  - Al crear/editar, el usuario puede seleccionar una imagen (desde explorador o drag & drop en web si aplica).
  - Si Supabase está configurado, la app debe subir la imagen al bucket `pizzas` y guardar la URL pública en Firestore.
  - Si Supabase no está configurado o la subida falla, la app debe guardar la imagen localmente en `assets/images/` y guardar la ruta relativa `assets/images/<nombre>` en Firestore.
  - En web, las vistas previas de imagen deben usar `blob:` URLs para evitar 404 en previews.

- RF4 — Feedback y errores
  - Mostrar estados de carga y errores en pantalla (ej. al subir imagen o crear pizza).
  - Registros en consola para operaciones críticas (uploads, fallbacks, auth transitions) para facilitar debugging.

---

**2. Requisitos no funcionales (RNF)**

- RNF1 — Disponibilidad y rendimiento
  - La UI debe responder a interacciones en menos de 200ms para acciones de tipo UI (mostrar previews, abrir forms).
  - Subidas de imagen en segundo plano deben notificar estado al usuario y no bloquear el hilo UI.

- RNF2 — Seguridad
  - No almacenar credenciales sensibles en el repositorio. `.env` y `lib/firebase_options.dart` deben estar en `.gitignore`.
  - En producción, las subidas a Supabase deben requerir autenticación o realizarse servidor-side con `service_role` con controles adecuados.

- RNF3 — Portabilidad y mantenibilidad
  - Código modular: repositorios (`pizza_repository`, `user_repository`) y BLoC para lógica de negocio.
  - Soporte multiplataforma: usar imports condicionales para IO vs web.

---

**3. Requisitos de entorno y dependencias**

- Plataforma de desarrollo: Windows (PowerShell), pero debe ejecutarse también en macOS/Linux.
- Requisitos mínimos:
  - Flutter SDK (estable, recomendado la versión que indique `flutter pub get` en el proyecto).
  - Dart SDK incluida con Flutter.
  - Node/npm si se usa Firebase CLI o herramientas (opcional).

- Dependencias principales (archivo `pubspec.yaml`):
  - `flutter_bloc`, `go_router`, `cloud_firestore`, `firebase_auth`, `firebase_core`, `supabase_flutter` (opcional), `flutter_dotenv`, `image_picker`, `path`.

---

**4. Variables de entorno y configuración**

- Variables esperadas (pueden provenir de `--dart-define` o `.env` con el script):
  - `SUPABASE_URL` — URL del proyecto Supabase.
  - `SUPABASE_ANON_KEY` — clave anon pública de Supabase (solo para dev si se usa directamente).
  - `SUPABASE_BUCKET` — nombre del bucket (por defecto `pizzas`).

- Firebase: `lib/firebase_options.dart` (no incluida en Git). Para desarrollo se puede usar Firebase Emulator Suite.

---

**5. Seguridad y análisis de riesgos**

- R1 — Exposición de credenciales:
  - Nunca commitear `lib/firebase_options.dart` ni archivos con keys privadas.
  - Si alguna clave fue expuesta en el repositorio remoto, rotar las credenciales inmediatamente.

- R2 — Subidas públicas a Supabase:
  - En desarrollo puede permitirse el uso de `anon` para simplicidad, pero en producción imponer autenticación o usar `service_role` desde un backend.
  - Documentar y aplicar RLS (Row-Level Security) si se necesita control granular.

---

**6. Pruebas y criterios de aceptación (QA)**

- CA1 — Autenticación
  - Dado un usuario válido, al iniciar sesión se debe navegar a `/home` en el primer intento. Verificar logs de `AuthenticationBloc` y `SignInBloc`.

- CA2 — Crear pizza con Supabase
  - Con `.env` configurado, subir una imagen y crear pizza. Verificar que Firestore contiene una URL pública (http(s)) y que la imagen está accesible.

- CA3 — Crear pizza con fallback local
  - Forzar fallo de Supabase (sin `.env`) y crear pizza. Verificar que el archivo aparece en `assets/images/` y Firestore contiene `assets/images/<file>`.

- CA4 — UI y errores
  - Simular fallo de subida y verificar que UI muestra mensaje de error y ofrece reintento.

---

**7. Operaciones y despliegue**

- Desarrollo local (comandos recomendados en PowerShell):

```powershell
# Instalar dependencias
flutter pub get

# Ejecutar app (sin Supabase)
flutter run -d chrome

# Con Supabase (usa .env y script)
pwsh .\scripts\run_dev_with_supabase.ps1
```

- Despliegue: la app web debe compilarse con `flutter build web` y servirse desde un host estático o un backend que sirva los assets. Si usas Supabase para imágenes, asegúrate de que las políticas de acceso sean correctas.

---

**8. Requisitos de mantenimiento y backlog**

- T1 — Añadir tests automatizados (unit + widget) para flujos críticos: login, crear pizza, subida/fallback.
- T2 — Implementar integración con CI (GitHub Actions) que haga `flutter analyze` y `flutter test`.
- T3 — Migrar subidas críticas a backend server-side con `service_role` para producción.

---

**9. Responsables y contactos**

- Responsable técnico: propietario del repo (`bobjk123`) — contact email: revisar en la configuración del proyecto.
- Instructor/owner del curso: Rodrigo Fidel Gaxiola Sosa.

---

Documento creado automáticamente el 2025-11-25. Para cambios, edita `docs/REQUIREMENTS.md` y crea un PR con la razón del cambio.

````
