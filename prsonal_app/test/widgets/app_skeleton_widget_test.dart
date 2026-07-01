import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/widgets/app_skeleton_widget.dart';

Widget _wrap(Widget child, {bool disableAnimations = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Scaffold(body: child),
  ),
);

void main() {
  group('AppSkeleton', () {
    testWidgets(
      'AC-001: Widget renders a surface1 rectangle of the given width and height',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const AppSkeleton(width: 120, height: 20)),
        );
        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, AppColors.dark.surface1);
        expect(container.constraints?.maxWidth, 120);
        expect(container.constraints?.maxHeight, 20);
      },
    );

    testWidgets(
      "AC-002: Widget's opacity animates over a 1.5s loop when motion is not reduced",
      (tester) async {
        await tester.pumpWidget(_wrap(const AppSkeleton()));
        final opacityAt0 = tester.widget<Opacity>(find.byType(Opacity)).opacity;
        await tester.pump(const Duration(milliseconds: 750));
        final opacityAt750 = tester
            .widget<Opacity>(find.byType(Opacity))
            .opacity;
        expect(opacityAt750, isNot(opacityAt0));
      },
    );

    testWidgets(
      'AC-003: Widget renders statically (no animation) when MediaQuery.disableAnimations is true',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const AppSkeleton(), disableAnimations: true),
        );
        expect(find.byType(Opacity), findsNothing);
        final container = tester.widget<Container>(find.byType(Container));
        expect(
          (container.decoration as BoxDecoration).color,
          AppColors.dark.surface1,
        );
      },
    );

    testWidgets(
      'AC-004: Under reduced motion the ticker itself stops, so pumpAndSettle terminates',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const AppSkeleton(), disableAnimations: true),
        );
        await tester.pumpAndSettle();
      },
    );
  });
}
