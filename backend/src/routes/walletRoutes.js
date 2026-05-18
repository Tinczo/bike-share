const express = require('express');
const router = express.Router();
const walletController = require('../controllers/walletController');

// GET /api/wallet - Get wallet balance and status
router.get('/', walletController.getWallet);

// GET /api/wallet/transactions - Get transaction history
router.get('/transactions', walletController.getTransactions);

// POST /api/wallet/topup - Top up wallet
router.post('/topup', walletController.topUpWallet);

// GET /api/wallet/payment-methods - Get saved payment methods
router.get('/payment-methods', walletController.getPaymentMethods);

// POST /api/wallet/payment-methods - Add a new payment method
router.post('/payment-methods', walletController.addPaymentMethod);

module.exports = router;
