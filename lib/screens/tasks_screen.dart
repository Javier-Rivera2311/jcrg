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
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[200],
      ),
    );
  }
}

class TaskManagerScreen extends StatefulWidget {
  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final String filePath = r'\\desktop-co5hnd9\SERVIDOR B\Informatica\flutter\tareas\tasks.json';
  List<dynamic> priorities = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _assigneeController = TextEditingController();
  String _selectedPriority = "Dibujantes";
  DateTime _selectedDate = DateTime.now();

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
    } catch (e) {
      print('Error al guardar tareas: $e');
    }
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty && _assigneeController.text.isNotEmpty) {
      final selectedPriority = priorities.firstWhere(
        (p) => p['title'] == _selectedPriority,
        orElse: () => null,
      );

      if (selectedPriority == null) return;

      setState(() {
        selectedPriority['tasks'].add({
          'title': _taskController.text,
          'status': 'Pendiente',
          'assignee': _assigneeController.text,
          'dueDate': _selectedDate.toIso8601String(),
        });
      });

      _taskController.clear();
      _assigneeController.clear();
      _saveTasks();
    }
  }

  void _updateTask(
      int priorityIndex, int taskIndex, String title, String assignee, DateTime dueDate) {
    setState(() {
      priorities[priorityIndex]['tasks'][taskIndex]['title'] = title;
      priorities[priorityIndex]['tasks'][taskIndex]['assignee'] = assignee;
      priorities[priorityIndex]['tasks'][taskIndex]['dueDate'] = dueDate.toIso8601String();
    });
    _saveTasks();
  }

  void _deleteTask(int priorityIndex, int taskIndex) {
    setState(() {
      priorities[priorityIndex]['tasks'].removeAt(taskIndex);
    });
    _saveTasks();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return const Color.fromARGB(255, 255, 5, 5);
      case 'En progreso':
        return const Color.fromARGB(255, 13, 141, 192);
      case 'Completada':
        return const Color.fromARGB(255, 3, 194, 13);
      default:
        return Colors.grey[300]!;
    }
  }

  Future<void> _pickDate(BuildContext context, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      onDateSelected(picked);
    }
  }

  void _editTask(int priorityIndex, int taskIndex) {
    final task = priorities[priorityIndex]['tasks'][taskIndex];
    final TextEditingController editTaskController =
        TextEditingController(text: task['title']);
    final TextEditingController editAssigneeController =
        TextEditingController(text: task['assignee']);
    DateTime editDate = DateTime.parse(task['dueDate']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Tarea'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editTaskController,
                decoration: InputDecoration(labelText: 'Título de la tarea'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: editAssigneeController,
                decoration: InputDecoration(labelText: 'Encargado'),
              ),
              SizedBox(height: 8),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: GestureDetector(
        onTap: () {
          _pickDate(context, (pickedDate) {
            setState(() {
              _selectedDate = pickedDate;
            });
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            'Fecha límite: ${_selectedDate.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ),
    ),
    const SizedBox(width: 8), // Espacio entre la fecha y el icono
    IconButton(
      icon: const Icon(Icons.calendar_today),
      onPressed: () {
        _pickDate(context, (pickedDate) {
          setState(() {
            _selectedDate = pickedDate;
          });
        });
      },
    ),
  ],
),

            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _updateTask(
                  priorityIndex,
                  taskIndex,
                  editTaskController.text,
                  editAssigneeController.text,
                  editDate,
                );
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Gestión de Tareas', style: TextStyle(color: Colors.white)),
      backgroundColor: const Color.fromARGB(255, 107, 135, 182),
    ),
    body: Column(
      children: [
        // Formulario para añadir tareas
        Padding(
          padding: const EdgeInsets.all(8),
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
                decoration: const InputDecoration(
                  labelText: 'Título de la tarea',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _assigneeController,
                decoration: const InputDecoration(
                  labelText: 'Encargado',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fecha límite: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      _pickDate(context, (pickedDate) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _addTask,
                child: const Text('Añadir Tarea'),
              ),
            ],
          ),
        ),
        // Lista de tareas agrupadas por prioridades
        Expanded(
          child: ListView.builder(
            itemCount: priorities.length,
            itemBuilder: (context, priorityIndex) {
              final priority = priorities[priorityIndex];
              return Card(
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: ExpansionTile(
                  title: Text(
                    priority['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  children: priority['tasks'].asMap().entries.map<Widget>((entry) {
                    final taskIndex = entry.key;
                    final task = entry.value;
                    final dueDate = DateTime.parse(task['dueDate']);

                    return ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      title: Text(task['title']),
                      subtitle: Row(
                        children: [
                          Expanded(child: Text('Encargado: ${task['assignee']}')),
                          Text(
                            'Fecha límite: ${dueDate.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            value: task['status'],
                            onChanged: (newStatus) {
                              setState(() {
                                task['status'] = newStatus!;
                                _saveTasks();
                              });
                            },
                            items: ['Pendiente', 'En progreso', 'Completada'].map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(
                                  status,
                                  style: TextStyle(color: _getStatusColor(status)),
                                ),
                              );
                            }).toList(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editTask(priorityIndex, taskIndex),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(priorityIndex, taskIndex),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
