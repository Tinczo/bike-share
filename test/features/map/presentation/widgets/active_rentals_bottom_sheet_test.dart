import 'package:bike_app/features/map/presentation/widgets/active_rentals_bottom_sheet.dart';
import 'package:bike_app/features/rental/domain/entities/rental.dart';
import 'package:bike_app/features/rental/domain/entities/rental_status.dart';
import 'package:bike_app/features/rental/domain/entities/reservation.dart';
import 'package:bike_app/features/rental/domain/entities/reservation_status.dart';
import 'package:bike_app/features/rental/presentation/bloc/rental_bloc.dart';
import 'package:bike_app/features/rental/presentation/bloc/reservation_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockRentalBloc extends MockBloc<RentalEvent, RentalState>
    implements RentalBloc {}

class MockReservationBloc extends MockBloc<ReservationEvent, ReservationState>
    implements ReservationBloc {}

void main() {
  group('ActiveRentalsBottomSheet', () {
    late MockRentalBloc mockRentalBloc;
    late MockReservationBloc mockReservationBloc;
    late GoRouter router;

    final tActiveRental = Rental(
      id: 'rental-123',
      bikeId: '12345',
      userId: 'user-123',
      startTime: DateTime.now().subtract(const Duration(minutes: 30)),
      cost: 15.0,
      status: RentalStatus.active,
    );

    final tPausedRental = Rental(
      id: 'rental-456',
      bikeId: '67890',
      userId: 'user-123',
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      cost: 25.5,
      status: RentalStatus.paused,
    );

    final tReservation = Reservation(
      id: 'reservation-123',
      bikeId: '11111',
      userId: 'user-123',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      status: ReservationStatus.active,
    );

    setUp(() {
      mockRentalBloc = MockRentalBloc();
      mockReservationBloc = MockReservationBloc();

      router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Stack(children: const [ActiveRentalsBottomSheet()]),
            ),
          ),
          GoRoute(
            path: '/rental/scan',
            builder: (context, state) =>
                const Scaffold(body: Text('Scan Screen')),
          ),
        ],
      );
    });

    Widget createWidget() {
      return MultiBlocProvider(
        providers: [
          BlocProvider<RentalBloc>.value(value: mockRentalBloc),
          BlocProvider<ReservationBloc>.value(value: mockReservationBloc),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    group('when no rental or reservation', () {
      setUp(() {
        when(() => mockRentalBloc.state).thenReturn(const RentalInitial());
        when(
          () => mockReservationBloc.state,
        ).thenReturn(const ReservationInitial());
      });

      testWidgets('shows only QR scan button', (tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.text('Skanuj QR, aby wypożyczyć'), findsOneWidget);
        expect(find.text('Aktywne wypożyczenia'), findsNothing);
      });

      testWidgets('does not show header row', (tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
        expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
      });
    });

    group('when has active rental', () {
      setUp(() {
        when(
          () => mockRentalBloc.state,
        ).thenReturn(RentalActive(tActiveRental));
        when(
          () => mockReservationBloc.state,
        ).thenReturn(const ReservationInitial());
      });

      testWidgets('shows QR scan button and header row', (tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.text('Skanuj QR, aby wypożyczyć'), findsOneWidget);
        expect(find.text('Aktywne wypożyczenia'), findsOneWidget);
        expect(find.text('1 rower'), findsOneWidget);
      });

      testWidgets('shows chevron up icon when collapsed', (tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      });
    });

    group('when has paused rental', () {
      setUp(() {
        when(
          () => mockRentalBloc.state,
        ).thenReturn(RentalPaused(tPausedRental));
        when(
          () => mockReservationBloc.state,
        ).thenReturn(const ReservationInitial());
      });

      testWidgets('shows Na postoju status when expanded', (tester) async {
        await tester.pumpWidget(createWidget());

        await tester.tap(find.text('Aktywne wypożyczenia'));
        await tester.pump();

        expect(find.text('Na postoju'), findsOneWidget);
        expect(find.text('Odblokuj'), findsOneWidget);
      });
    });

    group('when has active reservation', () {
      setUp(() {
        when(() => mockRentalBloc.state).thenReturn(const RentalInitial());
        when(() => mockReservationBloc.state).thenReturn(
          ReservationActiveState(
            reservation: tReservation,
            remainingTime: const Duration(minutes: 10),
          ),
        );
      });

      testWidgets('shows header with count', (tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.text('Aktywne wypożyczenia'), findsOneWidget);
        expect(find.text('1 rower'), findsOneWidget);
      });

      testWidgets('shows reservation card when expanded', (tester) async {
        await tester.pumpWidget(createWidget());

        await tester.tap(find.text('Aktywne wypożyczenia'));
        await tester.pump();

        expect(find.text('Rower #11111'), findsOneWidget);
        expect(find.text('Zarezerwowany'), findsOneWidget);
        expect(find.text('Wypożycz'), findsOneWidget);
        expect(find.text('Anuluj'), findsOneWidget);
      });
    });

    group('when has both rental and reservation', () {
      setUp(() {
        when(
          () => mockRentalBloc.state,
        ).thenReturn(RentalActive(tActiveRental));
        when(() => mockReservationBloc.state).thenReturn(
          ReservationActiveState(
            reservation: tReservation,
            remainingTime: const Duration(minutes: 10),
          ),
        );
      });

      testWidgets('shows count of 2', (tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.text('2 rowery'), findsOneWidget);
      });

      testWidgets('shows both cards when expanded', (tester) async {
        await tester.pumpWidget(createWidget());

        await tester.tap(find.text('Aktywne wypożyczenia'));
        await tester.pump();

        expect(find.text('Rower #12345'), findsOneWidget);
        expect(find.text('Rower #11111'), findsOneWidget);
      });
    });

    group('QR button navigation', () {
      setUp(() {
        when(() => mockRentalBloc.state).thenReturn(const RentalInitial());
        when(
          () => mockReservationBloc.state,
        ).thenReturn(const ReservationInitial());
      });

      testWidgets('navigates to scan screen when tapped', (tester) async {
        await tester.pumpWidget(createWidget());

        await tester.tap(find.text('Skanuj QR, aby wypożyczyć'));
        await tester.pumpAndSettle();

        expect(find.text('Scan Screen'), findsOneWidget);
      });
    });
  });
}
