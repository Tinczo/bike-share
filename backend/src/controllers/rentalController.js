const { v4: uuidv4 } = require("uuid");
const rentals = require("../models/rentalModel");
const reservations = require("../models/reservationModel");
const bikes = require("../models/bikeModel");
const wallets = require("../models/walletModel");

// Demo user ID
const DEMO_USER_ID = "1";

// Rental cost per minute in PLN
const COST_PER_MINUTE = 0.5;

const checkEligibility = (req, res) => {
  const wallet = wallets.find((w) => w.id_uzytkownika === DEMO_USER_ID);

  // Check for active rental
  const activeRental = rentals.find(
    (r) => r.id_uzytkownika === DEMO_USER_ID && r.status === "ACTIVE",
  );

  if (activeRental) {
    console.log("GET /api/rental/eligibility: User has active rental");
    return res.status(200).json({
      uprawniony: false,
      powod: "You already have an active rental",
    });
  }

  // Check wallet balance
  if (!wallet || wallet.saldo < 5) {
    console.log("GET /api/rental/eligibility: Insufficient funds");
    return res.status(200).json({
      uprawniony: false,
      powod: "Brak środków. Wymagane minimum 5 PLN.",
    });
  }

  // Check if wallet has card attached
  if (!wallet.ma_podpieta_karte) {
    console.log("GET /api/rental/eligibility: No payment method");
    return res.status(200).json({
      uprawniony: false,
      powod: "Please add a payment method to your account.",
    });
  }

  console.log("GET /api/rental/eligibility: User is eligible");
  res.status(200).json({
    uprawniony: true,
    powod: null,
  });
};

const startRental = (req, res) => {
  const { bikeId, method } = req.body;

  if (!bikeId) {
    return res.status(400).json({
      error: "Bad Request",
      message: "Bike ID is required",
    });
  }

  // Find bike
  const bike = bikes.find((b) => b.id_roweru === bikeId || b.kod_qr === bikeId);

  if (!bike) {
    return res.status(404).json({
      error: "Not Found",
      message: "Bike not found",
    });
  }

  // Check if bike is available
  if (bike.status !== "AVAILABLE" && bike.status !== "RESERVED") {
    console.log(`POST /api/rental/start: Bike ${bikeId} is not available`);
    return res.status(409).json({
      error: "Conflict",
      message: "Bike is not available for rental",
    });
  }

  // Check eligibility
  const wallet = wallets.find((w) => w.id_uzytkownika === DEMO_USER_ID);
  if (!wallet || wallet.saldo < 5) {
    return res.status(402).json({
      error: "Payment Required",
      message: "Insufficient funds",
    });
  }

  // Cancel any existing reservation for this bike
  const existingRes = reservations.find(
    (r) => r.id_roweru === bike.id_roweru && r.status === "ACTIVE",
  );
  if (existingRes) {
    existingRes.status = "CONVERTED";
  }

  // Create rental
  const newRental = {
    id_wypozyczenia: `rental_${uuidv4().slice(0, 8)}`,
    id_uzytkownika: DEMO_USER_ID,
    id_roweru: bike.id_roweru,
    status: "ACTIVE",
    data_rozpoczecia: new Date().toISOString(),
    data_zakonczenia: null,
    koszt_calkowity: null,
    metoda_uruchomienia: method || "QR",
    czas_pauzy_sekundy: 0,
  };

  rentals.push(newRental);

  // Update bike status
  bike.status = "RENTED";

  console.log(
    `POST /api/rental/start: Rental started for bike ${bike.id_roweru}`,
  );
  res.status(201).json({
    rental: {
      id_wypozyczenia: newRental.id_wypozyczenia,
      id_uzytkownika: newRental.id_uzytkownika,
      id_roweru: newRental.id_roweru,
      status: newRental.status,
      data_rozpoczecia: newRental.data_rozpoczecia,
      metoda_uruchomienia: newRental.metoda_uruchomienia,
      koszt_calkowity: newRental.koszt_calkowity,
    },
  });
};

const pauseRental = (req, res) => {
  const { rentalId } = req.params;

  const rental = rentals.find(
    (r) => r.id_wypozyczenia === rentalId && r.id_uzytkownika === DEMO_USER_ID,
  );

  if (!rental) {
    return res.status(404).json({
      error: "Not Found",
      message: "Rental not found",
    });
  }

  if (rental.status !== "ACTIVE") {
    return res.status(400).json({
      error: "Bad Request",
      message: "Only active rentals can be paused",
    });
  }

  rental.status = "PAUSED";

  console.log(`POST /api/rental/${rentalId}/pause: Rental paused`);
  res.status(200).json({
    rental: {
      id_wypozyczenia: rental.id_wypozyczenia,
      id_uzytkownika: rental.id_uzytkownika,
      id_roweru: rental.id_roweru,
      status: rental.status,
      data_rozpoczecia: rental.data_rozpoczecia,
      koszt_calkowity: rental.koszt_calkowity,
    },
  });
};

const resumeRental = (req, res) => {
  const { rentalId } = req.params;

  const rental = rentals.find(
    (r) => r.id_wypozyczenia === rentalId && r.id_uzytkownika === DEMO_USER_ID,
  );

  if (!rental) {
    return res.status(404).json({
      error: "Not Found",
      message: "Rental not found",
    });
  }

  if (rental.status !== "PAUSED") {
    return res.status(400).json({
      error: "Bad Request",
      message: "Only paused rentals can be resumed",
    });
  }

  rental.status = "ACTIVE";

  console.log(`POST /api/rental/${rentalId}/resume: Rental resumed`);
  res.status(200).json({
    rental: {
      id_wypozyczenia: rental.id_wypozyczenia,
      id_uzytkownika: rental.id_uzytkownika,
      id_roweru: rental.id_roweru,
      status: rental.status,
      data_rozpoczecia: rental.data_rozpoczecia,
      koszt_calkowity: rental.koszt_calkowity,
    },
  });
};

const endRental = (req, res) => {
  const { rentalId } = req.params;

  const rental = rentals.find(
    (r) => r.id_wypozyczenia === rentalId && r.id_uzytkownika === DEMO_USER_ID,
  );

  if (!rental) {
    return res.status(404).json({
      error: "Not Found",
      message: "Rental not found",
    });
  }

  if (rental.status === "FINISHED") {
    return res.status(400).json({
      error: "Bad Request",
      message: "Rental is already finished",
    });
  }

  // Calculate cost
  const startTime = new Date(rental.data_rozpoczecia);
  const endTime = new Date();
  const durationMinutes = Math.ceil((endTime - startTime) / 60000);
  const totalCost = durationMinutes * COST_PER_MINUTE;

  rental.status = "FINISHED";
  rental.data_zakonczenia = endTime.toISOString();
  rental.koszt_calkowity = totalCost;

  // Update bike status
  const bike = bikes.find((b) => b.id_roweru === rental.id_roweru);
  if (bike) {
    bike.status = "AVAILABLE";
  }

  // Deduct from wallet
  const wallet = wallets.find((w) => w.id_uzytkownika === DEMO_USER_ID);
  if (wallet) {
    wallet.saldo -= totalCost;
  }

  console.log(
    `POST /api/rental/${rentalId}/end: Rental ended, cost: ${totalCost} PLN`,
  );
  res.status(200).json({
    rental: {
      id_wypozyczenia: rental.id_wypozyczenia,
      id_roweru: rental.id_roweru,
      status: rental.status,
      data_rozpoczecia: rental.data_rozpoczecia,
      data_zakonczenia: rental.data_zakonczenia,
      koszt_calkowity: rental.koszt_calkowity,
    },
  });
};

const getActiveRental = (req, res) => {
  const activeRental = rentals.find(
    (r) =>
      r.id_uzytkownika === DEMO_USER_ID &&
      (r.status === "ACTIVE" || r.status === "PAUSED"),
  );

  if (!activeRental) {
    console.log("GET /api/rental/active: No active rental");
    return res.status(404).json({
      error: "Not Found",
      message: "No active rental",
    });
  }

  console.log("GET /api/rental/active: Active rental found");
  res.status(200).json({
    rental: {
      id_wypozyczenia: activeRental.id_wypozyczenia,
      id_uzytkownika: activeRental.id_uzytkownika,
      id_roweru: activeRental.id_roweru,
      status: activeRental.status,
      data_rozpoczecia: activeRental.data_rozpoczecia,
      metoda_uruchomienia: activeRental.metoda_uruchomienia,
      czas_pauzy_sekundy: activeRental.czas_pauzy_sekundy,
      koszt_calkowity: activeRental.koszt_calkowity,
    },
  });
};

const createReservation = (req, res) => {
  const { bikeId } = req.body;

  if (!bikeId) {
    return res.status(400).json({
      error: "Bad Request",
      message: "Bike ID is required",
    });
  }

  // Find bike
  const bike = bikes.find((b) => b.id_roweru === bikeId);

  if (!bike) {
    return res.status(404).json({
      error: "Not Found",
      message: "Bike not found",
    });
  }

  if (bike.status !== "AVAILABLE") {
    return res.status(409).json({
      error: "Conflict",
      message: "Bike is not available for reservation",
    });
  }

  // Check for existing reservation
  const existingRes = reservations.find(
    (r) => r.id_uzytkownika === DEMO_USER_ID && r.status === "ACTIVE",
  );

  if (existingRes) {
    return res.status(409).json({
      error: "Conflict",
      message: "You already have an active reservation",
    });
  }

  const now = new Date();
  const expiresAt = new Date(now.getTime() + 15 * 60 * 1000); // 15 minutes

  const newReservation = {
    id_rezerwacji: `res_${uuidv4().slice(0, 8)}`,
    id_uzytkownika: DEMO_USER_ID,
    id_roweru: bikeId,
    status: "ACTIVE",
    data_utworzenia: now.toISOString(),
    data_wygasniecia: expiresAt.toISOString(),
  };

  reservations.push(newReservation);

  // Update bike status
  bike.status = "RESERVED";

  console.log(
    `POST /api/rental/reservation: Reservation created for bike ${bikeId}`,
  );
  res.status(201).json({
    reservation: {
      id_rezerwacji: newReservation.id_rezerwacji,
      id_uzytkownika: newReservation.id_uzytkownika,
      id_roweru: newReservation.id_roweru,
      status: newReservation.status,
      data_utworzenia: newReservation.data_utworzenia,
      data_wygasniecia: newReservation.data_wygasniecia,
    },
  });
};

const cancelReservation = (req, res) => {
  const { reservationId } = req.params;

  const reservation = reservations.find(
    (r) =>
      r.id_rezerwacji === reservationId && r.id_uzytkownika === DEMO_USER_ID,
  );

  if (!reservation) {
    return res.status(404).json({
      error: "Not Found",
      message: "Reservation not found",
    });
  }

  if (reservation.status !== "ACTIVE") {
    return res.status(400).json({
      error: "Bad Request",
      message: "Reservation is not active",
    });
  }

  reservation.status = "CANCELLED";

  // Update bike status
  const bike = bikes.find((b) => b.id_roweru === reservation.id_roweru);
  if (bike) {
    bike.status = "AVAILABLE";
  }

  console.log(`DELETE /api/rental/reservation/${reservationId}: Cancelled`);
  res.status(200).json({
    success: true,
  });
};

const getActiveReservation = (req, res) => {
  const activeReservation = reservations.find(
    (r) => r.id_uzytkownika === DEMO_USER_ID && r.status === "ACTIVE",
  );

  if (!activeReservation) {
    return res.status(404).json({
      error: "Not Found",
      message: "No active reservation",
    });
  }

  // Check if expired
  if (new Date(activeReservation.data_wygasniecia) < new Date()) {
    activeReservation.status = "EXPIRED";
    const bike = bikes.find((b) => b.id_roweru === activeReservation.id_roweru);
    if (bike) {
      bike.status = "AVAILABLE";
    }
    return res.status(404).json({
      error: "Not Found",
      message: "Reservation has expired",
    });
  }

  console.log("GET /api/rental/reservation/active: Active reservation found");
  res.status(200).json({
    reservation: {
      id_rezerwacji: activeReservation.id_rezerwacji,
      id_uzytkownika: activeReservation.id_uzytkownika,
      id_roweru: activeReservation.id_roweru,
      status: activeReservation.status,
      data_utworzenia: activeReservation.data_utworzenia,
      data_wygasniecia: activeReservation.data_wygasniecia,
    },
  });
};

module.exports = {
  checkEligibility,
  startRental,
  pauseRental,
  resumeRental,
  endRental,
  getActiveRental,
  createReservation,
  cancelReservation,
  getActiveReservation,
};
