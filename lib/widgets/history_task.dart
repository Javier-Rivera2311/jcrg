import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jcrg/widgets/theme_manager.dart'; // Import the theme_manager.dart file
import 'package:jcrg/screens/theme_switcher.dart'; // Import the theme_switcher.dart file

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
//  final String historyFilePath = r'\\desktop-co5hnd9\SERVIDOR B\Informatica\flutter\tareas\history.json';
  final String historyFilePath = r'C:\Users\javie\OneDrive\Desktop\tests flutter\tareas\history.json';

  List<dynamic> taskHistory = [];
  List<dynamic> filteredTaskHistory = [];
  final TextEditingController _historySearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTaskHistory();
  }

  Future<void> _loadTaskHistory() async {
    try {
      final file = File(historyFilePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          taskHistory = json.decode(content);
          filteredTaskHistory = taskHistory;
        });
      }
    } catch (e) {
      print('Error al leer el archivo de historial: $e');
    }
  }

  Future<void> _saveTaskHistory() async {
    try {
      final file = File(historyFilePath);
      final content = json.encode(taskHistory);
      await file.writeAsString(content);
    } catch (e) {
      print('Error al guardar historial de tareas: $e');
    }
  }

  void _filterTaskHistory(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTaskHistory = taskHistory;
      } else {
        filteredTaskHistory = taskHistory.where((task) {
          final taskTitle = task['title'].toLowerCase();
          final searchQuery = query.toLowerCase();
          return taskTitle.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _deleteHistoryItem(int index) {
    setState(() {
      taskHistory.removeAt(index);
      _filterTaskHistory(_historySearchController.text); // Update filtered list
    });
    _saveTaskHistory(); // Save the updated history
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Tareas', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 107, 135, 182),
        actions: [
          ThemeSwitcher(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _historySearchController,
              decoration: const InputDecoration(
                labelText: 'Buscar en historial...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _filterTaskHistory(value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTaskHistory.length,
              itemBuilder: (context, index) {
                final task = filteredTaskHistory[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(task['title']),
                      subtitle: Text('Encargado: ${task['assignee']} - Fecha límite: ${_formatDate(DateTime.parse(task['dueDate']))}'),
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
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date); // Formato día-mes-año
  }
}
