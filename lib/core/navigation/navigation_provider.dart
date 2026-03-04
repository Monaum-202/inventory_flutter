import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track the currently expanded module (only one at a time)
final expandedModuleProvider = StateProvider<String?>((ref) => null);

/// Provider to track the currently active menu route
final activeMenuProvider = StateProvider<String?>((ref) => null);

/// Provider to track if sidebar is collapsed on desktop
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
