# 10. Widok Kontekstowy

## 10.1 Opis diagramu kontekstowego
Diagram kontekstowy przedstawia granice systemu oraz jego interakcje z aktorami i systemami zewnętrznymi. Centralnym elementem jest System Zarządzania Infrastrukturą Rowerową, który pośredniczy w komunikacji między użytkownikami a fizyczną infrastrukturą.

*   **Aktorzy:**
    *   **Użytkownik Mobilny:** Wchodzi w interakcję z systemem w celu wypożyczenia roweru i dokonania płatności.
    *   **Operator Systemu:** Pracownik techniczny lub administrator zarządzający flotą i zgłoszeniami poprzez panel WWW.
*   **Systemy Zewnętrzne:**
    *   **Rower / Stacja (IoT):** Fizyczne urządzenia komunikujące się z systemem za pomocą protokołu MQTT (telemetria, komendy sterujące).
    *   **System Płatności:** Zewnętrzny dostawca usług finansowych (np. Stripe, BLIK) odpowiedzialny za procesowanie transakcji.

## 10.2 Scenariusze interakcji

### 10.2.1 Scenariusz 1: Aktualizacja telemetrii roweru
Urządzenia IoT (rowery i stacje dokujące) transmitują dane telemetryczne do systemu backendowego w regularnych 30-sekundowych odstępach czasowych. Proces obejmuje zebranie danych z czujników (lokalizacja GPS, poziom baterii, ciśnienie w oponach, status zamka), ich transmisję poprzez protokół MQTT do brokera wiadomości oraz przetworzenie przez backend. System aktualizuje stan roweru w bazie danych, a moduł analityczny weryfikuje dane pod kątem anomalii. W przypadku wykrycia nieprawidłowości (niski poziom baterii, naruszenie strefy geofencing, niska wartość ciśnienia) generowany jest alert serwisowy kierowany do operatorów systemu.

### 10.2.2 Scenariusz 2: Wypożyczenie roweru przez użytkownika
Użytkownik inicjuje wypożyczenie poprzez zeskanowanie kodu QR umieszczonego na rowerze za pomocą aplikacji mobilnej. Aplikacja wysyła żądanie HTTP do API backendu, który weryfikuje stan konta użytkownika oraz dostępność roweru. Po pozytywnej weryfikacji system publikuje komendę odblokowania zamka elektronicznego poprzez protokół MQTT. Rower wykonuje operację i potwierdza jej wykonanie, po czym backend tworzy rekord wypożyczenia i zwraca potwierdzenie do aplikacji mobilnej. Całość procesu realizowana jest synchronicznie z perspektywy użytkownika przy wykorzystaniu asynchronicznej komunikacji z urządzeniem IoT.

### 10.2.3 Scenariusz 3: Rozliczenie wypożyczenia i płatność
Po zaparkowaniu roweru użytkownik potwierdza zakończenie wypożyczenia w aplikacji, co inicjuje sekwencję operacji: zablokowanie zamka elektronicznego, obliczenie kosztu na podstawie czasu trwania, publikację zdarzenia domenowego na magistralę oraz inicjację transakcji płatniczej. Domena Płatności odbiera zdarzenie i komunikuje się z zewnętrznym systemem płatności (Stripe) za pomocą REST API. Po pomyślnym przetworzeniu transakcji system aktualizuje saldo konta użytkownika, generuje fakturę oraz wysyła potwierdzenie do aplikacji mobilnej. Przepływ realizowany jest w modelu event-driven z wykorzystaniem choreografii pomiędzy domenami.

## 10.3 Interfejsy integracyjne – poziom logiczny

### 10.3.1 Interfejs 1: Urządzenia IoT → Backend (Telemetria)
*   **Opis:** Transmisja danych telemetrycznych z urządzeń IoT (rowery, stacje dokujące) do systemu backendowego w regularnych odstępach czasowych. Dane obejmują lokalizację GPS, poziom baterii, status zamka, ciśnienie w oponach oraz status stacji.
*   **Technika integracji:** MQTT over TLS (Message Broker: Eclipse Mosquitto)
*   **Kontrakt danych:** `{id_roweru: String, timestamp: ISO8601, lokalizacja: {dlugosc: Float, szerokosc: Float}, poziom_baterii: Integer, status_blokady: Enum, cisnienie_przednia_opona: Float, cisnienie_tylna_opona: Float, predkosc: Float}`

### 10.3.2 Interfejs 2: Backend → Urządzenia IoT (Komendy sterujące)
*   **Opis:** Transmisja komend sterujących z systemu backendowego do urządzeń IoT w celu zablokowania/odblokowania zamka elektronicznego oraz aktualizacji konfiguracji urządzenia.
*   **Technika integracji:** MQTT over TLS (Message Broker: Eclipse Mosquitto)
*   **Kontrakt danych:** `{id_roweru: String, komenda: Enum["LOCK", "UNLOCK", "UPDATE_CONFIG"], timestamp: ISO8601}`

### 10.3.3 Interfejs 3: Backend → System Płatności (Stripe)
*   **Opis:** Zewnętrzna usługa obsługi płatności elektronicznych. System kieruje transakcje użytkowników do bramki płatniczej w celu autoryzacji kart płatniczych, przelewów oraz zwrotów środków.
*   **Technika integracji:** REST API over HTTPS
*   **Kontrakt danych:**
    *   POST `/v1/payment_intents`: `{amount: Integer, currency: String, customer_id: String, payment_method: String}`
    *   POST `/v1/refunds`: `{payment_intent_id: String, amount: Integer}`

# 11. Widok Funkcjonalny (Kontenerowy)

## 11.1 Opis architektury systemu
Przedstawiony diagram obrazuje architekturę systemu w ujęciu kontenerowym, prezentując podział na warstwę prezentacji, logikę biznesową (backend) oraz warstwę danych. System został zaprojektowany w architekturze mikroserwisowej, aby spełnić wymagania skalowalności, wysokiej dostępności oraz separacji domenowej.

**Kluczowe decyzje architektoniczne:**
*   **Punkt wejścia i bezpieczeństwo:** Jedynym punktem wejścia dla aplikacji klienckich (Aplikacja Mobilna i Panel Operatora – oba oparte o technologię Flutter) jest **API Gateway** (zrealizowany na Spring Cloud Gateway). Pełni on rolę fasady bezpieczeństwa, odpowiadając za autoryzację użytkowników (weryfikacja tokenów JWT) oraz ochronę przed przeciążeniem (Rate Limiting).
*   **Wewnętrzny Load Balancing:** Zgodnie z przyjętą strategią wysokiej dostępności, za bramą API umieszczono dedykowany **Wewnętrzny Load Balancer** (Nginx/HAProxy). Jego zadaniem jest równoważenie obciążenia i dystrybucja zweryfikowanego ruchu HTTP do odpowiednich instancji mikroserwisów.
*   **Separacja ścieżki IoT:** Ruch telemetryczny z urządzeń (rowerów i stacji) został całkowicie odseparowany od standardowego ruchu HTTP. Komunikacja odbywa się poprzez protokół MQTT z wykorzystaniem **Brokera MQTT** (Mosquitto), co pozwala na obsługę tysięcy stałych połączeń i strumieniowe przekazywanie danych do Serwisu Floty.
*   **Komunikacja asynchroniczna:** W celu zapewnienia luźnych powiązań między domenami, system wykorzystuje **Szynę Zdarzeń** (Apache Kafka). Zastosowano wzorzec Pub/Sub:
    *   **Publikacja (Pub):** Serwis Wypożyczeń i Serwis Floty publikują zdarzenia biznesowe (np. „Rozpoczęto wypożyczenie”, „Rower poza strefą”).
    *   **Subskrypcja (Sub):** Serwis Płatności oraz Serwis Analityczny nasłuchują zdarzeń, realizując operacje w tle bez blokowania głównego wątku aplikacji.
*   **Poliglotyzm w warstwie danych:** Dobór technologii przechowywania danych został dostosowany do specyfiki każdej domeny:
    *   **PostgreSQL:** Baza operacyjna dla danych transakcyjnych (Płatności, Wypożyczenia) oraz danych GIS (Flota).
    *   **InfluxDB:** Baza szeregów czasowych dedykowana do wydajnego zapisu i odczytu historii logów GPS.
    *   **Redis Cluster:** Rozproszona pamięć podręczna (Cache) wykorzystywana do szybkiego dostępu do cenników oraz bieżącego stanu floty.

# 12. Architektura Domenowa (Szczegółowy Widok Kontenerów)

## 12.1 Domena Wypożyczeń
Serwis Wypożyczeń (*Rental Service*) stanowi serce logiki biznesowej dla użytkownika końcowego.
*   **Odpowiedzialność:** Zarządzanie cyklem życia wypożyczenia, rezerwacjami oraz taryfikacją.
*   **Integracja:** Komunikuje się asynchronicznie z Szyną Zdarzeń (Kafka) w celu potwierdzenia płatności oraz publikuje zdarzenia o rozpoczęciu wynajmu.
*   **Dane:** Wykorzystuje Redis do szybkiego odczytu cenników, co minimalizuje opóźnienia przy kalkulacji kosztów, oraz PostgreSQL do trwałego zapisu historii operacji.

## 12.2 Domena Płatności
Moduł odpowiedzialny za bezpieczeństwo i spójność transakcji finansowych.
*   **Odpowiedzialność:** Zarządzanie wirtualnym portfelem użytkownika oraz integracja z zewnętrzną Bramką Płatności (Stripe/BLIK).
*   **Model komunikacji:** Nasłuchuje na zdarzenia „Nalicz opłatę” poprzez kanał TCP (Kafka) i w odpowiedzi publikuje status transakcji (udana/nieudana).
*   **Dane:** Gwarantuje spójność danych finansowych poprzez transakcje ACID w bazie PostgreSQL.

## 12.3 Domena Monitoringu Floty
Najbardziej obciążony element systemu, obsługujący strumienie danych w czasie rzeczywistym.
*   **Broker MQTT:** Działa jako brama dla urządzeń IoT, obsługując tysiące równoległych połączeń.
*   **Serwis Floty:** Przetwarza strumień TCP z brokera, realizując logikę Geofencingu (wykrywanie stref) i walidację statusów technicznych.
*   **Dualizm danych:** Dane przestrzenne (strefy) przechowywane są w bazie z rozszerzeniem PostGIS, natomiast surowe logi telemetryczne trafiają do bazy InfluxDB (Time Series).

## 12.4 Domena Analityki
Moduł realizowany w odrębnym stosie technologicznym (Python/FastAPI) dedykowany przetwarzaniu danych.
*   **Event Sourcing:** Serwis Analityczny subskrybuje wszystkie zdarzenia domenowe z Kafki, budując na ich podstawie zagregowane widoki dla raportów.
*   **ETL i Raportowanie:** Generuje pliki PDF/CSV oraz heatmapy wykorzystania floty.
*   **Hurtownia Danych:** Wykorzystuje PostgreSQL (lub opcjonalnie ClickHouse) do przechowywania dużych wolumenów danych historycznych zoptymalizowanych pod kątem zapytań analitycznych.
