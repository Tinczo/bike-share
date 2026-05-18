# M3: Map & Bike Fleet Feature

**Goal:** Real-time map with bikes and stations.
**Ref:** `docs/02_requirements_functional.md` (3.2, 3.8, 3.9)
**Ref:** `docs/10_implementation_details.md`
**UI/UX:** `docs/05_ui_ux.md` (6.2)

- [x] **Domain Layer**
  - [x] Entity: `Bike` (`lib/features/map/domain/entities/bike.dart`).
    - Fields: `id` (String), `qrCode`, `status` (Enum: `AVAILABLE`, `RENTED`, `RESERVED`, `BROKEN`), `batteryLevel` (int), `location` (Location), `rangeKm` (int).
    - Ref: `rowery` table (`id_roweru`, `status`, `poziom_baterii`).
  - [x] Entity: `Station` (`lib/features/map/domain/entities/station.dart`).
    - Fields: `id` (String), `name` (String), `location` (Location), `capacity` (int), `availableBikes` (int), `availableStands` (int).
    - Ref: `stacje` & `statusy_stacji`.
  - [x] Entity: `Location` (`lib/features/map/domain/entities/location.dart`).
    - Fields: `latitude` (double), `longitude` (double).
  - [x] Repository Contract: `MapRepository`.
    - Methods: `getNearbyBikes(Location center, double radius)`, `getStations()`.
  - [x] UseCase: `GetNearbyBikes`.
  - [x] UseCase: `GetStations`.
  - [x] Unit Tests.

- [x] **Data Layer**
  - [x] Model: `BikeModel` (extends `Bike`).
    - Maps from Telemetry/Fleet DTO.
  - [x] Model: `StationModel` (extends `Station`).
  - [x] DataSource: `MapRemoteDataSource` (API endpoints for fleet).
    - Endpoint: `GET /map/bikes`, `GET /map/stations`.
    - Ref: `docs/use_cases_realisation/src/geofencing/geofencing.puml` (Read Path).
  - [x] Repository Impl: `MapRepositoryImpl`.
  - [x] Unit Tests.

- [x] **Presentation Layer**
  - [x] Bloc: `MapBloc` (Events: LoadMap, FilterBikes).
  - [x] Screen: `MapScreen` (using `flutter_map`).
  - [x] Widget: `BikeMarker`, `StationMarker`.
  - [x] Widget: `BikeDetailsBottomSheet` (triggered on marker tap).
  - [x] Bloc Tests.

---

## Enhancements

- [x] **Fix Marker Rotation**
  - [x] Add `rotate: false` to BikeMarker in `map_screen.dart` (~line 149)
  - [x] Add `rotate: false` to StationMarker in `map_screen.dart` (~line 168)
  - **Rationale:** Markers should stay upright when the map is panned/rotated.

- [ ] **Local Data Caching**
  - Strategy: Network-first with stale fallback (using SharedPreferences)
  - TTL: **3 minutes** for bikes, **10 minutes** for stations

  - [x] **Model:** Create `CachedMapData` (`lib/features/map/data/models/cached_map_data.dart`)
    - `CachedBikesData` with `List<BikeModel>`, `DateTime cachedAt`, `isExpired(Duration ttl)`
    - `CachedStationsData` with `List<StationModel>`, `DateTime cachedAt`, `isExpired(Duration ttl)`

  - [x] **DataSource:** Create `MapLocalDataSource` (`lib/features/map/data/datasources/map_local_datasource.dart`)
    - Interface methods:
      - `Future<List<BikeModel>> getCachedBikes()`
      - `Future<void> cacheBikes(List<BikeModel> bikes)`
      - `Future<bool> isBikesCacheValid()`
      - `Future<List<StationModel>> getCachedStations()`
      - `Future<void> cacheStations(List<StationModel> stations)`
      - `Future<bool> isStationsCacheValid()`
    - Implementation uses SharedPreferences with JSON + timestamp

  - [x] **Repository:** Update `MapRepositoryImpl` (`lib/features/map/data/repositories/map_repository_impl.dart`)
    - OLD caching logic:
      ```
      1. Online: Try remote → cache result with timestamp → return data
      2. Offline or server error: Check cache → if valid (not expired) → return cached data
      3. Cache expired or empty: Return CacheFailure
      ```
    - New caching logic:
      ```
      1. Online: Check cache → if valid (not expired) → return cached data -> Try remote → cache result with timestamp → return data
      2. Offline or server error: Check cache → if valid (not expired) → return cached data
      3. Cache expired or empty: Return CacheFailure
      ```

  - [x] **Tests:**
    - [x] Unit tests for `MapLocalDataSource` (`test/features/map/data/datasources/map_local_datasource_test.dart`)
    - [x] Update `MapRepositoryImpl` tests (`test/features/map/data/repositories/map_repository_impl_test.dart`)

  - [x] **Bug:**
    - [x] If can't reach server the loading spinner spins forever. Should timeout and show error after.

---

## Verification

1. **Marker rotation:** Pan/rotate map → markers stay upright
2. **Caching - online:** Load map → turn off wifi → refresh → still shows data (from cache)
3. **Caching - TTL:** Wait >3 min → refresh offline → should show CacheFailure for bikes
4. **Tests:** `flutter test` - all pass
5. **Analysis:** `flutter analyze` - no issues
