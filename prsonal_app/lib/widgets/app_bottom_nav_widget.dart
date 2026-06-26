import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_providers.dart';

class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;
  final void Function(int) onTabSelected;

  static const _tabs = [
    (label: 'Workout', icon: Icons.fitness_center_outlined),
    (label: 'Exercises', icon: Icons.list_outlined),
    (label: 'Body', icon: Icons.monitor_weight_outlined),
    (label: 'Progress', icon: Icons.bar_chart_outlined),
    (label: 'Settings', icon: Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionActive = ref.watch(activeSessionProvider);
    if (sessionActive) return const SizedBox.shrink();

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTabSelected,
      destinations: _tabs
          .map(
            (tab) => NavigationDestination(
              icon: Icon(tab.icon),
              label: tab.label,
            ),
          )
          .toList(),
    );
  }
}
