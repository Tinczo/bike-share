# 7. Cele i ograniczenia architektoniczne

## 7.1 Cele architektoniczne
*   **Cel 1: Wysoka dostępność i niezawodność**
    *   System musi zapewniać dostępność na poziomie 99.9% (SLA).
    *   Implementacja mechanizmów failover dla infrastruktury serwerowej.
    *   Obsługa min. 10,000 jednoczesnych połączeń IoT i 1,000 aktywnych użytkowników mobilnych.
*   **Cel 2: Skalowalność horyzontalna**
    *   Możliwość dynamicznego zwiększania liczby rowerów, stacji i użytkowników bez modyfikacji logiki aplikacji.
    *   Architektura umożliwiająca rozproszenie obciążenia na wiele instancji serwerów (skalowanie przez konteneryzację).
    *   Wsparcie dla wzrostu wolumenu danych telemetrycznych.
*   **Cel 3: Bezpieczeństwo danych i zgodność z przepisami**
    *   Szyfrowanie danych użytkowników (AES-256) w spoczynku i w transmisji.
    *   Zgodność z RODO (GDPR) w zakresie retencji i anonimizacji danych, dyrektywą PSD2 (płatności) oraz ustawą o elektromobilności.
    *   Zabezpieczenie komunikacji IoT przed manipulacją (mTLS, certyfikaty urządzeń).
*   **Cel 4: Separacja domenowa (Domain-Driven Design)**
    *   Logiczne rozdzielenie czterech domen: Wypożyczenia i Rezerwacje, Monitoring Floty, Płatności i Rozliczenia, Analityka.
    *   Niezależność kontekstów ograniczonych (Bounded Contexts) dla każdej domeny biznesowej.
    *   Minimalizacja zależności międzydomenowych poprzez luźne sprzężenie (loose coupling).
*   **Cel 5: Wydajność w czasie rzeczywistym**
    *   Czas reakcji interfejsu mobilnego < 1s.
    *   Przetwarzanie danych telemetrycznych w czasie quasi-rzeczywistym (opóźnienie < 5s od odczytu czujnika do bazy).
    *   Generowanie alertów serwisowych w czasie < 30s od wykrycia incydentu.
*   **Cel 6: Integrowalność i interoperacyjność**
    *   Wsparcie eksportu danych w formatach CSV, JSON, PDF (otwarte API dla miasta).
    *   Kompatybilność aplikacji mobilnej z systemami Android 9+ i iOS 14+.

## 7.2 Ograniczenia architektoniczne
*   **Ograniczenie 1: Zależności sprzętowe**
    *   System musi obsługiwać różnorodne urządzenia IoT (moduły GPS, czujniki ciśnienia, zamki elektroniczne).
    *   Komunikacja IoT przez protokoły MQTT/CoAP wymaga brokera wiadomości działającego jako brama wejściowa.
    *   Konieczność izolacji logiki IoT (warstwa sprzętowa) od warstwy biznesowej systemu.
*   **Ograniczenie 2: Warunki operacyjne**
    *   System musi działać w warunkach niestabilnej łączności sieciowej urządzeń IoT (GSM/LTE).
    *   Wymagane buforowanie danych telemetrycznych lokalnie na urządzeniu w przypadku utraty połączenia.
    *   Brak łączności z flotą IoT nie może wpływać na dostępność aplikacji użytkownika (asynchroniczność).
*   **Ograniczenie 3: Przetwarzanie transakcji finansowych**
    *   Zapewnienie właściwości ACID dla operacji płatności i sald użytkowników.
    *   Integracja z zewnętrznymi bramkami płatniczymi (BLIK, karty płatnicze) z obsługą błędów zewnętrznych.
    *   Obsługa scenariuszy częściowej płatności i zadłużenia użytkowników.
*   **Ograniczenie 4: Retencja i archiwizacja danych**
    *   Dane transakcyjne, telemetryczne i analityczne przechowywane w gorącym dostępie przez 2 lata.
    *   Automatyczna anonimizacja danych po okresie retencji (zgodność z RODO).
    *   Logowanie audytowe bezpieczeństwa przechowywane przez minimum 12 miesięcy.
*   **Ograniczenie 5: Mechanizmy geofencing i geolokalizacji**
    *   Precyzja lokalizacji GPS z tolerancją błędu ±10 metrów.
    *   Wykrywanie naruszeń stref (parkowanie, strefy zakazu) w czasie rzeczywistym.

# 8. Decyzje i ich uzasadnienie

| Cel architektoniczny | Sposób osiągnięcia (Taktyki) | Uzasadnienie |
| :--- | :--- | :--- |
| **Wysoka dostępność i niezawodność** | • Architektura mikroserwisowa z replikacją usług<br>• Load balancing (Nginx/HAProxy/ALB)<br>• Mechanizm failover z automatycznym przełączaniem<br>• Health checks i heartbeat monitoring | Minimalizacja pojedynczego punktu awarii (SPOF). Mikroserwisy umożliwiają izolację awarii jednej domeny bez wpływu na całość. Replikacja zapewnia ciągłość działania. |
| **Skalowalność horyzontalna** | • Architektura bezstanowa (stateless) dla API REST<br>• Konteneryzacja (Docker, Kubernetes/Fargate)<br>• Autoskalowanie oparte na metrykach obciążenia (CPU/RAM)<br>• Partycjonowanie bazy danych (sharding) | Konteneryzacja umożliwia szybkie powielanie instancji pod obciążeniem. Bezstanowość pozwala na kierowanie ruchu do dowolnej instancji przez Load Balancer. |
| **Bezpieczeństwo danych** | • Szyfrowanie end-to-end (TLS 1.3)<br>• Tokenizacja kart płatniczych (standard PCI DSS)<br>• Uwierzytelnianie JWT z rotacją tokenów<br>• Rate limiting i throttling na API Gateway | Ochrona danych wrażliwych (finansowych, osobowych). JWT umożliwia bezstanową autentykację między serwisami. Rate limiting chroni przed atakami DDoS. |
| **Separacja domenowa (DDD)** | • Bounded Contexts dla każdej domeny<br>• Architektura sterowana zdarzeniami (Event-driven, Kafka/RabbitMQ)<br>• API Gateway jako punkt wejścia<br>• Osobne schematy baz danych per domena | Izolacja logiki biznesowej. Komunikacja asynchroniczna redukuje ścisłe powiązania (coupling). Ułatwia to niezależny rozwój i wdrażanie modułów przez różne zespoły. |
| **Wydajność w czasie rzeczywistym** | • Cache rozproszony (Redis Cluster)<br>• Indeksowanie przestrzenne (PostGIS)<br>• Stream processing (Apache Kafka Streams)<br>• WebSocket dla aktualizacji "na żywo" w aplikacji | Cache odciąża bazę danych przy częstych odczytach (np. lista stacji). PostGIS drastycznie przyspiesza obliczenia geolokalizacyjne. Kafka Streams pozwala przetwarzać tysiące sygnałów z IoT w locie. |
| **Izolacja zależności sprzętowych** | • Warstwa abstrakcji IoT (IoT Gateway / MQTT Broker)<br>• Wzorzec Device Twin (Cyfrowy Bliźniak)<br>• Wzorzec Circuit Breaker dla komunikacji z IoT | Centralizacja zarządzania urządzeniami. Device Twin przechowuje ostatni znany stan urządzenia, co pozwala aplikacji działać nawet gdy rower straci zasięg. |
| **Obsługa niestabilnej łączności IoT** | • Lokalne buforowanie na kontrolerze roweru<br>• Polityka ponownych prób (Retry with exponential backoff)<br>• Wzorzec Store-and-forward | Zapewnienie dostarczania danych telemetrycznych po odzyskaniu zasięgu GSM bez utraty historii przejazdu. |
| **Spójność transakcji finansowych** | • Wzorzec Saga dla transakcji rozproszonych<br>• Idempotentność operacji płatności<br>• Transakcje kompensacyjne (rollback logiczny) | Saga zapewnia spójność danych między serwisem wypożyczeń a płatności. Idempotentność zapobiega podwójnemu obciążeniu karty przy błędach sieci. |
| **Archiwizacja i retencja** | • Baza Time-series dla telemetrii (np. InfluxDB)<br>• Polityki cyklu życia danych (Data lifecycle policies)<br>• ETL do hurtowni danych (Cold Storage) | Specjalizowana baza time-series jest wydajniejsza dla zapisu ciągłego z czujników. Automatyczna archiwizacja obniża koszty przechowywania danych historycznych. |

# 9. Mechanizmy architektoniczne

## 9.1 Mechanizm zarządzania urządzeniami IoT
**Cel:** Scentralizowane zarządzanie flotą rowerów i stacji, zbieranie telemetrii oraz wykonywanie poleceń zdalnych (unlock/lock).
*   **Atrybuty:** Protokół MQTT over TLS, Broker (Mosquitto/AWS IoT), format danych JSON/Protobuf, telemetria co 1 min (ruch).
*   **Funkcja:** Rejestracja urządzeń (Device Registry), utrzymanie wirtualnego stanu (Device Twin), kolejkowanie poleceń sterujących, odbiór danych z czujników i ich buforowanie w przypadku braku sieci (Offline Support).

## 9.2 Mechanizm autoryzacji i uwierzytelniania
**Cel:** Bezpieczny dostęp użytkowników i operatorów do systemu.
*   **Atrybuty:** OAuth 2.0 + OpenID Connect, Tokeny JWT (stateless), Refresh tokens.
*   **Funkcja:** Centralny Identity Provider (IdP). Walidacja tożsamości przy każdym żądaniu w API Gateway. Obsługa sesji mobilnych i webowych. Audyt logowań.

## 9.3 Mechanizm przetwarzania płatności
**Cel:** Bezpieczna i spójna obsługa transakcji finansowych.
*   **Atrybuty:** Integracja z bramkami (Przelewy24/Stripe), zgodność z PCI DSS, idempotentność transakcji.
*   **Funkcja:** Inicjalizacja płatności, pre-autoryzacja środków (blokada na karcie), obciążenie (capture) po zakończeniu jazdy, obsługa zwrotów (refund) i asynchronicznych powiadomień (webhooks) z bramek.

## 9.4 Mechanizm geofencing i detekcji lokalizacji
**Cel:** Monitorowanie stref operacyjnych i naliczanie opłat strefowych.
*   **Atrybuty:** Baza PostGIS, typy geometryczne, algorytmy Point-in-polygon.
*   **Funkcja:** Walidacja współrzędnych GPS względem zdefiniowanych wielokątów stref w czasie rzeczywistym. Generowanie zdarzeń wejścia/wyjścia ze strefy (do naliczania kar lub bonusów).

## 9.5 Mechanizm analityki i raportowania
**Cel:** Przetwarzanie danych historycznych dla celów biznesowych i miejskich.
*   **Atrybuty:** Procesy ETL (Extract-Transform-Load), Hurtownia danych, raporty PDF/CSV.
*   **Funkcja:** Nocna agregacja danych z baz operacyjnych. Anonimizacja danych wrażliwych. Obliczanie metryk KPI (średni czas wypożyczenia, mapy ciepła wykorzystania rowerów).

## 9.6 Mechanizm komunikacji asynchronicznej (Event-Driven)
**Cel:** Zapewnienie luźnego powiązania między domenami systemu.
*   **Atrybuty:** Message Broker (Apache Kafka / RabbitMQ), topiki zdarzeń (np. `rentals.finished`).
*   **Funkcja:** Publikowanie zdarzeń biznesowych ("Wypożyczenie zakończone") przez jedną domenę, na które reagują inne (Płatności → nalicz, Analityka → zapisz). Obsługa błędów (Dead Letter Queue).

## 9.7 Mechanizm cachowania
**Cel:** Odciążenie baz danych i przyspieszenie odczytów.
*   **Atrybuty:** Redis, TTL (czas życia danych) zależny od typu danych (np. GPS: 30s, Cennik: 1h).
*   **Funkcja:** Strategia Cache-aside. Przechowywanie danych często odczytywanych (lokalizacje rowerów na mapie, profil użytkownika) w pamięci operacyjnej.

## 9.8 Mechanizm obsługi Saga (Transakcje rozproszone)
**Cel:** Spójność procesów biznesowych rozpiętych między mikroserwisami.
*   **Atrybuty:** Saga oparta na orkiestracji lub choreografii.
*   **Funkcja:** Koordynacja ciągu operacji (Zablokuj rower → Obciąż kartę → Rozpocznij licznik). W razie błędu na dowolnym etapie, uruchamianie transakcji kompensacyjnych (np. Odblokuj rower, Zwolnij blokadę środków).
