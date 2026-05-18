// Mock wallet data
// Using Polish field names to match database schema

const wallets = [
  {
    id_konta: "1",
    id_uzytkownika: "1",
    saldo: 50.5,
    status: "ACTIVE",
    ma_podpieta_karte: true,
  },
  {
    id_konta: "2",
    id_uzytkownika: "2",
    saldo: -25.0,
    status: "DEBT",
    ma_podpieta_karte: false,
  },
];

module.exports = wallets;
