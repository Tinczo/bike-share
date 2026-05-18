const express = require('express');
const faultController = require('../controllers/faultController');

const router = express.Router();

// Fault reporting endpoint
router.post('/report', faultController.reportFault);

module.exports = router;
