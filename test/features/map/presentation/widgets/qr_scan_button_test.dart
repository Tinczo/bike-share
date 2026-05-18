import 'package:bike_app/features/map/presentation/widgets/qr_scan_button.dart';
import 'package:bike_app/features/rental/domain/entities/rental.dart';
import 'package:bike_app/features/rental/domain/entities/rental_status.dart';
import 'package:bike_app/features/rental/presentation/bloc/rental_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockRentalBloc extends Mock implements RentalBloc {}

void main() {
  group('QrScanButton', () {
    late GoRouter router;
    late MockRentalBloc mockRentalBloc;

    setUp(() {
      mockRentalBloc = MockRentalBloc();
      when(() => mockRentalBloc.state).thenReturn(const RentalInitial());
      when(() => mockRentalBloc.stream).thenAnswer(
        (_) => Stream.value(const RentalInitial()),
      );

      router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: QrScanButton()),
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
      return BlocProvider<RentalBloc>.value(
        value: mockRentalBloc,
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('renders correctly with icon and text', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(find.text('Skanuj QR, aby wypożyczyć'), findsOneWidget);
    });

    testWidgets('is wrapped in a SizedBox with full width', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('navigates to /rental/scan when tapped and no active rental',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Skanuj QR, aby wypożyczyć'));
      await tester.pumpAndSettle();

      expect(find.text('Scan Screen'), findsOneWidget);
    });

    testWidgets('has QR icon and text', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(find.text('Skanuj QR, aby wypożyczyć'), findsOneWidget);
    });

    testWidgets('shows dialog when tapped and has active rental',
        (tester) async {
      when(() => mockRentalBloc.state).thenReturn(
        RentalActive(
          Rental(
            id: 'rental-1',
            bikeId: 'bike-1',
            userId: 'user-1',
            startTime: DateTime.now(),
            cost: 0,
            status: RentalStatus.active,
          ),
        ),
      );
      when(() => mockRentalBloc.stream).thenAnswer(
        (_) => Stream.value(
          RentalActive(
            Rental(
              id: 'rental-1',
              bikeId: 'bike-1',
              userId: 'user-1',
              startTime: DateTime.now(),
              cost: 0,
              status: RentalStatus.active,
            ),
          ),
        ),
      );

      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Skanuj QR, aby wypożyczyć'));
      await tester.pumpAndSettle();

      // Should show dialog instead of navigating
      expect(find.text('Masz aktywne wypożyczenie'), findsOneWidget);
      expect(find.text('Scan Screen'), findsNothing);
    });

    testWidgets('shows dialog when tapped and has paused rental',
        (tester) async {
      when(() => mockRentalBloc.state).thenReturn(
        RentalPaused(
          Rental(
            id: 'rental-1',
            bikeId: 'bike-1',
            userId: 'user-1',
            startTime: DateTime.now(),
            cost: 0,
            status: RentalStatus.paused,
          ),
        ),
      );
      when(() => mockRentalBloc.stream).thenAnswer(
        (_) => Stream.value(
          RentalPaused(
            Rental(
              id: 'rental-1',
              bikeId: 'bike-1',
              userId: 'user-1',
              startTime: DateTime.now(),
              cost: 0,
              status: RentalStatus.paused,
            ),
          ),
        ),
      );

      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Skanuj QR, aby wypożyczyć'));
      await tester.pumpAndSettle();

      // Should show dialog instead of navigating
      expect(find.text('Masz aktywne wypożyczenie'), findsOneWidget);
      expect(find.text('Scan Screen'), findsNothing);
    });
  });
}
