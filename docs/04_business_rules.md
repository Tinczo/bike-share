# 5. Reguły biznesowe i ograniczenia systemowe

Część reguł i ograniczeń opisana jest w postaci wyrażeń OCL, które formalizują warunki, jakie muszą być spełnione przez system. Ze względu na czytelność, definicje OCL zostały umieszczone w opisie tekstowym, a nie bezpośrednio na diagramach.

## 5.1 Wypożyczenia i Rezerwacje

*   **Użytkownik** może zainicjować **Wypożyczenie** lub dokonać **Rezerwacji** tylko wtedy, gdy atrybut `dozwoloneWypozyczenie` ma wartość `true`. Atrybut ten jest wyliczany zgodnie z regułą:
    ```ocl
    context KontoUzytkownika derive dozwoloneWypozyczenie: Boolean:
    self.status = StatusKontaUzytkownika::AKTYWNE and (
      self.saldo >= 20.0 or
      self.maPodpietaKarte = true or
      self.abonament -> exists(a | a.czyAktywny = true)
    )
    ```

*   Atrybut `/liczbaWolnychMiejsc` **Stacji dokującej** jest wyliczany jako różnica między całkowitą pojemnością stacji a liczbą aktualnie zadokowanych w niej rowerów.
    ```ocl
    context StacjaDokujaca derive liczbaWolnychMiejsc: Integer:
    self.pojemnosc - self.rower -> size()
    ```

*   Atrybut `/czyAktywny` **Abonamentu** ma wartość `true`, jeśli bieżąca data znajduje się w okresie ważności abonamentu i nie został on anulowany.
    ```ocl
    context Abonament derive czyAktywny: Boolean:
    (
      OclDateTime.now() >= self.czasRozpoczecia and
      OclDateTime.now() <= self.czasZakonczenia and
      self.czasAnulowania.oclIsUndefined()
    )
    ```

*   Dla każdego **Roweru** może istnieć co najwyżej jedno aktywne **Wypożyczenie** (status `W_TRAKCIE` lub `ZAPAUZOWANE`) oraz co najwyżej jedna aktywna **Rezerwacja** (status `AKTYWNA`), zgodnie z regułą:
    ```ocl
    context Rower inv UnikalnoscAktywnychPowiazan:
    self.rezerwacja -> select(r | r.status = StatusRezerwacji::AKTYWNA) -> size() <= 1
    and
    self.wypozyczenie -> select(
      w | w.status = StatusWypozyczenia::W_TRAKCIE or
      w.status = StatusWypozyczenia::ZAPAUZOWANE
    ) -> size() <= 1
    ```

*   **Użytkownik** może mieć jednocześnie co najwyżej aktywne **Wypożyczenie** oraz co najwyżej jedną aktywną **Rezerwację**.
    ```ocl
    context Uzytkownik inv MaksymalnieJednaAktywnaSesja:
    self.wypozyczenie -> select(
      w | w.status = StatusWypozyczenia::W_TRAKCIE or
      w.status = StatusWypozyczenia::ZAPAUZOWANE
    ) -> size() <= 1
    and
    self.rezerwacja -> select(
      r | r.status = StatusRezerwacji::AKTYWNA
    ) -> size() <= 1
    ```

*   **Rezerwacja** ze statusem `AKTYWNA` automatycznie zmienia status na `WYGASLA`, jeśli jej ważność wygasła (minął `czasWygasniecia`) i nie została zrealizowana. Zmiana ta powoduje ustawienie statusu powiązanego **Roweru** na `DOSTEPNY`.

*   **Konto Użytkownika** otrzymuje status `ZADLUZONE`, jeśli po zakończeniu **Wypożyczenia** jego saldo jest ujemne i nie udało się pobrać wymaganej opłaty z podpiętej karty płatniczej (jeśli karta została podpięta do konta).

*   Po zweryfikowaniu i potwierdzeniu **Zgłoszenia usterki** (zmiana `czyZweryfikowane` na `true` i `czyPotwierdzone` na `true`, system automatycznie tworzy **Transakcję** typu `NAGRODA` na kwotę 0.50 zł dla **Konta Użytkownika**, który zarejestrował dane zgłoszenie.

*   System tworzy **Transakcję** typu `KARA`, jeśli **Wypożyczenie** zakończyło się w lokalizacji niebędącej w określonym promieniu od żadnej ze **Stacji dokujących**.

*   Jeśli atrybut `czasZakonczenia` **Wypożyczenia** jest zdefiniowany, jego wartość musi być późniejsza niż wartość `czasRozpoczecia`.

*   Jeśli atrybut `czasAnulowania` **Abonamentu** jest zdefiniowany, jego wartość musi być późniejsza niż wartość `czasRozpoczecia` i wcześniejsza niż `czasZakonczenia`.

*   Jeśli atrybut `koszt` **Wypożyczenia** jest zdefiniowany, jego wartość musi być nieujemna.

*   Wszystkie znaczniki czasu (atrybuty typu `DataCzas`) muszą być zgodne z formatem ISO 8601. Adresy e-mail muszą być zgodne ze standardem RFC 5322.

## 5.2 Monitoring Floty i Infrastruktury

*   Każdy **Rower** poza aktywną **StrefąGeofencing** generuje natychmiast **AlertSerwisowy** typu „naruszenie strefy”.
*   Poziom baterii roweru (`poziom_baterii`) poniżej ustalonego progu generuje **AlertSerwisowy** typu „niski poziom baterii”.
*   System oznacza rower jako potencjalnie uszkodzony, jeśli nie przesyła żadnych **OdczytówTelemetrycznych** przez ustalony czas (np. 24 godziny).
*   Liczba `dostepne_stojaki` w **Stacja** nie może przekraczać `liczba_stojakow`.
*   **Stacja** nie może być oznaczona jako operacyjna (`status_operacyjny` = „sprawna”), jeśli liczba `dostepne_stojaki` lub `dostepne_rowery` jest mniejsza od zera lub większa niż `liczba_stojakow`.
*   Każde **ZgloszenieUsterki** musi mieć określony `typ_usterki` i `data_zgloszenia`; brak któregokolwiek z tych atrybutów blokuje zapis.
*   W przypadku **RelokacjaRoweru**, `data_relokacji` nie może być wcześniejsza niż ostatni znacznik czasu powiązanego **OdczytuTelemetrycznego**.
*   Każdy **AlertSerwisowy** musi być powiązany z konkretnym **Rower** lub **Stacja**; brak powiązania blokuje wysyłkę powiadomienia.
*   Współrzędne GPS roweru i stacji (`szer_geo`, `dł_geo`) muszą znajdować się w granicach obsługiwanych przez system.
*   Poziom baterii (`poziom_baterii`) roweru musi być liczbą całkowitą w zakresie 0–100.
*   System nie pozwala na wprowadzenie dwóch aktywnych **StrefGeofencing** o tym samym `id_strefy` i geometrycznym pokryciu w tej samej lokalizacji.
*   Każde **NaruszenieStrefy** musi mieć `data_naruszenia`, współrzędne (`szer_geo`, `dł_geo`) i `status_obslugi`; brak któregokolwiek z tych atrybutów blokuje zapis incydentu.
*   Koszt serwisu (`koszt`) w **SerwisRoweru** musi być liczbą dodatnią lub zerem; wartości ujemne są niedozwolone.
*   Wszystkie **AlertSerwisowy** powiązane z **Rower** muszą mieć `data_alertu` nie wcześniejszą niż `data_ostatniego_serwisu` roweru.

## 5.3 Płatności i Rozliczenia

*   **Abonament** nie może mieć daty końca wcześniejszej niż data rozpoczęcia.
*   Kwota **Zwrotu** nie może przekraczać kwoty pierwotnej **Płatności**.
*   W przypadku powiązania **Płatności** z **Abonamentem**, data zakończenia płatności nie może być wcześniejsza niż data zakończenia abonamentu.
*   W przypadku powiązania **Kary** z **Fakturą**, kwota kary nie może przekraczać wartości faktury, a status faktury nie może być równy anulowana.
*   System nie pozwala na wprowadzenie dwóch aktywnych **Abonamentów** tego samego typu dla jednego **Użytkownika** z zachodzącym okresem obowiązywania.
*   Każda **Płatność** rozlicza albo **Fakturę**, albo **Paragon**, nigdy obu jednocześnie.
*   Wszystkie daty w systemie (**Płatności**, **Faktury**, **Paragony**, **Kary**, **Zwroty**) muszą być w formacie YYYY-MM-DD; brak poprawnego formatu blokuje zapis.
*   Każda **Płatność** typu *pay-per-ride* musi mieć powiązaną informację o wypożyczeniu roweru; brak powiązania uniemożliwia naliczenie opłaty.
*   System weryfikuje, że saldo **Użytkownika** nie może być ujemne po zapisaniu transakcji finansowej.

## 5.4 Analityka i Optymalizacja Miejska

*   Proces ETL zasilający hurtownię danych poprawnie mapuje współrzędne geograficzne początku i końca każdego przejazdu na odpowiedni rekord w **Wymiarze Lokalizacji**, zgodnie z następującą logiką:
    1.  Jeśli współrzędne znajdują się w zdefiniowanym promieniu stacji dokującej, przejazd jest łączony z rekordem tej stacji (wypełniając `idStacji`, `nazwaStacji`, `idStrefy`, `nazwaStrefy` i `miastoStrefy`).
    2.  Jeśli współrzędne nie wskazują na stację, ale znajdują się wewnątrz zdefiniowanej strefy operacyjnej, przejazd jest łączony z rekordem, który ma puste pola `idStacji` i `nazwaStacji`, ale wypełnione pola `idStrefy`, `nazwaStrefy` i `miastoStrefy`.
    3.  Jeśli współrzędne znajdują się poza wszystkimi zdefiniowanymi strefami, przejazd jest łączony z rekordem zawierającej jedynie dokładną geolokalizację danego punktu.
*   Dane w hurtowni danych są zanonimizowane. **Fakt Przejazdu** nie może zawierać bezpośredniego odniesienia do konkretnego **Użytkownika**, a jedynie do atrybutów nieidentyfikujących, takich jak `typRozliczenia`.
*   Dane analityczne (**Fakt Przejazdu** oraz powiązane wymiary) są przechowywane przez okres co najmniej 2 lat, zgodnie z wymaganiami funkcjonalnymi.
*   Dla każdego rekordu **Fakt Przejazdu** metryki czasowe i finansowe muszą być logicznie spójne i nieujemne:
    ```ocl
    context FaktPrzejazdu inv SpojnoscMetrykICzasu:
    self.czasZakonczenia >= self.czasRozpoczecia and
    self.czasTrwaniaSekundy >= 0 and
    self.przebytyDystansMetry >= 0 and
    self.koszt >= 0.0
    ```
*   Wartości generowane przez modele predykcyjne i analityczne muszą znajdować się w logicznie poprawnych zakresach.
*   System musi umożliwiać wygenerowanie **Raportu Analitycznego** dla zdefiniowanych okresów (np. TYGODNIOWY, MIESIECZNY) i formatów (np. PDF, CSV). Każdy raport musi być powiązany z zakresem dat, których dotyczy (`zakresOd`, `zakresDo`).
