const { v4: uuidv4 } = require('uuid');
const wallets = require('../models/walletModel');
const transactions = require('../models/transactionModel');
const paymentMethods = require('../models/paymentMethodModel');

// For demo purposes, we use a hardcoded user ID
// In a real app, this would come from authentication middleware
const DEMO_USER_ID = '1';

const getWallet = (req, res) => {
  const wallet = wallets.find((w) => w.id_uzytkownika === DEMO_USER_ID);

  if (!wallet) {
    console.log(`GET /api/wallet: Wallet not found for user ${DEMO_USER_ID}`);
    return res.status(404).json({
      error: 'Not Found',
      message: 'Wallet not found',
    });
  }

  console.log(`GET /api/wallet: Wallet retrieved for user ${DEMO_USER_ID}`);
  res.status(200).json({
    wallet: {
      saldo: wallet.saldo,
      status: wallet.status,
      ma_podpieta_karte: wallet.ma_podpieta_karte,
    },
  });
};

const getTransactions = (req, res) => {
  const userTransactions = transactions
    .filter((t) => t.id_uzytkownika === DEMO_USER_ID)
    .sort((a, b) => new Date(b.czas_rejestracji) - new Date(a.czas_rejestracji));

  console.log(
    `GET /api/wallet/transactions: Found ${userTransactions.length} transactions`,
  );
  res.status(200).json({
    transactions: userTransactions.map((t) => ({
      id_transakcji: t.id_transakcji,
      kwota: t.kwota,
      typ: t.typ,
      czas_rejestracji: t.czas_rejestracji,
      opis: t.opis,
    })),
  });
};

const topUpWallet = (req, res) => {
  const { amount, method } = req.body;

  if (!amount || amount <= 0) {
    console.log('POST /api/wallet/topup: Invalid amount');
    return res.status(400).json({
      error: 'Bad Request',
      message: 'Amount must be a positive number',
    });
  }

  if (!method) {
    console.log('POST /api/wallet/topup: Missing payment method');
    return res.status(400).json({
      error: 'Bad Request',
      message: 'Payment method is required',
    });
  }

  const wallet = wallets.find((w) => w.id_uzytkownika === DEMO_USER_ID);

  if (!wallet) {
    return res.status(404).json({
      error: 'Not Found',
      message: 'Wallet not found',
    });
  }

  // Update balance
  wallet.saldo += amount;

  // Update status if balance is now positive
  if (wallet.saldo >= 0 && wallet.status === 'DEBT') {
    wallet.status = 'ACTIVE';
  }

  // Create transaction record
  const newTransaction = {
    id_transakcji: `trans_${uuidv4().slice(0, 8)}`,
    id_uzytkownika: DEMO_USER_ID,
    kwota: amount,
    typ: 'TOP_UP',
    czas_rejestracji: new Date().toISOString(),
    opis: `Doładowanie przez ${method.toUpperCase()}`,
  };

  transactions.push(newTransaction);

  console.log(
    `POST /api/wallet/topup: Wallet topped up by ${amount} via ${method}`,
  );
  res.status(200).json({
    success: true,
    newBalance: wallet.saldo,
    transaction: {
      id_transakcji: newTransaction.id_transakcji,
      kwota: newTransaction.kwota,
      typ: newTransaction.typ,
      czas_rejestracji: newTransaction.czas_rejestracji,
      opis: newTransaction.opis,
    },
  });
};

const getPaymentMethods = (req, res) => {
  const userMethods = paymentMethods.filter(
    (m) => m.id_uzytkownika === DEMO_USER_ID,
  );

  console.log(
    `GET /api/wallet/payment-methods: Found ${userMethods.length} payment methods`,
  );
  res.status(200).json({
    methods: userMethods.map((m) => ({
      id_metody: m.id_metody,
      typ: m.typ,
      ostatnie_cztery: m.ostatnie_cztery,
      marka_karty: m.marka_karty,
    })),
  });
};

const addPaymentMethod = (req, res) => {
  const { type, lastFourDigits, cardBrand } = req.body;

  if (!type) {
    console.log('POST /api/wallet/payment-methods: Missing type');
    return res.status(400).json({
      error: 'Bad Request',
      message: 'Payment method type is required',
    });
  }

  const newMethod = {
    id_metody: `pm_${uuidv4().slice(0, 8)}`,
    id_uzytkownika: DEMO_USER_ID,
    typ: type.toUpperCase(),
    ostatnie_cztery: lastFourDigits || null,
    marka_karty: cardBrand || null,
  };

  paymentMethods.push(newMethod);

  // Update wallet to show it has a card if adding a card
  if (type.toUpperCase() === 'CARD') {
    const wallet = wallets.find((w) => w.id_uzytkownika === DEMO_USER_ID);
    if (wallet) {
      wallet.ma_podpieta_karte = true;
    }
  }

  console.log(`POST /api/wallet/payment-methods: Added ${type} payment method`);
  res.status(201).json({
    success: true,
    method: {
      id_metody: newMethod.id_metody,
      typ: newMethod.typ,
      ostatnie_cztery: newMethod.ostatnie_cztery,
      marka_karty: newMethod.marka_karty,
    },
  });
};

module.exports = {
  getWallet,
  getTransactions,
  topUpWallet,
  getPaymentMethods,
  addPaymentMethod,
};
