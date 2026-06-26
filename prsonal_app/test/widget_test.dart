import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prsonal_app/providers/session_pick_providers.dart';
import 'package:prsonal_app/screens/session_pick_screen.dart';

void main() {
  testWidgets('App root renders the session-pick screen', (WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: 'session-pick',
          builder: (_, _) => const SessionPickScreen(),
        ),
        GoRoute(
          path: '/session/active',
          name: 'session-active',
          builder: (_, _) => const Text('ACTIVE'),
        ),
        GoRoute(
          path: '/routines/new',
          name: 'routine-create',
          builder: (_, _) => const Text('NEW ROUTINE'),
        ),
        GoRoute(
          path: '/plans/new',
          name: 'plan-create',
          builder: (_, _) => const Text('NEW PLAN'),
        ),
        GoRoute(
          path: '/routines/:id/edit',
          name: 'routine-edit',
          builder: (_, _) => const Text('EDIT ROUTINE'),
        ),
        GoRoute(
          path: '/plans/:id/edit',
          name: 'plan-edit',
          builder: (_, _) => const Text('EDIT PLAN'),
        ),
      ],
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        activePlansViewProvider.overrideWithValue(const []),
        unplannedRoutinesProvider.overrideWithValue(const []),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Nothing here yet'), findsOneWidget);
  });
}
