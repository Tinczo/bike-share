// Mock fault reports data
const faults = [
  {
    id_zgloszenia: 'fault_001',
    id_roweru: '1',
    id_uzytkownika: '1',
    typ_usterki: 'przebita_opona',
    opis: 'Tylna opona jest przebita, nie da się jechać',
    data_zgloszenia: '2025-01-15T10:30:00.000Z',
    czy_zweryfikowane: true,
    czy_potwierdzone: true,
    data_weryfikacji: '2025-01-16T14:00:00.000Z',
    kwota_nagrody: 5.0,
  },
  {
    id_zgloszenia: 'fault_002',
    id_roweru: '3',
    id_uzytkownika: '1',
    typ_usterki: 'uszkodzone_hamulce',
    opis: 'Hamulec przedni nie działa prawidłowo',
    data_zgloszenia: '2025-01-18T15:45:00.000Z',
    czy_zweryfikowane: true,
    czy_potwierdzone: false,
    data_weryfikacji: '2025-01-19T09:00:00.000Z',
    kwota_nagrody: null,
  },
  {
    id_zgloszenia: 'fault_003',
    id_roweru: '5',
    id_uzytkownika: '1',
    typ_usterki: 'zepsuty_dzwonek',
    opis: null,
    data_zgloszenia: '2025-01-20T08:15:00.000Z',
    czy_zweryfikowane: false,
    czy_potwierdzone: false,
    data_weryfikacji: null,
    kwota_nagrody: null,
  },
];

module.exports = faults;
