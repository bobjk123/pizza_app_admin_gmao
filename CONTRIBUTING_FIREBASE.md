**Contributing to Firebase**

This document describes how to configure, test, and contribute Firebase-related changes in this repository. It includes security best practices (do not commit credentials), how to use local emulators, steps to rotate keys, and how to propose changes (PR) that affect Firebase configuration or rules.

**Quick summary**:
- **Do not** commit `lib/firebase_options.dart` or any configuration files containing secrets.
- Use the **Firebase Emulator Suite** for local testing.
- Keep Firestore and Storage security rules in separate files and test them with the emulator before publishing.
- If a secret was exposed, **rotate** the key immediately and avoid history purges without team coordination.

**Prerequisites (local development)**:
- Install `flutter` and `dart`.
- Firebase CLI: `npm install -g firebase-tools`.
- (Optional) `gcloud` if you manage resources with Google Cloud.
- To reconfigure Firebase locally: `dart pub global activate flutterfire_cli` and then `flutterfire configure`.

Useful commands:

```
# Install Firebase CLI (if missing)
npm install -g firebase-tools

# Optional: install FlutterFire CLI
dart pub global activate flutterfire_cli

# Start emulators (from project root where firebase.json is located)
firebase emulators:start --only firestore,auth

# Run the app using emulators (example)
# Set environment variables in your terminal if needed
flutter run -d chrome
```

**Setting up your local environment (do not commit)**:

1. Run `flutterfire configure` to generate your local `lib/firebase_options.dart`.
2. Ensure `lib/firebase_options.dart` is excluded in `.gitignore`. Do not `git add` this file.
3. If you need to share non-secret parameters (collection names, rule structure), publish them in documentation rather than configuration files containing credentials.

**Testing with the Firebase Emulator Suite (recommended)**:

1. In the repository root, configure `firebase.json` with the services you need (auth, firestore, storage if applicable).
2. Run: `firebase emulators:start`.
3. Adjust your code to target emulator endpoints during tests (for example, call `FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080)` from `main()` when detecting `kDebugMode` or an environment variable).

Short example for Firestore in `main.dart` (debug mode):

```
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    FirebaseFirestore.instance.settings = Settings(host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  }
  runApp(MyApp());
}
```

Adapt ports to match your `firebase.json`.

**Security rules and Firestore Rules**:

- Keep your rules in a separate file (for example `firestore.rules`) and test them with the emulator before deploying.
- Review and test each rules change locally using `firebase emulators:exec` or `firebase emulators:start` and testing utilities.

Example flow to test rules:

```
# Start the emulators
firebase emulators:start --only firestore,auth

# (Optional) run rule tests or scripts that validate behavior
```

**Best practices for commits and PRs that touch Firebase**:

- Always include a description in the PR listing which Firebase services are affected.
- Include steps to test locally with the emulator in the PR description.
- If you change security rules or sensitive config, request review from at least one security-aware maintainer.

**If you accidentally committed `firebase_options.dart` or a key**:

1. Rotate the exposed key immediately in the Firebase/Google Cloud Console (API key / OAuth client secret / service account).
2. Add the pattern to `.gitignore` and remove the file from the index: `git rm --cached lib/firebase_options.dart` and `git commit -m "chore: remove firebase config from repo"`.
3. If the secret was public and you need to remove it from history, coordinate with your team before using history-rewrite tools (BFG or `git filter-repo`) because they require a force-push and impact all collaborators.

Example commands to remove from the index (does not rewrite history):

```
git rm --cached lib/firebase_options.dart
git commit -m "chore: remove firebase config from index"
git push origin HEAD
```

**API key rotation (quick procedure)**:

1. Open Firebase Console → Project Settings → General → Your apps → Config.
2. For API keys: open Google Cloud Console → APIs & Services → Credentials.
3. Create a new API key and restrict usage by HTTP referrer or IP addresses as appropriate.
4. Replace your local `lib/firebase_options.dart` with the new configuration (or run `flutterfire configure` again).
5. Test locally with emulators and then deploy.

**CI / Continuous Integration**:

- Do not commit `firebase_options.dart` to the repo. Instead, store secrets in the CI runner environment (GitHub Actions secrets, etc.) and generate `firebase_options.dart` during the workflow if needed.
- For automated deployments to Firebase Hosting or Functions, use `firebase login:ci` and limited-scope secrets.

Example GitHub Actions skeleton:

```yaml
name: Flutter CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - name: Install dependencies
        run: flutter pub get
      - name: Run tests
        run: flutter test
```

For operations that require Firebase credentials (deploy), store credentials in `Secrets` and use them in the workflow.

**Security checklist before merging PRs that touch Firebase/config**:

- [ ] No credentials appear in the diff (API keys, service account JSON, `firebase_options.dart`).
- [ ] Firestore rules changes have been tested with the emulator.
- [ ] Test and rollback steps are documented in the PR.
- [ ] If secrets were exposed, they have been rotated and the rotation scope documented.

**Contact & support**:

If you need help rotating keys, testing rules, or configuring emulators, open an issue titled `firebase: ...` or tag the project maintainers.

---
Date created: November 20, 2025
