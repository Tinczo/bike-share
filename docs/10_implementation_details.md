# 15. Widok Wytwarzania

Widok wytwarzania prezentuje strukturę kodu źródłowego systemu, organizację pakietów oraz zależności między modułami implementacyjnymi. System charakteryzuje się architekturą poliglotyczną, wykorzystującą technologie Java (Spring Boot), Python (FastAPI) oraz Dart (Flutter).

## 15.1 Mikroserwisy Backendowe (Java/Spring Boot)
Serwisy transakcyjne i operacyjne zostały zaimplementowane w języku Java przy użyciu frameworka Spring Boot. Ich architektura wewnętrzna opiera się na podziale na warstwy (Layered Architecture) z elementami architektury heksagonalnej.

### 15.1.1 Serwis Wypożyczeń (Rental Service)
Centralny moduł systemu odpowiedzialny za logikę biznesową wynajmu.
*   **web (API Layer):** `RentalController`, `RentalDTO`.
*   **domain (Business Logic):** `RentalService`, `ReservationService`, `CostCalculator` (pricing), `RentalSagaManager` (process_saga).
*   **infrastructure:** `RentalRepository`, `RedisPriceProvider`, `RentalEventProducer` (Kafka).

### 15.1.2 Serwis Płatności (Payment Service)
Moduł realizujący operacje finansowe.
*   **api (Web Layer):** `PaymentController`.
*   **domain (Business Logic):** `WalletService`, `TransactionManager`, `PaymentGatewayPort`.
*   **infrastructure:** `PaymentStatusProducer` (Kafka), `StripeAdapter`/`BlikAdapter` (External), `PaymentRepository`.

### 15.1.3 Serwis Floty (Fleet Service)
Specyficzny mikroserwis obsługujący zarówno ruch HTTP, jak i strumieniowy ruch IoT/MQTT.
*   **interfaces:** `MqttMessageHandler`, `FleetController`.
*   **domain (Core Logic):** `GeofencingService`, `BikeStatusService`.
*   **infrastructure:** `FleetEventProducer` (Kafka), `ZoneRepository` (PostgreSQL), `TelemetryRepository` (InfluxDB), `LiveMapRepository` (Redis).

## 15.2 Serwis Analityczny (Python)
Moduł zaimplementowany w języku Python (FastAPI).
*   **app:**
    *   **api:** `ReportRouter`.
    *   **core:** `ETLService`, `ReportGenerator`.
    *   **consumers:** `EventConsumer` (Kafka).
    *   **db:** Konektory do ClickHouse/Postgres.
    *   **models:** Pydantic/ORM models.

## 15.3 Aplikacja Mobilna (Flutter)
Architektura aplikacji klienckiej oparta jest o podejście "Feature-first" i Clean Architecture.

### 15.3.1 Struktura ogólna
*   **lib:** Główny punkt wejścia (`main.dart`).
*   **features:** Katalogi poszczególnych funkcjonalności:
    *   `auth` (Logowanie)
    *   `account` (Profil)
    *   `faults` (Usterki)
    *   `map` (Mapa)
    *   `wallet` (Portfel)
    *   `rental` (Wypożyczenia)
*   **core:** Współdzielone elementy infrastrukturalne:
    *   `util`: Narzędzia pomocnicze (np. `InputConverter`).
    *   `usecases`: Generyczny interfejs przypadków użycia (`UseCase`).
    *   `network`: Obsługa połączeń sieciowych (`NetworkInfo`).
    *   `error`: Definicje wyjątków i błędów (`Exceptions`, `Failures`).

### 15.3.2 Szczegóły implementacji funkcji (Feature: Rental)
Wnętrze każdego modułu `feature` podzielone jest na trzy warstwy: Presentation, Domain, Data.
*   **presentation:**
    *   `pages`: Ekrany aplikacji (`RentalScreen`).
    *   `widgets`: Komponenty UI (`TimerWidget`).
    *   `bloc`: Zarządzanie stanem (`RentalEvent`, `RentalBloc`, `RentalState`).
*   **domain:** Warstwa logiki biznesowej (niezależna od frameworka).
    *   `usecases`: Konkretne przypadki użycia (`ReturnBikeUseCase`, `RentBikeUseCase`).
    *   `entities`: Modele domenowe (`Rental`).
    *   `contracts (repositories)`: Interfejsy repozytoriów (`RentalRepositoryContract`).
*   **data:** Warstwa dostępu do danych.
    *   `models`: Modele transportowe/JSON (`RentalModel`).
    *   `repositories`: Implementacja interfejsów (`RentalRepositoryImpl`).
    *   `datasources`: Źródła danych – zdalne API (`RentalRemoteDataSource`) oraz lokalny cache (`RentalLocalDataSource`).
