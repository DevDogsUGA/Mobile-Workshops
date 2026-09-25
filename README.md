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

## Project layout

- `lib/main.dart` — app entry point and root widget
- `test/` — widget tests

## Deep links

The app already registers the `org.devdogsuga.mobileworkshops://login-callback` redirect scheme
on Android and iOS. It isn't used yet — a later workshop wires it up for Supabase OAuth sign-in —
but the scheme has to already be in place before that lands.
