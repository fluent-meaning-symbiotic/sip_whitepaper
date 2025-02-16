import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_root/ui_root_screen.dart';

/// Application router configuration
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (final context, final state) => const UiRootScreen(),
    ),
    GoRoute(
      path: '/workbench',
      builder: (final context, final state) => const UiWorkbenchScreen(),
    ),
  ],
);

/// Route names for the application
abstract class AppRoutes {
  /// Root route
  static const root = '/';

  /// Intent editor route
  static const intentEditor = '/intent-editor';

  /// Workbench route
  static const workbench = '/workbench';
}
