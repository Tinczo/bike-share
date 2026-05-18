const getHealth = (req, res) => {
  console.log("GET /api/health: Health check requested");
  res.json({ status: "ok", timestamp: new Date().toISOString() });
};

module.exports = { getHealth };
