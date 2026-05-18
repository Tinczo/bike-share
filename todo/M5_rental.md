# M5: Rental Feature (Core)

**Goal:** Complete rental lifecycle: Scan/Input -> Validate -> Unlock -> Ride -> Pause -> Lock -> Pay.
**Ref:** `docs/02_requirements_functional.md` (3.3-3.6), `docs/04_business_rules.md` (5.1), `docs/11_flows.md`

---

## Domain Layer

### Entities

- [x] **Entity: `Rental`** (`lib/features/rental/domain/entities/rental.dart`)
  - Fields:
    - `id` (String) - unique rental identifier
    - `bikeId` (String) - FK to bike
    - `userId` (String) - FK to user
    - `startTime` (DateTime) - rental start timestamp
    - `endTime` (DateTime?) - rental end timestamp (null if active)
    - `cost` (double) - calculated cost (must be >= 0) [Ref: 5.1]
    - `status` (RentalStatus enum: `ACTIVE`, `PAUSED`, `FINISHED`)
  - Ref: `wypozyczenia` table, `docs/09_database_design.md`

- [x] **Entity: `Reservation`** (`lib/features/rental/domain/entities/reservation.dart`)
  - Fields:
    - `id` (String) - unique reservation identifier
    - `bikeId` (String) - FK to bike
    - `userId` (String) - FK to user
    - `createdAt` (DateTime) - creation timestamp
    - `expiresAt` (DateTime) - expiration timestamp (createdAt + 15 minutes)
    - `status` (ReservationStatus enum: `ACTIVE`, `EXPIRED`, `CANCELLED`, `CONVERTED`)
  - Business Rules:
    - Auto-expires after 15 minutes [Ref: 3.3]
    - User can have only ONE active reservation at a time [Ref: 5.1]
  - Ref: `rezerwacje` table

- [x] **Entity: `RentalEligibility`** (`lib/features/rental/domain/entities/rental_eligibility.dart`)
  - Fields:
    - `isEligible` (bool) - computed from rules below
    - `hasMinimumBalance` (bool) - balance >= 20 PLN
    - `hasLinkedCard` (bool) - payment card attached
    - `hasActiveSubscription` (bool) - valid subscription exists
    - `isDebtor` (bool) - user has negative balance
    - `reason` (String?) - human-readable denial reason if not eligible
  - Business Rule: `isEligible = !isDebtor && (hasMinimumBalance || hasLinkedCard || hasActiveSubscription)` [Ref: 5.1]

### Repository Contract

- [x] **Repository: `RentalRepository`** (`lib/features/rental/domain/repositories/rental_repository.dart`)
  - Methods:
    - `Future<Either<Failure, RentalEligibility>> checkEligibility()` - validate user can rent
    - `Future<Either<Failure, Rental>> startRental({required String bikeId, required RentalLaunchMethod method})` - initiate rental (QR or MANUAL)
    - `Future<Either<Failure, Rental>> pauseRental({required String rentalId})` - toggle pause/resume [Ref: 3.5]
    - `Future<Either<Failure, Rental>> endRental({required String rentalId})` - explicit end (optional, IoT-driven primarily)
    - `Future<Either<Failure, Rental>> getActiveRental()` - get current user's active rental
    - `Future<Either<Failure, Reservation>> createReservation({required String bikeId})` - reserve bike
    - `Future<Either<Failure, Unit>> cancelReservation({required String reservationId})` - cancel reservation
    - `Future<Either<Failure, Reservation>> getActiveReservation()` - get current user's active reservation
    - ~~`Stream<Rental> watchActiveRental()` - real-time rental status updates (for IoT events)~~ _(moved to M7 nice-to-have)_

### Use Cases

- [x] **UseCase: `CheckRentalEligibility`** (`lib/features/rental/domain/usecases/check_rental_eligibility.dart`)
  - Purpose: Verify user meets rental prerequisites BEFORE attempting rental
  - Logic: Check balance >= 20 PLN OR hasLinkedCard OR hasActiveSubscription, AND not debtor [Ref: 5.1]
  - Returns: `Either<Failure, RentalEligibility>`
  - **Unit Tests Required** ✅

- [x] **UseCase: `StartRental`** (`lib/features/rental/domain/usecases/start_rental.dart`)
  - Purpose: Initiate bike rental (Saga Step 1: Pre-auth, Step 2: Unlock)
  - Input: `bikeId`, `launchMethod` (QR | MANUAL)
  - Flow: [Ref: `docs/use_cases_realisation/src/rent/rent.puml`]
    1. Validate eligibility (call `CheckRentalEligibility` internally or assume pre-checked)
    2. API call -> Pre-auth payment -> Unlock command -> Await IoT confirmation
  - Error Handling:
    - `402 Payment Required` - insufficient funds [Ref: `rent_refuse.puml`]
    - `504 Gateway Timeout` - IoT lock failure, triggers compensation (refund) [Ref: `rent_lock_error.puml`]
    - `409 Conflict` - bike already rented/reserved
  - Returns: `Either<Failure, Rental>`
  - **Unit Tests Required** ✅

- [x] **UseCase: `PauseRental`** (`lib/features/rental/domain/usecases/pause_rental.dart`)
  - Purpose: Toggle pause/resume for stopover functionality [Ref: 3.5]
  - Logic:
    - If `status == ACTIVE` -> change to `PAUSED` (lock bike)
    - If `status == PAUSED` -> change to `ACTIVE` (unlock bike)
  - Note: Billing continues during pause (per requirement 3.5)
  - Returns: `Either<Failure, Rental>`
  - **Unit Tests Required** ✅

- [x] **UseCase: `EndRental`** (`lib/features/rental/domain/usecases/end_rental.dart`)
  - Purpose: Explicitly end rental (alternative to IoT-driven end)
  - Flow: [Ref: `docs/use_cases_realisation/src/finish_ride/finish_ride.puml`]
    - IoT detects lock -> `BikeLocked` event -> Calculate cost -> Charge
  - Geofencing: [Ref: `finish_ride_out_of_zone.puml`, 3.6]
    - If location is outside station/zone -> add penalty fee
  - Returns: `Either<Failure, Rental>` with final cost
  - **Unit Tests Required** ✅

- [x] **UseCase: `CreateReservation`** (`lib/features/rental/domain/usecases/create_reservation.dart`)
  - Purpose: Reserve a bike for 15 minutes [Ref: 3.3]
  - Preconditions:
    - User has no other active reservation [Ref: 5.1]
    - User is not a debtor
    - User meets eligibility criteria
  - Returns: `Either<Failure, Reservation>`
  - **Unit Tests Required** ✅

- [x] **UseCase: `CancelReservation`** (`lib/features/rental/domain/usecases/cancel_reservation.dart`)
  - Purpose: Manually cancel an active reservation
  - Returns: `Either<Failure, Unit>`
  - **Unit Tests Required** ✅

- [x] **UseCase: `GetActiveRental`** (`lib/features/rental/domain/usecases/get_active_rental.dart`)
  - Purpose: Fetch current user's active rental (if any)
  - Returns: `Either<Failure, Rental?>`
  - **Unit Tests Required** ✅

- [x] **UseCase: `GetActiveReservation`** (`lib/features/rental/domain/usecases/get_active_reservation.dart`)
  - Purpose: Fetch current user's active reservation (if any)
  - Returns: `Either<Failure, Reservation?>`
  - **Unit Tests Required** ✅

### Failures

- [x] **Failure Classes** (`lib/core/error/failures.dart`)
  - `InsufficientFundsFailure` - 402 error, prompt user to top-up
  - `BikeUnavailableFailure` - bike already rented/reserved
  - `IoTFailure` - 504 timeout, lock mechanism error (with compensation info)
  - `EligibilityFailure` - user is debtor or doesn't meet criteria
  - `ReservationExpiredFailure` - reservation timed out
  - `GeofencingPenaltyInfo` - not a failure, but info about penalty applied

---

## Data Layer

### Models

- [x] **Model: `RentalModel`** (`lib/features/rental/data/models/rental_model.dart`)
  - Extends `Rental` entity
  - `fromJson(Map<String, dynamic> json)` - parse API response
  - `toJson()` - serialize for API requests
  - Handle status enum mapping: `W_TRAKCIE` -> `ACTIVE`, `ZAPAUZOWANE` -> `PAUSED`, `ZAKONCZONE` -> `FINISHED`
  - **Unit Tests Required** ✅

- [x] **Model: `ReservationModel`** (`lib/features/rental/data/models/reservation_model.dart`)
  - Extends `Reservation` entity
  - `fromJson(Map<String, dynamic> json)` - parse API response
  - `toJson()` - serialize for API requests
  - Handle status enum mapping: `AKTYWNA` -> `ACTIVE`, `WYGASLA` -> `EXPIRED`, etc.
  - **Unit Tests Required** ✅

- [x] **Model: `RentalEligibilityModel`** (`lib/features/rental/data/models/rental_eligibility_model.dart`)
  - Extends `RentalEligibility` entity
  - `fromJson(Map<String, dynamic> json)` - parse eligibility check response
  - **Unit Tests Required** ✅

### Data Sources

- [x] **Remote Data Source: `RentalRemoteDataSource`** (`lib/features/rental/data/datasources/rental_remote_datasource.dart`)
  - Interface + Implementation
  - Endpoints:
    - `GET /rentals/eligibility` -> `RentalEligibilityModel`
    - `POST /rentals/start` `{bikeId, launchMethod: "QR" | "MANUAL"}` -> `RentalModel`
    - `POST /rentals/{id}/pause` -> `RentalModel`
    - `POST /rentals/{id}/end` -> `RentalModel`
    - `GET /rentals/active` -> `RentalModel?`
    - `POST /reservations` `{bikeId}` -> `ReservationModel`
    - `DELETE /reservations/{id}` -> void
    - `GET /reservations/active` -> `ReservationModel?`
  - Error Code Handling:
    - `402 Payment Required` -> throw `PaymentRequiredException`
    - `504 Gateway Timeout` -> throw `IoTTimeoutException` (include compensation status)
    - `409 Conflict` -> throw `BikeUnavailableException`
  - **Unit Tests Required** ✅

### Repository Implementation

- [x] **Repository: `RentalRepositoryImpl`** (`lib/features/rental/data/repositories/rental_repository_impl.dart`)
  - Implements `RentalRepository`
  - Inject `RentalRemoteDataSource`, `NetworkInfo`
  - Map exceptions to domain Failures
  - Handle network connectivity checks
  - **Unit Tests Required** ✅

---

## Presentation Layer

### BLoC

- [x] **Bloc: `RentalBloc`** (`lib/features/rental/presentation/bloc/rental_bloc.dart`)
  - **Events:**
    - `CheckEligibilityRequested` - validate before showing scan screen
    - `RentalStarted({bikeId, launchMethod})` - initiate rental
    - `RentalPauseToggled` - toggle pause/resume
    - `RentalEndRequested` - explicit end request
    - `ActiveRentalLoaded` - fetch current rental state
    - ~~`RentalUpdatedFromStream(Rental)` - IoT event received~~ _(deferred - requires watchActiveRental)_
  - **States:**
    - `RentalInitial`
    - `RentalEligibilityChecking`
    - `RentalEligible(RentalEligibility)` - user can rent
    - `RentalIneligible(RentalEligibility)` - user cannot rent (show reason)
    - `RentalStarting` - pre-auth in progress
    - `RentalUnlocking` - waiting for IoT unlock confirmation (show loading with bike icon)
    - `RentalActive(Rental)` - ride in progress (show timer, cost)
    - `RentalPaused(Rental)` - stopover in progress [Ref: 3.5]
    - `RentalEnding` - processing end request
    - `RentalEnded(Rental, {bool hasPenalty, double penaltyAmount?})` - show summary
    - `RentalFailure(Failure)` - error with specific type:
      - `InsufficientFunds` - prompt to top-up wallet
      - `IoTError` - inform about refund/compensation
      - `BikeUnavailable` - suggest another bike
  - **Bloc Tests Required** ✅

- [x] **Bloc: `ReservationBloc`** (`lib/features/rental/presentation/bloc/reservation_bloc.dart`)
  - **Events:**
    - `ReservationCreated({bikeId})`
    - `ReservationCancelled`
    - `ReservationTimerTicked` - countdown update
    - `ActiveReservationLoaded`
  - **States:**
    - `ReservationInitial`
    - `ReservationLoading`
    - `ReservationActive(Reservation, Duration remainingTime)` - show countdown
    - `ReservationExpired` - auto-transition when timer hits 0
    - `ReservationCancelled`
    - `ReservationFailure(Failure)`
  - Implements 15-minute countdown timer internally [Ref: 3.3]
  - **Bloc Tests Required** ✅

### Screens

- [x] **Screen: `QRScanScreen`** (`lib/features/rental/presentation/pages/qr_scan_screen.dart`)
  - Primary: Camera viewfinder for QR code scanning
  - **Camera Permissions:** Handle with `permission_handler` package
    - Request permission on screen load
    - Show rationale dialog if denied
    - Navigate to settings if permanently denied
  - **Manual Code Entry Fallback:**
    - "Enter Code Manually" button at bottom
    - Opens bottom sheet with 5-digit numeric input field
    - Validate format before submission
  - **Damaged Bike Warning:** [Ref: 3.4]
    - If scanned bike has `isPotentiallyDamaged == true`, show warning dialog before proceeding
  - **Loading States:**
    - `RentalStarting` - show "Processing payment..."
    - `RentalUnlocking` - show "Unlocking bike..." with animation
  - **Error Handling:**
    - `InsufficientFunds` - dialog with "Top-up Wallet" button -> navigate to wallet
    - `IoTError` - dialog explaining refund, "Try Again" or "Choose Another Bike"
  - Ref: `docs/05_ui_ux.md` for Figma design

- [x] **Screen: `ActiveRentalScreen`** (`lib/features/rental/presentation/pages/active_rental_screen.dart`)
  - **Header:** Bike ID/name, status badge (ACTIVE / PAUSED)
  - **Timer Display:** Live duration counter (HH:MM:SS)
  - **Cost Display:** Real-time estimated cost calculation
  - **Pause Button:** "Zrob postoj" / "Make a Stop" [Ref: 3.5]
    - When pressed: Lock bike, change status to PAUSED
    - Button changes to "Odblokuj" / "Resume" when paused
    - Info text: "Billing continues during stop"
  - **End Rental Button:** "Zakoncz przejazd" / "End Ride"
    - **Geofencing Check:** [Ref: 3.6]
      1. Get current location
      2. If outside station/zone -> show penalty confirmation dialog:
         - "You're returning outside a station. A fee of X PLN will be added."
         - "Confirm" / "Find Nearest Station" buttons
      3. If confirmed -> proceed with end
  - **Map Widget:** Show current location and nearest stations
  - Ref: `docs/05_ui_ux.md` for Figma design

- [x] **Screen: `RentalSummaryScreen`** (`lib/features/rental/presentation/pages/rental_summary_screen.dart`)
  - **Trip Summary:**
    - Duration (formatted)
    - Distance (if available from telemetry)
    - Start/End locations
  - **Cost Breakdown:**
    - Base fare
    - Time charges
    - Penalty fee (if applicable, highlighted in red) [Ref: 3.6]
    - Total
  - **Payment Status:** Charged to wallet/card
  - **Actions:**
    - "Done" -> return to map
    - "Report Issue" -> navigate to issue reporting
  - Ref: `docs/05_ui_ux.md` for Figma design

- [x] **Screen: `ReservationScreen`** (`lib/features/rental/presentation/pages/reservation_screen.dart`)
  - **Or integrate into bike detail sheet**
  - **Countdown Timer:** Large, prominent display (MM:SS) [Ref: 3.3]
    - Visual warning when < 2 minutes remaining (color change)
  - **Bike Info:** Name, location, distance
  - **Actions:**
    - "Cancel Reservation" button
    - "Start Rental" button (scan QR or enter code)
  - **Auto-Expiry Handling:**
    - When timer reaches 0, show "Reservation Expired" message
    - Auto-navigate back or show "Reserve Again" option
  - Ref: `docs/05_ui_ux.md` for Figma design

### Widgets

- [x] **Widget: `RentalTimerWidget`** - Live duration counter
- [x] **Widget: `CostDisplayWidget`** - Real-time cost with currency formatting
- [x] **Widget: `PenaltyWarningDialog`** - Geofencing penalty confirmation [Ref: 3.6]
- [x] **Widget: `ManualCodeEntrySheet`** - Bottom sheet for manual bike ID input
- [x] **Widget: `RentalStatusBadge`** - ACTIVE/PAUSED/ENDED badge
- [x] **Widget: `ReservationCountdownWidget`** - 15-minute countdown display
- [x] **Widget: `DamagedBikeWarningDialog`** - Warning for potentially damaged bikes [Ref: 3.4]

---

## Integration & Navigation

- [x] **Router Integration** (`lib/core/router/app_router.dart`)
  - `/rental/scan` - QRScanScreen (requires auth)
  - `/rental/active` - ActiveRentalScreen (requires active rental)
  - `/rental/summary/:id` - RentalSummaryScreen
  - `/reservation/:bikeId` - ReservationScreen or integrated in bike detail

- [x] **Dependency Injection** (`lib/injection_container.dart`)
  - Register all UseCases, Repository, DataSource, Blocs

---

## Backend Endpoints (Reference for Frontend)

Backend (`backend/`) supports these endpoints: ✅

| Method | Endpoint               | Request Body             | Response                                                                                   | Notes                    |
| ------ | ---------------------- | ------------------------ | ------------------------------------------------------------------------------------------ | ------------------------ |
| GET    | `/rentals/eligibility` | -                        | `{isEligible, hasMinimumBalance, hasLinkedCard, hasActiveSubscription, isDebtor, reason?}` | Check before rental      |
| POST   | `/rentals/start`       | `{bikeId, launchMethod}` | `{id, bikeId, userId, startTime, status}`                                                  | May return 402, 504, 409 |
| POST   | `/rentals/:id/pause`   | -                        | `{...rental, status: PAUSED\|ACTIVE}`                                                      | Toggle pause             |
| POST   | `/rentals/:id/end`     | -                        | `{...rental, endTime, cost, hasPenalty?, penaltyAmount?}`                                  | Explicit end             |
| GET    | `/rentals/active`      | -                        | `{...rental}` or `null`                                                                    | Get current rental       |
| POST   | `/reservations`        | `{bikeId}`               | `{id, bikeId, userId, createdAt, expiresAt, status}`                                       |                          |
| DELETE | `/reservations/:id`    | -                        | `204 No Content`                                                                           | Cancel reservation       |
| GET    | `/reservations/active` | -                        | `{...reservation}` or `null`                                                               | Get current reservation  |

---

## Testing Checklist

### Unit Tests

- [x] `RentalEligibility` entity logic
- [x] `CheckRentalEligibility` use case
- [x] `StartRental` use case (success + all failure scenarios)
- [x] `PauseRental` use case
- [x] `EndRental` use case
- [x] `CreateReservation` use case
- [x] `CancelReservation` use case
- [x] `RentalModel` fromJson/toJson
- [x] `ReservationModel` fromJson/toJson
- [x] `RentalRepositoryImpl` (mock data source)
- [x] `RentalRemoteDataSource` (mock Dio)

### Bloc Tests

- [x] `RentalBloc` - all events and state transitions
- [x] `ReservationBloc` - timer countdown, expiry handling

### Widget Tests

- [ ] `QRScanScreen` - permission handling, manual entry _(moved to M7 nice-to-have)_
- [ ] `ActiveRentalScreen` - pause toggle, end with geofencing _(moved to M7 nice-to-have)_
- [ ] `ReservationCountdownWidget` - timer accuracy _(moved to M7 nice-to-have)_

---

## Dependencies to Add

```yaml
# pubspec.yaml
dependencies:
  mobile_scanner: ^5.0.0 # QR code scanning ✅
  permission_handler: ^11.0.0 # Camera permissions ✅
  geolocator: ^10.0.0 # Location for geofencing check ✅
```

---

## Acceptance Criteria Summary

1. ✅ User cannot rent if: debtor OR (balance < 20 PLN AND no card AND no subscription) [Ref: 5.1]
2. ✅ QR scan OR manual 5-digit code entry unlocks bike [Ref: 3.4]
3. ✅ Pause/Resume functionality works, billing continues [Ref: 3.5]
4. ✅ Reservation expires after 15 minutes with visible countdown [Ref: 3.3]
5. ✅ Return outside station shows penalty warning before confirmation [Ref: 3.6]
6. ✅ IoT failure triggers compensation (refund) and user-friendly error [Ref: `rent_lock_error.puml`]
7. ✅ Damaged bike warning shown before rental start [Ref: 3.4]

---

## Summary

**Status: COMPLETE** ✅

- **155 tests passing** (39 domain + 59 data + 27 datasource + 30 presentation)
- All core functionality implemented
- Backend stubs created
- Integration complete (DI, routing, BikeDetailsBottomSheet)

**Deferred to M7 (Nice to have):**

- `watchActiveRental()` Stream for real-time IoT updates
- Widget tests for rental screens
