# 13. Widok rozmieszczenia

## 13.1 Specyfikacja węzłów infrastruktury (AWS)
Całość backendu została osadzona w regionie eu-central-1 (Frankfurt) w ramach sieci VPC (10.0.0.0/16), podzielonej na dedykowane podsieci:

### 13.1.1 Warstwa Publiczna (Public Subnet)
Jest to strefa DMZ (Demilitarized Zone), stanowiąca jedyny punkt styku z internetem.
*   **AWS ALB (Application Load Balancer):** Odpowiada za terminację ruchu szyfrowanego (HTTPS/MQTTS) i automatyczne skalowanie przepustowości. Dystrybuuje ruch do warstwy aplikacji.

### 13.1.2 Warstwa Aplikacyjna (Private Application Subnet)
Wydzielona podsieć prywatna hostująca klaster **AWS ECS Fargate**. Uruchomione tutaj kontenery realizują logikę biznesową i komunikację asynchroniczną. Zasoby obliczeniowe (vCPU/RAM) zostały dobrane zadaniowo:
*   **Serwis Floty [4 vCPU, 8 GB RAM]:** Komponent o najwyższym priorytecie wydajnościowym. Zwiększone zasoby są niezbędne do ciągłego przetwarzania strumienia danych telemetrycznych z 10 000 urządzeń IoT oraz obliczeń geofencingu w czasie rzeczywistym.
*   **Klaster Kafka [4 vCPU, 16 GB RAM]:** Broker wiadomości wyposażony w dużą ilość pamięci operacyjnej, co pozwala na efektywne buforowanie zdarzeń i zapewnia niezawodność komunikacji asynchronicznej.
*   **Serwis Analityczny [2 vCPU, 8 GB RAM]:** Zoptymalizowany pod kątem operacji w pamięci, wymaganych przy procesach ETL (Extract-Transform-Load) i generowaniu raportów.
*   **Broker MQTT (Mosquitto):** Dedykowany węzeł kolejkowy do obsługi stałych połączeń TCP z rowerami.
*   **Pozostałe komponenty:** API Gateway, Wewnętrzny Load Balancer oraz serwisy transakcyjne (Wypożyczeń, Płatności) działają na standardowych instancjach [2 vCPU, 4 GB RAM], skalując się horyzontalnie.

### 13.1.3 Warstwa Danych (Private Data Subnet)
Najbardziej restrykcyjna strefa sieciowa. Zgodnie z paradygmatem mikroserwisowym wdrożono wzorzec **Database per Service**, co zapewnia pełną izolację danych między domenami.
*   **Bazy Transakcyjne i Domenowe (AWS RDS PostgreSQL):** Dla domen Wypożyczeń, Płatności oraz Floty zastosowano dedykowane instancje bazodanowe klasy `db.m5.large` z dyskami SSD (gp3) o pojemności 100 GB. Baza Floty wykorzystuje dodatkowo rozszerzenie **PostGIS** do obsługi danych przestrzennych.
*   **Hurtownia Danych (Analityka):** Dla domeny analitycznej wydzielono instancję `db.m5.large` ze zwiększoną przestrzenią dyskową **500 GB SSD**, przystosowaną do składowania dużych wolumenów danych historycznych i agregatów.
*   **Baza Telemetryczna (InfluxDB):** Uruchomiona na dedykowanej instancji EC2 (typ *Storage Optimized*) z szybkim dyskiem EBS, dedykowana do wysokowydajnego zapisu logów GPS (Write-Heavy).
*   **Cache Rozproszony (AWS ElastiCache Redis):** Współdzielony klaster pamięci podręcznej na instancjach `cache.t3.medium`, zapewniający milisekundowe czasy dostępu do danych ulotnych (cenniki, sesje, bieżący stan mapy).

## 13.2 Urządzenia Klienckie i IoT
System obsługuje różnorodne urządzenia końcowe, wykorzystując dedykowane protokoły komunikacyjne:
*   **Urządzenia IoT (Rowery):** Wyposażone w mikrokontrolery ESP32/STM32 z modułem GSM. Komunikują się z chmurą za pomocą lekkiego protokołu **MQTT**, co minimalizuje zużycie energii i danych.
*   **Aplikacje Klienckie:**
    *   **Smartfon Użytkownika:** Natywna aplikacja Flutter komunikująca się po **HTTPS**.
    *   **Panel Operatora:** Aplikacja webowa (SPA) hostowana statycznie w usłudze **AWS S3**, pobierana przez przeglądarkę pracownika.

## 13.3 Protokoły komunikacyjne
*   **Niebieski (HTTPS):** Bezpieczna komunikacja zewnętrzna z klientami oraz bramką płatności.
*   **Zielony (HTTP):** Wewnętrzna komunikacja REST między serwisami a Load Balancerem oraz dostęp do InfluxDB.
*   **Pomarańczowy (TCP):** Niskopoziomowa komunikacja z brokerami wiadomości (Kafka) oraz pamięcią podręczną (Redis).
*   **Czerwony (JDBC):** Połączenia serwisów z ich dedykowanymi relacyjnymi bazami danych.
*   **Różowy (Stream):** Strumieniowe przesyłanie danych telemetrycznych z brokera MQTT do serwisu floty.
