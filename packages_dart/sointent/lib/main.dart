import 'package:sointent/common_imports.dart';

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
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigoAccent,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          routerConfig: appRouter,
        ),
  );
}
