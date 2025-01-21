import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jcrg/screens/theme_switcher.dart'; // No se elimina el import

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

  void _showAddMeetingDialog() {
    _titleController.clear();
    _locationController.clear();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _meetingType = "remoto";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 40, 40, 40), // Fondo oscuro
              title: const Text(
                'Agregar Reunión',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Título de la reunión',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
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
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fecha: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Icon(Icons.calendar_today, color: Colors.white),
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
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hora: ${_selectedTime.format(context)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Icon(Icons.access_time, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _meetingType,
                      dropdownColor: const Color.fromARGB(255, 50, 50, 50),
                      items: ['remoto', 'presencial'].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          _meetingType = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tipo de reunión',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    if (_meetingType == 'presencial')
                      const SizedBox(height: 8),
                    if (_meetingType == 'presencial')
                      TextField(
                        controller: _locationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Ubicación',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: _addMeeting,
                  child: const Text('Guardar', style: TextStyle(color: Colors.blue)),
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
        title: const Text('Gestión de Reuniones'),
        backgroundColor: const Color.fromARGB(255, 107, 135, 182),
        actions: [
          ThemeSwitcher(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMeetingDialog,
            tooltip: 'Agregar Reunión',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: meetings.length,
        itemBuilder: (context, index) {
          final meeting = meetings[index];
          return ListTile(
            title: Text(meeting['title']),
            subtitle: Text(
              'Fecha: ${DateTime.parse(meeting['date']).toLocal().toString().split(' ')[0]}\n'
              'Hora: ${meeting['time']}\n'
              'Tipo: ${meeting['type']}'
              '${meeting['type'] == 'presencial' ? '\nUbicación: ${meeting['location']}' : ''}',
            ),
          );
        },
      ),
    );
  }
}
