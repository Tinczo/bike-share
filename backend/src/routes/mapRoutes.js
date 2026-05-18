const express = require("express");
const router = express.Router();
const mapController = require("../controllers/mapController");

router.get("/bikes", mapController.getBikes);
router.get("/stations", mapController.getStations);

module.exports = router;
