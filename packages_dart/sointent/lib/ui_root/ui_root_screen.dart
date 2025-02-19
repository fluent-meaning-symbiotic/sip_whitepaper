import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:sointent/common_imports.dart';
import 'package:sointent/data_commands/data_commands.dart';
import 'package:sointent/ui_kit/ui_kit.dart';

/// {@template ui_root_screen}
/// Initial screen of the application that handles app loading and folder selection.
/// Shows a loading indicator while initializing and then provides folder selection interface.
/// {@endtemplate}
class UiRootScreen extends StatefulWidget {
  /// {@macro ui_root_screen}
  const UiRootScreen({super.key});

  @override
  State<UiRootScreen> createState() => _UiRootScreenState();
}

class _UiRootScreenState extends State<UiRootScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_initApp());
  }

  Future<void> _initApp() async {
    final appStateResource = context.read<AppStateResource>();
    try {
      await const LoadAppCommand().execute();
      appStateResource.value = AppState.loaded;
    } catch (e) {
      debugPrint('Error loading app: $e');
      appStateResource.value = AppState.error;
    }
  }

  @override
  Widget build(final BuildContext context) {
    final appStateResource = context.watch<AppStateResource>();
    final foldersResource = context.watch<FoldersResource>();
    final isLoading = appStateResource.value == AppState.loading;
    final neumorphicTheme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: neumorphicTheme.baseBackground,
      body: AnimatedSwitcher(
        duration: AnimationTokens.stateDuration,
        switchInCurve: AnimationTokens.stateCurve,
        switchOutCurve: AnimationTokens.stateCurve,
        child:
            isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: neumorphicTheme.primaryAccent,
                  ),
                )
                : Padding(
                  padding: Spacing.sectionPadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: FolderSelectionPanel(
                        foldersResource: foldersResource,
                      ),
                    ),
                  ),
                ),
      ),
    );
  }
}

/// Panel that displays folder selection interface including a button to open
/// new folders and a list of recently opened folders.
class FolderSelectionPanel extends StatelessWidget {
  const FolderSelectionPanel({required this.foldersResource, super.key});

  final FoldersResource foldersResource;

  Future<void> _handleFolderSelection(
    final BuildContext context, {
    final String? folderPath,
  }) async {
    try {
      final dirPath = await FilePicker.platform.getDirectoryPath(
        initialDirectory: folderPath,
      );
      if (dirPath == null || dirPath.isEmpty) return;
      await SaveFolderCommand(folderPath: dirPath).execute();
      await LoadIntentsCommand(dirPath: dirPath).execute();
      if (context.mounted) {
        context.go('/workbench');
      }
    } catch (e) {
      debugPrint('Error loading intents: $e');
    }
  }

  @override
  Widget build(final BuildContext context) {
    final recentFolders = context.select<FoldersResource, List<String>>(
      (final resource) => resource.toList(),
    );
    final theme = Theme.of(context);
    final neumorphicTheme = AppTheme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: neumorphicTheme.surfaceBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ComponentSize.cardRadius),
      ),
      elevation: Elevation.defaultDesktop,
      child: Padding(
        padding: Spacing.sectionPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: ComponentSize.buttonHeight,
              child: ElevatedButton(
                onPressed: () async => _handleFolderSelection(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: neumorphicTheme.primaryAccent,
                  foregroundColor: Colors.white,
                  elevation: Elevation.defaultDesktop,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ComponentSize.buttonRadius,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.horizontalElement,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.folder_open,
                      size: ComponentSize.actionIconSize,
                    ),
                    const SizedBox(width: Spacing.micro * 2),
                    Text('Open Folder', style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            if (recentFolders.isNotEmpty) ...[
              const SizedBox(height: Spacing.verticalElement),
              Text('Recent Folders', style: theme.textTheme.labelLarge),
              const SizedBox(height: Spacing.micro * 2),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: recentFolders.length,
                  itemBuilder: (final context, final index) {
                    final folderPath = recentFolders[index];
                    final folderName = folderPath.split('/').last;

                    return ListItemCard(
                      title: folderName,
                      subtitle: folderPath,
                      onTap:
                          () async => _handleFolderSelection(
                            context,
                            folderPath: folderPath,
                          ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
