# Changelog

All notable changes to this project are documented in this file.

## [Unreleased] - 2025-11-21

- Supabase Storage integration: the `pizza_repository` now supports uploading images to Supabase Storage. Implementations include `sendImage(Uint8List, String)` and `sendImageFile(Object, String)` which prefer Supabase's `upload`/`uploadBinary` APIs and fall back to local saves on failure.
- Default storage bucket changed to `pizzas`. The bucket can still be overridden with the `SUPABASE_BUCKET` compile-time define or via `.env`/`--dart-define` at runtime.
- Added `scripts/run_dev_with_supabase.ps1` to read a local `.env` file and run `flutter` with the appropriate `--dart-define` flags for `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
- Added `.env.example` and guidance to use `.env` (ignored by git) for local development.
- Markdown documentation updated:
  - `README.md` updated to reflect Supabase usage and that images uploaded from `CreatePizzaScreen` are stored in Supabase and saved as public URLs in Firestore.
  - `CONTRIBUTING_FIREBASE.md` added/updated with Supabase instructions, RLS SQL snippets (dev anon vs production authenticated), and testing guidance.
- Web preview fix: web image preview now uses blob URLs to avoid 404s for local preview images.
- RLS (Row-Level Security) guidance: added SQL snippets to allow anonymous uploads for development or require `authenticated` users in production. Apply these policies in Supabase SQL editor to avoid 403 errors like "new row violates row-level security policy".
 - RLS guidance: documentation previously included SQL snippets for RLS policies. The docs have been updated to treat RLS as optional and to recommend production-safe approaches (authenticated uploads or server-side uploads using `service_role`).

### Login flow fixes (recent)

- Date: 2025-11-25
- Fix: Resolved a race condition in the login flow that could require a second sign-in attempt to reach the home screen.
  - `SignInScreen` now uses a `MultiBlocListener` to separately handle `SignInBloc` state (progress/errors) and `AuthenticationBloc` state (global authenticated/unauthenticated). Navigation to `/home` occurs only when `AuthenticationBloc` reports `authenticated`, eliminating the premature navigation that could cause an immediate redirect back to login.
  - `SignInBloc` now guards against reentrant sign-in attempts (ignored while a sign-in is already in progress).
  - Result: Single successful sign-in reliably navigates to `/home` without needing a repeated attempt.

  - Docs: README updated with recent changes (see commit `8885e53` — 2025-11-25). The README now includes a "Recent changes (2025-11-25)" section summarizing the login fixes, router update and new requirements documents.

### Testing / Verification

- Create the `pizzas` bucket in your Supabase project (Dashboard or REST API with `service_role`).
- Apply the chosen RLS policy in Supabase SQL Editor (see `CONTRIBUTING_FIREBASE.md`).
- Ensure `.env` contains your `SUPABASE_URL`, `SUPABASE_ANON_KEY` and `SUPABASE_BUCKET=pizzas`.
- Run the helper script and launch the app:

```powershell
pwsh .\scripts\run_dev_with_supabase.ps1
```

- From the app UI (`CreatePizzaScreen`), add an image and create a pizza. Check logs for `Uploaded to Supabase Storage: ...` and verify the saved URL in Firestore.

### Next steps / Notes

- For production, prefer server-side uploads (using a backend with `service_role` key) or require `authenticated` users. Do not allow anonymous `anon` uploads in production.
- Consider adding automated tests that exercise the upload flow against an emulated or test Supabase instance.
