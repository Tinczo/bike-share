const rentals = require('../models/rentalModel');
const faults = require('../models/faultModel');

// Demo user ID
const DEMO_USER_ID = '1';

const getRentalHistory = (req, res) => {
  // Get finished rentals for the user
  const userRentals = rentals.filter(
    (r) => r.id_uzytkownika === DEMO_USER_ID && r.status === 'FINISHED'
  );

  // Map to history format with station names
  const history = userRentals.map((rental) => ({
    id_wypozyczenia: rental.id_wypozyczenia,
    id_roweru: rental.id_roweru,
    data_rozpoczecia: rental.data_rozpoczecia,
    data_zakonczenia: rental.data_zakonczenia,
    koszt_calkowity: rental.koszt_calkowity,
    nazwa_stacji_start: 'Rynek Główny',
    nazwa_stacji_koniec: 'Dworzec PKP',
  }));

  console.log(`GET /api/history/rentals: Returning ${history.length} rentals`);
  res.status(200).json({ rentals: history });
};

const getFaultHistory = (req, res) => {
  // Get faults for the user
  const userFaults = faults.filter((f) => f.id_uzytkownika === DEMO_USER_ID);

  console.log(`GET /api/history/faults: Returning ${userFaults.length} faults`);
  res.status(200).json({ faults: userFaults });
};

module.exports = {
  getRentalHistory,
  getFaultHistory,
};
