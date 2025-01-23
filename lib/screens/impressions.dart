import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:jcrg/screens/theme_switcher.dart'; // Import ThemeSwitcher

class ImpressionsScreen extends StatefulWidget {
  const ImpressionsScreen({super.key});

  @override
  ImpressionsScreenState createState() => ImpressionsScreenState();
}

class ImpressionsScreenState extends State<ImpressionsScreen> {
  List<File> selectedFiles = [];
  Map<File, int> fileCopies = {};

  void _selectFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'txt'], // Extensiones permitidas
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
        for (var file in selectedFiles) {
          fileCopies[file] = 1; // Default to 1 copy per file
        }
      });
    }
  }

  Future<void> _printFiles() async {
    if (selectedFiles.isEmpty) {
      _showMessage("No hay archivos seleccionados para imprimir.");
      return;
    }

    for (File file in selectedFiles) {
      int copies = fileCopies[file] ?? 1;
      for (int i = 1; i <= copies; i++) {
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
          } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
            // Convertir archivos de Word a PDF antes de imprimir
            final pdf = await _convertWordToPdf(file);
            await Printing.layoutPdf(onLayout: (PdfPageFormat format) => pdf);
          } else if (fileName.endsWith('.dwg')) {
            // Convertir archivos de AutoCAD a PDF antes de imprimir
            final pdf = await _convertDwgToPdf(file);
            await Printing.layoutPdf(onLayout: (PdfPageFormat format) => pdf);
          } else {
            _showMessage("El archivo '$fileName' no es compatible para impresión.");
          }
        } catch (e) {
          _showMessage(
              "Error al imprimir el archivo '${file.path.split('/').last}' en la copia $i: $e",
              persistent: true);
        }
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

  Future<Uint8List> _convertWordToPdf(File wordFile) async {
    // Implementar la conversión de Word a PDF
    // Puedes usar paquetes como 'flutter_html_to_pdf' o servicios externos
    throw UnimplementedError("Conversión de Word a PDF no implementada.");
  }

  Future<Uint8List> _convertDwgToPdf(File dwgFile) async {
    // Implementar la conversión de AutoCAD a PDF
    // Puedes usar servicios externos o bibliotecas específicas
    throw UnimplementedError("Conversión de AutoCAD a PDF no implementada.");
  }

  void _showMessage(String message, {bool persistent = false}) {
    if (persistent) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Mensaje'),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Subir Archivos',
            onPressed: _selectFiles,
          ),
          ThemeSwitcher(), // Add ThemeSwitcher to AppBar actions
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mostrar archivos seleccionados
            Expanded(
              child: ListView.builder(
                itemCount: selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = selectedFiles[index];
                  return ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(file.path.split('/').last),
                    trailing: DropdownButton<int>(
                      value: fileCopies[file],
                      onChanged: (value) {
                        setState(() {
                          fileCopies[file] = value!;
                        });
                      },
                      items: List.generate(10, (index) => index + 1)
                          .map((num) => DropdownMenuItem(
                                value: num,
                                child: Text(num.toString()),
                              ))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Botón para enviar a impresión
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
      ),
    );
  }
}