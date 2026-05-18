const express = require('express');
const historyController = require('../controllers/historyController');

const router = express.Router();

// History endpoints
router.get('/rentals', historyController.getRentalHistory);
router.get('/faults', historyController.getFaultHistory);

module.exports = router;
