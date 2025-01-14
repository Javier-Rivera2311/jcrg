import 'dart:io';
import 'dart:convert'; // Para manejar JSON
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  String _currentPath = r'\\desktop-co5hnd9\SERVIDOR B';
  List<FileSystemEntity> _files = [];
  List<FileSystemEntity> _filteredFiles = [];
  final Map<String, DateTime> _fileRegistry = {}; // Registro de archivos con fechas
  final String _registryPath = r'\\desktop-co5hnd9\SERVIDOR B\Informatica\flutter\tareas\registry.json';
  final List<String> _selectedFiles = []; // Lista de archivos seleccionados para mover
  final TextEditingController _searchController = TextEditingController(); // Controlador para el buscador

  @override
  void initState() {
    super.initState();
    _loadRegistry(); // Cargar registro persistente
    _listFiles(_currentPath);
  }

  // Cargar el registro desde el archivo JSON
  void _loadRegistry() {
    final registryFile = File(_registryPath);
    if (registryFile.existsSync()) {
      final content = registryFile.readAsStringSync();
      final Map<String, dynamic> jsonRegistry = jsonDecode(content);
      setState(() {
        jsonRegistry.forEach((key, value) {
          _fileRegistry[key] = DateTime.parse(value);
        });
      });
    }
  }

  // Guardar el registro en un archivo JSON
  void _saveRegistry() {
    final registryFile = File(_registryPath);
    final jsonRegistry = _fileRegistry.map((key, value) => MapEntry(key, value.toIso8601String()));
    registryFile.writeAsStringSync(jsonEncode(jsonRegistry));
  }

void _listFiles(String path) {
  final directory = Directory(path);
  try {
    final files = directory.listSync();
    setState(() {
      _currentPath = path;

      // Filtrar archivos y carpetas ocultos o específicos
      _files = files.where((file) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        // Excluir archivos o carpetas no deseados
        if (fileName.startsWith(r'$') || 
            fileName == 'System Volume Information' || 
            fileName == ".BIN"  || fileName =="desktop.ini" )
            {
          return false;
        }
        return true;
      }).toList();

      _filteredFiles = _files;

      // Eliminar del registro los archivos que ya no existen
      _fileRegistry.removeWhere((key, value) => !File(key).existsSync());
      _saveRegistry(); // Guardar cambios en el registro
    });
  } catch (e) {
    _showMessage('Error al acceder al directorio: $e');
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

  Future<void> _selectFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true, // Permitir selección múltiple
        type: FileType.any,  // Permitir cualquier tipo de archivo
      );

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          final newFilePath = '$_currentPath${Platform.pathSeparator}${file.name}';
          final selectedFile = File(file.path!);

          if (File(newFilePath).existsSync()) {
            await selectedFile.copy(newFilePath);
            setState(() {
              _fileRegistry[newFilePath] = DateTime.now();
            });
          } else {
            await selectedFile.copy(newFilePath);
            setState(() {
              _fileRegistry[newFilePath] = DateTime.now();
            });
          }

          _listFiles(_currentPath); // Actualizar lista
        }

        _saveRegistry(); // Guardar el registro actualizado
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
                  final newFolderPath = '$_currentPath${Platform.pathSeparator}$folderName';
                  final newFolder = Directory(newFolderPath);
                  if (!newFolder.existsSync()) {
                    newFolder.createSync();
                    _listFiles(_currentPath); // Actualizar lista de archivos
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
          final file = File(filePath);
          final newFilePath = '$result${Platform.pathSeparator}${file.path.split(Platform.pathSeparator).last}';
          file.renameSync(newFilePath);

          setState(() {
            _fileRegistry.remove(file.path);
            _fileRegistry[newFilePath] = DateTime.now();
          });
        }

        _listFiles(_currentPath);
        _saveRegistry();
        _showMessage('Archivos movidos exitosamente.');
        _selectedFiles.clear();
      }
    } catch (e) {
      _showMessage('Error al mover archivos: $e');
    }
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

  void _filterFiles(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFiles = _files;
      });
    } else {
      setState(() {
        _filteredFiles = _files.where((file) {
          final fileName = file.path.split(Platform.pathSeparator).last;
          return fileName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void _deleteFile(FileSystemEntity file) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Archivo'),
          content: Text('¿Estás seguro de que deseas eliminar el archivo "${file.path.split(Platform.pathSeparator).last}"? Esta acción no se puede deshacer.'),
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
        file.deleteSync();
        setState(() {
          _fileRegistry.remove(file.path);
          _listFiles(_currentPath);
        });
        _showMessage('Archivo eliminado exitosamente.');
      }
    } catch (e) {
      _showMessage('Error al eliminar el archivo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SERVIDOR B',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 107, 135, 182),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar archivos...',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterFiles,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final parentDir = Directory(_currentPath).parent.path;
                    _listFiles(parentDir);
                  },
                  child: const Text('Atrás'),
                ),
                ElevatedButton(
                  onPressed: _selectFiles,
                  child: const Text('Subir Archivos'),
                ),
                ElevatedButton(
                  onPressed: _selectedFiles.isNotEmpty ? _moveSelectedFiles : null,
                  child: const Text('Mover Archivos seleccionados'),
                ),
                ElevatedButton(
                  onPressed: _createFolder,
                  child: const Text('Nueva Carpeta'),
                ),
              ],
            ),
          ),

  Expanded(
  child: ListView.builder(
    itemCount: _filteredFiles.length,
    itemBuilder: (context, index) {
      final file = _filteredFiles[index];
      final fileName = file.path.split(Platform.pathSeparator).last;

      // Formatear fecha de última modificación
      final lastModified = file.statSync().modified;
      final lastModifiedFormatted = DateFormat('dd-MM-yyyy HH:mm').format(lastModified);

      // Fecha de subida
      final uploadedAt = _fileRegistry[file.path] != null
          ? DateFormat('dd-MM-yyyy HH:mm').format(_fileRegistry[file.path]!)
          : 'No registrado';

      return ListTile(
        leading: Checkbox(
          value: _selectedFiles.contains(file.path),
          onChanged: (isSelected) {
            setState(() {
              if (isSelected ?? false) {
                _selectedFiles.add(file.path);
              } else {
                _selectedFiles.remove(file.path);
              }
            });
          },
        ),
        title: Text(fileName),
        subtitle: Row(
          children: [
            Text(
              'Subido el: $uploadedAt',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 16), // Espaciado horizontal
            Text(
              'Modificado el: $lastModifiedFormatted',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteFile(file),
        ),
        onTap: () {
          if (file is Directory) {
            _listFiles(file.path);
          } else if (file is File) {
            _openFile(file);
          }
        },
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
    title: 'Explorador de Archivos',
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.grey[200], // Color de fondo del scaffold
    ),
    home: const FileExplorer(),
  ));
}
