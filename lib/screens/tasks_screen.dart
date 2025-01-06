import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TaskManagerScreen(),
    );
  }
}

class TaskManagerScreen extends StatefulWidget {
  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final String filePath = r'\\desktop-co5hnd9\SERVIDOR B\Informatica\flutter\tareas\tasks.json';
  //final String filePath = r'C:\Users\javie\OneDrive\Desktop\tests flutter\tareas\tasks.json';
  
  List<dynamic> priorities = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _assigneeController = TextEditingController();
  String _selectedPriority = 'P1';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          priorities = json.decode(content);
        });
      } else {
        print('El archivo no existe.');
      }
    } catch (e) {
      print('Error al leer el archivo: $e');
    }
  }

  Future<void> _saveTasks() async {
    try {
      final file = File(filePath);
      final content = json.encode(priorities);
      await file.writeAsString(content);
      print('Tareas guardadas exitosamente.');
    } catch (e) {
      print('Error al guardar tareas: $e');
    }
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty && _assigneeController.text.isNotEmpty) {
      if (priorities.isEmpty) {
        print('No hay prioridades disponibles.');
        return;
      }

      final selectedPriority = priorities.firstWhere(
        (p) => p['title'] == _selectedPriority,
        orElse: () => null,
      );

      if (selectedPriority == null) {
        print('No se encontró la prioridad seleccionada: $_selectedPriority');
        return;
      }

      setState(() {
        selectedPriority['tasks'].add({
          'title': _taskController.text,
          'status': 'To-do',
          'assignee': _assigneeController.text,
          'size': 'M',
          'estimate': 1,
        });
      });

      _taskController.clear();
      _assigneeController.clear();
      _saveTasks();
    }
  }

  void _updateTaskStatus(int priorityIndex, int taskIndex, String newStatus) {
    setState(() {
      priorities[priorityIndex]['tasks'][taskIndex]['status'] = newStatus;
    });
    _saveTasks();
  }

  void _deleteTask(int priorityIndex, int taskIndex) {
    setState(() {
      priorities[priorityIndex]['tasks'].removeAt(taskIndex);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tareas'),
      ),
      body: Column(
        children: [
          // Formulario para agregar tareas
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: _selectedPriority,
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value!;
                    });
                  },
                  items: priorities.map<DropdownMenuItem<String>>((priority) {
                    return DropdownMenuItem(
                      value: priority['title'],
                      child: Text(priority['title']),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(labelText: 'Titulo de la tarea'),
                ),
                TextField(
                  controller: _assigneeController,
                  decoration: InputDecoration(labelText: 'Encargado'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Añadir Tarea'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: priorities.length,
              itemBuilder: (context, priorityIndex) {
                final priority = priorities[priorityIndex];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${priority['title']} (Estimate: ${priority['estimate']})',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        ...priority['tasks'].asMap().entries.map<Widget>((entry) {
                          final taskIndex = entry.key;
                          final task = entry.value;
                          return ListTile(
                            title: Text(task['title']),
                            subtitle: Text(
                                'Status: ${task['status']} - Assignee: ${task['assignee']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<String>(
                                  value: task['status'],
                                  onChanged: (newStatus) {
                                    _updateTaskStatus(priorityIndex, taskIndex, newStatus!);
                                  },
                                  items: ['To-do', 'In progress', 'Done']
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status),
                                          ))
                                      .toList(),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteTask(priorityIndex, taskIndex);
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
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
