import 'package:sointent/common_imports.dart';
import 'package:sointent/ui_kit/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SoIntentApp());
}

/// {@template so_intent_app}
/// Root widget of the SoIntent application.
/// Provides necessary providers and configuration.
/// {@endtemplate}
class SoIntentApp extends StatelessWidget {
  /// {@macro so_intent_app}
  const SoIntentApp({super.key});

  @override
  Widget build(final BuildContext context) => MultiProvider(
    providers: resourceProviders,
    builder:
        (final context, final child) => MaterialApp.router(
          title: 'SoIntent',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              ThemeMode
                  .dark, // Default to dark theme for better developer experience
          routerConfig: appRouter,
        ),
  );
}
