import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  DateTime editDate = task['dueDate'] != null
      ? DateTime.parse(task['dueDate'])
      : DateTime.now(); // Usa la fecha actual si no existe dueDate

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Editar Tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editTaskController,
              decoration: const InputDecoration(labelText: 'Título de la tarea'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: editAssigneeController,
              decoration: const InputDecoration(labelText: 'Encargado(a)'),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: editDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    editDate = pickedDate; // Actualiza la fecha seleccionada
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Fecha límite: ${editDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _updateTask(
                priorityIndex,
                taskIndex,
                editTaskController.text,
                editAssigneeController.text,
                editDate, // Usa la fecha actualizada
              );
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}
String _formatDate(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date); // Formato día-mes-año
}

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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Fecha límite: ${_formatDate(_selectedDate)}', // Usar _formatDate aquí
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
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
              const SizedBox(height: 16),
              Center(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.green), // Color de fondo personalizado
                        foregroundColor: MaterialStateProperty.all(Colors.white), // Color del texto
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _addTask,
                    child: const Text('Añadir Tarea'),
                  ),
                ),
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

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['title'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        Text('Encargado: ${task['assignee']}'),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Fecha límite: ${_formatDate(dueDate)}', // Usar _formatDate aquí
                                          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
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
                                  const SizedBox(width: 10),
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
                            ],
                          ),
                        ),
                        const Divider(thickness: 1, height: 1, color: Colors.grey), // Línea horizontal
                      ],
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