# 🍕 Pizza Admin — Project README

> A short, practical guide for running and understanding this Flutter web app.

---

## 🔎 Short description

This is a Flutter web application (also runnable on desktop) for administering a pizza menu. The app supports creating pizzas with images and stores metadata in Cloud Firestore. Image storage can be provided by Supabase Storage (preferred) or fall back to a local simulation when Supabase is not configured.

Main features: create/read pizzas, upload images (to Supabase when configured), and authentication (Firebase Auth).

## 🧩 Main widgets / UI pieces

- **CreatePizzaScreen** — form to add a new pizza (name, description, price, macros, picture). Shows image preview and triggers creation.
- **HomeScreen** — lists pizzas fetched from Cloud Firestore.
- **LoginScreen** — sign in with Firebase Auth (note: see login behavior caveat below).
- **Reusable components** — `MyTextField`, macro widgets, and common UI elements used across screens.

## 🛠️ Technologies & Setup (Windows + VS Code)

This project uses:
- Flutter (Dart)
- Firebase: Auth and Cloud Firestore
- Packages: `flutter_bloc`, `go_router`, `image_picker`, and local `pizza_repository` and `user_repository` packages.

Recommended VS Code setup on Windows:
1. Install Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Add `flutter` to your PATH and run `flutter doctor`.
3. Install Visual Studio Code: https://code.visualstudio.com/
4. In VS Code, install extensions: **Flutter**, **Dart**, **Firebase Explorer** (optional).
5. (Optional) Install Git and set up your repo.

Quick commands in PowerShell (run from project root):
```powershell
# Get dependencies
cd 'C:\Users\aaron\Desktop\Aplicaciones Moviles\pizza_app_admin_gmao'
flutter pub get

# Run the web app in Chrome (no Supabase)
flutter run -d chrome

# Run with Supabase (temporary defines)
flutter run -d chrome --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key

# Or use the helper script that reads a local .env file and forwards the defines
pwsh .\scripts\run_dev_with_supabase.ps1
```

### Firebase setup (Auth & Firestore)
1. Create a Firebase project: https://console.firebase.google.com/
2. Register your app (Web) and follow the instructions to add Firebase config. The generated config is typically placed in `lib/firebase_options.dart` using `flutterfire` CLI or manual values.
3. Enable **Authentication** (Email/Password or providers you want).
4. Create a **Cloud Firestore** database and set rules appropriate for development.

Security notes about API keys and Firebase config:
- Firebase config (API keys in `firebase_options.dart`) is not a secret like a password — it identifies your Firebase project, but you still must secure your backend by writing proper Firestore Security Rules and restricting API usage where applicable.
- Do NOT embed service account JSON files in the client or commit private credentials to the repo.

### 🔐 Firebase security & leaked config (important)

- The repository previously contained a `lib/firebase_options.dart` file with Firebase configuration (API key and project identifiers). That file has been removed from Git tracking and a `.gitignore` entry was added to prevent future commits of the file. The local file may still exist in your working copy.
- If your Firebase config (API key) was ever pushed to a public remote, treat it as potentially exposed.

Recommended immediate actions if a Firebase file was pushed to a public repository:
1. **Rotate your API key and credentials** in Firebase Console immediately:
  - Go to Project Settings → General → Your apps, and regenerate or replace API keys where applicable.
  - If any server-side credentials (service accounts) were exposed, rotate them as well.
2. **Harden Firestore rules** to require proper authentication and validate inputs. Do not rely on the secrecy of client keys.
3. If you want the file removed from the remote Git history (so it no longer appears in past commits), use a history-rewrite tool like BFG or git-filter-repo. This requires a force-push and coordination with all collaborators.

Quick purge (example with BFG, run from a fresh clone):

```bash
# 1) make a bare mirror clone
git clone --mirror git@github.com:YOUR-USER/pizza_app_admin_gmao.git

# 2) use the BFG tool to delete the file across history
java -jar bfg.jar --delete-files firebase_options.dart pizza_app_admin_gmao.git

# 3) clean refs and garbage-collect
cd pizza_app_admin_gmao.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 4) push the cleaned history (force)
git push --force
```

Notes about purging history:
- Rewriting history changes commit SHAs and requires all collaborators to re-clone or reset their local clones. Coordinate before doing this on a shared repository.
- Even after purging, rotate any credentials that were exposed; purging does not invalidate keys.

If you'd like, I can guide you through using BFG or `git filter-repo` step-by-step, or run the commands here if you confirm you want to force-push rewritten history.

## 📁 Project structure (important files)

- `lib/` — main Flutter app code
  - `main.dart` — app entrypoint and Firebase initialization
  - `app.dart` / `app_view.dart` — app-level widgets and routing
  - `src/modules/` — feature folders (create_pizza, home, auth, splash)
    - `create_pizza/views/create_pizza_screen.dart` — pizza creation UI
    - `create_pizza/blocs/` — BLoC classes for creation and upload
  - `src/utils/` — small helpers (image provider, image mover)

- `packages/pizza_repository/` — local package that implements PizzaRepo
  - `lib/src/firebase_pizza_repo.dart` — repository implementation (uses local save helper)
  - `lib/src/save_image_local_io.dart` — IO helper that saves images to `assets/images/`
  - `lib/src/save_image_local_web.dart` — web helper that triggers a download
  - `lib/src/entities/` & `lib/src/models/` — data models and entities

- `packages/user_repository/` — user repository (Auth wrappers)

## 🔁 How images are handled (important)

- This project simulates Firebase Storage by saving uploaded images locally.
- There are two steps to the flow:
  1. When you select an image in `CreatePizzaScreen`, the image is saved temporarily into the current project's folder: `pizza_app_admin_gmao/assets/images/` (temporary preview). The UI displays that image immediately.
  2. When you press **Create Pizza**, the app attempts to move that temporary image file to the final folder used by the original project: `C:\Users\aaron\Desktop\Aplicaciones Moviles\pizza_app_8sc_gmao\assets\images\`. The `picture` field saved in Cloud Firestore will be the relative path `assets/images/<filename.ext>`.

Important: because images are stored locally on disk, production deployments or other machines will not see them unless you copy the files to the same folder or update the `picture` field in Firestore to match actual stored locations.

If uploaded images are not visible in the app or Firestore references don't match, do one of the following:
- Manually copy the image files into `pizza_app_8sc_gmao/assets/images/` and ensure the filenames match the `picture` field stored in Firestore.
- Or update the Firestore `picture` field to point to the existing filename in the local `assets/images/` of this project.
- Or replace the local-storage simulation with a proper remote storage (e.g., Firebase Storage) and update `packages/pizza_repository/lib/src/save_image_local_io.dart` accordingly.

## ⚠️ Known behavior / caveats

- Login flow: Fixed in recent commits — after a successful sign-in the app now navigates reliably to `/home` without requiring a second attempt. The fix includes:
  - `SignInScreen` now uses a `MultiBlocListener` that listens to `SignInBloc` (progress / errors) and `AuthenticationBloc` (global auth state). Navigation to `/home` happens only when `AuthenticationBloc` reports `authenticated`.
  - `SignInBloc` includes a reentrancy guard to ignore duplicate sign-in attempts while a sign-in is in progress.
  - These changes remove the previous race condition that could cause an immediate redirect back to the login screen.
- The local storage approach is intended for development and demo only. For real deployments use remote storage and secure Firestore rules.

## 🎬 Demo GIF

- Include a GIF that demonstrates the full flow: login → create pizza (select image) → preview → create → image appears in final folder and Firestore entry.
- I did not add a GIF file to the repo. To create one locally on Windows you can use a screen recorder (e.g. ShareX) and export a GIF, then place it in the repo (e.g. `docs/demo.gif`) and link it here:

```
![Demo](docs/demo.gif)
```

## ✅ Recommendations

- For production, replace the local-image simulation with Firebase Storage or another cloud storage provider. Update `pizza_repository` implementation accordingly.
- Keep your Firebase rules strict (require authentication, validate data types) so client API keys are not the only line of defense.
- Consider storing only storage URLs in Firestore (not filesystem paths) and host images on a CDN or cloud storage for cross-machine availability.

## 📚 Course & Credits

- Course: **Programación de Aplicaciones Móviles**
- Instructor: **Rodrigo Fidel Gaxiola Sosa**

Design credit:
- Inspired by Romain Girou — The Best Flutter Course in 3 Hours • Pizza App #1
  - YouTube: https://www.youtube.com/@Romain_Girou
  - Video: https://www.youtube.com/watch?v=PqOOUAbViLc

## 🔐 Contributing to Firebase (quick summary)

If you plan to contribute changes that touch Firebase (config, rules, or code interacting with Auth/Firestore), follow these minimal steps before opening a PR. For the full guide, see `CONTRIBUTING_FIREBASE.md` at the repository root.

- **Do not** commit `lib/firebase_options.dart` or any credentials to the repository.
- Use the **Firebase Emulator Suite** to test changes locally: `firebase emulators:start --only firestore,auth`.
- Generate your local `lib/firebase_options.dart` only with `flutterfire configure` and keep it listed in `.gitignore`.
- Validate Firestore rules changes using the emulator before deploying.

Quick commands:

```powershell
# Install Firebase CLI
npm install -g firebase-tools

# (Optional) install FlutterFire CLI
dart pub global activate flutterfire_cli

# Start emulators (from project root)
firebase emulators:start --only firestore,auth

# Run the app in debug (use emulators instead of live services)
flutter run -d chrome
```

If you need the complete guide or instructions for rotating/removing leaked keys, see `CONTRIBUTING_FIREBASE.md`.

## Supabase / .env (optional image storage)

- This project supports uploading images to Supabase Storage in addition to the local simulation. Supabase is used only for object storage; Firebase Auth and Cloud Firestore remain in use for authentication and metadata.
- You can provide Supabase credentials in two ways:
  - Via `--dart-define` when running the app (for example: `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`).
  - Or create a local `.env` file (copy `.env.example` → `.env`) and run the helper script `pwsh .\scripts\run_dev_with_supabase.ps1` which loads the `.env` values and runs `flutter` with the defines. The `.env` file is ignored by git.

- Default storage bucket: `pizzas`. The `pizza_repository` will attempt to use a `SupabaseClient` injected by the app; if none is provided the repo also tries to use the globally-initialized `Supabase.instance.client` (when `Supabase.initialize` runs in `main.dart`).

When Supabase is set up and configured, image uploads return a Supabase public URL that is saved in Firestore instead of a local filesystem path. In the current project state the `pizzas` bucket is used and uploads are working — images uploaded from `CreatePizzaScreen` are visible and the app saves the public URL in Firestore. If Supabase is not available or an upload fails, the app falls back to the local image simulation.

Security note: for development the project uses a permissive setup so uploads from the app work out-of-the-box. For production you should restrict uploads — either require authenticated users or perform uploads server-side using a `service_role` key. Row-Level Security (RLS) policies are optional and can be applied in your Supabase project if you need finer-grained controls.
