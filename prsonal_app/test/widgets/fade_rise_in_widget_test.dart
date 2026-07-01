import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/fade_rise_in_widget.dart';

Widget _wrap(Widget child, {bool disableAnimations = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Scaffold(body: child),
  ),
);

void main() {
  group('FadeRiseIn', () {
    testWidgets('AC-001: Widget renders its child', (tester) async {
      await tester.pumpWidget(_wrap(const FadeRiseIn(child: Text('Hello'))));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets(
      'AC-002: On mount, the child animates from 0 opacity / +8dp offset to 1 '
      'opacity / 0dp offset over AppDurations.normal when motion is not reduced',
      (tester) async {
        await tester.pumpWidget(_wrap(const FadeRiseIn(child: Text('Hello'))));
        final opacityAt0 = tester
            .widget<Opacity>(find.byKey(const ValueKey('fadeRiseInOpacity')))
            .opacity;
        final offsetAt0 = tester
            .widget<Transform>(find.byKey(const ValueKey('fadeRiseInOffset')))
            .transform
            .getTranslation()
            .y;
        expect(opacityAt0, 0.0);
        expect(offsetAt0, 8.0);

        await tester.pumpAndSettle();
        final opacityAtEnd = tester
            .widget<Opacity>(find.byKey(const ValueKey('fadeRiseInOpacity')))
            .opacity;
        final offsetAtEnd = tester
            .widget<Transform>(find.byKey(const ValueKey('fadeRiseInOffset')))
            .transform
            .getTranslation()
            .y;
        expect(opacityAtEnd, 1.0);
        expect(offsetAtEnd, 0.0);
      },
    );

    testWidgets(
      'AC-003: Widget renders the child immediately at full opacity and no '
      'offset when MediaQuery.disableAnimations is true',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const FadeRiseIn(child: Text('Hello')),
            disableAnimations: true,
          ),
        );
        expect(find.byKey(const ValueKey('fadeRiseInOpacity')), findsNothing);
        expect(find.byKey(const ValueKey('fadeRiseInOffset')), findsNothing);
        expect(find.text('Hello'), findsOneWidget);
      },
    );
  });
}
