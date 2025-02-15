import 'package:flutter/widgets.dart';

enum AppState { loading, loaded, error }

/// Resource for managing application state
class AppStateResource extends ValueNotifier<AppState> {
  /// Creates a new [AppStateResource]
  AppStateResource() : super(AppState.loading);

  /// Singleton instance
  static late AppStateResource instance;

  /// Sets the current application state
  // ignore: use_setters_to_change_properties
  void setState(final AppState state) => value = state;
}
