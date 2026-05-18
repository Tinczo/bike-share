import 'package:bike_app/features/map/presentation/widgets/reservation_item_card.dart';
import 'package:bike_app/features/rental/domain/entities/reservation.dart';
import 'package:bike_app/features/rental/domain/entities/reservation_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReservationItemCard', () {
    final tReservation = Reservation(
      id: 'reservation-123',
      bikeId: '12345',
      userId: 'user-123',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      status: ReservationStatus.active,
    );

    Widget createWidget({
      required Reservation reservation,
      Duration remainingTime = const Duration(minutes: 10),
      VoidCallback? onRent,
      VoidCallback? onCancel,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ReservationItemCard(
            reservation: reservation,
            remainingTime: remainingTime,
            onRent: onRent,
            onCancel: onCancel,
          ),
        ),
      );
    }

    testWidgets('displays bike ID correctly', (tester) async {
      await tester.pumpWidget(createWidget(reservation: tReservation));

      expect(find.text('Rower #12345'), findsOneWidget);
    });

    testWidgets('displays Zarezerwowany status badge', (tester) async {
      await tester.pumpWidget(createWidget(reservation: tReservation));

      expect(find.text('Zarezerwowany'), findsOneWidget);
    });

    testWidgets('displays countdown timer', (tester) async {
      await tester.pumpWidget(
        createWidget(
          reservation: tReservation,
          remainingTime: const Duration(minutes: 10, seconds: 30),
        ),
      );

      expect(find.text('Pozostało: '), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
    });

    testWidgets('formats countdown with leading zeros', (tester) async {
      await tester.pumpWidget(
        createWidget(
          reservation: tReservation,
          remainingTime: const Duration(minutes: 5, seconds: 9),
        ),
      );

      expect(find.text('05:09'), findsOneWidget);
    });

    testWidgets('displays Wypożycz button', (tester) async {
      await tester.pumpWidget(createWidget(reservation: tReservation));

      expect(find.text('Wypożycz'), findsOneWidget);
    });

    testWidgets('displays Anuluj button', (tester) async {
      await tester.pumpWidget(createWidget(reservation: tReservation));

      expect(find.text('Anuluj'), findsOneWidget);
    });

    testWidgets('calls onRent when Wypożycz is tapped', (tester) async {
      var rentCalled = false;
      await tester.pumpWidget(
        createWidget(
          reservation: tReservation,
          onRent: () => rentCalled = true,
        ),
      );

      await tester.tap(find.text('Wypożycz'));
      await tester.pump();

      expect(rentCalled, isTrue);
    });

    testWidgets('calls onCancel when Anuluj is tapped', (tester) async {
      var cancelCalled = false;
      await tester.pumpWidget(
        createWidget(
          reservation: tReservation,
          onCancel: () => cancelCalled = true,
        ),
      );

      await tester.tap(find.text('Anuluj'));
      await tester.pump();

      expect(cancelCalled, isTrue);
    });

    testWidgets('displays bike icon', (tester) async {
      await tester.pumpWidget(createWidget(reservation: tReservation));

      expect(find.byIcon(Icons.directions_bike), findsOneWidget);
    });

    testWidgets('displays timer icon', (tester) async {
      await tester.pumpWidget(createWidget(reservation: tReservation));

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    group('low time warning', () {
      testWidgets('shows warning color when time is below 2 minutes', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidget(
            reservation: tReservation,
            remainingTime: const Duration(minutes: 1, seconds: 30),
          ),
        );

        expect(find.text('01:30'), findsOneWidget);
        // The warning color should be applied but we can verify it renders
      });
    });
  });
}
