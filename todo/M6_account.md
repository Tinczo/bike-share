# M6: User Account & History

**Goal:** User profile, rental history, and fault report history display.
**Ref:** `docs/02_requirements_functional.md` (3.14, 3.7), `docs/04_business_rules.md` (5.1, 5.2), `docs/05_ui_ux.md` (6.7)

---

## Important Context

> **Navigation Note:** The `ReportFaultScreen` entry points are located in:
>
> - `ActiveRentalScreen` (M5) - "Zglos problem" button on the active rental tile
> - `BikeDetailsScreen` (M3) - "Zglos usterke" option in bike details (before renting)
>
> This module (M6) handles the **history display** of fault reports and user account management.
> The actual fault reporting UI/logic should be implemented considering entry points from M3 and M5.

> **Rewards System:** Users receive **0.50 PLN** reward when their fault report is verified and confirmed by a service worker. The UI should inform users about this incentive (e.g., "Zglos usterke i zyskaj 0,50 zl" or display reward status in history).

---

## Fault Types Enum

Based on UI prototypes and database schema, implement the following enum:

```dart
enum FaultType {
  flatTireFront,    // BRAK_POWIETRZA_PRZOD
  flatTireRear,     // BRAK_POWIETRZA_TYL
  brokenLock,       // USZKODZONY_ZAMEK
  brokenChain,      // USZKODZONY_LANCUCH
  damagedSaddle,    // USZKODZONE_SIODELKO
  damagedHandlebar, // USZKODZONA_KIEROWNICA
  other,            // INNE
}
```

---

## Tasks

- [x] **Domain Layer**
  - [x] Entity: `RentalHistoryItem` (`lib/features/account/domain/entities/rental_history_item.dart`).
    - Fields: `id`, `bikeId`, `startTime`, `endTime`, `cost`, `startStation`, `endStation`.
    - Aggregated from `wypozyczenia` and `fakt_przejazdu` concepts.
  - [x] Entity: `FaultReport` (`lib/features/account/domain/entities/fault_report.dart`).
    - Fields:
      - `id` (String) - Unique identifier
      - `bikeId` (String) - Reference to the bike
      - `userId` (String) - Reference to the reporting user
      - `type` (FaultType enum) - See enum definition above
      - `description` (String?) - Optional description (required when type is `other`)
      - `timestamp` (DateTime) - When the fault was reported
      - `isVerified` (bool) - Whether service worker has verified the report
      - `isConfirmed` (bool) - Whether the fault was confirmed as valid
      - `verificationDate` (DateTime?) - When verification occurred
      - `rewardAmount` (double?) - Reward amount if confirmed (0.50 PLN)
    - Ref: `zgloszenia_usterek` table (`docs/09_database_design.md`)
  - [x] Enum: `FaultType` (`lib/features/account/domain/entities/fault_type.dart`).
  - [x] Repository Contract: `AccountRepository`.
    - Methods:
      - `getRentalHistory()` -> `Future<Either<Failure, List<RentalHistoryItem>>>`
      - `getFaultReportHistory()` -> `Future<Either<Failure, List<FaultReport>>>`
      - `reportFault(FaultReport report)` -> `Future<Either<Failure, FaultReport>>`
  - [x] UseCase: `GetRentalHistory`.
  - [x] UseCase: `GetFaultReportHistory`.
  - [x] UseCase: `ReportFault`.
  - [x] Unit Tests.

- [x] **Data Layer**
  - [x] Model: `RentalHistoryItemModel` (extends `RentalHistoryItem`).
  - [x] Model: `FaultReportModel` (extends `FaultReport`).
    - Include `fromJson`/`toJson` for API communication.
    - Map API field names: `czy_zweryfikowane` -> `isVerified`, `czy_potwierdzone` -> `isConfirmed`.
  - [x] DataSource: `AccountRemoteDataSource`.
    - `GET /history/rentals` - Fetch rental history.
    - `GET /history/faults` - Fetch fault report history with verification status.
    - `POST /faults/report` - Submit a new fault report.
  - [x] Repository Impl: `AccountRepositoryImpl`.
  - [x] Unit Tests.

- [x] **Presentation Layer**
  - [x] Bloc: `HistoryBloc` - Manages rental history state.
  - [x] Bloc: `FaultHistoryBloc` - Manages fault report history state.
  - [x] Bloc: `ReportFaultBloc` - Manages fault reporting form state.
  - [x] Screen: `HistoryScreen` - Displays rental history list.
  - [x] Screen: `FaultHistoryScreen` - Displays fault reports with verification/reward status.
  - [x] Screen: `ReportFaultScreen` - Fault reporting form.
    - Display fault type selector (dropdown/chips).
    - Show description field (expanded when "Inne" selected).
    - Show reward incentive message: "Zglos usterke i zyskaj 0,50 zl!".
    - Figma: https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-1049&m=dev
  - [x] Widget: `FaultReportTile` - Shows report with status indicator (pending/verified/confirmed + reward).
  - [x] Bloc Tests.

---

## API Response Examples

### GET /history/faults Response

```json
{
  "faults": [
    {
      "id": "fault-123",
      "bike_id": "bike-456",
      "user_id": "user-789",
      "typ_usterki": "USZKODZONY_ZAMEK",
      "opis": null,
      "czas_zgloszenia": "2024-01-15T10:30:00Z",
      "czy_zweryfikowane": true,
      "czy_potwierdzone": true,
      "data_weryfikacji": "2024-01-15T14:00:00Z",
      "reward_amount": 0.5
    }
  ]
}
```

### POST /faults/report Request

```json
{
  "bike_id": "bike-456",
  "typ_usterki": "BRAK_POWIETRZA_TYL",
  "opis": null
}
```

---

## UI States for Fault History

Display different states for fault reports in history:

- **Pending** (yellow) - `isVerified: false` - "Oczekuje na weryfikacje"
- **Verified** (blue) - `isVerified: true, isConfirmed: false` - "Zweryfikowane"
- **Confirmed + Reward** (green) - `isVerified: true, isConfirmed: true` - "Potwierdzone - Otrzymano 0,50 zl"
- **Rejected** (red) - `isVerified: true, isConfirmed: false` (after verification) - "Odrzucone"
