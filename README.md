# Sh7anly — International Shopping Assistant

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
git clone https://github.com/your-org/sh7anly.git
cd sh7anly

# Copy the environment template and fill in your credentials
cp .env.example .env
# Edit .env with your Supabase URL and anon key

flutter pub get
flutter run
```

### Environment variables

Create a `.env` file at the project root (never commit this file):

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

See `.env.example` for the template.

### Supabase setup

1. Create a new Supabase project
2. Run the migrations in `supabase/migrations/` in order:
   - `001_initial_schema.sql`
   - `002_...`
   - `005_fix_auth_profiles.sql`
3. Enable Row Level Security on all tables
4. Configure Auth providers (Email/Password at minimum)

## Deployment

### iOS (App Store)

Bundle ID: `com.sh7anly.app`

1. Create an App ID in Apple Developer Portal with bundle ID `com.sh7anly.app`
2. Create a Distribution certificate and provisioning profile
3. In Codemagic, create the `app_store_credentials` variable group:
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`
   - `APP_STORE_CONNECT_API_KEY`
   - `APP_STORE_CONNECT_ISSUER_ID`
4. Push a git tag `v1.0.0` to trigger the `ios-release` workflow

### Android (Google Play)

Application ID: `com.sh7anly.app`

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
    orders/       — Order list, detail, tracking
    admin/        — Admin dashboard (orders/users/payments/notifications)
    profile/      — User profile, settings
  shared/         — Reusable widgets, services
supabase/
  migrations/     — Database migration scripts
```

## License

Proprietary — all rights reserved.
