import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:sointent/common_imports.dart';
import 'package:sointent/data_commands/data_commands.dart';

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

    return Scaffold(
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : FolderSelectionPanel(foldersResource: foldersResource),
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
      final dirPath =
          folderPath ?? await FilePicker.platform.getDirectoryPath();
      if (dirPath == null || dirPath.isEmpty) return;
      await SaveFolderCommand(folderPath: dirPath).execute();
      await LoadIntentsCommand(dirPath: dirPath).execute();
      if (context.mounted) {
        context.go('/workbench');
      }
    } catch (e) {
      // TODO: Handle error state
      debugPrint('Error loading intents: $e');
    }
  }

  @override
  Widget build(final BuildContext context) {
    final recentFolders = context.select<FoldersResource, List<String>>(
      (final resource) => resource.toList(),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              await _handleFolderSelection(context);
            },
            child: const Text('Open Folder'),
          ),
          const SizedBox(height: 16),
          if (recentFolders.isNotEmpty) ...[
            const Text(
              'Recent Folders',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: recentFolders.length,
                itemBuilder: (final context, final index) {
                  final folderPath = recentFolders[index];
                  return ListTile(
                    title: Text(folderPath.split('/').last),
                    subtitle: Text(folderPath),
                    onTap: () async {
                      await _handleFolderSelection(
                        context,
                        folderPath: folderPath,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
