import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/presentation/pages/fault_history_screen.dart';
import '../../features/account/presentation/pages/history_screen.dart';
import '../../features/account/presentation/pages/report_fault_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/map/presentation/pages/map_screen.dart';
import '../../features/options/presentation/pages/options_screen.dart';
import '../../features/rental/presentation/pages/end_rental_screen.dart';
import '../../features/rental/presentation/pages/qr_scan_screen.dart';
import '../../features/rental/presentation/pages/rental_confirmation_screen.dart';
import '../../features/rental/presentation/pages/rental_summary_screen.dart';
import '../../features/rental/presentation/pages/reservation_screen.dart';
import '../../features/rental/presentation/pages/return_options_screen.dart';
import '../../features/wallet/presentation/pages/top_up_screen.dart';
import '../../features/wallet/presentation/pages/wallet_screen.dart';

/// Listenable that reacts to AuthBloc state changes for GoRouter refreshes.
class AuthStateListener extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  AuthStateListener(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Creates the app router with authentication-based navigation guards.
GoRouter createRouter(AuthBloc authBloc) {
  final authStateListener = AuthStateListener(authBloc);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authStateListener,
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isSettingsPage = state.matchedLocation == '/settings';

      // Still loading auth state, don't redirect
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      // Settings page is accessible without authentication
      if (isSettingsPage) {
        return null;
      }

      // Not authenticated, redirect to login (unless already on auth page)
      if (authState is AuthUnauthenticated || authState is AuthError) {
        return isAuthPage ? null : '/login';
      }

      // Authenticated, redirect away from auth pages
      if (authState is AuthAuthenticated) {
        return isAuthPage ? '/' : null;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MapScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/wallet/topup',
        builder: (context, state) => const TopUpScreen(),
      ),
      GoRoute(
        path: '/rental/scan',
        builder: (context, state) => const QRScanScreen(),
      ),
      GoRoute(
        path: '/rental/confirmation/:rentalId/:bikeId',
        builder: (context, state) => RentalConfirmationScreen(
          rentalId: state.pathParameters['rentalId']!,
          bikeId: state.pathParameters['bikeId']!,
        ),
      ),
      GoRoute(
        path: '/rental/summary/:id',
        builder: (context, state) =>
            RentalSummaryScreen(rentalId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/rental/end/:rentalId/:bikeId',
        builder: (context, state) => EndRentalScreen(
          rentalId: state.pathParameters['rentalId']!,
          bikeId: state.pathParameters['bikeId']!,
        ),
      ),
      GoRoute(
        path: '/rental/return-options/:rentalId/:bikeId',
        builder: (context, state) => ReturnOptionsScreen(
          rentalId: state.pathParameters['rentalId']!,
          bikeId: state.pathParameters['bikeId']!,
        ),
      ),
      GoRoute(
        path: '/reservation/:bikeId',
        builder: (context, state) =>
            ReservationScreen(bikeId: state.pathParameters['bikeId']!),
      ),
      GoRoute(
        path: '/fault/report/:bikeId',
        builder: (context, state) =>
            ReportFaultScreen(bikeId: state.pathParameters['bikeId']!),
      ),
      GoRoute(
        path: '/account/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/account/faults',
        builder: (context, state) => const FaultHistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const OptionsScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Page not found'))),
  );
}
