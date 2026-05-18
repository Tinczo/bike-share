# 14. Widok informacyjny

## 14.2 Projekt bazy danych Domeny Wypożyczeń
### 14.2.1 Ogólne informacje
*   **SID/Service Name:** rental-service-db
*   **Type:** Relacyjna – PostgreSQL 14
*   **Opis:** Przechowuje dane dotyczące użytkowników, kont, wypożyczeń, rezerwacji, rowerów, abonamentów oraz zgłoszeń usterek w systemie rowerowym miejskim.

### 14.2.2 Backup
*   **Pełna kopia zapasowa:** Codziennie o 02:00 UTC.
*   **Kopia przyrostowa:** Co godzinę (WAL).
*   **Retencja:** 14 ostatnich pełnych kopii (2 tygodnie).
*   **PITR:** 14 dni.

### 14.2.3 Schemat public
Poniżej przedstawiono definicje tabel dla domeny wypożyczeń (Rental Context):

```sql
Table uzytkownicy {
  id_uzytkownika bigint [pk]
  email varchar(255) [not null]
  skrot_hasla varchar(255) [not null]
}

Table konta_uzytkownikow {
  id_konta bigint [pk]
  id_uzytkownika bigint [not null, ref: > uzytkownicy.id_uzytkownika]
  saldo double [not null]
  status varchar(20) [not null]
  ma_podpieta_karte boolean [not null]
  data_utworzenia timestamp [not null]
  data_aktualizacji timestamp [not null]
  ostatnie_logowanie timestamp
}

Table stacje {
  id_stacji bigint [pk]
  nazwa varchar(200) [not null]
  lokalizacja_dlugosc double [not null]
  lokalizacja_szerokosc double [not null]
  pojemnosc int [not null]
}

Table rowery {
  id_roweru bigint [pk]
  kod_qr varchar(100) [not null]
  status varchar(30) [not null]
  lokalizacja_dlugosc double
  lokalizacja_szerokosc double
  id_stacji bigint [ref: > stacje.id_stacji]
}

Table wypozyczenia {
  id_wypozyczenia bigint [pk]
  id_uzytkownika bigint [not null, ref: > uzytkownicy.id_uzytkownika]
  id_roweru bigint [not null, ref: > rowery.id_roweru]
  czas_rozpoczecia timestamp [not null]
  czas_zakonczenia timestamp
  koszt double
  status varchar(20) [not null]
}

Table rezerwacje {
  id_rezerwacji bigint [pk]
  id_uzytkownika bigint [not null, ref: > uzytkownicy.id_uzytkownika]
  id_roweru bigint [not null, ref: > rowery.id_roweru]
  czas_utworzenia timestamp [not null]
  czas_wygasniecia timestamp [not null]
  status varchar(20) [not null]
}

Table abonamenty {
  id_abonamentu bigint [pk]
  id_konta bigint [not null, ref: > konta_uzytkownikow.id_konta]
  typ varchar(20) [not null]
  czas_rozpoczecia timestamp [not null]
  czas_zakonczenia timestamp [not null]
  czas_anulowania timestamp
}

Table zgloszenia_usterek {
  id_zgloszenia bigint [pk]
  id_uzytkownika bigint [not null, ref: > uzytkownicy.id_uzytkownika]
  id_roweru bigint [not null, ref: > rowery.id_roweru]
  czas_zgloszenia timestamp [not null]
  typ_usterki varchar(50) [not null]
  opis text
  czy_zweryfikowane boolean [not null]
  czy_potwierdzone boolean [not null]
}

Table transakcje {
  id_transakcji bigint [pk]
  id_konta bigint [not null, ref: > konta_uzytkownikow.id_konta]
  id_wypozyczenia bigint [ref: > wypozyczenia.id_wypozyczenia]
  kwota double [not null]
  czas_rejestracji timestamp [not null]
  typ varchar(20) [not null]
}
```

### 14.2.4 Szacunki wolumetryczne (dla 100 tys. mieszkańców)
*   **Tabela wypożyczenia:** ~365 MB/rok (1.8 mln rekordów).
*   **Tabela rezerwacje:** ~98 MB/rok.
*   **Tabela transakcje:** ~547 MB/rok.
*   **Tabela zgłoszenia_usterek:** ~23 MB/rok.
*   **Tabele pomocnicze:** ~100 MB/rok.
*   **Suma całkowita:** ~2.5 GB/rok.

### 14.2.5 Strategia partycjonowania
Zalecane wprowadzenie po 12 miesiącach: Range partitioning po kolumnie `czas_rozpoczecia`, granulacja miesięczna.

## 14.3 Projekt bazy danych Domeny Monitoringu
### 14.3.1 Ogólne informacje
*   **SID/Service Name:** monitoring-service-db
*   **Type:** Relacyjna – PostgreSQL 14 + PostGIS 3.2
*   **Opis:** Przechowuje dane telemetryczne, alerty serwisowe, zgłoszenia usterek, geofencing, relokacje.

### 14.3.2 Backup
*   **Pełna kopia zapasowa:** Codziennie o 03:00 UTC.
*   **Kopia przyrostowa:** Co 2 godziny.
*   **Retencja:** Pełne kopie: 7 ostatnich. Telemetria: archiwizacja do S3 po 30 dniach.

### 14.3.3 Schemat public (Monitoring Floty)
Poniżej przedstawiono definicje tabel dla domeny monitoringu (Fleet Context):

```sql
Table rowery {
  id_roweru bigint [pk]
  id_stacji bigint [ref: > stacje.id_stacji]
  numer_seryjny varchar(100) [not null]
  model varchar(100) [not null]
  status_operacyjny varchar(20) [not null]
  ostatnia_lokalizacja_szer_geo double
  ostatnia_lokalizacja_dl_geo double
  ostatni_poziom_baterii int
  data_zakupu timestamp [not null]
  data_ostatniego_serwisu timestamp
}

Table odczyty_telemetryczne {
  id_odczytu bigint [pk]
  id_roweru bigint [not null, ref: > rowery.id_roweru]
  czas_odczytu timestamp [not null]
  szer_geo double [not null]
  dl_geo double [not null]
  poziom_baterii int [not null]
  cisnienie_przednia_opona double
  cisnienie_tylna_opona double
  predkosc double
  status_blokady varchar(20) [not null]
}

Table stacje {
  id_stacji bigint [pk]
  nazwa varchar(200) [not null]
  szer_geo double [not null]
  dl_geo double [not null]
  pojemnosc int [not null]
  status_operacyjny varchar(20) [not null]
  data_instalacji timestamp [not null]
}

Table statusy_stacji {
  id_statusu bigint [pk]
  id_stacji bigint [not null, ref: > stacje.id_stacji]
  czas_statusu timestamp [not null]
  dostepne_rowery int [not null]
  dostepne_stojaki int [not null]
  czy_sprawna boolean [not null]
}

Table zgloszenia_usterek {
  id_zgloszenia bigint [pk]
  id_roweru bigint [not null, ref: > rowery.id_roweru]
  id_uzytkownika bigint
  data_zgloszenia timestamp [not null]
  typ_usterki varchar(30) [not null]
  opis text
  status_rozwiazania varchar(30)
  czy_zweryfikowane boolean
  data_weryfikacji timestamp
  data_rozwiazania timestamp
}

Table alerty_serwisowe {
  id_alertu bigint [pk]
  id_roweru bigint [ref: > rowery.id_roweru]
  id_stacji bigint [ref: > stacje.id_stacji]
  typ_alertu varchar(30) [not null]
  data_alertu timestamp [not null]
  powaga varchar(20) [not null]
  wiadomosc text
  status_rozwiazania varchar(30)
  data_rozwiazania timestamp
}

Table strefy_geofencing {
  id_strefy bigint [pk]
  nazwa varchar(200) [not null]
  miasto varchar(100) [not null]
  geometria geometry [not null]
  typ_strefy varchar(30) [not null]
  czy_aktywna boolean [not null]
}

Table naruszenia_strefy {
  id_naruszenia bigint [pk]
  id_roweru bigint [not null, ref: > rowery.id_roweru]
  id_strefy bigint [not null, ref: > strefy_geofencing.id_strefy]
  data_naruszenia timestamp [not null]
  szer_geo double [not null]
  dl_geo double [not null]
  status_obslugi varchar(20) [not null]
}

Table relokacje_rowerow {
  id_relokacji bigint [pk]
  id_roweru bigint [not null, ref: > rowery.id_roweru]
  id_stacji_zrodlowej bigint [ref: > stacje.id_stacji]
  id_stacji_docelowej bigint [not null, ref: > stacje.id_stacji]
  data_relokacji timestamp [not null]
  powod text
  status_relokacji varchar(20) [not null]
}

Table serwisy_rowerow {
  id_serwisu bigint [pk]
  id_roweru bigint [not null, ref: > rowery.id_roweru]
  data_serwisu timestamp [not null]
  typ_serwisu varchar(30) [not null]
  opis text
  koszt double
}
```

### 14.3.4 Szacunki wolumetryczne
*   **Tabela odczyty_telemetryczne:** ~22 GB/rok (122 mln rekordów).
*   **Tabela statusy_stacji:** ~2.6 GB/rok.
*   **Suma całkowita:** ~45 GB/rok.

### 14.3.5 Strategia archiwizacji
*   **Dane hot (ostatnie 30 dni):** PostgreSQL primary.
*   **Dane warm (31–90 dni):** PostgreSQL read-replica.
*   **Dane cold (>90 dni):** Eksport do S3 Glacier (Parquet).

## 14.4 Projekt bazy danych Domeny Płatności
### 14.4.1 Ogólne informacje
*   **SID/Service Name:** payment-service-db
*   **Type:** Relacyjna – PostgreSQL 14
*   **Opis:** Dane finansowe użytkowników: płatności, abonamenty, faktury, paragony, kary, zwroty. Baza krytyczna (ACID).

### 14.4.2 Backup
*   **Pełna kopia zapasowa:** Codziennie o 01:00 UTC.
*   **Kopia przyrostowa:** Co 30 minut (WAL).
*   **Retencja:** Pełne kopie: 30 ostatnich. Kopie archiwalne: 7 lat.

### 14.4.3 Schemat public (Płatności)
Poniżej przedstawiono definicje tabel dla domeny płatności (Payment Context):

```sql
Table uzytkownicy {
  id_uzytkownika bigint [pk]
}

Table abonamenty {
  id_abonamentu bigint [pk]
  id_uzytkownika bigint [not null, ref: > uzytkownicy.id_uzytkownika]
  typ_abonamentu varchar(30) [not null]
  czas_rozpoczecia timestamp [not null]
  czas_zakonczenia timestamp [not null]
  automatyczne_odnowienie boolean [not null]
  cena double [not null]
}

Table platnosci {
  id_platnosci bigint [pk]
  id_uzytkownika bigint [not null, ref: > uzytkownicy.id_uzytkownika]
  id_abonamentu bigint [ref: > abonamenty.id_abonamentu]
  typ_platnosci varchar(30) [not null]
  kwota double [not null]
  czas_zlecenia timestamp [not null]
  czas_zakonczenia timestamp
  status varchar(20) [not null]
  id_wypozyczenia varchar(255)
}

Table faktury {
  id_faktury bigint [pk]
  id_uzytkownika bigint [not null, ref: > uzytkownicy.id_uzytkownika]
  id_platnosci bigint [not null, ref: > platnosci.id_platnosci]
  numer_faktury varchar(50) [not null]
  kwota_netto double [not null]
  kwota_brutto double [not null]
  stawka_vat double [not null]
  czas_wystawienia timestamp [not null]
  czas_sprzedazy timestamp [not null]
  czas_zaplaty timestamp
  status varchar(20) [not null]
}

Table paragony {
  id_paragonu bigint [pk]
  id_uzytkownika bigint [not null, ref: > uzytkownicy.id_uzytkownika]
  id_platnosci bigint [ref: > platnosci.id_platnosci]
  numer_paragonu varchar(50) [not null]
  kwota double [not null]
  czas_wystawienia timestamp [not null]
}

Table kary {
  id_kary bigint [pk]
  id_uzytkownika bigint [not null, ref: > uzytkownicy.id_uzytkownika]
  id_wypozyczenia bigint [not null]
  id_faktury bigint [ref: > faktury.id_faktury]
  typ_kary varchar(30) [not null]
  kwota double [not null]
  czas_naliczenia timestamp [not null]
  status varchar(20) [not null]
  opis text
}

Table zwroty {
  id_zwrotu bigint [pk]
  id_uzytkownika bigint [not null, ref: > uzytkownicy.id_uzytkownika]
  id_platnosci bigint [not null, ref: > platnosci.id_platnosci]
  kwota double [not null]
  czas_zwrotu timestamp [not null]
  powod text
}
```

### 14.4.5 Szacunki wolumetryczne
*   **Tabela płatności:** ~458 MB/rok.
*   **Tabela faktury:** ~110 MB/rok.
*   **Tabela paragony:** ~292 MB/rok.
*   **Suma całkowita:** ~1.2 GB/rok.

## 14.5 Projekt bazy danych Domeny Analityki (Hurtownia Danych)
### 14.5.1 Ogólne informacje
*   **SID/Service Name:** analytics-service-db
*   **Type:** PostgreSQL 14 + TimescaleDB 2.8 + PostGIS 3.2
*   **Opis:** Hurtownia danych (DW) dla analiz OLAP i time-series.

### 14.5.2 Backup
*   **Pełna kopia zapasowa:** Co tydzień (niedziela 04:00 UTC).
*   **Kopia przyrostowa:** Codziennie.

### 14.5.3 Schemat public (Analityka)
Poniżej przedstawiono definicje tabel dla hurtowni danych:

```sql
Table wymiar_czasu {
  id_czasu bigint [pk]
  czas timestamp [not null]
  godzina int [not null]
  minuta int [not null]
  sekunda int [not null]
  dzien_tygodnia varchar(20) [not null]
  dzien_miesiaca int [not null]
  miesiac int [not null]
  rok int [not null]
  pora_dnia varchar(30) [not null]
  czy_dzien_roboczy boolean [not null]
  czy_weekend boolean [not null]
}

Table wymiar_lokalizacji {
  id_lokalizacji bigint [pk]
  dokladna_lokalizacja_dlugosc double [not null]
  dokladna_lokalizacja_szerokosc double [not null]
  id_strefy varchar(100)
  nazwa_strefy varchar(200)
  miasto_strefy varchar(100) [not null]
  id_stacji varchar(100)
  nazwa_stacji varchar(200)
}

Table fakt_przejazdu {
  id_przejazdu bigint [pk]
  id_czasu_rozpoczecia bigint [not null, ref: > wymiar_czasu.id_czasu]
  id_czasu_zakonczenia bigint [not null, ref: > wymiar_czasu.id_czasu]
  id_lokalizacji_start bigint [not null, ref: > wymiar_lokalizacji.id_lokalizacji]
  id_lokalizacji_koniec bigint [not null, ref: > wymiar_lokalizacji.id_lokalizacji]
  czas_rozpoczecia timestamp [not null]
  czas_zakonczenia timestamp [not null]
  czas_trwania_sekundy int [not null]
  przebyte_metry int [not null]
  koszt double [not null]
  typ_rozliczenia varchar(20) [not null]
}

Table predykcje_popytu {
  id_predykcji bigint [pk]
  id_lokalizacji bigint [not null, ref: > wymiar_lokalizacji.id_lokalizacji]
  id_czasu bigint [not null, ref: > wymiar_czasu.id_czasu]
  czas_predykcji timestamp [not null]
  przewidywana_liczba_rowerow int [not null]
  poziom_pewnosci double
  dolny_przedzial_ufnosci int
  gorny_przedzial_ufnosci int
  nazwa_modelu varchar(100)
}

Table raporty_analityczne {
  id_raportu bigint [pk]
  nazwa_raportu varchar(200) [not null]
  typ_raportu varchar(30) [not null]
  zakres_od timestamp [not null]
  zakres_do timestamp [not null]
  czas_wygenerowania timestamp [not null]
  tresc_binarna bytea [not null]
  format varchar(10) [not null]
  sciezka_pliku varchar(500)
  rozmiar_bajty bigint
}

Table raporty_fakty {
  id_raportu bigint [not null, ref: > raporty_analityczne.id_raportu]
  id_przejazdu bigint [not null, ref: > fakt_przejazdu.id_przejazdu]

  indexes {
    (id_raportu, id_przejazdu) [pk]
  }
}

Table rekomendacje_lokalizacji {
  id_rekomendacji bigint [pk]
  data_utworzenia timestamp [not null]
  proponowana_lokalizacja_dlugosc double [not null]
  proponowana_lokalizacja_szerokosc double [not null]
  wynik_oceny double [not null]
  uzasadnienie text
  typ_rekomendacji varchar(50)
  status varchar(30)
}
```

### 14.5.5 Szacunki wolumetryczne
*   **Tabela fakt_przejazdu:** ~548 MB/rok (dane surowe), ~274 MB/rok (po kompresji TimescaleDB).
*   **Suma całkowita:** ~8 GB/rok.
