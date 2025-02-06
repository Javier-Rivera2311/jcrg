import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importar la librería intl
import 'package:jcrg/screens/theme_switcher.dart'; // Import ThemeSwitcher

class HistoryImpressionsScreen extends StatefulWidget {
  const HistoryImpressionsScreen({super.key});

  @override
  HistoryImpressionsScreenState createState() => HistoryImpressionsScreenState();
}

class HistoryImpressionsScreenState extends State<HistoryImpressionsScreen> {
  List<Map<String, dynamic>> printHistory = [];
  final String historyFilePath = r'C:\Users\javie\OneDrive\Desktop\tests flutter\tareas\print_history.json';

  List<dynamic> filteredPrintHistory = [];
  final TextEditingController _historySearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrintHistory();
  }

  Future<void> _loadPrintHistory() async {
    try {
      final file = File(historyFilePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          printHistory = List<Map<String, dynamic>>.from(json.decode(content));
          filteredPrintHistory = printHistory;
        });
      }
    } catch (e) {
      print('Error al leer el archivo de historial: $e');
    }
  }

  Future<void> _savePrintHistory() async {
    try {
      final file = File(historyFilePath);
      final content = json.encode(printHistory);
      await file.writeAsString(content);
    } catch (e) {
      print('Error al guardar historial de impresiones: $e');
    }
  }

  void _filterPrintHistory(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPrintHistory = printHistory;
      } else {
        filteredPrintHistory = printHistory.where((item) {
          final fileName = item['fileName'].toLowerCase();
          final searchQuery = query.toLowerCase();
          return fileName.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _deleteHistoryItem(int index) {
    setState(() {
      printHistory.removeAt(index);
      _filterPrintHistory(_historySearchController.text); // Update filtered list
    });
    _savePrintHistory(); // Save the updated history
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Historial de impresión
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _historySearchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar en historial...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _filterPrintHistory(value),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredPrintHistory.length,
                itemBuilder: (context, index) {
                  final item = filteredPrintHistory[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(item['fileName']),
                        subtitle: Text('Copias: ${item['copies']} - Fecha: ${_formatDate(DateTime.parse(item['timestamp']))}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteHistoryItem(index),
                        ),
                      ),
                      const Divider(thickness: 1, height: 1, color: Colors.grey),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy HH:mm').format(date); // Formato día-mes-año hora:minuto
  }
}
