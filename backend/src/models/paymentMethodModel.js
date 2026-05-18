// Mock payment method data
// Using Polish field names to match database schema

const paymentMethods = [
  {
    id_metody: 'pm_001',
    id_uzytkownika: '1',
    typ: 'CARD',
    ostatnie_cztery: '4242',
    marka_karty: 'Visa',
  },
  {
    id_metody: 'pm_002',
    id_uzytkownika: '1',
    typ: 'BLIK',
    ostatnie_cztery: null,
    marka_karty: null,
  },
];

module.exports = paymentMethods;
