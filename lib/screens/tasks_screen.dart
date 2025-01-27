import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jcrg/screens/theme_switcher.dart';
import 'package:provider/provider.dart';
import 'package:jcrg/widgets/theme_manager.dart';
import 'package:jcrg/widgets/calendar_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(), // Usamos Provider para manejar el tema
      child: TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Recuperamos el ThemeNotifier desde el Provider
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.themeMode, // Usamos el ThemeNotifier para manejar el tema
      home: const TaskManagerScreen(), // Pantalla principal
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés (por defecto)
      ],
      locale: const Locale('es', 'ES'), // Forzar español como idioma
    );
  }
}

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({Key? key}) : super(key: key);

  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final String filePath = r'\\desktop-co5hnd9\SERVIDOR B\Informatica\flutter\tareas\tasks.json';
  List<dynamic> priorities = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _assigneeController = TextEditingController();
  String _selectedPriority = "Dibujantes";
  DateTime _selectedDate = DateTime.now();
  bool _isAddingTask = false; // Controla la visibilidad del formulario de añadir tarea

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
        selectedPriority['tasks'].sort((a, b) => DateTime.parse(a['dueDate']).compareTo(DateTime.parse(b['dueDate']))); // Ordenar tareas por fecha
        _isAddingTask = false; // Ocultar el formulario después de añadir la tarea
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
      return StatefulBuilder(
        builder: (context, setState) {
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
                      color: const Color.fromARGB(255, 255, 255, 255),
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Fecha límite: ${_formatDate(editDate)}',
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
    },
  );
}

String _formatDate(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date); // Formato día-mes-año
}

Color _getDueDateColor(DateTime dueDate) {
  final now = DateTime.now();
  if (dueDate.isBefore(now)) {
    return const Color.fromARGB(255, 204, 14, 0); // Atrasado
  } else if (dueDate.isSameDate(now)) {
    return const Color.fromARGB(255, 255, 165, 0); // Mismo día (naranja)
  } else {
    return Colors.blue; // Tiene tiempo
  }
}

void _showAddTaskDialog() {
  showDialog(
    context: context,
    builder: (context) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: isDarkMode
                ? const Color.fromARGB(255, 40, 40, 40)
                : Colors.white,
            title: Text(
              'Añadir Tarea',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 8),
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    labelText: 'Título de la tarea',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _assigneeController,
                  decoration: InputDecoration(
                    labelText: 'Encargado',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha límite: ${_formatDate(_selectedDate)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _getDueDateColor(_selectedDate),
                      ),
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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _taskController.clear();
                  _assigneeController.clear();
                },
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              TextButton(
                onPressed: () {
                  _addTask();
                  Navigator.pop(context);
                },
                child: Text(
                  'Guardar',
                  style: TextStyle(color: isDarkMode ? Colors.blue : Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Gestión de Tareas', style: TextStyle(color: Colors.white, fontSize: 22)),
      backgroundColor: const Color.fromARGB(255, 107, 135, 182),
      leading: Center(
          child: Image.asset(
            'lib/assets/Log/LOGO.png', // Asegúrate de que esta ruta sea correcta
            height: 75,
            width: 75,
            fit: BoxFit.contain, // Ajusta la imagen si es necesario
          ),
      ),
      actions: [
        ThemeSwitcher(),
       IconButton(
          icon: const Icon(Icons.calendar_today),
          color: Colors.white,  // Ícono de calendario
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CalendarScreen(tasks: priorities),
              ),
            );
          },
          tooltip: 'Ver Calendario',
        ),
      ],
      
    ),
    
body: Column(
  children: [
    Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Lista de tareas agrupadas por prioridades
              ...priorities.map((priority) {
                return Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: ExpansionTile(
                    title: Text(
                      priority['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      Row(
                                        children: [
                                          Text('Encargado: ${task['assignee']}', style: const TextStyle(fontSize: 16)),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Fecha límite: ${_formatDate(dueDate)}',
                                            style: TextStyle(
                                              color: _getDueDateColor(dueDate),
                                              fontSize: 16,
                                            ),
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
                                            style: TextStyle(color: _getStatusColor(status), fontSize: 16),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editTask(
                                        priorities.indexOf(priority),
                                        taskIndex,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteTask(
                                        priorities.indexOf(priority),
                                        taskIndex,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(thickness: 1, height: 1, color: Colors.grey),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _showAddTaskDialog,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 76, 78, 175)), // Cambia el color de fondo
          foregroundColor: MaterialStateProperty.all(Colors.white), // Cambia el color del texto
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Ajusta el tamaño del botón
          ),
        ),
        child: const Text('Añadir Tarea', style: TextStyle(fontSize: 18)),
      ),
    ),
  ],
),
  );
}
}