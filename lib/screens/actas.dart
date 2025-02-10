import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jcrg/widgets/file_utils.dart';
import 'package:jcrg/screens/theme_switcher.dart';

class ActasScreen extends StatefulWidget {
  const ActasScreen({Key? key}) : super(key: key);

  @override
  _ActasScreenState createState() => _ActasScreenState();
}

class _ActasScreenState extends State<ActasScreen> {
  final List<Map<String, String>> _projects = [];
  final String _projectsFile = r'\\desktop-co5hnd9\SERVIDOR B\Informatica\flutter\actas.json';
  //final String _projectsFile = r'C:\Users\javie\OneDrive\Desktop\tests flutter\tareas\actas.json';

  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectPathController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedFiles = []; // Archivos seleccionados para mover
  final Map<String, DateTime> _fileRegistry = {}; // Registro de archivos con fechas
  final String _registryPath = r'\\desktop-co5hnd9\SERVIDOR B\Informatica\flutter\tareas\registry_actas.json';
  //final String _registryPath = r'C:\Users\javie\OneDrive\Desktop\tests flutter\tareas\registry_actas.json';
  
  List<Map<String, String>> _filteredProjects = [];
  
  final String _currentPath = ''; // Ruta actual del directorio

  String _getUploadDate(FileSystemEntity file) {
    if (_fileRegistry.containsKey(file.path)) {
      final uploadDate = _fileRegistry[file.path];
      return '${uploadDate!.day}-${uploadDate.month}-${uploadDate.year} ${uploadDate.hour}:${uploadDate.minute}';
    }
    return 'No registrado';
  }


  String _getModifiedDate(FileSystemEntity file) {
    try {
      final lastModified = file.statSync().modified;
      return '${lastModified.day}-${lastModified.month}-${lastModified.year} ${lastModified.hour}:${lastModified.minute}';
    } catch (e) {
      return 'Desconocido';
    }
  }


void _loadRegistry() {
  final registryFile = File(_registryPath);
  if (registryFile.existsSync()) {
    try {
      final content = registryFile.readAsStringSync();
      final Map<String, dynamic> jsonRegistry = jsonDecode(content);
      setState(() {
        jsonRegistry.forEach((key, value) {
          _fileRegistry[key] = DateTime.parse(value);
        });
      });
    } catch (e) {
      _showMessage('Error al cargar el registro: $e');
    }
  }
}
void _saveRegistry() {
  final registryFile = File(_registryPath);
  try {
    final jsonRegistry = _fileRegistry.map((key, value) => MapEntry(key, value.toIso8601String()));
    registryFile.writeAsStringSync(jsonEncode(jsonRegistry));
  } catch (e) {
    _showMessage('Error al guardar el registro: $e');
  }
}

  String? _selectedProjectPath;
  List<FileSystemEntity> _files = [];

@override
void initState() {
  super.initState();
  _loadProjects();
  _loadRegistry(); // Carga el registro al iniciar
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

void _goBackToProjectSelection() {
  setState(() {
    _selectedProjectPath = null;
    _files.clear();
  });
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
    _showMessage('Acta Reunion"$name" agregado exitosamente.');
  }

  void _deleteProject(int index) {
    setState(() {
      _projects.removeAt(index);
      _saveProjects();
    });
    _showMessage('Acta reunion eliminada.');
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
Future<void> _selectFiles() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Permitir selección múltiple
      type: FileType.any,  // Permitir cualquier tipo de archivo
    );

    if (result != null && result.files.isNotEmpty) {
      for (var file in result.files) {
        final newFilePath = '$_selectedProjectPath${Platform.pathSeparator}${file.name}';
        final selectedFile = File(file.path!);

        if (File(newFilePath).existsSync()) {
          await selectedFile.copy(newFilePath);
          setState(() {
            _files.add(File(newFilePath)); // Agregar a la lista de archivos
          });
        } else {
          await selectedFile.copy(newFilePath);
          setState(() {
            _files.add(File(newFilePath)); // Agregar a la lista de archivos
          });
        }
      }

      _showMessage('Archivos subidos exitosamente.');
    } else {
      _showMessage('No se seleccionaron archivos.');
    }
  } catch (e) {
    _showMessage('Error al seleccionar archivos: $e');
  }
}
void _createFolder() {
  showDialog(
    context: context,
    builder: (context) {
      final TextEditingController folderNameController = TextEditingController();
      return AlertDialog(
        title: const Text('Crear Carpeta'),
        content: TextField(
          controller: folderNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la nueva carpeta',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Crear'),
            onPressed: () {
              final folderName = folderNameController.text.trim();
              if (folderName.isNotEmpty) {
                final newFolderPath = '$_selectedProjectPath${Platform.pathSeparator}$folderName';
                final newFolder = Directory(newFolderPath);
                if (!newFolder.existsSync()) {
                  newFolder.createSync(recursive: true);
                  _listFiles(_selectedProjectPath!); // Actualizar lista de archivos
                  _showMessage('Carpeta creada exitosamente.');
                } else {
                  _showMessage('La carpeta ya existe.');
                }
              }
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

Future<void> _moveSelectedFiles() async {
  try {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      for (var filePath in _selectedFiles) {
        final file = FileSystemEntity.typeSync(filePath) == FileSystemEntityType.directory
            ? Directory(filePath)
            : File(filePath);
        final newFilePath = '$result${Platform.pathSeparator}${file.path.split(Platform.pathSeparator).last}';
        
        if (file is Directory) {
          Directory(newFilePath).createSync(recursive: true);
          file.listSync(recursive: true).forEach((entity) {
            final relativePath = entity.path.substring(file.path.length + 1);
            final newEntityPath = '$newFilePath${Platform.pathSeparator}$relativePath';
            if (entity is File) {
              entity.copySync(newEntityPath);
            } else if (entity is Directory) {
              Directory(newEntityPath).createSync(recursive: true);
            }
          });
          file.deleteSync(recursive: true);
        } else if (file is File) {
          file.renameSync(newFilePath);
        }

        setState(() {
          _fileRegistry.remove(file.path);
          _fileRegistry[newFilePath] = DateTime.now();
        });
      }

      _listFiles(_selectedProjectPath!);
      _saveRegistry();
      _showMessage('Archivos movidos exitosamente.');
      _selectedFiles.clear();
    }
  } catch (e) {
    _showMessage('Error al mover archivos: $e');
  }
}

Future<void> _copySelectedFiles() async {
  try {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      for (var filePath in _selectedFiles) {
        final file = FileSystemEntity.typeSync(filePath) == FileSystemEntityType.directory
            ? Directory(filePath)
            : File(filePath);
        final newFilePath = '$result${Platform.pathSeparator}${file.path.split(Platform.pathSeparator).last}';
        
        if (file is Directory) {
          Directory(newFilePath).createSync(recursive: true);
          file.listSync(recursive: true).forEach((entity) {
            final relativePath = entity.path.substring(file.path.length + 1);
            final newEntityPath = '$newFilePath${Platform.pathSeparator}$relativePath';
            if (entity is File) {
              entity.copySync(newEntityPath);
            } else if (entity is Directory) {
              Directory(newEntityPath).createSync(recursive: true);
            }
          });
        } else if (file is File) {
          file.copySync(newFilePath);
        }

        setState(() {
          _fileRegistry[newFilePath] = DateTime.now();
        });
      }

      _listFiles(_selectedProjectPath!);
      _saveRegistry();
      _showMessage('Archivos copiados exitosamente.');
      _selectedFiles.clear();
    }
  } catch (e) {
    _showMessage('Error al copiar archivos: $e');
  }
}

void _copyDirectory(Directory source, Directory destination) {
  if (!destination.existsSync()) {
    destination.createSync(recursive: true);
  }
  source.listSync(recursive: false).forEach((entity) {
    if (entity is Directory) {
      final newDirectory = Directory('${destination.path}${Platform.pathSeparator}${entity.path.split(Platform.pathSeparator).last}');
      _copyDirectory(entity, newDirectory);
    } else if (entity is File) {
      final newFile = File('${destination.path}${Platform.pathSeparator}${entity.path.split(Platform.pathSeparator).last}');
      entity.copySync(newFile.path);
    }
  });
}

void _deleteFile(FileSystemEntity file) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Eliminar Archivo'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el archivo "${file.path.split(Platform.pathSeparator).last}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () {
              Navigator.pop(context);
              _performDeleteFile(file);
            },
          ),
        ],
      );
    },
  );
}

void _performDeleteFile(FileSystemEntity file) {
  try {
    if (file.existsSync()) {
      file.deleteSync(); // Elimina el archivo o carpeta
      setState(() {
        _files.remove(file); // Actualiza la lista de archivos
        _selectedFiles.remove(file.path); // Elimina de la lista de seleccionados si es necesario
        _fileRegistry.remove(file.path); // Elimina del registro
      });
      _saveRegistry(); // Guarda los cambios en el registro
      _showMessage('Archivo eliminado exitosamente.');
    } else {
      _showMessage('El archivo no existe.');
    }
  } catch (e) {
    _showMessage('Error al eliminar el archivo: $e');
  }
}

Future<void> _downloadProjectContent(String projectPath) async {
  try {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      final directory = Directory(projectPath);
      if (await directory.exists()) {
        final files = directory.listSync(recursive: true);
        for (var file in files) {
          if (file is File) {
            final relativePath = file.path.replaceFirst(directory.path, '');
            final newFilePath = '$result$relativePath';
            final newFile = File(newFilePath);
            await newFile.create(recursive: true);
            await file.copy(newFilePath);
          } else if (file is Directory) {
            final relativePath = file.path.replaceFirst(directory.path, '');
            final newDirPath = '$result$relativePath';
            final newDir = Directory(newDirPath);
            await newDir.create(recursive: true);
          }
        }
        _showMessage('Archivos descargados exitosamente.');
      } else {
        _showMessage('El directorio de la reunion no existe.');
      }
    } else {
      _showMessage('No se seleccionó una carpeta de destino.');
    }
  } catch (e) {
    _showMessage('Error al descargar el contenido del proyecto: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actas de reuniones', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 107, 135, 182),
        leading: _selectedProjectPath != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _goBackToProjectSelection,
              )
            : Center(
                child: Image.asset(
                  'lib/assets/Log/LOGO.png', // Asegúrate de que esta ruta sea correcta
                  height: 75,
                  width: 75,
                  fit: BoxFit.contain, // Ajusta la imagen si es necesario
                ),
              ),
        actions: [
          ThemeSwitcher(),
        ],
      ),
      body: _selectedProjectPath == null
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar Actas...',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    onChanged: (value) => _filterProjects(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = _filteredProjects[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          leading: const Icon(Icons.folder, color: Colors.blueAccent),
                          title: Text(
                            project['name'] ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          onTap: () {
                            _listFiles(project['path'] ?? '');
                            setState(() {
                              _selectedProjectPath = project['path'];
                            });
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download, color: Colors.green),
                                onPressed: () => _downloadProjectContent(project['path'] ?? ''),
                                tooltip: 'Descargar contenido del proyecto',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Color.fromARGB(255, 255, 17, 0)),
                                onPressed: () => _deleteProject(index),
                                tooltip: 'Eliminar proyecto',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
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
                            backgroundColor: isDarkMode
                                ? const Color.fromARGB(255, 40, 40, 40)
                                : Colors.white,
                            title: Text(
                              'Añadir Acta',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _projectNameController,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Nombre de la reunión',
                                    labelStyle: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                    border: const OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: isDarkMode ? Colors.grey : Colors.black45,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _projectPathController,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Ruta de la reunión',
                                    labelStyle: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                    border: const OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: isDarkMode ? Colors.grey : Colors.black45,
                                      ),
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
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _projectNameController.clear();
                                  _projectPathController.clear();
                                },
                              ),
                              TextButton(
                                child: Text(
                                  'Agregar',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.blue : Colors.blue,
                                  ),
                                ),
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
                    child: const Text('Añadir Acta'),
                  ),
                ),
              ],
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
                          (project) => _selectedProjectPath!.startsWith(project['path']!),
                          orElse: () => {'name': 'Sin proyecto seleccionado'},
                        )['name']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Wrap(
                          spacing: 8.0,
                          children: [
ElevatedButton(
  onPressed: _selectedProjectPath != null && _selectedProjectPath != _projects.firstWhere(
    (project) => project['path'] == _selectedProjectPath,
    orElse: () => {'path': ''},
  )['path']
      ? _goBack
      : null,
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all(
      _selectedProjectPath != null && _selectedProjectPath != _projects.firstWhere(
        (project) => project['path'] == _selectedProjectPath,
        orElse: () => {'path': ''},
      )['path']
          ? const Color.fromARGB(255, 76, 78, 175) // Color activo
          : Colors.grey, // Color deshabilitado
    ),
    foregroundColor: MaterialStateProperty.all(
      _selectedProjectPath != null && _selectedProjectPath != _projects.firstWhere(
        (project) => project['path'] == _selectedProjectPath,
        orElse: () => {'path': ''},
      )['path']
          ? Colors.white
          : Colors.black38, // Ajusta el color del texto
    ),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Ajusta el tamaño del botón
    ),
  ),
  child: const Text('Atrás'),
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
                              onPressed: _selectedProjectPath == null
                                  ? null
                                  : () => _selectFiles(),
                              child: const Text('Subir Archivos'),
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
                              onPressed: _selectedProjectPath == null
                                  ? null
                                  : () => _createFolder(),
                              child: const Text('Crear Carpeta'),
                            ),
ElevatedButton(
  // Habilitar o deshabilitar según los archivos seleccionados
  onPressed: _selectedFiles.isNotEmpty ? _moveSelectedFiles : null,
  style: ButtonStyle(
    // Estilo condicional: deshabilitado si no hay archivos seleccionados
    backgroundColor: MaterialStateProperty.all(
      _selectedFiles.isNotEmpty
          ? const Color.fromARGB(255, 76, 78, 175) // Color activo
          : Colors.grey, // Color deshabilitado
    ),
    foregroundColor: MaterialStateProperty.all(
      _selectedFiles.isNotEmpty ? Colors.white : Colors.black38, // Ajusta el color del texto
    ),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Ajusta el tamaño del botón
    ),
  ),
  child: const Text('Mover Archivos seleccionados'),
),
ElevatedButton(
  onPressed: _selectedFiles.isNotEmpty ? _copySelectedFiles : null,
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all(
      _selectedFiles.isNotEmpty
          ? const Color.fromARGB(255, 76, 78, 175)
          : Colors.grey,
    ),
    foregroundColor: MaterialStateProperty.all(
      _selectedFiles.isNotEmpty ? Colors.white : Colors.black38,
    ),
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  child: const Text('Copiar Archivos seleccionados'),
),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
Expanded(
  child: ListView.builder(
    itemCount: _files.length,
    itemBuilder: (context, index) {
      final file = _files[index];
      final fileName = file.path.split(Platform.pathSeparator).last;
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min, // Para que la fila ocupe solo el espacio necesario
            children: [
              Icon(
                getFileIcon(file), // Función para obtener el ícono del archivo
                color: getFileColor(file), // Función para obtener el color del ícono
              ),
              Checkbox(
                value: _selectedFiles.contains(file.path), // Estado del checkbox
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedFiles.add(file.path); // Agregar archivo a la lista seleccionada
                    } else {
                      _selectedFiles.remove(file.path); // Remover archivo de la lista seleccionada
                    }
                  });
                },
              ),
            ],
          ),
          title: Text(
            fileName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subido el: ${_getUploadDate(file)}'),
              Text('Modificado el: ${_getModifiedDate(file)}'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteFile(file),
          ),
          onTap: () {
            if (file is File) {
              _openFile(file);
            } else if (file is Directory) {
              _listFiles(file.path);
            }
          },
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
  runApp(MaterialApp(
    home: const ActasScreen(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(),
    ),
  )
  )
  );
}
