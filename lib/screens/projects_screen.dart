import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
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
    _filteredProjects = _projects;
  }

  void _loadProjects() {
    final file = File(_projectsFile);
    if (file.existsSync()) {
      final content = file.readAsStringSync();
      final List<dynamic> jsonProjects = jsonDecode(content);
      setState(() {
        _projects.addAll(jsonProjects.map((project) => Map<String, String>.from(project)));
        _filteredProjects = List.from(_projects);
      });
    }
  }

  void _saveProjects() {
    final file = File(_projectsFile);
    final content = jsonEncode(_projects);
    file.writeAsStringSync(content);
  }

void _listFiles(String path) {
  final directory = Directory(path);
  try {
    final files = directory.listSync();
    setState(() {
      _selectedProjectPath = path;

      // Filtrar archivos y carpetas ocultos o específicos
      _files = files.where((file) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        // Excluir archivos o carpetas no deseados
        if (fileName.startsWith(r'$') || 
            fileName == 'System Volume Information' || 
            fileName == '.BIN' || 
            fileName == 'desktop.ini') {
          return false;
        }
        return true;
      }).toList();
    });
  } catch (e) {
    _showMessage('Error al acceder al directorio: $e');
  }
}

void _goBack() {
  if (_selectedProjectPath != null) {
    // Obtener el directorio inicial del proyecto seleccionado
    final initialPath = _projects.firstWhere(
      (project) => project['path'] == _selectedProjectPath,
      orElse: () => {'path': ''},
    )['path'];

    if (initialPath != null && _selectedProjectPath != initialPath) {
      // Retroceder al directorio padre
      final parentDir = Directory(_selectedProjectPath!).parent.path;
      if (parentDir.startsWith(initialPath)) {
        _listFiles(parentDir);
      } else {
        _showMessage('No puedes retroceder más allá del directorio inicial.');
      }
    } else {
      _showMessage('No puedes retroceder más allá del directorio inicial.');
    }
  }
}



  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mensaje'),
        content: Text(message),
        actions: [
          TextButton(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Proyectos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 107, 135, 182),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar proyectos...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _filterProjects(),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 76, 78, 175)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(fontSize: 16),
                    ),
                  ),
                  onPressed: () {
showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      backgroundColor: Colors.white, // Color de fondo completamente opaco
      title: const Text('Añadir Proyecto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
TextField(
  controller: _projectNameController,
  decoration: InputDecoration(
    labelText: 'Nombre del proyecto',
    border: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.grey, // Color del borde
        width: 1.5, // Grosor del borde
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.blue, // Color del borde al enfocar
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
),

          const SizedBox(height: 20),
       TextField(
  controller: _projectPathController,
  decoration: InputDecoration(
    labelText: 'Ruta del proyecto',
    border: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.grey,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.blue,
        width: 2.0,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    suffixIcon: IconButton(
      icon: const Icon(Icons.folder),
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
),

        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.pop(context);
            _projectNameController.clear();
            _projectPathController.clear();
          },
        ),
        TextButton(
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
                  child: const Text('Añadir Proyecto'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = _filteredProjects[index];
                      return ListTile(
                        title: Text(project['name'] ?? ''),
                        onTap: () {
                          _listFiles(project['path'] ?? '');
                          setState(() {
                            _selectedProjectPath = project['path'];
                          });
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Color.fromARGB(255, 255, 17, 0),),
                          onPressed: () => _deleteProject(index),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
Expanded(
  flex: 2,
  child: _selectedProjectPath == null
      ? const Center(
          child: Text('Seleccione un proyecto para ver los archivos'),
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Proyecto: ${_projects.firstWhere(
                      (project) => project['path'] == _selectedProjectPath,
                      orElse: () => {'name': 'Sin proyecto seleccionado'},
                    )['name']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 76, 78, 175)),
                      foregroundColor:
                          MaterialStateProperty.all(Colors.white),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 16)),
                    ),
                    onPressed: _goBack,
                    child: const Text('Atrás'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return ListTile(
                    leading: Icon(file is Directory
                        ? Icons.folder
                        : Icons.insert_drive_file),
                    title: Text(file.path
                        .split(Platform.pathSeparator)
                        .last),
                    onTap: () {
                      if (file is File) {
                        _openFile(file);
                      } else if (file is Directory) {
                        _listFiles(file.path);
                      }
                    },
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

void main() {
  runApp(MaterialApp(
    home: const ProjectManager(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(),
    ),
  )
  )
  );
}
