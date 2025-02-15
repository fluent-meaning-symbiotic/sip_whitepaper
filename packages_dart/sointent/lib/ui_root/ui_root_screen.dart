import 'dart:async';

import 'package:sointent/common_imports.dart';
import 'package:sointent/data_commands/loads/load_app.cmd.dart';
import 'package:sointent/data_commands/loads/load_intents.cmd.dart';
import 'package:sointent/data_resources/folders_resource.dart';

/// {@template ui_root_screen}
/// Initial screen of the application that handles app loading and folder selection.
/// Shows a loading indicator while initializing and then provides folder selection interface.
/// {@endtemplate}
class UiRootScreen extends HookWidget {
  /// {@macro ui_root_screen}
  const UiRootScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final appStateResource = context.watch<AppStateResource>();
    final foldersResource = context.watch<FoldersResource>();
    final isLoading = appStateResource.value == AppState.loading;
    useEffect(() {
      Future<void> initApp() async {
        try {
          await const LoadAppCommand().execute();
          appStateResource.value = AppState.loaded;
        } catch (e) {
          debugPrint('Error loading app: $e');
          appStateResource.value = AppState.error;
        }
      }

      unawaited(
        initApp().catchError((final e) {
          appStateResource.value = AppState.error;
          debugPrint('Error in init: $e');
        }),
      );

      return null;
    }, []);

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

  Future<void> _handleFolderSelection(final BuildContext context) async {
    try {
      await const LoadIntentsCommand().execute();
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
      (final resource) => resource.value,
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
                      await _handleFolderSelection(context);
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
