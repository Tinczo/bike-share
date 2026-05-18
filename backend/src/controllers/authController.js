const { v4: uuidv4 } = require("uuid");
const users = require("../models/userModel");
const { generateToken } = require("../utils/tokenUtils");

const login = (req, res) => {
  const { email, password } = req.body;

  // Validate request body
  if (!email || !password) {
    console.log(
      "GET /api/auth/login: Login attempt with missing email or password",
    );
    return res.status(400).json({
      error: "Bad Request",
      message: "Email and password are required",
    });
  }

  // Find user by email and password
  const user = users.find((u) => u.email === email && u.password === password);

  if (!user) {
    console.log(
      `GET /api/auth/login: Failed login attempt for email: ${email}`,
    );
    return res.status(401).json({
      error: "Unauthorized",
      message: "Invalid email or password",
    });
  }

  // Return success response
  console.log(`GET /api/auth/login: User logged in: ${email}`);
  res.status(200).json({
    user: {
      id_uzytkownika: user.id_uzytkownika,
      email: user.email,
    },
    token: generateToken(user.id_uzytkownika),
  });
};

const register = (req, res) => {
  const { email, password } = req.body;

  // Validate request body
  if (!email || !password) {
    console.log(
      "POST /api/auth/register: Register attempt with missing email or password",
    );
    return res.status(400).json({
      error: "Bad Request",
      message: "Email and password are required",
    });
  }

  // Check if email already exists
  const existingUser = users.find((u) => u.email === email);

  if (existingUser) {
    console.log(
      `POST /api/auth/register: Register attempt with existing email: ${email}`,
    );
    return res.status(409).json({
      error: "Conflict",
      message: "Email already exists",
    });
  }

  // Create new user
  const newUser = {
    id_uzytkownika: uuidv4(),
    email,
    password,
  };

  users.push(newUser);

  // Return success response
  console.log(`POST /api/auth/register: User registered: ${email}`);
  res.status(201).json({
    user: {
      id_uzytkownika: newUser.id_uzytkownika,
      email: newUser.email,
    },
    token: generateToken(newUser.id_uzytkownika),
  });
};

module.exports = {
  login,
  register,
};
