# M1: Project Setup & Core

**Goal:** Initialize the Flutter project with Clean Architecture structure and core dependencies.

- [x] **Initialize Project**
  - [x] Create new Flutter project (if not already clean).
  - [x] Rename/Setup package name `com.bikeapp`.
  - [x] Configure `analysis_options.yaml` (strict rules).

- [x] **Dependencies & Assets**
  - [x] Add dependencies: `flutter_bloc`, `get_it`, `injectable`, `equatable`, `dartz`, `go_router`, `dio`, `shared_preferences`.
  - [x] Add dev dependencies: `mocktail`, `bloc_test`, `build_runner`, `injectable_generator`.
  - [x] Setup assets folder structure (images, icons).

- [x] **Core Architecture Layer**
  - [x] Create `lib/core/error/failures.dart`.
  - [x] Create `lib/core/error/exceptions.dart`.
  - [x] Create `lib/core/usecases/usecase.dart`.
  - [x] Create `lib/core/network/network_info.dart`.
  - [x] Create `lib/core/util/input_converter.dart`.

- [x] **Routing & Theme**
  - [x] Setup `GoRouter` configuration (`lib/core/router/app_router.dart`).
  - [x] Define basic App Theme (`lib/core/theme/app_theme.dart`).

- [x] **Dependency Injection**
  - [x] Setup `GetIt` and `Injectable` (`lib/injection_container.dart`).

- [x] **UI Source**
  - [x] Add source UI screens from Figma designs.
  - [x] Setup basic navigation between screens.
