# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app (`stayindia_owner`) — the Owner/Partner-facing client for Stay India (PG/hostel management). Targets iOS, Android, plus web/desktop scaffolding that isn't actively used for release builds.

## Commands

Run Flutter commands from the repo root.

- Install deps: `flutter pub get`
- Run (dev/staging backend): `flutter run --dart-define-from-file=config/env.dev.json`
- Run (prod backend): `flutter run --dart-define-from-file=config/env.prod.json`
- Analyze/lint: `flutter analyze`
- Run all tests: `flutter test`
- Run a single test file: `flutter test test/core/constants/api_constants_test.dart`
- Run a single test by name: `flutter test --plain-name "builds S3 image URLs"`

VS Code launch configs for all three Flutter modes (debug/profile/release) against both `env.dev.json` and `env.prod.json` are already defined in `.vscode/launch.json`.

### Release builds

`./build_app.sh [dev|prod] [ipa|appbundle|apk|all]` (defaults to `prod`/`all`). It runs `flutter clean`, then builds using `--dart-define-from-file=config/env.<environment>.json`.

- Android release builds require `android/key.properties` pointing at a valid keystore.
- IPA builds require macOS + Xcode with valid iOS signing.
- `config/env.*.json` values are compiled into the app binary — they are not secure storage. Never put real secrets in them.

## Architecture

### Bootstrapping

`lib/main.dart` only calls `runApp(const AppBootstrapper())`. All real startup work lives in `lib/core/services/app_bootstrapper.dart`, which runs as a staged sequence shown behind a splash screen:

1. Load `SharedPreferences`/onboarding flag, set system UI chrome, init `easy_localization`.
2. Build `HydratedBloc` storage and init Hive.
3. Init Firebase (+ wire `FlutterError.onError` / `PlatformDispatcher.instance.onError` to Crashlytics).
4. Run `di.init()` (get_it service locator setup, see below), then re-register the already-loaded `AppConfigService` as a singleton.
5. Flush stale cache, init notifications, warm the profile cache if a token exists, then call `AuthCubit.restoreSession()`.

`AppBootstrapper`'s `build()` decides the home screen from `AuthState` (`AuthInitial`/`AuthSessionRestoring` → splash, `AuthGoogleNeedsPhone` → link-phone, `AuthAuthenticated`/`AuthProfileCompleted` → registration or `MainNavigationPage`, `AuthUnauthenticated`/`AuthOtpSent` → login, `AuthSessionRestoreError` → retry screen). Top-level blocs provided here: `AuthCubit`, `ThemeCubit`, `GuestSessionCubit`; a second tier of per-session cubits (Hostel, Bookings, Dashboard, Tenant, Maintenance, Notice, Staff, Payment, Profile, Settings, Community, OwnerCommunity, Association, Notification, AssociationMembership) is re-provided inside a `MultiBlocProvider` keyed by the owner's session id, so switching accounts rebuilds all of them.

### Dependency injection

`get_it` (`sl` global in `lib/injection_container.dart`) is the service locator. `di.init()` fans out to one `register<Feature>Feature(sl)` function per feature, each defined in that feature's own `<feature>_injections.dart` (e.g. `lib/features/tenants/tenants_injections.dart`). A feature injection file registers, in order: data sources → repositories → use cases → cubits (factories for cubits/use cases, lazy singletons for repos/data sources — follow the existing pattern in a feature before adding to it). Cross-cutting singletons (Dio, TokenStorage, CacheService, SocketService, NotificationService, OfflineQueueService, LocationService/Cubit, ThemeCubit, GuestSessionCubit) are registered directly in `injection_container.dart` rather than a feature file.

### Feature module structure

Each `lib/features/<name>/` follows clean-architecture layering:

- `data/datasources/` — Dio-backed remote data sources
- `data/models/` — JSON (de)serialization models
- `data/repositories/` — repository implementations
- `domain/entities/` or `domain/models/` — plain domain objects
- `domain/repositories/` — repository interfaces
- `domain/usecases/` — single-purpose use case classes called by cubits
- `presentation/cubit/` — `flutter_bloc` Cubits/States (state management is Cubit-based, not full Bloc, throughout the app)
- `presentation/pages/`, `presentation/widgets/` — UI

Shared, feature-agnostic code lives in `lib/core/` (constants, DI helpers, error types, network interceptors, services, socket, theme, usecase base class, utils, shared widgets).

### Networking

A single shared `Dio` instance (`lib/injection_container.dart`) is configured with `ApiConstants.effectiveBaseUrl` and an interceptor chain: `ConnectivityInterceptor` → auth-token-injecting `InterceptorsWrapper` → (see `lib/core/network/`) `ErrorInterceptor`, `RetryInterceptor`, `ApiLoggingInterceptor`. `ApiConstants` (`lib/core/constants/api_constants.dart`) centralizes every API path and reads base URL/S3 bucket/partner URLs from `String.fromEnvironment`, which are supplied at build/run time via `--dart-define-from-file=config/env.<env>.json`. `ApiConstants.getImageUrl()` is the single place that resolves relative server paths vs. `stay-india/` S3-prefixed paths into absolute URLs.

### Environments

Two environment files, `config/env.dev.json` (staging API) and `config/env.prod.json` (production API), are selected via `--dart-define-from-file` — never hardcode environment-specific URLs; add new values to `ApiConstants` via `String.fromEnvironment` and both JSON files.

### Persistence

- `flutter_secure_storage` → `TokenStorage` (auth tokens)
- `hydrated_bloc` → automatically persists/restores cubit state across launches for any Cubit extending `HydratedCubit`
- `hive`/`hive_flutter` → structured local cache (see `CacheService`)
- `shared_preferences` → simple flags (e.g. onboarding-seen)
