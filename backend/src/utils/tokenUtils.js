// Helper to generate mock JWT token
const generateToken = (userId) => {
  return `mock_jwt_token_${userId}_${Date.now()}`;
};

module.exports = { generateToken };
