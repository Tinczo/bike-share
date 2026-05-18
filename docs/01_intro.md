# 1. Cel

System Zarządzania Infrastrukturą Rowerową Miejską ma na celu wsparcie funkcjonowania miejskiej sieci rowerów publicznych. System umożliwia mieszkańcom łatwe wypożyczanie rowerów i transport pomiędzy stacjami, a także wspiera administrację w efektywnym monitorowaniu floty, zarządzaniu płatnościami oraz analizie danych w celu poprawy jakości infrastruktury rowerowej. Projekt obejmuje część programistyczną (backend, aplikacja mobilna, dashboard analityczny) oraz elementy sprzętowe (rowery z modułami IoT, stacje dokujące, terminale płatnicze).

W ramach pierwszego etapu opracowano analizę wymagań, definicje funkcjonalności, reguły biznesowe i model informacyjny dla czterech głównych obszarów systemu.

W ramach drugiego etapu podjęliśmy kluczowe decyzje architektoniczne oraz ich uzasadnienie dla Systemu Zarządzania Infrastrukturą Rowerową Miejską. Definiuje on cele architektoniczne, ograniczenia systemowe oraz mechanizmy realizacji wymagań funkcjonalnych i niefunkcjonalnych zidentyfikowanych w etapie 1. Architektura skupia się na zapewnieniu skalowalności, niezawodności, bezpieczeństwa oraz integracji komponentów backendowych, mobilnych, IoT i analitycznych.

# 2. Słownik pojęć

| Termin | Synonimy | Definicja |
| :--- | :--- | :--- |
| **Rower miejski** | Rower, Pojazd | Rower dostępny w ramach miejskiego systemu wypożyczeń, wyposażony w moduł GPS i zamek elektroniczny. |
| **Stacja** | Punkt, Lokalizacja, Terminal | Element infrastruktury systemu rowerowego stanowiący fizyczny punkt obsługi rowerów, wyposażony w stojaki, moduł komunikacji IoT oraz terminal umożliwiający docking (blokowanie) i odblokowywanie rowerów. Każda stacja posiada status operacyjny, liczbę dostępnych rowerów i stojaków. |
| **Stacja dokująca** | Punkt zwrotu | Podzespół lub rola stacji, umożliwiający użytkownikowi wypożyczenie lub zwrot roweru. Stacja dokująca jest przypisana do konkretnej lokalizacji i nadzoruje stan dostępnych miejsc oraz zablokowanych rowerów. |
| **Poziom baterii** | Naładowanie akumulatora, Stan zasilania | Wartość procentowa (0–100%) określająca stopień naładowania akumulatora w rowerze miejskim lub urządzeniu IoT. |
| **Rezerwacja** | — | Tymczasowe zablokowanie dostępności roweru na określony czas przed rozpoczęciem wypożyczenia. |
| **Serwis Roweru** | Naprawa, Obsługa techniczna, Konserwacja | Proces utrzymania technicznego rowerów w systemie, obejmujący diagnozę, naprawę i przywrócenie do eksploatacji. |
| **Abonament** | Subskrypcja | Plan taryfowy umożliwiający użytkownikowi korzystanie z rowerów w ramach określonych limitów. |
| **IoT moduł** | Czujnik, urządzenie telemetryczne | Urządzenie wbudowane w rower lub stację, przesyłające dane o stanie i lokalizacji. |
| **Relokacja** | Przemieszczenie | Proces przemieszczenia rowerów do stref o większym zapotrzebowaniu. |
| **Heatmapa** | Mapa cieplna | Wizualizacja intensywności użycia rowerów lub stacji na podstawie danych historycznych. |
| **Odczyt telemetryczny** | — | Pojedynczy zestaw danych przesyłanych przez moduł IoT w rowerze, zawierający m.in. położenie GPS, poziom baterii, ciśnienie w oponach oraz status zamka. |
| **Alert serwisowy** | Powiadomienie serwisowe | Powiadomienie generowane przez system w przypadku wykrycia usterki, niskiego poziomu baterii lub naruszenia strefy geofencing. |
| **Zgłoszenie usterki** | — | Formalny zapis problemu technicznego Roweru zgłoszony przez Użytkownika, zawierający typ usterki, opis i datę zgłoszenia. |
| **Strefa geofencing** | — | Obszar geograficzny definiowany w systemie, którego przekroczenie przez rower generuje alert. |
| **Naruszenie strefy** | Incydent geofencingowy | Zdarzenie, w którym rower opuścił wyznaczoną strefę geofencingową. |
| **Użytkownik** | — | Osoba fizyczna posiadająca konto w systemie. |
| **Konto Użytkownika** | — | Finansowa i statusowa reprezentacja Użytkownika. |
| **Wypożyczenie** | — | Okres, w którym Rower jest w użyciu przez Użytkownika. |
| **Transakcja** | — | Pojedyncza operacja finansowa wykonywana na Koncie Użytkownika. |
| **Kara** | Opłata dodatkowa, Sankcja finansowa | Dodatkowa opłata nakładana na użytkownika w przypadku naruszenia zasad korzystania z systemu (np. zwrot roweru poza strefą miejską lub po upływie limitu czasu). |
