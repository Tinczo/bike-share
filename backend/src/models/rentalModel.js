// Mock rental data
const mockRentals = [
  {
    id_wypozyczenia: "rental_001",
    id_uzytkownika: "1",
    id_roweru: "3",
    status: "ACTIVE",
    data_rozpoczecia: new Date(Date.now() - 30 * 60 * 20 * 1000).toISOString(), // 30 min ago
    data_zakonczenia: null,
    koszt_calkowity: null,
    metoda_uruchomienia: "QR",
    czas_pauzy_sekundy: 0,
  },
];

module.exports = mockRentals;
