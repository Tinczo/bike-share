# 6. Prototypy interfejsu

W tym rozdziale przedstawiono powiązanie zdefiniowanych wymagań funkcjonalnych z prototypami interfejsu użytkownika aplikacji mobilnej.

## 6.1 Rejestracja i logowanie użytkownika

### 6.1.1 Mapa nawigacyjna

Przepływ rozpoczyna się od ekranu logowania z opcją „Zarejestruj się”. Prowadzi ona do ekranu rejestracji, gdzie użytkownik podaje e-mail i hasło. Po zatwierdzeniu, system informuje o wysłaniu linku aktywacyjnego.

Ekran logowania:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-114&m=dev

Ekran rejestracji:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-241&m=dev

## 6.2 Przeglądanie dostępności rowerów

### 6.2.1 Mapa nawigacyjna

Ekran główny wyświetla mapę z lokalizacją użytkownika, stacjami i rowerami. Naciśnięcie na ikonę roweru wyświetla panel podglądu z informacją o statusie („Dostępny”) i cenniku („0,50 zł / min”).

Ekran główny z mapą:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-170&m=dev

Ekran główny z podglądem wypożyczonych rowerów:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-635&m=dev

Ekran podglądu roweru:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-1201&m=dev

Ekran podglądu roweru elektrycznego:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-1286&m=dev

## 6.3 Rezerwacja roweru

### 6.3.1 Mapa nawigacyjna

Użytkownik wybiera przycisk „Rezerwuj” na ekranie podglądu roweru. System wyświetla ekran aktywnej rezerwacji z 15-minutowym licznikiem czasu.

Ekran rezerwacji roweru:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-1241&m=dev

## 6.4 Rozpoczynanie przejazdu

### 6.4.1 Mapa nawigacyjna

Użytkownik wybiera „Wypożycz” lub główny przycisk „Skanuj QR”. Aplikacja uruchamia skaner kodu QR. Ekran skanera pozwala na przełączenie się na ręczne wprowadzanie kodu. Po pomyślnym odblokowaniu, wyświetlane jest potwierdzenie.

Ekran skanera QR:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-294&m=dev

Ekran skanera kodu QR z ręcznym wprowadzeniem numeru roweru:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-348&m=dev

## 6.5 Postój w trakcie przejazdu

### 6.5.1 Mapa nawigacyjna

Po ręcznym zablokowaniu roweru poza stacją, system wyświetla ekran wyboru opcji. Użytkownik wybiera opcję „Zrób postój”. Status roweru zmienia się na „Na postoju” na liście aktywnych wypożyczeń, gdzie dostępny staje się przycisk „Odblokuj” do wznowienia jazdy.

Ekran zakończenia wypożyczenia:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-767&m=dev

Ekran blokady roweru z opcją postoju:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-867&m=dev

## 6.6 Zakończenie przejazdu

### 6.6.1 Mapa nawigacyjna

Użytkownik inicjuje zakończenie z listy wypożyczeń przyciskiem „Zakończ” lub ręczną blokadą roweru. System wyświetla ekran instruktażowy. Po fizycznej blokadzie poza stacją (zgodnie z wymaganiem kary finansowej), użytkownik musi potwierdzić zwrot na ekranie wybierając „Zwróć i zakończ”.

Ekran główny z listą aktywnych wypożyczeń:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-635&m=dev

Ekran zakończenia wypożyczenia:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-767&m=dev

Ekran blokady roweru z opcją postoju:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-867&m=dev

Ekran potwierdzenia zakończenia wypożyczenia:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-933&m=dev

## 6.7 Zgłaszanie usterek

### 6.7.1 Mapa nawigacyjna

Z listy aktywnych wypożyczeń użytkownik wybiera „Zgłoś problem”. Otwiera się formularz z predefiniowaną listą usterek. Wybranie opcji „Inne” rozwija pole na opis tekstowy.

Ekran zgłoszenia usterki:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-1049&m=dev

Przykład ekranu z wybraną usterką „Brak powietrza w oponie”:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-1123&m=dev

## 6.8 Zarządzanie metodami płatności

### 6.8.1 Mapa nawigacyjna

Ekran „Portfel” umożliwia dodanie karty (przycisk „Dodaj”) oraz zasilenie salda konta (przycisk „Doładuj konto”).

Ekran portfela:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-414&m=dev

## 6.9 Uregulowanie długu

### 6.9.1 Mapa nawigacyjna

W przypadku ujemnego salda, system wyświetla ekran doładowania informujący o długu („Nieregulowane płatności”), minimalnej kwocie doładowania oraz blokadzie wypożyczeń. Użytkownik wybiera kwotę, metodę płatności i zatwierdza przyciskiem „Ureguluj dług teraz”.

Ekran doładowania salda z informacją o długu:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-555&m=dev

## 6.10 Naliczenie opłat

### 6.10.1 Mapa nawigacyjna

Cennik (stawka minutowa „pay-per-ride”) jest widoczny na ekranie podglądu roweru oraz na ekranie potwierdzenia wypożyczenia. Bieżąca naliczona opłata jest widoczna na liście aktywnych wypożyczeń.

## 6.11 Historia transakcji i saldo

### 6.11.1 Mapa nawigacyjna

Wymaganie realizowane przez ekran „Portfel”, który wyświetla „Saldo konta” oraz listę w sekcji „Historia transakcji”.

Ekran portfela:
https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-414&m=dev
