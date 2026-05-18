const mockBikes = require("../models/bikeModel");
const mockStations = require("../models/stationModel");

const getBikes = (req, res) => {
  const { lat, lng, radius } = req.query;

  console.log(
    `GET /api/map/bikes - lat: ${lat}, lng: ${lng}, radius: ${radius}`,
  );

  // For mock purposes, return all bikes (in production, filter by distance)
  res.json({ bikes: mockBikes });
};

const getStations = (req, res) => {
  console.log("GET /api/map/stations");

  res.json({ stations: mockStations });
};

module.exports = {
  getBikes,
  getStations,
};
