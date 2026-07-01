import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/widgets/brand_title.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BrandTitle', () {
    testWidgets('AC-001: Widget renders the page title', (tester) async {
      await tester.pumpWidget(_wrap(const BrandTitle('History')));
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets(
      'AC-002: Widget renders the "sonal" portion of the wordmark in the accent colour',
      (tester) async {
        await tester.pumpWidget(_wrap(const BrandTitle('History')));
        final wordmark = tester
            .widgetList<Text>(find.byType(Text))
            .firstWhere((t) => t.semanticsLabel == 'PRsonal');
        final sonalSpan =
            (wordmark.textSpan as TextSpan).children!.last as TextSpan;
        expect(sonalSpan.text, 'sonal');
        expect(sonalSpan.style!.color, AppColors.dark.accent);
      },
    );
  });
}
