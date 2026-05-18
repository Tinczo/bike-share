// Mock transaction data
// Using Polish field names to match database schema

const transactions = [
  {
    id_transakcji: 'trans_001',
    id_uzytkownika: '1',
    kwota: 100.00,
    typ: 'TOP_UP',
    czas_rejestracji: '2024-01-15T10:30:00.000',
    opis: 'Doładowanie przez BLIK',
  },
  {
    id_transakcji: 'trans_002',
    id_uzytkownika: '1',
    kwota: -5.50,
    typ: 'FEE',
    czas_rejestracji: '2024-01-16T14:20:00.000',
    opis: 'Opłata za wynajem roweru',
  },
  {
    id_transakcji: 'trans_003',
    id_uzytkownika: '1',
    kwota: 50.00,
    typ: 'TOP_UP',
    czas_rejestracji: '2024-01-17T09:00:00.000',
    opis: 'Doładowanie kartą',
  },
  {
    id_transakcji: 'trans_004',
    id_uzytkownika: '1',
    kwota: 10.00,
    typ: 'REWARD',
    czas_rejestracji: '2024-01-18T12:00:00.000',
    opis: 'Bonus za polecenie',
  },
  {
    id_transakcji: 'trans_005',
    id_uzytkownika: '1',
    kwota: -4.00,
    typ: 'FEE',
    czas_rejestracji: '2024-01-19T16:45:00.000',
    opis: 'Opłata za wynajem roweru',
  },
];

module.exports = transactions;
