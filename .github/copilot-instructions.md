# Copilot Instructions for inventory

> **Note:** This repository is a Flutter application using Clean Architecture and feature‑first organization. The workspace currently contains a Flutter project scaffolded with Riverpod state management.

---

## Project overview

This Flutter app is structured around Clean Architecture with a feature‑first layout. Each feature folder (`auth`, `dashboard`, `inventory`, `reports`) contains `presentation`, `domain`, and `data` subfolders. Shared code lives under `lib/core` (themes, widgets, services, providers).

Key characteristics:

* **Features** define their own pages, entities, repositories, and data models.
* **Repository pattern** is used; concrete implementations live in `data/repositories` and depend on a shared `ApiService`.
* **State** is managed with Riverpod 3.0; providers are defined in `data/providers` within features or under `core/providers` for cross-cutting services.
* **Authentication**: The `auth` feature handles login/logout, token storage (via `SharedPreferences`), and supplies an access token to all API requests through the global `accessTokenProvider`.
* **API integration**: `ApiService` centralizes HTTP communication and automatically includes the Bearer token in the Authorization header when available.
* **Navigation**: Determined dynamically by auth state via `_RootNavigator`; shows `LoginPage` if not authenticated, otherwise renders the main app.
* **UI** targets Material 3 with custom theming under `core/themes/app_theme.dart`.

When adding new features or layers, follow existing folders as examples.

## Developer workflows

- **Building**: run `flutter pub get` after modifying `pubspec.yaml`. Use `flutter run` or `flutter build` for development and production builds.
- **Code generation**: execute `flutter pub run build_runner build --delete-conflicting-outputs` when using Riverpod generators, Freezed, or JSON serialization.
- **Testing**: use `flutter test` for unit/widget tests; feature tests may live under `test/`.
- **Debugging**: standard Flutter tooling (DevTools, `flutter analyze`, `flutter doctor`). The project has `analysis_options.yaml` with the default `flutter_lints` rules.

> Update these notes if new build or test scripts are added.

## Conventions & patterns

- **Feature-first folders**: Each feature has `presentation`, `domain`, and `data` subdirectories. Repositories, use cases, and providers live close to related code.
- **Core utilities**: Shared theming, widgets (e.g. `AppDrawer`), and services (e.g. `ApiService`) reside in `lib/core`.
- **State providers**: Use Riverpod generators where appropriate; provider files often sit in `data/providers` within features or under `core/providers` for cross-cutting services.
- **API layer**: `ApiService` centralizes HTTP communication; repositories take it as a dependency through providers.
* **Navigation**: The app uses a professional responsive navigation system under `core/navigation/`:
  - **Mobile**: Standard drawer (`ProfessionalNavigationSidebar` in drawer mode)
  - **Desktop**: Collapsible sidebar that animates between 250px (expanded) and 80px (collapsed)
  - **Modules**: `NavigationModule` defines expandable sections; `NavigationMenu` defines sub-items
  - **State**: `navigationProvider.dart` manages expanded module and active menu via Riverpod
  - **Styling**: `NavColors` (black background, coral red #ff5252/#ff6b6b active) and `NavSizing` constants
  - New modules can be added to `defaultNavigationModules` in `navigation_model.dart`
- **Styling**: Material 3 is enabled through `ThemeData` in `core/themes/app_theme.dart`.
- **Data models**: include `.toJson()`/`fromJson()` helpers; Freezed may be adopted later.

Avoid adding large logic into presentation widgets; prefer Riverpod state notifiers or providers.

## Integration and dependencies

Dependencies are managed in `pubspec.yaml`. Current packages include:

* `flutter_riverpod`, `riverpod_generator` – state management
* `fl_chart` – charts for dashboard
* `http` – simple HTTP client used by `ApiService`
* `shared_preferences` – local persistent token storage
* `freezed`/`json_serializable` – data modeling (installed but not yet used)

**Backend integration**: The app connects to a backend at `http://localhost:9091`. Update the base URL in `core/providers/api_provider.dart` if needed. Authentication uses POST `/api/auth/authenticate` with `{login, password}` and stores returned `access_token` and `refresh_token`.

When connecting to new endpoints, add methods to `ApiService` and update `AuthRepositoryImpl` or create new feature repositories that depend on `apiServiceProvider`.

## How to update the instructions

Whenever you add meaningful code:

1. Read the new files and update the big‑picture section above to describe the architecture.
2. Record any non‑standard build/test commands under Developer workflows.
3. Note any conventions that differ from typical language defaults (e.g. files ending in `.ts` but transpiled by a custom script).
4. Keep this file concise (20–50 lines) and specific to the current state of the repository.

---

🧠 If you (the human or another AI) are unsure what to write, ask the user or the team for clarification instead of guessing. Once the first real code is added, regenerate this document with actual details.
