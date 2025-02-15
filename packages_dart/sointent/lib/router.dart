import 'package:sointent/common_imports.dart';

/// Application router configuration
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (final context, final state) => const WorkbenchScreen(),
    ),
    GoRoute(
      path: '/intent-editor',
      builder: (final context, final state) => const UiIntentEditor(),
    ),
  ],
);

/// Route names for the application
abstract class AppRoutes {
  /// Root route
  static const root = '/';

  /// Intent editor route
  static const intentEditor = '/intent-editor';
}
