const { v4: uuidv4 } = require('uuid');
const faults = require('../models/faultModel');
const bikes = require('../models/bikeModel');

// Demo user ID
const DEMO_USER_ID = '1';

// Valid fault types (lowercase for comparison)
const VALID_FAULT_TYPES = [
  'przebita_opona',
  'zerwany_lancuch',
  'uszkodzone_hamulce',
  'uszkodzona_rama',
  'zepsuty_dzwonek',
  'uszkodzone_oswietlenie',
  'uszkodzone_swiatla', // Alternative spelling from Flutter
  'inne',
];

const reportFault = (req, res) => {
  const { bikeId, type, description } = req.body;

  // Validate required fields
  if (!bikeId) {
    return res.status(400).json({
      error: 'Bad Request',
      message: 'Bike ID is required',
    });
  }

  if (!type) {
    return res.status(400).json({
      error: 'Bad Request',
      message: 'Fault type is required',
    });
  }

  // Normalize fault type to lowercase for comparison
  const normalizedType = type.toLowerCase();

  // Validate fault type (case-insensitive)
  if (!VALID_FAULT_TYPES.includes(normalizedType)) {
    return res.status(400).json({
      error: 'Bad Request',
      message: `Invalid fault type. Valid types: ${VALID_FAULT_TYPES.join(', ')}`,
    });
  }

  // Check if bike exists
  const bike = bikes.find((b) => b.id_roweru === bikeId || b.kod_qr === bikeId);
  if (!bike) {
    return res.status(404).json({
      error: 'Not Found',
      message: 'Bike not found',
    });
  }

  // Create new fault report (store normalized lowercase type)
  const newFault = {
    id_zgloszenia: `fault_${uuidv4().slice(0, 8)}`,
    id_roweru: bike.id_roweru,
    id_uzytkownika: DEMO_USER_ID,
    typ_usterki: normalizedType,
    opis: description || null,
    data_zgloszenia: new Date().toISOString(),
    czy_zweryfikowane: false,
    czy_potwierdzone: false,
    data_weryfikacji: null,
    kwota_nagrody: null,
  };

  faults.push(newFault);

  console.log(
    `POST /api/faults/report: Fault reported for bike ${bike.id_roweru}, type: ${normalizedType}`
  );

  res.status(201).json({ fault: newFault });
};

module.exports = {
  reportFault,
};
