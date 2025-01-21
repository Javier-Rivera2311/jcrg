import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jcrg/screens/theme_switcher.dart'; // No se elimina el import
import 'package:intl/intl.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({Key? key}) : super(key: key);

  @override
  _MeetingsScreenState createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  final String filePath = r'\\desktop-co5hnd9\SERVIDOR B\Informatica\flutter\reuniones\meetings.json';
  List<dynamic> meetings = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _meetingType = "remoto";

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          meetings = json.decode(content);
        });
      }
    } catch (e) {
      print('Error al leer el archivo: $e');
    }
  }

  Future<void> _saveMeetings() async {
    try {
      final file = File(filePath);
      final content = json.encode(meetings);
      await file.writeAsString(content);
    } catch (e) {
      print('Error al guardar reuniones: $e');
    }
  }

  void _addMeeting() {
    if (_titleController.text.isEmpty ||
        (_meetingType == 'presencial' && _locationController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos obligatorios')),
      );
      return;
    }

    setState(() {
      meetings.add({
        'title': _titleController.text,
        'date': _selectedDate.toIso8601String(),
        'time': _selectedTime.format(context),
        'type': _meetingType,
        'location': _meetingType == 'presencial' ? _locationController.text : null,
      });
    });

    _titleController.clear();
    _locationController.clear();
    _saveMeetings();
    Navigator.pop(context);
  }


void _deleteMeeting(int index) {
  setState(() {
    meetings.removeAt(index);
  });
  _saveMeetings();
}

void _editMeeting(int index) {
  final meeting = meetings[index];
  _titleController.text = meeting['title'] ?? '';
  _selectedDate = DateTime.parse(meeting['date']);
  _selectedTime = TimeOfDay(
    hour: int.parse(meeting['time']?.split(':')[0] ?? '0'),
    minute: int.parse(meeting['time']?.split(':')[1] ?? '0'),
  );
  _meetingType = meeting['type'] ?? 'remoto';
  _locationController.text = meeting['location'] ?? '';

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            backgroundColor: isDarkMode
                ? const Color.fromARGB(255, 40, 40, 40)
                : Colors.white,
            title: Text(
              'Editar Reunión',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Título de la reunión',
                      labelStyle:
                          TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.grey : Colors.black45),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isDarkMode ? Colors.grey : Colors.black45),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fecha: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                            style:
                                TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          ),
                          Icon(Icons.calendar_today,
                              color: isDarkMode ? Colors.white : Colors.black),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (pickedTime != null) {
                        setDialogState(() {
                          _selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isDarkMode ? Colors.grey : Colors.black45),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hora: ${_selectedTime.format(context)}',
                            style:
                                TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          ),
                          Icon(Icons.access_time,
                              color: isDarkMode ? Colors.white : Colors.black),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _meetingType,
                    dropdownColor: isDarkMode
                        ? const Color.fromARGB(255, 50, 50, 50)
                        : Colors.white,
                    items: ['remoto', 'presencial'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type,
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _meetingType = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Tipo de reunión',
                      labelStyle:
                          TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.grey : Colors.black45),
                      ),
                    ),
                  ),
                  if (_meetingType == 'presencial')
                    const SizedBox(height: 8),
                  if (_meetingType == 'presencial')
                    TextField(
                      controller: _locationController,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Ubicación',
                        labelStyle:
                            TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isDarkMode ? Colors.grey : Colors.black45),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar',
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    meetings[index] = {
                      'title': _titleController.text,
                      'date': _selectedDate.toIso8601String(),
                      'time': _selectedTime.format(context),
                      'type': _meetingType,
                      'location': _meetingType == 'presencial'
                          ? _locationController.text
                          : null,
                    };
                  });
                  _saveMeetings();
                  Navigator.pop(context);
                },
                child: Text('Guardar',
                    style: TextStyle(color: isDarkMode ? Colors.blue : Colors.blue)),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showAddMeetingDialog({int? index}) {
  // Si es edición, inicializa los valores del formulario
  if (index != null) {
    final meeting = meetings[index];
    _titleController.text = meeting['title'] ?? '';
    _selectedDate = DateTime.parse(meeting['date']);
    _selectedTime = TimeOfDay(
      hour: int.parse(meeting['time']?.split(':')[0] ?? '0'),
      minute: int.parse(meeting['time']?.split(':')[1] ?? '0'),
    );
    _meetingType = meeting['type'] ?? 'remoto';
    _locationController.text = meeting['location'] ?? '';
  } else {
    // Si es nueva reunión, limpia los valores
    _titleController.clear();
    _locationController.clear();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _meetingType = "remoto";
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(255, 40, 40, 40) // Fondo oscuro
              : Colors.white, // Fondo claro
          title: Text(
            index == null ? 'Agregar Reunión' : 'Editar Reunión',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black, // Color del texto según el tema
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  TextField(
                    controller: _titleController,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Título de la reunión',
                      labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.grey : Colors.black45),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isDarkMode ? Colors.grey : Colors.black45),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                            style:
                                TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          ),
                          Icon(Icons.calendar_today,
                              color: isDarkMode ? Colors.white : Colors.black),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (pickedTime != null) {
                        setDialogState(() {
                          _selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isDarkMode ? Colors.grey : Colors.black45),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hora: ${_selectedTime.format(context)}',
                            style:
                                TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          ),
                          Icon(Icons.access_time,
                              color: isDarkMode ? Colors.white : Colors.black),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _meetingType,
                    dropdownColor: isDarkMode
                        ? const Color.fromARGB(255, 50, 50, 50)
                        : Colors.white,
                    items: ['remoto', 'presencial'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type,
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _meetingType = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Tipo de reunión',
                      labelStyle:
                          TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.grey : Colors.black45),
                      ),
                    ),
                  ),
                  if (_meetingType == 'presencial')
                    const SizedBox(height: 8),
                  if (_meetingType == 'presencial')
                    TextField(
                      controller: _locationController,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Ubicación',
                        labelStyle:
                            TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isDarkMode ? Colors.grey : Colors.black45),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar',
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
              ),
              TextButton(
                onPressed: () {
                  if (index == null) {
                    _addMeeting(); // Agregar nueva reunión
                  } else {
                    setState(() {
                      meetings[index] = {
                        'title': _titleController.text,
                        'date': _selectedDate.toIso8601String(),
                        'time': _selectedTime.format(context),
                        'type': _meetingType,
                        'location': _meetingType == 'presencial'
                            ? _locationController.text
                            : null,
                      };
                    });
                    _saveMeetings(); // Guardar cambios
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  index == null ? 'Guardar' : 'Actualizar',
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
  return Scaffold(
    appBar: AppBar(
      title: const Text('Gestión de Reuniones', style: TextStyle(color: Colors.white)),
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
        ThemeSwitcher(),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: _showAddMeetingDialog,
          tooltip: 'Agregar Reunión',
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(
                label: Text(
                  'Título',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Fecha',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Hora',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Tipo',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Ubicación',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Acciones',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: meetings.asMap().entries.map((entry) {
              final index = entry.key;
              final meeting = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text(meeting['title'] ?? '')),
                  DataCell(Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(meeting['date']).toLocal()))),
                  DataCell(Text(meeting['time'] ?? '')),
                  DataCell(Text(meeting['type'] ?? '')),
                  DataCell(Text(meeting['type'] == 'presencial'
                      ? (meeting['location'] ?? '')
                      : 'N/A')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editMeeting(index),
                        tooltip: 'Editar Reunión',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMeeting(index),
                        tooltip: 'Borrar Reunión',
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    ),
floatingActionButton: Align(
  alignment: Alignment.bottomCenter,
  child: FloatingActionButton.extended(
    onPressed: _showAddMeetingDialog,
    backgroundColor: const Color.fromARGB(255, 76, 78, 175), // Color de fondo
    icon: const Icon(Icons.add, color: Colors.white), // Ícono a la izquierda
    label: const Text('Añadir reunión', style: TextStyle(color: Colors.white)), // Texto del botón
    tooltip: 'Añadir nueva reunión',
  ),
),

    
  );
}
}