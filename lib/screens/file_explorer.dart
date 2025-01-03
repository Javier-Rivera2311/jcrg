import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  String _currentPath = r'\\desktop-co5hnd9\SERVIDOR B\01.- PROYECTOS';
  List<FileSystemEntity> _files = [];

  @override
  void initState() {
    super.initState();
    _listFiles(_currentPath);
  }

  void _listFiles(String path) {
    final directory = Directory(path);
    try {
      final files = directory.listSync();
      setState(() {
        _currentPath = path;
        _files = files;
      });
    } catch (e) {
      _showMessage('Error al acceder al directorio: $e');
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Mensaje'),
        content: Text(message),
        actions: [
          Button(
            child: const Text('Aceptar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openFile(FileSystemEntity file) async {
    if (file is File) {
      final Uri fileUri = Uri.file(file.path);

      try {
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri); // Abre el archivo con la aplicación predeterminada
        } else {
          _showMessage('No se pudo abrir el archivo: ${file.path}');
        }
      } catch (e) {
        _showMessage('Error al abrir el archivo: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text("Explorador de Archivos - $_currentPath"),
        commandBar: _currentPath != Directory.current.path
            ? Button(
                child: const Text("Atrás"),
                onPressed: () {
                  final parentDir = Directory(_currentPath).parent.path;
                  _listFiles(parentDir);
                },
              )
            : null,
      ),
      content: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                return GestureDetector(
                  onTap: () {
                    if (file is Directory) {
                      _listFiles(file.path);
                    } else if (file is File) {
                      _openFile(file);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[200]!,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(file is Directory
                            ? FluentIcons.folder_open
                            : FluentIcons.page),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            file.path.split(Platform.pathSeparator).last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(FluentApp(
    title: 'Explorador de Archivos',
    home: const FileExplorer(),
  ));
}
