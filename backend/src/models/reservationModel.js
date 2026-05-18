// Mock reservation data
const mockReservations = [
  {
    id_rezerwacji: 'res_001',
    id_uzytkownika: '2',
    id_roweru: '6',
    status: 'ACTIVE',
    data_utworzenia: new Date(Date.now() - 5 * 60 * 1000).toISOString(), // 5 min ago
    data_wygasniecia: new Date(Date.now() + 10 * 60 * 1000).toISOString(), // 10 min from now
  },
];

module.exports = mockReservations;
