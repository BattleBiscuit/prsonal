import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/widgets/live_dot_widget.dart';

Widget _wrap(Widget child, {bool disableAnimations = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Scaffold(body: child),
  ),
);

void main() {
  group('LiveDot', () {
    testWidgets(
      'AC-001: Widget renders an accent-coloured circular dot of the given size',
      (tester) async {
        await tester.pumpWidget(_wrap(const LiveDot(size: 10)));
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.shape, BoxShape.circle);
        expect(decoration.color, AppColors.dark.accent);
        expect(container.constraints?.maxWidth, 10);
        expect(container.constraints?.maxHeight, 10);
      },
    );

    testWidgets(
      "AC-002: Widget's opacity/scale animates over a 1.6s loop when motion is not reduced",
      (tester) async {
        await tester.pumpWidget(_wrap(const LiveDot()));
        final opacityAt0 = tester.widget<Opacity>(find.byType(Opacity)).opacity;
        await tester.pump(const Duration(milliseconds: 800));
        final opacityAt800 = tester
            .widget<Opacity>(find.byType(Opacity))
            .opacity;
        expect(opacityAt800, isNot(opacityAt0));
      },
    );

    testWidgets(
      'AC-003: Widget renders statically (no animation) when MediaQuery.disableAnimations is true',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const LiveDot(), disableAnimations: true),
        );
        expect(find.byType(Opacity), findsNothing);
        final container = tester.widget<Container>(find.byType(Container));
        expect(
          (container.decoration as BoxDecoration).color,
          AppColors.dark.accent,
        );
      },
    );

    testWidgets(
      'AC-004: Under reduced motion the ticker itself stops, so pumpAndSettle terminates',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const LiveDot(), disableAnimations: true),
        );
        await tester.pumpAndSettle();
      },
    );
  });
}
