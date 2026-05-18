const express = require('express');
const rentalController = require('../controllers/rentalController');

const router = express.Router();

// Eligibility check
router.get('/eligibility', rentalController.checkEligibility);

// Rental operations
router.post('/start', rentalController.startRental);
router.get('/active', rentalController.getActiveRental);
router.post('/:rentalId/pause', rentalController.pauseRental);
router.post('/:rentalId/resume', rentalController.resumeRental);
router.post('/:rentalId/end', rentalController.endRental);

// Reservation operations
router.post('/reservation', rentalController.createReservation);
router.get('/reservation/active', rentalController.getActiveReservation);
router.delete('/reservation/:reservationId', rentalController.cancelReservation);

module.exports = router;
