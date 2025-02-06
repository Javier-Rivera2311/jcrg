import 'dart:io'; // Importar dart:io
import 'dart:typed_data'; // Importar dart:typed_data
import 'dart:convert'; // Importar dart:convert
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Importar FilePicker
import 'package:printing/printing.dart'; // Importar Printing
import 'package:pdf/pdf.dart'; // Importar Pdf
import 'package:pdf/widgets.dart' as pw; // Importar pdf/widgets
import 'package:jcrg/screens/theme_switcher.dart'; // Import ThemeSwitcher
import 'package:jcrg/widgets/history_impressions.dart'; // Importar el historial de impresiones

class ImpressionsScreen extends StatefulWidget {
  const ImpressionsScreen({super.key});

  @override
  ImpressionsScreenState createState() => ImpressionsScreenState();
}

class ImpressionsScreenState extends State<ImpressionsScreen> {
  bool _showHistory = false;
  List<File> _selectedFiles = [];
  List<Map<String, dynamic>> _printHistory = [];
  final String _historyFilePath = r'C:\Users\javie\OneDrive\Desktop\tests flutter\tareas\print_history.json';

  @override
  void initState() {
    super.initState();
    _loadPrintHistory();
  }

  void _togglePrintHistory() {
    setState(() {
      _showHistory = !_showHistory;
    });
  }

  void _selectFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'txt'], // Extensiones permitidas
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.paths.map((path) => File(path!)).toList();
        });
      } else {
        // El usuario canceló la selección
        print('No se seleccionaron archivos.');
      }
    } catch (e) {
      print('Error al seleccionar archivos: $e');
    }
  }

  Future<void> _printFiles() async {
    if (_selectedFiles.isEmpty) {
      _showMessage("No hay archivos seleccionados para imprimir.");
      return;
    }

    for (File file in _selectedFiles) {
      try {
        final fileName = file.path.split('/').last;
        if (fileName.endsWith('.pdf')) {
          // Imprimir archivos PDF
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async =>
                Uint8List.fromList(file.readAsBytesSync()),
          );
        } else if (fileName.endsWith('.png') || fileName.endsWith('.jpg')) {
          // Convertir imágenes a PDF antes de imprimir
          final pdf = await _convertImageToPdf(file);
          await Printing.layoutPdf(onLayout: (PdfPageFormat format) => pdf);
        } else {
          _showMessage("El archivo '$fileName' no es compatible para impresión.");
        }

        // Registrar en el historial de impresiones
        _printHistory.add({
          'fileName': fileName,
          'copies': 1, // Asumimos una copia por archivo
          'timestamp': DateTime.now().toIso8601String(),
        });
        _savePrintHistory();
      } catch (e) {
        _showMessage("Error al imprimir el archivo '${file.path.split('/').last}': $e");
      }
    }

    _showMessage("Proceso de impresión completado.");
  }

  Future<Uint8List> _convertImageToPdf(File imageFile) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageFile.readAsBytesSync());
    pdf.addPage(pw.Page(build: (context) => pw.Center(child: pw.Image(image))));
    return Uint8List.fromList(await pdf.save());
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

  Future<void> _loadPrintHistory() async {
    try {
      final file = File(_historyFilePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _printHistory = json.decode(content);
        });
      }
    } catch (e) {
      print('Error al leer el archivo de historial: $e');
    }
  }

  Future<void> _savePrintHistory() async {
    try {
      final file = File(_historyFilePath);
      final content = json.encode(_printHistory);
      await file.writeAsString(content);
    } catch (e) {
      print('Error al guardar historial de impresiones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showHistory
            ? const Text(
                'Historial de Impresiones',
                style: TextStyle(color: Colors.white),
              )
            : const Text(
                'Gestión de Impresiones',
                style: TextStyle(color: Colors.white),
              ),
        backgroundColor: const Color.fromARGB(255, 107, 135, 182),
        leading: Center(
          child: Image.asset(
            'lib/assets/Log/LOGO.png',
            height: 75,
            width: 75,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          if (!_showHistory)
            IconButton(
              icon: const Icon(Icons.file_upload),
              tooltip: 'Subir Archivos',
              onPressed: _selectFiles,
            ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial de Impresiones',
            onPressed: _togglePrintHistory,
          ),
          ThemeSwitcher(), // Add ThemeSwitcher to AppBar actions
        ],
      ),
      body: _showHistory
          ? const HistoryImpressionsScreen()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _selectedFiles[index];
                      return ListTile(
                        leading: const Icon(Icons.picture_as_pdf),
                        title: Text(file.path.split('/').last),
                      );
                    },
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _printFiles,
                  icon: const Icon(Icons.print),
                  label: const Text('Imprimir Archivos'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    backgroundColor: const Color.fromARGB(255, 76, 78, 175),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }
}