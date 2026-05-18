# M5: Payment & Wallet Feature

**Goal:** Manage user balance and payment methods.
**Ref:** `docs/02_requirements_functional.md` (3.10, 3.11, 3.13)

- [x] **Domain Layer**
  - [x] Entity: `Wallet` (`lib/features/wallet/domain/entities/wallet.dart`).
    - Fields: `balance` (double), `status` (Enum: `ACTIVE`, `DEBT`, `INACTIVE`), `hasCard` (bool).
    - Ref: `konta_uzytkownikow` table.
  - [x] Entity: `Transaction` (`lib/features/wallet/domain/entities/transaction.dart`).
    - Fields: `id` (String), `amount` (double), `type` (Enum: `TOP_UP`, `FEE`, `REWARD`, `PENALTY`), `date` (DateTime), `description`.
    - Ref: `transakcje` table.
  - [x] Entity: `PaymentMethod`.
  - [x] Repository Contract: `WalletRepository`.
    - Methods: `getWallet()`, `topUpWallet(double amount, String method)`, `getTransactions()`, `getPaymentMethods()`, `addPaymentMethod()`.
  - [x] UseCase: `GetWallet`.
  - [x] UseCase: `GetTransactions`.
  - [x] UseCase: `TopUpWallet`.
  - [x] UseCase: `GetPaymentMethods`.
  - [x] UseCase: `AddPaymentMethod`.
  - [x] Unit Tests (19 tests).

- [x] **Data Layer**
  - [x] Model: `WalletModel` (extends `Wallet`).
  - [x] Model: `TransactionModel` (extends `Transaction`).
  - [x] Model: `PaymentMethodModel` (extends `PaymentMethod`).
  - [x] DataSource: `WalletRemoteDataSource`.
    - `GET /wallet`.
    - `POST /wallet/topup`.
    - `GET /wallet/transactions`.
    - `GET /wallet/payment-methods`.
    - `POST /wallet/payment-methods`.
  - [x] Repository Impl: `WalletRepositoryImpl`.
  - [x] Unit Tests (44 tests).
  - [x] Implement mocked endpoints in `backend/`

- [x] **Presentation Layer**
  - [x] Bloc: `WalletBloc`.
  - [x] Screen: `WalletScreen` (Balance, Transactions). Link to figma in `docs/05_ui_ux.md`:
        https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-414&m=dev

  - [x] Screen: `TopUpScreen`. Link to figma in `docs/05_ui_ux.md`:
        https://www.figma.com/design/AervH3KqGXST3aczy8EEmc/studia?node-id=1-555&m=dev
  - [x] Bloc Tests (8 tests).
  - [x] Widgets: `WalletBalanceCard`, `DebtCard`, `PaymentMethodTile`, `TransactionTile`, `AmountSelectionGrid`, `PaymentMethodSelector`.
  - [x] Routes: `/wallet`, `/wallet/topup`.
  - [x] Navigation from MapDrawer.
