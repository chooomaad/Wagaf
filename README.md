# Wagaf — International Shopping Assistant

A Flutter application that lets users in Mauritania order products from international marketplaces (AliExpress, Amazon, Temu, Alibaba, etc.) with delivery tracked to their door.

## Features

- Browse and order from 12+ global marketplaces
- Paste any product URL for instant analysis and pricing
- Full order lifecycle tracking (pending → purchased → in transit → delivered)
- Automatic pricing with service fees in MRU
- Push notifications for order status updates
- Admin dashboard with order/user/payment management

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | Riverpod |
| Backend | Supabase (PostgreSQL + Auth + Realtime) |
| Navigation | GoRouter |
| DI | GetIt |
| Push notifications | Firebase Cloud Messaging |
| CI/CD | Codemagic |

## Getting Started

### Prerequisites

- Flutter SDK (stable channel) — `flutter channel stable && flutter upgrade`
- Dart SDK ≥ 3.1.0
- Xcode 15+ (for iOS builds)
- Android Studio / SDK (for Android builds)
- A Supabase project

### Installation

```bash
git clone https://github.com/chooomaad/Wagaf.git
cd Wagaf

flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### Environment variables

Values are injected at compile time via `--dart-define` (no `.env` file needed):

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

In VS Code, add to `.vscode/launch.json`:
```json
{
  "configurations": [{
    "name": "Wagaf",
    "request": "launch",
    "type": "dart",
    "toolArgs": [
      "--dart-define=SUPABASE_URL=https://your-project.supabase.co",
      "--dart-define=SUPABASE_ANON_KEY=your-anon-key"
    ]
  }]
}
```

### Supabase setup

1. Create a new Supabase project
2. Run the migrations in `supabase/migrations/` in order
3. Enable Row Level Security on all tables
4. Configure Auth providers (Email/Password at minimum)

## Deployment

### iOS (App Store / TestFlight)

Bundle ID: `com.wagaf.app`

1. Create an App ID in Apple Developer Portal with bundle ID `com.wagaf.app`
2. Create a Distribution certificate and App Store provisioning profile
3. In Codemagic, create the `app_store_credentials` variable group:
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`
   - `APP_STORE_CONNECT_API_KEY`
   - `APP_STORE_CONNECT_ISSUER_ID`
4. Push a git tag `v1.0.0` to trigger the `ios-release` workflow

### Android (Google Play)

Application ID: `com.wagaf.app`

1. Create a signing keystore and add to Codemagic's `keystore_credentials` group
2. Create a Google Play service account and add JSON to `google_play_credentials` group
3. Push a git tag `v1.0.0` to trigger the `android-release` workflow

### Codemagic variable groups

| Group name | Variables |
|---|---|
| `supabase_credentials` | `SUPABASE_URL`, `SUPABASE_ANON_KEY` |
| `app_store_credentials` | `APP_STORE_CONNECT_KEY_IDENTIFIER`, `APP_STORE_CONNECT_API_KEY`, `APP_STORE_CONNECT_ISSUER_ID` |
| `keystore_credentials` | `CM_KEYSTORE`, `CM_KEY_ALIAS`, `CM_KEY_PASSWORD`, `CM_STORE_PASSWORD` |
| `google_play_credentials` | `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` |

## Project structure

```
lib/
  app/            — App widget, router
  core/           — DI, constants, theme, failures
  features/
    auth/         — Login, register, password reset
    home/         — Home screen, URL analyzer
    requests/     — Request list, detail, confirmation
    admin/        — Admin dashboard (orders/users/payments/notifications)
    profile/      — User profile, settings
  shared/         — Reusable widgets, services
```

## License

Proprietary — all rights reserved.
