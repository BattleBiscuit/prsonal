import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/theme/app_theme.dart';

// Guards the semantic button-colour decision (see design_system.md "Buttons"):
// affirmative actions are the signature chalk; neutral actions are grey, never
// chalk. Resolving the theme's WidgetStateProperty in the default state is
// enough to assert the mapping without pumping a widget.
void main() {
  const accent = Color(0xFFEDEDED); // signature chalk
  const text2 = Color(0xFF9E9E9E); // neutral grey

  group('Button colour semantics', () {
    test(
      'Affirmative buttons (filled and elevated) use the signature accent',
      () {
        final filledBg = appTheme.filledButtonTheme.style!.backgroundColor!
            .resolve({});
        final elevatedBg = appTheme.elevatedButtonTheme.style!.backgroundColor!
            .resolve({});
        expect(filledBg, accent);
        expect(elevatedBg, accent);
      },
    );

    test('Neutral buttons (text and outlined) use grey, never the accent', () {
      final textFg = appTheme.textButtonTheme.style!.foregroundColor!.resolve(
        {},
      );
      final outlinedFg = appTheme.outlinedButtonTheme.style!.foregroundColor!
          .resolve({});
      expect(textFg, text2);
      expect(outlinedFg, text2);
      expect(textFg, isNot(accent));
      expect(outlinedFg, isNot(accent));
    });
  });

  group('Input contours (design_system.md "High-glare input contours")', () {
    const border = Color(0xFF2E2E2E); // AppColors.dark.border

    test('Unfocused inputs render the border-token baseline, not none', () {
      final enabledBorder =
          appTheme.inputDecorationTheme.enabledBorder as OutlineInputBorder;
      expect(enabledBorder.borderSide.style, BorderStyle.solid);
      expect(enabledBorder.borderSide.color, border);
      expect(enabledBorder.borderSide.width, 1);
    });

    test('Focus raises the border to the 2px accent ring', () {
      final focusedBorder =
          appTheme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
      expect(focusedBorder.borderSide.color, accent);
      expect(focusedBorder.borderSide.width, 2);
    });
  });
}
