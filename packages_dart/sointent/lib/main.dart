import 'package:sointent/common_imports.dart';
import 'package:sointent/data_resources/data_resources.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await initDI();

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
    providers: [
      ChangeNotifierProvider<AppStateResource>.value(
        value: AppStateResource.instance,
      ),
      ChangeNotifierProvider<SemanticIntentsResource>.value(
        value: SemanticIntentsResource.instance,
      ),
      ChangeNotifierProvider<DialogMessagesResource>.value(
        value: DialogMessagesResource.instance,
      ),
    ],
    child: MaterialApp.router(
      title: 'SoIntent',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    ),
  );
}
