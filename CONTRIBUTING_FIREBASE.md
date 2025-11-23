**Contributing to Firebase & Storage**

This document explains how to configure, test, and contribute changes that affect Firebase (Auth / Firestore) and optional Supabase Storage usage in this repository. It focuses on security best practices (do not commit credentials), running local emulators, how to enable Supabase uploads for images, and recommended policies (RLS) for Supabase Storage.

**Quick summary**:
- **Do not** commit `lib/firebase_options.dart` or any configuration files containing secrets.
- Use the **Firebase Emulator Suite** for local testing of Auth and Firestore.
- Store secrets (service_role keys, API keys) in secure environments (CI secrets, local `.env` ignored by git).
- When using Supabase Storage, configure Row-Level Security (RLS) policies for the `pizzas` bucket as appropriate (examples below).

---

## Prerequisites (local development)

- Install `flutter` and `dart`.
- Firebase CLI: `npm install -g firebase-tools`.
- (Optional) `gcloud` if you manage resources with Google Cloud.
- To configure Firebase locally: `dart pub global activate flutterfire_cli` and then `flutterfire configure`.

## Supabase Storage (images)

This repository supports storing images in Supabase Storage instead of using the local simulation. Firebase Auth and Cloud Firestore are still used for authentication and metadata.

How to enable Supabase uploads locally:

- Method A (temporary): provide `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define` when running the app. Example:

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key --dart-define=SUPABASE_BUCKET=pizzas
```

- Method B (recommended for local development): copy `.env.example` → `.env` and fill the values, then run the helper script which reads the `.env` and runs Flutter with the defines:

```powershell
pwsh .\scripts\run_dev_with_supabase.ps1
```

Notes:
- Default storage bucket used by the code is `pizzas` unless you override it with `SUPABASE_BUCKET`.
- The repository prefers a `SupabaseClient` injected by the app; otherwise it uses `Supabase.instance.client` initialized in `main.dart`.
- Uploaded images return a public URL (via `getPublicUrl`) and the public URL is stored in Firestore in place of a local path.

## Storage security and policies

Supabase Storage supports Row-Level Security (RLS) for fine-grained access control, but RLS is optional. The default development setup for this project is permissive so that image uploads work immediately during development. For production deployments you should either:

- Require authenticated users for uploads (use Supabase Auth), or
- Perform uploads server-side using a `service_role` key (recommended when you need to restrict client permissions).

If you do decide to use RLS, create appropriate policies in the Supabase SQL editor for your chosen bucket (for example, `pizzas`). The repository documentation previously included example SQL; those examples were intentionally removed to avoid encouraging permissive rules in production. Contact the maintainers if you need tailored RLS recommendations for your deployment.

## Code locations & helpers

- `packages/pizza_repository/lib/src/firebase_pizza_repo.dart`: implements image upload using Supabase Storage. It provides `sendImage(Uint8List, String)` (uploads bytes) and `sendImageFile(Object, String)` (accepts a `File` or file-like object and prefers `upload(File)` with `FileOptions`).
- `lib/main.dart`: initializes Supabase when `SUPABASE_URL` and `SUPABASE_ANON_KEY` are present.
- `scripts/run_dev_with_supabase.ps1`: helper that reads `.env` and launches `flutter run` with `--dart-define` flags.

## Testing locally

1. Create the `pizzas` bucket in the Storage section of the Supabase Dashboard or via the REST API (service_role required).
2. Apply the RLS policy you prefer (development or production) in the SQL editor of Supabase.
3. Ensure your `.env` contains the correct values for `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_BUCKET=pizzas`.
4. Run the app with the helper script:

```powershell
pwsh .\scripts\run_dev_with_supabase.ps1
```

5. From the app UI (`CreatePizzaScreen`), add an image and create a pizza. Check logs for `Uploaded to Supabase Storage: ...` and verify the saved URL in Firestore.

## Firebase emulator & Firestore

Use the Firebase Emulator Suite for testing Auth and Firestore rules. Keep Firestore rules in a separate file and test them locally before deploying.

```
# Start emulators
firebase emulators:start --only firestore,auth
```

## If you accidentally committed credentials

1. Rotate the exposed key immediately in Firebase / Google Cloud Console.
2. Remove the file from the index: `git rm --cached lib/firebase_options.dart` and commit.
3. If you must remove history, coordinate with your team and use history-rewrite tools (BFG/git-filter-repo) with caution.

## CI / Secrets

- Do not commit `lib/firebase_options.dart`. Use CI secrets to provide runtime configuration.

---
Date updated: November 21, 2025
