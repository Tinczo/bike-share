# M7: UI Polish & Integration Testing

**Goal:** Finalize the app look and feel and ensure stability.
**Ref:** `docs/05_ui_ux.md`

- [ ] **UI Polish**
  - [ ] Ensure consistent spacing and typography (Material 3).
  - [ ] Add animations for state transitions (e.g., Unlocking bike spinner).
  - [x] Verify error states and loading indicators across all screens.
  - [x] Verify "Happy Paths" from `docs/use_cases_realisation`.
  - [ ] Add battery icon on right-bottom corner of bike marker if bike is electric. (has batteryLevel and rangeKm). Nice to have: different icon states based on battery level (e.g., full, medium, low).
  - [x] bike_details_bottom_sheet: don't show range and battery level if bike is not electric (batteryLevel == null, rangeKm == null).
  - [x] station_mark: refactor to look simmalr like the mockups on figma:
        https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-170&m=dev

- [ ] **Integration Testing**
  - [ ] Write integration tests for the "Happy Path" (Login -> Rent -> Return).
  - [ ] Test offline capabilities (caching).

- [ ] **Final Review**
  - [ ] Check compliance with all functional requirements.
  - [ ] Ensure all `todo` annotations from M1-M6 are met.

- [ ] **Fixes**
  - [x] Fetching data is realy slow. Espesially for wallet. Maybe because there are three calls in sequence. Let's optimize it. And let's cache wallet data.
  - [x] Fetching data is also an issue because it needs to check internet connection first. Maybe we can optimize it.
  - [x] Bikes and stations are feteched befor logging in (fix tests and code). Maybe it's a bug, maybe not.
  - [x] Test multiple pauses and resumes during rental.

- [ ] **Nice to have**
  - [x] Similar UI for wallet as mockups on figma
        https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-555&m=dev
        https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-414&m=dev
  - [x] Make nice sliding animation for bike details bottom sheet.
  - [ ] Add `watchActiveRental()` Stream method to RentalRepository for real-time IoT updates
  - [ ] Widget tests for rental screens (QRScanScreen, ActiveRentalScreen, ReservationCountdownWidget)
