# Bike App — Urban Bike Rental System

A fully-featured Flutter mobile application for managing urban bicycle infrastructure. Users can rent bikes, view real-time station availability on a map, manage their wallet, and track rental history. Built as a portfolio project demonstrating production-grade Flutter architecture.

---

## Tech Stack

| Category                      | Technology                                            |
| ----------------------------- | ----------------------------------------------------- |
| **Framework**                 | Flutter 3.x, Dart 3 (null safety)                     |
| **State Management**          | `flutter_bloc` (BLoC pattern with event transformers) |
| **Navigation**                | `go_router` (typed routes, auth guards)               |
| **Dependency Injection**      | `get_it` + `injectable`                               |
| **Networking**                | `dio` (interceptors, auth token injection)            |
| **Functional Error Handling** | `dartz` — `Either<Failure, T>` throughout             |
| **Maps**                      | `flutter_map` (OpenStreetMap) + `geolocator`          |
| **QR Scanning**               | `mobile_scanner`                                      |
| **Secure Storage**            | `flutter_secure_storage`                              |
| **Serialization**             | `json_annotation` + `json_serializable`               |
| **Testing**                   | `mocktail`, `bloc_test`, `flutter_test`               |
| **Backend**                   | Node.js / Express REST API                            |

---

## Architecture

The project follows **Clean Architecture** organized **Feature-First**, consistent with the Reso Coder methodology.

```
lib/
  core/               # Shared: failures, network, theme, router, DI
  features/
    auth/             # Login, register, secure token storage
    map/              # Real-time bike & station display
    rental/           # Full rental lifecycle (QR → ride → end)
    wallet/           # Balance, top-ups, transaction history
    account/          # Profile, rental history, fault reports
  main.dart
  injection_container.dart
```

Each feature is split into three clean layers:

- **Domain** — pure Dart: entities, repository contracts, use cases, failures
- **Data** — DTOs, remote/local data sources, repository implementations
- **Presentation** — BLoC (events/states), pages, widgets

Error handling uses `Either<Failure, T>` across repository and use case boundaries. The UI never sees raw exceptions — only typed `Failure` subclasses surfaced through BLoC states.

---

## Features

### Authentication

- Registration and login with JWT token management
- Secure token persistence via `flutter_secure_storage`
- GoRouter auth guard — protected routes redirect unauthenticated users

### Map & Bike Fleet

- Real-time map of bike stations powered by `flutter_map` (OpenStreetMap)
- Live geolocation via `geolocator`
- Station detail view: available bikes, capacity, distance

### Rental Lifecycle

- Eligibility check before rental (active debt, active reservation conflicts)
- QR code scanning (`mobile_scanner`) with manual bike ID fallback
- Unlock → ride timer → pause/resume → end rental
- Geofencing-based penalty detection for out-of-zone returns
- Rental cost summary screen

### Wallet & Payments

- Account balance display
- Top-up flow with amount selection
- Full transaction history

### Account & History

- User profile management
- Full rental history with filtering
- Fault/damage reporting for bikes

---

## App Screens

<table>
  <tr>
    <td align="center"><img src="mockups/ekran logowania.png" width="180"/><br/><sub>Login</sub></td>
    <td align="center"><img src="mockups/ekran rejestracji.png" width="180"/><br/><sub>Registration</sub></td>
    <td align="center"><img src="mockups/ekran główny.png" width="180"/><br/><sub>Map — Main</sub></td>
    <td align="center"><img src="mockups/ekran główny-podgląd roweru.png" width="180"/><br/><sub>Bike Preview</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="mockups/ekran główny-podgląd wypożyczeń.png" width="180"/><br/><sub>Rental Preview</sub></td>
    <td align="center"><img src="mockups/ekran rezerwacji.png" width="180"/><br/><sub>Reservation</sub></td>
    <td align="center"><img src="mockups/ekran skanowania kodu qr.png" width="180"/><br/><sub>QR Scan</sub></td>
    <td align="center"><img src="mockups/ekran skanowania kodu qr-wprowadznenie numeru.png" width="180"/><br/><sub>Manual ID Entry</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="mockups/ekran potwierdzenia wypożyczenia.png" width="180"/><br/><sub>Rental Confirmation</sub></td>
    <td align="center"><img src="mockups/ekran zakończenia wypożyczenia.png" width="180"/><br/><sub>End Rental</sub></td>
    <td align="center"><img src="mockups/ekran zakończenia wypożyczenia podsumowanie.png" width="180"/><br/><sub>Rental Summary</sub></td>
    <td align="center"><img src="mockups/ekran potwierdzenia blokady poza stacją.png" width="180"/><br/><sub>Out-of-Zone Lock</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="mockups/ekran portfela.png" width="180"/><br/><sub>Wallet</sub></td>
    <td align="center"><img src="mockups/ekran doładowania-1.png" width="180"/><br/><sub>Top-up Step 1</sub></td>
    <td align="center"><img src="mockups/ekran doładowania-2.png" width="180"/><br/><sub>Top-up Step 2</sub></td>
    <td align="center"><img src="mockups/ekran zgłoszenia usterek.png" width="180"/><br/><sub>Fault Report</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="mockups/ekran zgłoszenia usterek-inne.png" width="180"/><br/><sub>Fault Report — Other</sub></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
</table>

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Dart 3.x
- Android Studio or Xcode (for emulator/simulator)

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/bike-app.git
cd bike-app

# Install dependencies
flutter pub get

# Generate DI and serialization code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Running Tests

```bash
flutter test
```

---

## Project Status

| Milestone | Status  | Description                                          |
| --------- | ------- | ---------------------------------------------------- |
| M1        | ✅ Done | Project setup, architecture, CI/CD, routing          |
| M2        | ✅ Done | Authentication (login, register, token storage)      |
| M3        | ✅ Done | Map & bike fleet (real-time display, geolocation)    |
| M4        | ✅ Done | Wallet & payments (top-up, history)                  |
| M5        | ✅ Done | Rental feature (QR scan, ride lifecycle, 155+ tests) |
| M6        | ✅ Done | Account & rental history                             |
| M7        | ✅ Done | UI polish, comprehensive testing, bug fixes          |

---

## Documentation

Full specification is maintained in the [`docs/`](docs/) folder:

- [`01_intro.md`](docs/01_intro.md) — Project goals and glossary
- [`02_requirements_functional.md`](docs/02_requirements_functional.md) — 16 functional requirements
- [`04_business_rules.md`](docs/04_business_rules.md) — Business rules and constraints
- [`06_architecture.md`](docs/06_architecture.md) — Architectural decisions
- [`09_database_design.md`](docs/09_database_design.md) — Database schema
- [`11_flows.md`](docs/11_flows.md) — Sequence diagrams and use case flows
