# Firebase setup

`lib/firebase_options.dart` is safe to commit. It does not contain real Firebase values.
It reads Firebase config from build-time variables using `String.fromEnvironment`.

The real local values live in:

```text
firebase_config.local.json
```

That file is ignored by git. Copy the shape from:

```text
firebase_config.example.json
```

## Run commands

Run the app with:

```bash
flutter run -d chrome --dart-define-from-file=firebase_config.local.json
```

Build web with:

```bash
flutter build web --dart-define-from-file=firebase_config.local.json
```

Run the Firestore web seed tool with:

```bash
flutter run -t tool/seed_firestore_web.dart -d chrome --dart-define-from-file=firebase_config.local.json
```

If Firebase config changes, run FlutterFire locally:

```bash
flutterfire configure
```

Then copy the generated values into `firebase_config.local.json`. Do not commit the generated raw values.

The app still imports:

```dart
import 'firebase_options.dart';
```

So every developer needs either `firebase_config.local.json` or their own local Firebase project values before running the app.

## GitHub secret scanning note

Firebase web/mobile API keys are app identifiers, not admin credentials, but GitHub may still flag them as leaked Google API keys. The real protection must come from:

- Firebase Authentication rules
- Firestore Security Rules
- API key restrictions in Google Cloud Console
- App Check later if needed

If a real key was already pushed, removing the file from future commits does not remove it from git history. For extra safety, restrict or rotate the key in Google Cloud Console.
