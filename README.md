# 🍕 Pizza Admin — Project README

> A short, practical guide for running and understanding this Flutter web app.

---

## 🔎 Short description

- This is a Flutter web application (also runnable on desktop) for administering a pizza menu. The app supports creating pizzas with images, storing metadata in Cloud Firestore, and a local simulation of image storage used when Firebase Storage is not available.
- Main features: create/read pizzas, upload images (saved locally by default), and authentication (Firebase Auth).

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

# Run the web app in Chrome
flutter run -d chrome
```

### Firebase setup (Auth & Firestore)
1. Create a Firebase project: https://console.firebase.google.com/
2. Register your app (Web) and follow the instructions to add Firebase config. The generated config is typically placed in `lib/firebase_options.dart` using `flutterfire` CLI or manual values.
3. Enable **Authentication** (Email/Password or providers you want).
4. Create a **Cloud Firestore** database and set rules appropriate for development.

Security notes about API keys and Firebase config:
- Firebase config (API keys in `firebase_options.dart`) is not a secret like a password — it identifies your Firebase project, but you still must secure your backend by writing proper Firestore Security Rules and restricting API usage where applicable.
- Do NOT embed service account JSON files in the client or commit private credentials to the repo.

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

- Login flow: after a successful sign-in on the Login page, the app may redirect back to the login page once; signing in a second time (immediately) then proceeds to the home page. This is a known navigation timing quirk — likely caused by navigation being called during the widget build lifecycle. A fix is scheduled to defer navigation using a post-frame callback.
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

---

If you want, I can:
- Add the demo GIF to the repo after you record it.
- Make the final images folder configurable instead of hard-coded.
- Create a small script to sync `assets/images/` between the two folders automatically.

Enjoy! 🍕🚀


# pizza_app_admin_gmao

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
