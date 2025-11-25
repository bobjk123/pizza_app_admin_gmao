````markdown
# Project Requirements — Pizza Admin

Date: 2025-11-25

This document describes the functional and non-functional requirements for the "Pizza Admin" project (a Flutter application for managing a pizza menu). It is intended for developers, QA, and product owners.

**Brief summary**
- Flutter application (web + desktop) to manage pizzas: create, list, edit and delete entries. Each pizza includes a name, description, price, macros and an image.
- Authentication: Firebase Auth (email/password).
- Metadata: Cloud Firestore.
- Image storage: Supabase Storage (preferred) or a local simulation (fallback) for development.

---

**1. Functional Requirements (FR)**

- FR1 — Sign-in
  - Users must authenticate using email and password via Firebase Auth.
  - After a successful sign-in, the app must navigate to `/home` only once (no repeated attempts required).

- FR2 — Pizza management (CRUD)
  - Create pizza: form with fields `name`, `description`, `price`, `macros` and `picture`.
  - Read/list pizzas: `HomeScreen` displays pizzas from Firestore.
  - Update pizza: the app allows updating fields and replacing the image.
  - Delete pizza: allows deleting a Firestore entry (and optionally its image).

- FR3 — Image upload and handling
  - When creating/editing, the user can select an image (from file picker or drag & drop on web if applicable).
  - If Supabase is configured, the app must upload the image to the `pizzas` bucket and store the public URL in Firestore.
  - If Supabase is not configured or upload fails, the app must save the image locally in `assets/images/` and store the relative path `assets/images/<name>` in Firestore.
  - On web, image previews should use `blob:` URLs to avoid 404s for previews.

- FR4 — Feedback and errors
  - Show loading states and errors in the UI (e.g., when uploading an image or creating a pizza).
  - Log critical operations to the console (uploads, fallbacks, auth transitions) to aid debugging.

---

**2. Non-functional Requirements (NFR)**

- NFR1 — Availability and performance
  - The UI should respond to interactions within 200ms for UI actions (showing previews, opening forms).
  - Image uploads should run in the background, notify the user of status, and not block the UI thread.

- NFR2 — Security
  - Do not store sensitive credentials in the repository. `.env` and `lib/firebase_options.dart` must be in `.gitignore`.
  - In production, Supabase uploads should require authentication or be performed server-side with a `service_role` key under proper controls.

- NFR3 — Portability and maintainability
  - Modular code: repositories (`pizza_repository`, `user_repository`) and BLoC for business logic.
  - Cross-platform support: use conditional imports for IO vs web.

---

**3. Environment and dependency requirements**

- Development platform: Windows (PowerShell), but the app must also run on macOS/Linux.
- Minimum requirements:
  - Flutter SDK (stable — use the version indicated by `flutter pub get` for the project).
  - Dart SDK included with Flutter.
  - Node/npm if using the Firebase CLI or related tools (optional).

- Key dependencies (in `pubspec.yaml`):
  - `flutter_bloc`, `go_router`, `cloud_firestore`, `firebase_auth`, `firebase_core`, `supabase_flutter` (optional), `flutter_dotenv`, `image_picker`, `path`.

---

**4. Environment variables and configuration**

- Expected variables (can come from `--dart-define` or `.env` via the helper script):
  - `SUPABASE_URL` — Supabase project URL.
  - `SUPABASE_ANON_KEY` — Supabase public anon key (for dev use only if used directly).
  - `SUPABASE_BUCKET` — bucket name (default: `pizzas`).

- Firebase: `lib/firebase_options.dart` (not included in Git). For development, the Firebase Emulator Suite may be used.

---

**5. Security and risk analysis**

- R1 — Credential exposure:
  - Never commit `lib/firebase_options.dart` or files containing private keys.
  - If any key was exposed in the remote repository, rotate credentials immediately.

- R2 — Public uploads to Supabase:
  - For development, using `anon` may be acceptable for convenience, but in production require authentication or use a backend with `service_role`.
  - Document and apply RLS (Row-Level Security) when fine-grained controls are required.

---

**6. Testing and acceptance criteria (QA)**

- AC1 — Authentication
  - Given a valid user, signing in should navigate to `/home` on the first attempt. Check `AuthenticationBloc` and `SignInBloc` logs.

- AC2 — Create pizza with Supabase
  - With `.env` configured, upload an image and create a pizza. Verify Firestore contains a public URL (http(s)) and the image is accessible.

- AC3 — Create pizza with local fallback
  - Force a Supabase failure (no `.env`) and create a pizza. Verify the file appears in `assets/images/` and Firestore contains `assets/images/<file>`.

- AC4 — UI and errors
  - Simulate an upload failure and verify the UI shows an error message and offers a retry.

---

**7. Operations and deployment**

- Local development (recommended PowerShell commands):

```powershell
# Install dependencies
flutter pub get

# Run the app (without Supabase)
flutter run -d chrome

# With Supabase (uses .env and helper script)
pwsh .\scripts\run_dev_with_supabase.ps1
```

- Deployment: the web app should be built with `flutter build web` and served from a static host or backend serving the assets. If using Supabase for images, ensure access policies are configured correctly.

---

**8. Maintenance requirements and backlog**

- T1 — Add automated tests (unit + widget) for critical flows: login, create pizza, upload/fallback.
- T2 — Add CI integration (GitHub Actions) to run `flutter analyze` and `flutter test`.
- T3 — Migrate critical uploads to a server-side backend with `service_role` for production.

---

**9. Owners and contacts**

- Technical owner: repository owner (`bobjk123`) — contact email: check project settings.
- Course owner/instructor: Rodrigo Fidel Gaxiola Sosa.

---

Document auto-generated on 2025-11-25. To change, edit `docs/REQUIREMENTS_EN.md` and open a PR describing the reason for the change.

````
