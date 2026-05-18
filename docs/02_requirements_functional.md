# 3. Definicja wymagań funkcjonalnych

## 3.1 Rejestracja i logowanie użytkownika
**Historyjka:** Jako nowy użytkownik, chcę móc założyć konto, aby uzyskać łatwiejszy dostęp do wypożyczania rowerów.
**Kryteria akceptacji:**
*   System wymaga podania adresu e-mail i hasła.
*   Użytkownik musi potwierdzić adres e-mail, aby aktywować konto.
*   System pozwala na logowanie za pomocą e-maila i hasła.

## 3.2 Przeglądanie dostępności rowerów
**Historyjka:** Jako zalogowany użytkownik, chcę widzieć na mapie lokalizacje dostępnych rowerów i stacji, aby znaleźć najbliższy wolny rower lub stację dokującą.
**Kryteria akceptacji:**
*   Aplikacja wyświetla mapę z moją aktualną lokalizacją.
*   Na mapie widoczne są ikony dostępnych rowerów oraz stacji pokazujące liczbę rowerów i miejsc.

## 3.3 Rezerwacja roweru
**Historyjka:** Jako użytkownik, chcę móc zarezerwować wybrany rower na krótki czas, aby nikt inny go nie wypożyczył, zanim do niego dotrę.
**Kryteria akceptacji:**
*   Użytkownik, który jest dłużnikiem nie może zarezerwować rower.
*   Użytkownik może wypożyczyć rower wtedy, gdy jego konto jest zasilone kredytem conajmniej 20 złotych lub ma podpiętą kartę lub wykupiony abonament.
*   Mogę wybrać rower na mapie i kliknąć "Rezerwuj".
*   Rezerwacja blokuje rower na 15 minut.
*   W aplikacji wyświetla się licznik czasu pozostałego do wygaśnięcia rezerwacji.
*   Jeśli rezerwacja wygaśnie, rower automatycznie staje się dostępny dla innych.
*   Użytkownik może mieć tylko jedną aktywną rezerwację w danym momencie.

## 3.4 Rozpoczynanie przejazdu
**Historyjka:** Jako użytkownik, chcę szybko wypożyczyć dostępny rower, aby rozpocząć przejazd.
**Kryteria akceptacji:**
*   Użytkownik, który jest dłużnikiem nie może zarezerwować rower.
*   Użytkownik może wypożyczyć rower wtedy, gdy jego konto jest zasilone kredytem conajmniej 20 złotych lub ma podpiętą kartę lub wykupiony abonament.
*   Aplikacja umożliwia zeskanowanie kodu QR umieszczonego na rowerze.
*   Po poprawnym zeskanowaniu, zamek elektroniczny na rowerze odblokowuje się automatycznie.
*   Aplikacja potwierdza rozpoczęcie wypożyczenia i zaczyna naliczać czas.
*   Jeśli rower jest oznaczony jako "potencjalnie uszkodzony" aplikacja informuje o tym użytkownika, przed rozpoczęciem jazdy.

## 3.5 Postój w trakcie przejazdu
**Historyjka:** Jako użytkownik w trakcie aktywnego przejazdu, chcę mieć możliwość zrobienia postoju i tymczasowego zamknięcia zamka, aby zabezpieczyć rower (np. gdy idę do sklepu), zachowując go dla siebie do dalszej jazdy.
**Kryteria akceptacji:**
*   Użytkownik w trakcie przejazdu może ręcznie zamknąć blokadę roweru w dowolnym miejscu.
*   System rozpoznaje blokade i pyta się użytkowika, czy chce zwrócić rower poza stacją, czy chce zrobić postój.
*   Rower w systemie pozostaje w statusie „zapauzowany” i jest przypisany do tego samego użytkownika (nie jest widoczny na mapie dla innych).
*   Czas wypożyczenia oraz naliczanie opłat są kontynuowane normalnie przez cały czas trwania postoju.
*   Aplikacja użytkownika wyświetla status "Na postoju" i pokazuje przycisk "Odblokuj".

## 3.6 Zakończenie przejazdu
**Historyjka:** Jako użytkownik, chcę móc łatwo zwrócić rower na stacji, aby poprawnie zakończyć wypożyczenie i naliczanie opłat.
**Kryteria akceptacji:**
*   Po zamknięciu blokady w obrębie stacji, system automatycznie rozpoznaje zwrot.
*   Użytkownik otrzymuje powiadomienie w aplikacji o poprawnym zakończeniu przejazdu.
*   System nalicza karę finansową, jeśli rower zostanie zwrócony poza wyznaczoną strefą miejską lub stacją.
*   Jeśli nie udało się pobrać wystarczającej kwoty z salda użytkownika lub/i z podpiętej karty użytkownik zostaje oznaczony jako „dłużnik”.

## 3.7 Zgłaszanie usterek
**Historyjka:** Jako użytkownik, chcę móc zgłosić problem techniczny z rowerem (np. brak powietrza, uszkodzony zamek), aby serwis mógł go naprawić.
**Kryteria akceptacji:**
*   W aplikacji, przy szczegółach roweru, dostępna jest opcja „Zgłoś usterkę”.
*   Mogę wybrać typ usterki z predefiniowanej listy i dodać krótki opis.
*   Rower ze zgłoszoną usterką jest oznaczany na mapie jako „potencjalnie uszkodzony”.
*   Jeśli pracownik potwierdzi uszkodzenie roweru, użytkownik, który zgłosił usterkę zostaje nagrodzony kwotą w wysokości 0.50 zł.

## 3.8 Podgląd floty w czasie rzeczywistym
**Historyjka:** Jako operator systemu, chcę mieć na żywo podgląd lokalizacji i stanu wszystkich rowerów, aby móc planować działania serwisowe i relokacje.
**Kryteria akceptacji:**
*   Dashboard operatora wyświetla mapę ze wszystkimi rowerami.
*   Każdy rower przesyła swoje dane GPS w regularnych interwałach (np. co 1 minutę w ruchu, co 10 minut w spoczynku).
*   Mogę kliknąć na rower, aby zobaczyć jego status (dostępny, wypożyczony, serwis) oraz dane techniczne (poziom naładowania baterii, ciśnienie w oponach).
*   System wyświetla status stacji dokujących (liczba wolnych miejsc, liczba rowerów, awarie, w tym liczbę rowerów potencjalnie uszkodzonych).

## 3.9 Alerty serwisowe i Geofencing
**Historyjka:** Jako operator systemu, chcę otrzymywać automatyczne alerty o nietypowych zdarzeniach, aby szybko reagować na problemy i zapobiegać kradzieżom.
**Kryteria akceptacji:**
*   System generuje alert, gdy rower opuści wyznaczoną strefę miejską (Geofencing).
*   System generuje alert, gdy rower nie wysyła danych telemetrycznych przez określony czas (np. 10 minut).
*   System generuje alert, gdy bateria roweru spadnie poniżej krytycznego poziomu (np. 10%).
*   Alerty pojawiają się w panelu operatora.

## 3.10 Zarządzanie metodami płatności
**Historyjka:** Jako użytkownik, chcę móc podpiąć różne metody płatności lub zasilić saldo konta, aby móc płacić za przejazdy.
**Kryteria akceptacji:**
*   System umożliwia podpięcie karty płatniczej.
*   System umożliwia zasilenie wewnętrznego salda (portfela) w aplikacji za pomocą BLIKa lub przelewu.
*   Opłaty za przejazdy są pobierane automatycznie z salda lub, gdy jest puste, z podpiętej karty.

## 3.11 Uregulowanie długu
**Historyjka:** Jako użytkownik, chcę móc uregulować mój dług, aby status dłużnika nie blokował mojej możliwości rezerwacji i/lub wypożyczenia roweru.
**Kryteria akceptacji:**
*   System umożliwia ureulowanie długu poprzez doładowanie ujemnego salda konta.
*   System umożliwia zasilenie wewnętrznego salda (portfela) w aplikacji za pomocą BLIKa lub przelewu.
*   Opłaty za przejazdy są pobierane automatycznie z salda lub, gdy jest puste, z podpiętej karty.

## 3.12 Naliczenie opłat i abonamenty
**Historyjka:** Jako system, chcę automatycznie naliczać opłaty za przejazdy zgodnie z cennikiem, aby rozliczyć użytkownika.
**Kryteria akceptacji:**
*   Opłaty są naliczane minutowo po rozpoczęciu wypożyczenia (taryfa "pay-per-ride").
*   System obsługuje abonamenty (24-godzinny, tygodniowy oraz miesięczny).
*   Abonament miesięczny obejmuje określoną liczbę darmowych minut dziennie (np. 60), a każda minuta powyżej limitu jest płatna standardowo.
*   Użytkownik może zarządzać swoimi abonamentami (kupić, anulować) w aplikacji.

## 3.13 Dostęp do faktur
**Historyjka:** Jako użytkownik, chcę otrzymać fakturę elektroniczną za moje przejazdy, aby móc je rozliczyć.
**Kryteria akceptacji:**
*   System automatycznie generuje fakturę (np. miesięczną) lub na żądanie za pojedynczy przejazd.
*   Użytkownik może pobrać fakturę w formacie PDF z poziomu aplikacji lub strony WWW.

## 3.14 Historia transakcji i saldo
**Historyjka:** Jako użytkownik, chcę móc przeglądać historię transakcji oraz aktualne saldo konta, aby mieć kontrolę nad moimi wydatkami.
**Kryteria akceptacji:**
*   System wyświetla listę wszystkich transakcji (np. opłaty za przejazdy, doładowania, zwroty, abonamenty).
*   Każda transakcja zawiera datę, typ operacji, kwotę oraz status.
*   Użytkownik może sprawdzić aktualne saldo wewnętrznego portfela.

## 3.15 Generowanie raportów i statystyk
**Historyjka:** Jako analityk miejski, chcę mieć dostęp do zagregowanych danych i raportów, aby analizować trendy i popularność systemu.
**Kryteria akceptacji:**
*   System udostępnia dashboard analityczny.
*   Mogę generować raporty tygodniowe i miesięczne.
*   Raporty zawierają dane o liczbie wypożyczeń, średnim czasie przejazdu, popularności stacji.
*   Raporty można eksportować do formatu PDF lub CSV.
*   Dane analityczne są przechowywane przez określony czas (np. 2 lata).

## 3.16 Wizualizacja danych (Heatmapy)
**Historyjka:** Jako analityk miejski, chcę widzieć heatmapy (mapy cieplne) popularności tras i stacji, aby optymalizować rozmieszczenie infrastruktury rowerowej.
**Kryteria akceptacji:**
*   Dashboard analityczny zawiera interaktywną mapę.
*   Mogę włączyć warstwę heatmapy pokazującą intensywność wypożyczeń w danych strefach.
*   Mogę filtrować heatmapę według pory dnia i dnia tygodnia, aby zidentyfikować wzorce (np. dojazdy do pracy vs. przejazdy weekendowe).
