# mobile-workshops

The starting point for DevDogs Flutter workshops. Clone it, get it running, and build along with
each week's session.

## How this repo works

- **`main`** is the clean template — a minimal Flutter app and nothing else. Start here.
- Each week's **completed** workshop lives on its own branch, numbered in order (`01-flutter-intro`, `02-supabase`, …).

So if you want the finished code from a given week, fetch and switch to that week's branch:

```bash
git fetch && git switch 01-flutter-intro
```

## Prerequisites

- The **Flutter SDK** (stable channel) — see https://docs.flutter.dev/get-started/install
- An editor with the Flutter/Dart extensions (VS Code or Android Studio)
- A web browser — this is the target we teach in workshops

Check your setup:

```bash
flutter doctor
```

## Getting started

```bash
git clone https://github.com/DevDogsUGA/mobile-workshops.git
cd mobile-workshops
flutter pub get
flutter run -d web-server --web-port 3000
```

If you have Chrome installed, you can use it instead so the app opens automatically:

```bash
flutter run -d chrome --web-port 3000
```

You should see a **Hello, World!** screen. From there, follow along with the workshop.

## Running the tests

```bash
flutter test
```

## 02 · Supabase

Branch `02-supabase` adds a real backend to the guestbook: sign-in,
row-level security, and a Postgres table instead of in-memory state.

1. Create a project at [supabase.com](https://supabase.com), or run
   `npx supabase start` to spin one up locally.
2. Apply the two migrations under `supabase/migrations/` in order — either
   paste each file into the dashboard's SQL editor, or let
   `supabase start` / `supabase db reset` apply them for you.
3. Add "Sign in with DevDogs" as an OAuth provider:

   ```bash
   pnpm dlx @devdogsuga/devtools oauth
   ```

   Note: this provider is stored outside the migrations, so it needs to be
   re-added any time you run `supabase db reset`.
4. Copy `.env.example` to `.env.local` and fill in your project's URL and
   publishable key (both on the dashboard, under Project Settings > API).
5. Run with those values baked in via `--dart-define-from-file`:

   ```bash
   flutter run -d web-server --web-port 3000 --dart-define-from-file=.env.local
   ```

## Project layout

- `lib/main.dart` — app entry point and root widget
- `test/` — widget tests

## Deep links

The app registers the `org.devdogsuga.mobileworkshops://login-callback` redirect scheme on
Android and iOS, and the guestbook's sign-in button already points at it on those platforms. Flutter
web is the target we actually teach and demo, though, so this scheme mostly sits ready for whenever
someone runs the app on a device instead.
