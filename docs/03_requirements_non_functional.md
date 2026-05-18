# 4. Wymagania niefunkcjonalne

## 4.1 Bezpieczeństwo danych
System musi szyfrować wszystkie dane użytkowników (w tym dane płatnicze) zgodnie z normą AES-256. Dostęp do konta chroniony jest przez uwierzytelnianie dwuetapowe.

## 4.2 Wydajność systemu
System powinien obsługiwać jednoczesne połączenia z minimum 10 000 urządzeń IoT i 1 000 aktywnych użytkowników aplikacji mobilnej.

## 4.3 Niezawodność i dostępność systemu
W przypadku awarii infrastruktury serwerowej system musi automatycznie przełączyć się na środowisko zapasowe (mechanizm failover). Brak łączności z urządzeniami IoT nie może wpływać na dostępność aplikacji użytkownika.

## 4.4 Skalowalność
Architektura systemu musi umożliwiać płynne zwiększanie liczby obsługiwanych rowerów, stacji dokujących, użytkowników oraz urządzeń IoT bez konieczności modyfikacji logiki aplikacji. System powinien umożliwiać łatwe rozszerzanie infrastruktury o nowe stacje oraz integrację z dodatkowymi serwerami i komponentami analitycznymi w celu obsługi rosnącego wolumenu danych telemetrycznych.

## 4.5 Użyteczność (UX/UI)
Aplikacja mobilna i panel administracyjny powinny być intuicyjne, czytelne i responsywne, z czasem reakcji interfejsu nieprzekraczającym 1 sekundy na standardowych urządzeniach mobilnych. Interfejs użytkownika musi być zgodny z wytycznymi WCAG 2.1 (poziom AA) w zakresie dostępności cyfrowej.

## 4.6 Niezawodność danych i spójność transakcji
System powinien zapewniać atomowość, spójność, izolację i trwałość (ACID) operacji finansowych oraz transakcji wypożyczeń. W przypadku utraty połączenia z siecią IoT dane telemetryczne muszą być buforowane lokalnie i przesyłane po przywróceniu łączności.

## 4.7 Odporność i bezpieczeństwo operacyjne
System musi automatycznie wykrywać i raportować:
*   próby nieautoryzowanego dostępu,
*   manipulacje w danych telemetrycznych,
*   próby fizycznego sabotażu urządzeń IoT.

Logi bezpieczeństwa muszą być przechowywane przez minimum 12 miesięcy i zabezpieczone przed modyfikacją.

## 4.8 Przenośność i interoperacyjność
System powinien umożliwiać integrację z zewnętrznymi systemami miejskimi (np. kartą miejską) poprzez API REST. Aplikacja mobilna musi działać na platformach Android (min. wersja 9) i iOS (min. wersja 14).

## 4.9 Utrzymanie i monitorowanie
System powinien udostępniać panel monitoringu umożliwiający śledzenie:
*   statusu urządzeń IoT,
*   stanu serwerów i usług,
*   historii alertów, błędów i zgłoszeń serwisowych.

Administratorzy muszą mieć możliwość ręcznej dezaktywacji urządzenia lub użytkownika w przypadku nadużyć.

## 4.10 Archiwizacja i retencja danych
Dane transakcyjne, telemetryczne i analityczne powinny być przechowywane przez okres 2 lat, a następnie automatycznie archiwizowane lub anonimizowane. System musi umożliwiać eksport danych historycznych w formacie CSV lub JSON.

## 4.11 Zgodność prawna (compliance)
System musi być zgodny z obowiązującymi przepisami prawa, w szczególności:
*   RODO (GDPR) – w zakresie przetwarzania danych osobowych,
*   Dyrektywą PSD2 – w zakresie obsługi płatności elektronicznych,
*   Ustawą o elektromobilności i transporcie publicznym – dla wdrożeń miejskich.
