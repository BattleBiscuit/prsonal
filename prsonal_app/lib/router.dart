import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'services/session_service.dart';
import 'screens/all_prs_screen.dart';
import 'screens/body_screen.dart';
import 'screens/history_detail_screen.dart';
import 'screens/history_screen.dart';
import 'screens/library_screen.dart';
import 'screens/plan_edit_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/routine_edit_screen.dart';
import 'screens/session_active_screen.dart';
import 'screens/session_pick_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/app_bottom_nav_widget.dart';

/// Provider exposing the router so screens can access it via ref.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final sessionActive = ref.read(sessionEngineProvider) != null;
      final loc = state.matchedLocation;

      // Guard: navigating to session-active with no active session
      if (loc == '/session/active' && !sessionActive) return '/';
      // Guard: navigating to session-pick while a session is active
      if (loc == '/' && sessionActive) return '/session/active';
      return null;
    },
    routes: [
      // Active session (full-screen, outside shell)
      GoRoute(
        path: '/session/active',
        name: 'session-active',
        builder: (context, state) => const SessionActiveScreen(),
      ),

      // Main shell with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _ShellScaffold(shell: shell),
        branches: [
          // 0 – Workout
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'session-pick',
                builder: (context, state) => const SessionPickScreen(),
                routes: [
                  GoRoute(
                    path: 'routines/new',
                    name: 'routine-create',
                    builder: (context, state) => const RoutineEditScreen(),
                  ),
                  GoRoute(
                    path: 'routines/:id/edit',
                    name: 'routine-edit',
                    builder: (context, state) => RoutineEditScreen(
                      routineId: state.pathParameters['id'],
                    ),
                  ),
                  GoRoute(
                    path: 'plans/new',
                    name: 'plan-create',
                    builder: (context, state) => const PlanEditScreen(),
                  ),
                  GoRoute(
                    path: 'plans/:id/edit',
                    name: 'plan-edit',
                    builder: (context, state) =>
                        PlanEditScreen(planId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),

          // 1 – Exercises / Library
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                name: 'library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),

          // 2 – Body
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/body',
                name: 'body',
                builder: (context, state) => const BodyScreen(),
              ),
            ],
          ),

          // 3 – Progress
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                name: 'progress',
                builder: (context, state) => const ProgressScreen(),
                routes: [
                  GoRoute(
                    path: 'prs',
                    name: 'all-prs',
                    builder: (context, state) => const AllPrsScreen(),
                  ),
                  GoRoute(
                    path: 'history',
                    name: 'history',
                    builder: (context, state) => const HistoryScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: 'history-detail',
                        builder: (context, state) => HistoryDetailScreen(
                          sessionId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // 4 – Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _ShellScaffold extends ConsumerWidget {
  const _ShellScaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: shell.currentIndex,
        onTabSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}
