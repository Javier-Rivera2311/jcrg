import 'dart:io';
import 'dart:convert'; // Para manejar JSON
import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart' as MaterialColors;

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  String _currentPath = r'\\desktop-co5hnd9\SERVIDOR B\01.- PROYECTOS';
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

      // Filtrar archivos y carpetas ocultos o del sistema
      _files = files.where((file) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        // Excluir archivos o carpetas ocultos y aquellos específicos como System Volume Information
        if (fileName.startsWith(r'$') || fileName == 'System Volume Information') {
          return false;
        }

        // En sistemas Windows, se podría verificar si es un archivo oculto
        if (file is File || file is Directory) {
          try {
            final attributes = FileStat.statSync(file.path);
            return !(attributes.modeString().contains('hidden') || attributes.modeString().contains('system'));
          } catch (_) {
            return true; // En caso de error, asumimos que no es oculto
          }
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

  // Método para subir archivos
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
            // Si el archivo ya existe, actualizar su fecha y hora
            await selectedFile.copy(newFilePath);
            setState(() {
              _fileRegistry[newFilePath] = DateTime.now();
            });
          } else {
            // Si el archivo es nuevo, agregarlo al registro
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

  // Crear una nueva carpeta
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
            Button(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // Mover archivos seleccionados
  void _moveSelectedFiles() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(); // Seleccionar carpeta de destino
      if (result != null) {
        for (var filePath in _selectedFiles) {
          final file = File(filePath);
          final newFilePath = '$result${Platform.pathSeparator}${file.path.split(Platform.pathSeparator).last}';
          file.renameSync(newFilePath);

          setState(() {
            _fileRegistry.remove(file.path); // Eliminar del registro el archivo antiguo
            _fileRegistry[newFilePath] = DateTime.now(); // Registrar el archivo en su nueva ubicación
          });
        }

        _listFiles(_currentPath); // Actualizar lista de archivos
        _saveRegistry(); // Guardar el registro actualizado
        _showMessage('Archivos movidos exitosamente.');
        _selectedFiles.clear(); // Limpiar selección
      }
    } catch (e) {
      _showMessage('Error al mover archivos: $e');
    }
  }
// Método para abrir un archivo
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

  // Buscar archivos
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

// Método para confirmar y eliminar un archivo
void _deleteFile(FileSystemEntity file) {
  showDialog(
    context: context,
    builder: (context) {
      return ContentDialog(
        title: const Text('Eliminar Archivo'),
        content: Text('¿Estás seguro de que deseas eliminar el archivo "${file.path.split(Platform.pathSeparator).last}"? Esta acción no se puede deshacer.'),
        actions: [
          Button(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.pop(context); // Cierra el cuadro de diálogo
            },
          ),
          Button(
            child: const Text('Eliminar'),
            onPressed: () {
              Navigator.pop(context); // Cierra el cuadro de diálogo
              _performDeleteFile(file); // Llama al método que realiza la eliminación
            },
          ),
        ],
      );
    },
  );
}

// Método para realizar la eliminación del archivo
void _performDeleteFile(FileSystemEntity file) {
  try {
    if (file.existsSync()) {
      file.deleteSync();
      setState(() {
        _fileRegistry.remove(file.path); // Eliminar del registro
        _listFiles(_currentPath); // Actualizar lista de archivos
      });
      _showMessage('Archivo eliminado exitosamente.');
    }
  } catch (e) {
    _showMessage('Error al eliminar el archivo: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text("Explorador de Archivos - $_currentPath"),
commandBar: Wrap(
  spacing: 8.0, // Espaciado entre botones
  runSpacing: 4.0, // Espaciado entre líneas de botones
  children: [
    if (_currentPath != Directory.current.path)
      Button(
        child: const Text("Atrás"),
        onPressed: () {
          final parentDir = Directory(_currentPath).parent.path;
          _listFiles(parentDir);
        },
      ),
    Button(
      child: const Text("Subir Archivos"),
      onPressed: _selectFiles,
    ),
    Button(
      child: const Text("Mover Archivos Seleccionados"),
      onPressed: _selectedFiles.isNotEmpty ? _moveSelectedFiles : null,
    ),
    Button(
      child: const Text("Crear Carpeta"),
      onPressed: _createFolder,
    ),
  ],
),

      ),
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextBox(
              controller: _searchController,
              placeholder: "Buscar archivos...",
              onChanged: _filterFiles,
            ),
          ),
Expanded(
  child: ListView.builder(
    itemCount: _filteredFiles.length,
    itemBuilder: (context, index) {
      final file = _filteredFiles[index];
      final fileName = file.path.split(Platform.pathSeparator).last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final uploadedAt = _fileRegistry[file.path] != null
          ? DateFormat('dd-MM-yyyy HH:mm').format(_fileRegistry[file.path]!)
          : 'No registrado';

// Determinar color e ícono por tipo de archivo
// Determinar color e ícono por tipo de archivo
final Color fileColor = {
  'docx': MaterialColors.Colors.blue,
  'pdf': MaterialColors.Colors.red,
  'xlsx': MaterialColors.Colors.green,
  'txt': MaterialColors.Colors.grey,
  'jpg': MaterialColors.Colors.orange,
  'png': MaterialColors.Colors.purple,
  'dwg': MaterialColors.Colors.cyan, // DWG de AutoCAD
  'dxf': MaterialColors.Colors.teal,       // DXF de AutoCAD
}[fileExtension] ?? MaterialColors.Colors.black;


final IconData fileIcon = {
  'docx': FluentIcons.page, // Icono genérico para Word
  'pdf': FluentIcons.pdf,
  'xlsx': FluentIcons.excel_document,
  'txt': FluentIcons.text_document,
  'jpg': FluentIcons.photo2,
  'png': FluentIcons.photo2,
  'dwg': FluentIcons.auto_racing, // DWG
  'dxf': FluentIcons.settings, // Reemplazo para DXF
}[fileExtension] ?? FluentIcons.page;
      return Row(
        children: [
          Checkbox(
            checked: _selectedFiles.contains(file.path),
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
          Expanded(
            child: HoverButton(
              onPressed: () {
                if (file is Directory) {
                  _listFiles(file.path);
                } else if (file is File) {
                  _openFile(file);
                }
              },
              builder: (context, states) => Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: MaterialColors.Colors.grey[200]!,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      fileIcon,
                      color: fileColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: fileColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Subido el: $uploadedAt',
                            style: const TextStyle(
                              fontSize: 12,
                              color: MaterialColors.Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.delete),
                      onPressed: () => _deleteFile(file),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
