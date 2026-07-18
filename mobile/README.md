# CarCare Mobile (Flutter)

Flutter mobile client for the CarCare Laravel API.

## Stack

- **Flutter + Dart**
- **Provider** — state management
- **GoRouter** — navigation & auth redirects
- **Dio** — HTTP client
- **flutter_secure_storage** — Sanctum token storage

---

## Project structure

```
mobile/
├── lib/
│   ├── main.dart                 # App entry point & dependency wiring
│   ├── app.dart                  # MaterialApp + theme
│   ├── core/
│   │   ├── config/               # API base URL, app constants
│   │   ├── constants/            # Fuel type labels
│   │   ├── network/              # ApiClient, ApiException
│   │   ├── router/               # GoRouter routes & auth guards
│   │   ├── storage/              # Secure token storage
│   │   ├── theme/                # Material 3 theme
│   │   └── widgets/              # Shared UI states (loading, error, empty)
│   └── features/
│       ├── auth/
│       │   ├── data/             # AuthRepository (API calls)
│       │   ├── models/           # User model
│       │   ├── providers/        # AuthProvider (state)
│       │   └── screens/          # Splash, Login, Register
│       └── vehicles/
│           ├── data/             # VehicleRepository
│           ├── models/           # Vehicle model
│           ├── providers/        # VehicleProvider
│           └── screens/          # List, Detail, Form
└── pubspec.yaml
```

### Architecture principles

- **Feature-first folders** — each feature owns its data, models, state, and UI.
- **Thin repositories** — map JSON ↔ models and call the API.
- **Providers for UI state** — no over-abstraction, easy to read for a portfolio.
- **Core layer shared** — network, storage, theme, routing reused across features.

---

## Prerequisites

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart 3.5+)
2. Android Studio / Xcode (for emulators) or a physical device
3. Laravel API running locally with Sanctum

---

## First-time setup

### 1. Install Flutter

Verify installation:

```bash
flutter doctor
```

### 2. Generate platform folders (first time only)

If `android/` and `ios/` folders are missing, run inside `mobile/`:

```bash
cd mobile
flutter create . --org com.carcare --project-name carcare_mobile
flutter pub get
```

This keeps existing `lib/` code and adds Android/iOS project files.

### 3. Allow HTTP on Android (local development)

Edit `android/app/src/main/AndroidManifest.xml` and add inside `<application>`:

```xml
android:usesCleartextTraffic="true"
```

### 4. Configure API URL

Default in `lib/core/config/app_config.dart`:

| Environment        | URL                              |
|--------------------|----------------------------------|
| Android emulator   | `http://10.0.2.2:8000/api`       |
| iOS simulator      | `http://127.0.0.1:8000/api`      |
| Physical device    | `http://YOUR_PC_IP:8000/api`     |

Override at run time:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

### 5. Start the Laravel API

From the project root (not `mobile/`):

```bash
php artisan migrate --force
php artisan db:seed
php artisan serve --host=0.0.0.0 --port=8000
```

> **Important:** After installing Sanctum, you must run `php artisan migrate` so the `personal_access_tokens` table exists. Without it, login/register will fail on the server even though users may be created.

**Seeded test account:** `test@example.com` / `password`

Use `--host=0.0.0.0` so a phone on the same Wi‑Fi can reach your PC.

---

## Run the app

```bash
cd mobile
flutter pub get
flutter run
```

Other useful commands:

```bash
flutter devices          # list emulators & connected devices
flutter run -d chrome    # web (optional, for quick UI checks)
flutter analyze          # static analysis
flutter test             # run tests
```

---

## Implemented screens

| Screen        | Route                    | API                          |
|---------------|--------------------------|------------------------------|
| Splash        | `/splash`                | Restores session via `/profile` |
| Login         | `/login`                 | `POST /api/login`            |
| Register      | `/register`              | `POST /api/register`         |
| Vehicle list  | `/vehicles`              | `GET /api/vehicles`          |
| Add vehicle   | `/vehicles/new`          | `POST /api/vehicles`         |
| Vehicle detail| `/vehicles/:id`          | `GET /api/vehicles/:id`      |
| Edit vehicle  | `/vehicles/:id/edit`     | `PUT /api/vehicles/:id`      |

### Auth flow

1. App opens → **Splash** loads saved Sanctum token.
2. Token valid → **Vehicle list**; invalid/missing → **Login**.
3. Login/Register stores token in **secure storage**.
4. Logout calls `POST /api/logout` and clears the token.

---

## Next features (planned)

- Maintenance list & create (nested items)
- Dashboard (stats + reminders)
- Profile editing
