import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/history_card_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('HistoryCard', () {
    testWidgets('AC-001: Widget renders the routine name, date and meta line', (tester) async {
      await tester.pumpWidget(_wrap(HistoryCard(
        routineName: 'Push Day A',
        dateLabel: 'Mon, 23 Jun',
        metaLabel: '47m · 4,230 kg',
        onTap: () {},
        onDelete: () {},
      )));
      expect(find.text('Push Day A'), findsOneWidget);
      expect(find.text('Mon, 23 Jun'), findsOneWidget);
      expect(find.text('47m · 4,230 kg'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders an "Abandoned" label when abandoned is true',
        (tester) async {
      await tester.pumpWidget(_wrap(HistoryCard(
        routineName: 'Push Day A',
        dateLabel: 'Mon, 23 Jun',
        metaLabel: '22m · 0 kg',
        abandoned: true,
        onTap: () {},
        onDelete: () {},
      )));
      expect(find.textContaining('Abandoned'), findsOneWidget);
    });

    testWidgets('AC-003: Widget calls onTap when the card body is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(HistoryCard(
        routineName: 'Push Day A',
        dateLabel: 'Mon, 23 Jun',
        metaLabel: '47m · 4,230 kg',
        onTap: () => tapped = true,
        onDelete: () {},
      )));
      await tester.tap(find.text('Push Day A'));
      expect(tapped, isTrue);
    });

    testWidgets('AC-004: Widget calls onDelete when the delete button is tapped',
        (tester) async {
      var deleted = false;
      await tester.pumpWidget(_wrap(HistoryCard(
        routineName: 'Push Day A',
        dateLabel: 'Mon, 23 Jun',
        metaLabel: '47m · 4,230 kg',
        onTap: () {},
        onDelete: () => deleted = true,
      )));
      await tester.tap(find.bySemanticsLabel('Delete workout'));
      expect(deleted, isTrue);
    });
  });
}
