import 'dart:io';
import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectManager extends StatefulWidget {
  const ProjectManager({Key? key}) : super(key: key);

  @override
  _ProjectManagerState createState() => _ProjectManagerState();
}

class _ProjectManagerState extends State<ProjectManager> {
  final List<Map<String, String>> _projects = [];
  final String _projectsFile = r'\\desktop-co5hnd9\SERVIDOR B\Informatica\flutter\projects.json';
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectPathController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredProjects = [];
  
  String? _selectedProjectPath;
  List<FileSystemEntity> _files = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _filteredProjects= _projects;
  }

  void _loadProjects() {
    final file = File(_projectsFile);
    if (file.existsSync()) {
      final content = file.readAsStringSync();
      final List<dynamic> jsonProjects = jsonDecode(content);
      setState(() {
        _projects.addAll(jsonProjects.map((project) => Map<String, String>.from(project)));
        _filteredProjects = List.from(_projects); // Actualizamos los proyectos filtrados
      });
    }
  }

  void _saveProjects() {
    final file = File(_projectsFile);
    final content = jsonEncode(_projects);
    file.writeAsStringSync(content);
  }

  void _listFiles(String path) {
    setState(() {
      _isLoading = true;
    });

    try {
      final directory = Directory(path);
      final files = directory.listSync();
      setState(() {
        _files = files;
        _selectedProjectPath = path;
      });
    } catch (e) {
      _showMessage('Error al cargar archivos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void _addProject(String name, String path) {
    setState(() {
      _projects.add({'name': name, 'path': path});
      _saveProjects();
    });
    _showMessage('Proyecto "$name" agregado exitosamente.');
  }

  void _deleteProject(int index) {
    setState(() {
      _projects.removeAt(index);
      _saveProjects();
    });
    _showMessage('Proyecto eliminado.');
  }

  Future<void> _openFile(FileSystemEntity file) async {
    if (file is File) {
      final Uri fileUri = Uri.file(file.path);

      try {
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri);
        } else {
          _showMessage('No se pudo abrir el archivo: ${file.path}');
        }
      } catch (e) {
        _showMessage('Error al abrir el archivo: $e');
      }
    }
  }

  void _filterProjects() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProjects = _projects
          .where((project) => project['name']!.toLowerCase().contains(query))
          .toList();
    });
  }

  void _createFolder() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController folderNameController = TextEditingController();
        return ContentDialog(
          title: const Text('Crear Carpeta'),
          content: TextBox(
            controller: folderNameController,
            placeholder: 'Nombre de la nueva carpeta',
          ),
          actions: [
            Button(
              child: const Text('Crear'),
              onPressed: () {
                final folderName = folderNameController.text.trim();
                if (folderName.isNotEmpty) {
                  final newFolderPath = '$_selectedProjectPath${Platform.pathSeparator}$folderName';
                  Directory(newFolderPath).createSync();
                  _listFiles(_selectedProjectPath!);
                  _showMessage('Carpeta creada exitosamente.');
                }
                Navigator.pop(context);
              },
            ),
            Button(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }


@override
Widget build(BuildContext context) {
  return ScaffoldPage(
    header: PageHeader(
      title: const Text('Gestión de Proyectos'),
    ),
    content: Row(
      children: [
        // Panel de Proyectos con Buscador
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // Buscador
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextBox(
                  controller: _searchController,
                  placeholder: 'Buscar proyectos...',
                  onChanged: (value) => _filterProjects(),
                ),
              ),
              Button(
                child: const Text('Agregar Proyecto'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ContentDialog(
                        title: const Text('Agregar Proyecto'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextBox(
                              controller: _projectNameController,
                              placeholder: 'Nombre del proyecto',
                            ),
                            const SizedBox(height: 20),
                            TextBox(
                              controller: _projectPathController,
                              placeholder: 'Ruta del proyecto',
                              suffix: Button(
                                child: const Text('Seleccionar'),
                                onPressed: () async {
                                  final result =
                                      await FilePicker.platform.getDirectoryPath();
                                  if (result != null) {
                                    setState(() {
                                      _projectPathController.text = result;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          Button(
                            child: const Text('Cancelar'),
                            onPressed: () {
                              Navigator.pop(context);
                              _projectNameController.clear();
                              _projectPathController.clear();
                            },
                          ),
                          Button(
                            child: const Text('Agregar'),
                            onPressed: () {
                              final name = _projectNameController.text.trim();
                              final path = _projectPathController.text.trim();
                              if (name.isNotEmpty && path.isNotEmpty) {
                                _addProject(name, path);
                                _projectNameController.clear();
                                _projectPathController.clear();
                                Navigator.pop(context);
                              } else {
                                _showMessage('Por favor, complete ambos campos.');
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = _filteredProjects[index];
                    return HoverButton(
                      onPressed: () {
                        _listFiles(project['path'] ?? '');
                        setState(() {
                          _selectedProjectPath = project['path'];
                        });
                      },
                      builder: (context, states) => Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: states.isHovering ? Colors.grey[30] : null,
                        ),
                        child: Row(
                          children: [
                            const Icon(FluentIcons.folder_open),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                project['name'] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(FluentIcons.delete),
                              onPressed: () => _deleteProject(index),
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
        ),

        // Panel de Archivos
Expanded(
  flex: 2,
  child: _selectedProjectPath == null
      ? const Center(child: Text('Seleccione un proyecto para ver los archivos'))
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar el nombre del proyecto seleccionado
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Proyecto: ${_projects.firstWhere(
                  (project) => project['path'] == _selectedProjectPath,
                  orElse: () => {'name': 'Sin proyecto seleccionado'}
                )['name']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Listar archivos del proyecto seleccionado
            Expanded(
              child: ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return HoverButton(
                    onPressed: () {
                      if (file is File) {
                        _openFile(file); // Asegúrate de que _openFile esté definido
                      } else if (file is Directory) {
                        _listFiles(file.path);
                      }
                    },
                    builder: (context, states) => Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200],
                          ),
                        ),
                        color: states.isHovering ? Colors.grey[30] : null,
                      ),
                      child: Row(
                        children: [
                          Icon(file is Directory
                              ? FluentIcons.folder_open
                              : FluentIcons.page),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(file.path.split(Platform.pathSeparator).last),
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
),

      ],
    ),
  );
}

}
