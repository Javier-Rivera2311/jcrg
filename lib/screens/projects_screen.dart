import 'dart:io';
import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';

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
  bool _isLoading = false;
  List<FileSystemEntity> _files = [];
  String? _selectedProjectPath;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  // Cargar proyectos desde el archivo JSON
  void _loadProjects() {
    final file = File(_projectsFile);
    if (file.existsSync()) {
      final content = file.readAsStringSync();
      final List<dynamic> jsonProjects = jsonDecode(content);
      setState(() {
        _projects.addAll(jsonProjects.map((project) => Map<String, String>.from(project)));
      });
    }
  }

  // Guardar proyectos en el archivo JSON
  void _saveProjects() {
    final file = File(_projectsFile);
    final content = jsonEncode(_projects);
    file.writeAsStringSync(content);
  }

  // Agregar un nuevo proyecto
  void _addProject(String name, String path) {
    setState(() {
      _projects.add({'name': name, 'path': path});
      _saveProjects();
    });
    _showMessage('Proyecto "$name" agregado exitosamente.');
  }

  // Eliminar un proyecto
  void _deleteProject(int index) {
    setState(() {
      _projects.removeAt(index);
      _saveProjects();
    });
    _showMessage('Proyecto eliminado.');
  }

  // Cargar archivos del proyecto seleccionado
  Future<void> _listFiles(String path) async {
    setState(() {
      _isLoading = true;
      _selectedProjectPath = path;
    });

    try {
      final directory = Directory(path);
      final files = directory.listSync();
      setState(() {
        _files = files;
      });
    } catch (e) {
      _showMessage('Error al cargar archivos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mostrar un mensaje de confirmación o error
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Gestión de Proyectos'),
        commandBar: Button(
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
                      const SizedBox(height: 10),
                      TextBox(
                        controller: _projectPathController,
                        placeholder: 'Ruta del proyecto',
                        suffix: Button(
                          child: const Text('Seleccionar'),
                          onPressed: () async {
                            final result = await FilePicker.platform.getDirectoryPath();
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
      ),
      content: Row(
        children: [
          // Panel de Proyectos
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index];
                return ListTile(
                  title: Text(project['name'] ?? ''),
                  subtitle: Text(project['path'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(FluentIcons.delete),
                    onPressed: () => _deleteProject(index),
                  ),
                  onPressed: () {
                    _listFiles(project['path'] ?? '');
                  },
                );
              },
            ),
          ),
          // Panel de Archivos
          Expanded(
            flex: 2,
            child: _isLoading
                ? const Center(child: ProgressRing())
                : _selectedProjectPath == null
                    ? const Center(child: Text('Seleccione un proyecto para ver los archivos'))
                    : ListView.builder(
                        itemCount: _files.length,
                        itemBuilder: (context, index) {
                          final file = _files[index];
                          return ListTile(
                            title: Text(file.path.split(Platform.pathSeparator).last),
                            subtitle: Text(file is Directory ? 'Carpeta' : 'Archivo'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
