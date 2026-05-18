import 'package:bike_app/features/map/presentation/widgets/rental_item_card.dart';
import 'package:bike_app/features/rental/domain/entities/rental.dart';
import 'package:bike_app/features/rental/domain/entities/rental_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RentalItemCard', () {
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

    Widget createWidget({
      required Rental rental,
      VoidCallback? onEnd,
      VoidCallback? onUnlock,
      VoidCallback? onReportIssue,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: RentalItemCard(
            rental: rental,
            onEnd: onEnd,
            onUnlock: onUnlock,
            onReportIssue: onReportIssue,
          ),
        ),
      );
    }

    group('active rental', () {
      testWidgets('displays bike ID correctly', (tester) async {
        await tester.pumpWidget(createWidget(rental: tActiveRental));

        expect(find.text('Rower #12345'), findsOneWidget);
      });

      testWidgets('displays Aktywny status badge', (tester) async {
        await tester.pumpWidget(createWidget(rental: tActiveRental));

        expect(find.text('Aktywny'), findsOneWidget);
      });

      testWidgets('displays cost', (tester) async {
        await tester.pumpWidget(createWidget(rental: tActiveRental));

        expect(find.text('15.00 zł'), findsOneWidget);
      });

      testWidgets('displays Zakończ button', (tester) async {
        await tester.pumpWidget(createWidget(rental: tActiveRental));

        expect(find.text('Zakończ'), findsOneWidget);
        expect(find.text('Odblokuj'), findsNothing);
      });

      testWidgets('displays Zgłoś problem button', (tester) async {
        await tester.pumpWidget(createWidget(rental: tActiveRental));

        expect(find.text('Zgłoś problem'), findsOneWidget);
      });

      testWidgets('calls onEnd when Zakończ is tapped', (tester) async {
        var endCalled = false;
        await tester.pumpWidget(
          createWidget(rental: tActiveRental, onEnd: () => endCalled = true),
        );

        await tester.tap(find.text('Zakończ'));
        await tester.pump();

        expect(endCalled, isTrue);
      });

      testWidgets('calls onReportIssue when Zgłoś problem is tapped', (
        tester,
      ) async {
        var reportCalled = false;
        await tester.pumpWidget(
          createWidget(
            rental: tActiveRental,
            onReportIssue: () => reportCalled = true,
          ),
        );

        await tester.tap(find.text('Zgłoś problem'));
        await tester.pump();

        expect(reportCalled, isTrue);
      });
    });

    group('paused rental', () {
      testWidgets('displays Na postoju status badge', (tester) async {
        await tester.pumpWidget(createWidget(rental: tPausedRental));

        expect(find.text('Na postoju'), findsOneWidget);
      });

      testWidgets('displays Odblokuj button instead of Zakończ', (
        tester,
      ) async {
        await tester.pumpWidget(createWidget(rental: tPausedRental));

        expect(find.text('Odblokuj'), findsOneWidget);
        expect(find.text('Zakończ'), findsNothing);
      });

      testWidgets('calls onUnlock when Odblokuj is tapped', (tester) async {
        var unlockCalled = false;
        await tester.pumpWidget(
          createWidget(
            rental: tPausedRental,
            onUnlock: () => unlockCalled = true,
          ),
        );

        await tester.tap(find.text('Odblokuj'));
        await tester.pump();

        expect(unlockCalled, isTrue);
      });
    });

    testWidgets('displays bike icon', (tester) async {
      await tester.pumpWidget(createWidget(rental: tActiveRental));

      expect(find.byIcon(Icons.directions_bike), findsOneWidget);
    });

    testWidgets('displays time icon', (tester) async {
      await tester.pumpWidget(createWidget(rental: tActiveRental));

      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('displays payments icon', (tester) async {
      await tester.pumpWidget(createWidget(rental: tActiveRental));

      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    });
  });
}
