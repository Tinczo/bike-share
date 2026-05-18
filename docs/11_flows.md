# 16. Realizacja przypadków użycia

## 16.1 Proces wypożyczenia roweru
Proces wypożyczenia jest operacją krytyczną, wymagającą ścisłej spójności danych oraz niskiego czasu reakcji. Zrealizowano go przy użyciu wzorca **Saga** (kroki walidacji finansowej i sterowania sprzętem), co pozwala na zachowanie spójności w systemie rozproszonym.

### 16.1.1 Scenariusz główny: Pomyślne wypożyczenie
Użytkownik skanuje kod QR, a system weryfikuje dostępność roweru i środki na koncie. Po pomyślnej pre-autoryzacji płatności, wysyłany jest sygnał otwarcia zamka do urządzenia IoT.

**Przepływ techniczny (Happy Path):**
1.  **Aplikacja Mobilna**: Wysyła żądanie `POST /rentals/start {bikeId}` do API Gateway.
2.  **Serwis Wypożyczeń**:
    *   Sprawdza status w Redis: `GET bike:{id}` (oczekiwany: `AVAILABLE`).
    *   Wysyła żądanie do Serwisu Płatności: `Pre-auth` (blokada środków).
3.  **Serwis Płatności**: Potwierdza blokadę (zwraca ID transakcji).
4.  **Serwis Wypożyczeń**: Wysyła komendę do Serwisu Floty: `Unlock Bike`.
5.  **Serwis Floty**: Publikuje komunikat MQTT: `cmd/unlock {bikeId}`.
6.  **Rower (IoT)**: Otwiera zamek i potwierdza: `status/locked = false`.
7.  **Serwis Wypożyczeń**:
    *   Zapisuje rekord w bazie PostgreSQL (`status: ACTIVE`).
    *   Publikuje zdarzenie na Kafce: `RentalStarted`.
    *   Zwraca `200 OK` do aplikacji mobilnej.

**Kluczowe aspekty realizacji:**
*   **Walidacja:** Serwis Wypożyczeń korzysta z Cache (Redis) do szybkiego sprawdzenia statusu roweru, unikając obciążania głównej bazy danych.
*   **Pre-autoryzacja:** Środki na koncie użytkownika są blokowane przed fizycznym otwarciem roweru, co zabezpiecza interesy operatora.
*   **Komunikacja z IoT:** Serwis Floty tłumaczy żądanie biznesowe na komendę MQTT, która jest natychmiastowo dostarczana do roweru przez brokera (Mosquitto).

### 16.1.2 Scenariusz alternatywny: Odmowa wypożyczenia (Brak środków)
Zgodnie z regułami biznesowymi, system blokuje wypożyczenie, jeśli saldo użytkownika jest niewystarczające (poniżej 20 zł) lub karta płatnicza została odrzucona. W tym przypadku proces zostaje przerwany na etapie walidacji w Serwisie Płatności. Żaden komunikat nie jest wysyłany do Serwisu Floty ani do urządzenia IoT.

### 16.1.3 Scenariusz alternatywny: Błąd otwarcia zamka (Kompensacja)
Scenariusz ten ilustruje działanie mechanizmu **Transakcji Kompensacyjnej** w ramach wzorca Saga. Sytuacja występuje, gdy środki zostały zablokowane, ale rower nie otworzył się z przyczyn technicznych (np. zacięcie mechaniczne, utrata zasięgu GSM). Serwis Wypożyczeń inicjuje procedurę wycofania (Rollback), wysyłając do Serwisu Płatności żądanie zwolnienia blokady środków.

## 16.2 Proces zakończenia przejazdu
Zakończenie przejazdu opiera się na architekturze sterowanej zdarzeniami (**Event-Driven**). Inicjatorem procesu jest fizyczne zamknięcie blokady roweru przez użytkownika, co jest traktowane jako fakt dokonany.

### 16.2.1 Scenariusz główny: Zwrot na stacji
Rower przesyła informację o zamknięciu blokady. System przetwarza to zdarzenie asynchronicznie, finalizując wypożyczenie i naliczając opłatę. Wykorzystanie Szyny Zdarzeń (Kafka) zapewnia wysoką dostępność – nawet przy chwilowej niedostępności Serwisu Płatności lub Analitycznego, zdarzenie zwrotu jest bezpiecznie zbuforowane i zostanie przetworzone po odzyskaniu sprawności usług.

**Przepływ techniczny:**
1.  **Rower (IoT)**: Wysyła telemetrię MQTT: `{locked: true, gps: ...}`.
2.  **Serwis Floty**:
    *   Odbiera strumień TCP z Brokera MQTT.
    *   Aktualizuje "Device Twin".
    *   Publikuje zdarzenie na Kafce: `BikeLocked {bikeId, geo, timestamp}`.
3.  **Serwis Wypożyczeń**:
    *   Konsumuje zdarzenie `BikeLocked`.
    *   Wyszukuje aktywne wypożyczenie dla `bikeId`.
    *   Oblicza koszt i zamyka rekord w bazie (`status: FINISHED`).
    *   Publikuje zdarzenie na Kafce: `RentalEnded {userId, amount}`.
4.  **Serwis Płatności**:
    *   Konsumuje zdarzenie `RentalEnded`.
    *   Obciąża kartę użytkownika (Stripe Capture).
    *   Publikuje `PaymentSuccessful`.

**Kluczowe aspekty realizacji:**
*   **Event-Driven:** Proces nie blokuje użytkownika przy rowerze. Powiadomienie przychodzi asynchronicznie.
*   **Idempotentność:** Serwis Wypożyczeń ignoruje duplikaty zdarzeń `BikeLocked` dla tego samego wypożyczenia.

### 16.2.2 Scenariusz alternatywny: Zwrot poza strefą (Naliczenie kary)
System automatycznie weryfikuje lokalizację zwrotu wykorzystując mechanizm **Geofencingu** zaimplementowany w Serwisie Floty (PostGIS). Jeśli współrzędne GPS wskazują na lokalizację poza wyznaczoną stacją lub strefą operacyjną, zdarzenie `BikeLocked` jest wzbogacane o typ lokalizacji (`OUTSIDE_STATION`). Serwis Wypożyczeń na tej podstawie dolicza do rachunku opłatę dodatkową (karę) zgodnie z cennikiem.

## 16.3 Geofencing i Telemetria
Proces ten odbywa się w tle, niezależnie od akcji użytkownika. Rower cyklicznie wysyła pakiety telemetryczne, które są przetwarzane dwutorowo ("Hot Path" i "Cold Path").

**Zastosowane mechanizmy:**
*   **Aktualizacja Cache ("Hot Path"):** Najnowsza lokalizacja trafia do Redis Cluster, co pozwala na natychmiastowe wyświetlenie roweru na mapie w aplikacji użytkownika.
*   **Archiwizacja ("Cold Path"):** Dane są równolegle zapisywane w bazie szeregów czasowych (InfluxDB) do celów analitycznych i historycznych.
*   **Detekcja naruszeń:** Serwis Floty weryfikuje położenie względem stref geofencingu. Wykrycie naruszenia (np. wyjazd poza miasto) skutkuje publikacją zdarzenia na szynie Kafka, co może uruchomić procesy windykacyjne lub powiadomienia dla operatora.
