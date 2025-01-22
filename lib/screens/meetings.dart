import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jcrg/screens/theme_switcher.dart'; // No se elimina el import
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({Key? key}) : super(key: key);

  @override
  _MeetingsScreenState createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  final String filePath = r'\\desktop-co5hnd9\SERVIDOR B\Informatica\flutter\reuniones\meetings.json';
  List<dynamic> meetings = [];
  List<dynamic> filteredMeetings = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
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
        filteredMeetings = List.from(meetings); // Copia la lista original
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

void _filterMeetings(String query) {
  setState(() {
    if (query.isEmpty) {
      filteredMeetings = List.from(meetings); // Restaura la lista original
    } else {
      filteredMeetings = meetings.where((meeting) {
        return (meeting['title'] as String).toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  });
}


void _addMeeting() {
  if (_titleController.text.isEmpty ||
      (_meetingType == 'presencial' && _locationController.text.isEmpty)) {
    return;
  }

  setState(() {
    final newMeeting = {
      'title': _titleController.text,
      'date': _selectedDate.toIso8601String(),
      'time': _selectedTime.format(context),
      'type': _meetingType,
      'location': _meetingType == 'presencial' ? _locationController.text : null,
      'url': _meetingType == 'remoto' ? _urlController.text : null,
    };

    meetings.add(newMeeting);
    _filterMeetings(''); // Actualiza la lista filtrada para mostrar la nueva reunión
  });

  _titleController.clear();
  _locationController.clear();
  _urlController.clear();
  _saveMeetings();
  Navigator.pop(context);
}

void _deleteMeeting(int index) {
  setState(() {
    meetings.removeAt(index);
    _filterMeetings(''); // Actualiza la lista filtrada
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
  _urlController.text = meeting['url'] ?? '';

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
                  //AJUSTE CUADRO DE DIALOGO DE EDITAR REUNION
                    GestureDetector(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData(
                                colorScheme: Theme.of(context).brightness == Brightness.dark
                                    ? ColorScheme.dark(
                                        primary: Colors.blue, // Color del botón principal
                                        surface: Colors.grey[900]!, // Fondo sólido oscuro
                                        onSurface: Colors.white, // Color del texto
                                      )
                                    : ColorScheme.light(
                                        primary: Colors.blue, // Color del botón principal
                                        surface: Colors.white, // Fondo sólido claro
                                        onSurface: Colors.black, // Color del texto
                                      ),
                              ),
                              child: child!,
                            );
                          },
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
                            color: isDarkMode ? Colors.grey : Colors.black45,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
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
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData(
                                colorScheme: Theme.of(context).brightness == Brightness.dark
                                    ? ColorScheme.dark(
                                        primary: Colors.blue, // Color del botón principal
                                        surface: Colors.grey[900]!, // Fondo sólido oscuro
                                        onSurface: Colors.white, // Color del texto
                                      )
                                    : ColorScheme.light(
                                        primary: Colors.blue, // Color del botón principal
                                        surface: Colors.white, // Fondo sólido claro
                                        onSurface: Colors.black, // Color del texto
                                      ),
                              ),
                              child: child!,
                            );
                          },
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
                            color: isDarkMode ? Colors.grey : Colors.black45,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hora: ${_selectedTime.format(context)}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Icon(
                              Icons.access_time,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
// FIN DE CUADRO DE DIALOGO DE EDITAR REUNION
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
                  if (_meetingType == 'remoto')
                    TextField(
                      controller: _urlController,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'URL/Link de la reunión',
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
                      'url': _meetingType == 'remoto'
                          ? _urlController.text
                          : null,
                    };
                    filteredMeetings = List.from(meetings); // Actualizar la lista filtrada
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
          backgroundColor: isDarkMode
              ? const Color.fromARGB(255, 40, 40, 40)
              : Colors.white,
          title: Text(
            index == null ? 'Agregar Reunión' : 'Editar Reunión',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
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

                //Cuadro de dialogo Fecha
                  GestureDetector(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData(
                              colorScheme: Theme.of(context).brightness == Brightness.dark
                                  ? ColorScheme.dark(
                                      primary: Colors.blue,
                                      surface: Colors.grey[900]!,
                                      onSurface: Colors.white,
                                    )
                                  : ColorScheme.light(
                                      primary: Colors.blue,
                                      surface: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                            ),
                            child: child!,
                          );
                        },
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey
                              : Colors.black45,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                //Cuadro de dialogo tiempo (hora)
                  GestureDetector(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData(
                              colorScheme: Theme.of(context).brightness == Brightness.dark
                                  ? ColorScheme.dark(
                                      primary: Colors.blue,
                                      surface: Colors.grey[900]!,
                                      onSurface: Colors.white,
                                    )
                                  : ColorScheme.light(
                                      primary: Colors.blue,
                                      surface: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                            ),
                            child: child!,
                          );
                        },
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey
                              : Colors.black45,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hora: ${_selectedTime.format(context)}',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.access_time,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
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
                if (_meetingType == 'remoto')
                  TextField(
                    controller: _urlController,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'URL/Link de la reunión',
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
                      'url': _meetingType == 'remoto'
                          ? _urlController.text
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
      title: const Text('Lista de Reuniones', style: TextStyle(color: Colors.white)),
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

//Vista del contenido en una tabla

body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      // Barra de búsqueda
      TextField(
        onChanged: _filterMeetings,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Buscar reunión',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
      const SizedBox(height: 16),
      // Tabla
Expanded(
  child: Padding(
    padding: const EdgeInsets.only(top: 16.0), // Espaciado debajo de la barra de búsqueda
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) =>
              Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 60, 60, 60)
                  : const Color.fromARGB(255, 230, 230, 230),
        ),
        columnSpacing: 32.0,
        horizontalMargin: 16.0,
        columns: const [
          DataColumn(
            label: Text(
              'Título',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          DataColumn(
            label: Text(
              'Fecha',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          DataColumn(
            label: Text(
              'Hora',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          DataColumn(
            label: Text(
              'Tipo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          DataColumn(
            label: Text(
              'Detalles (Link / ubicación)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          DataColumn(
            label: Text(
              'Editar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          DataColumn(
            label: Text(
              'Borrar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ],
        rows: filteredMeetings.map((meeting) {
          final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return DataRow(
            color: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) => filteredMeetings.indexOf(meeting) % 2 == 0
                  ? (isDarkMode
                      ? const Color.fromARGB(255, 50, 50, 50)
                      : const Color.fromARGB(255, 245, 245, 245))
                  : (isDarkMode
                      ? const Color.fromARGB(255, 40, 40, 40)
                      : Colors.white),
            ),
            cells: [
              DataCell(Text(
                meeting['title'] ?? 'Sin título',
                style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18),
              )),
              DataCell(Text(
                DateFormat('dd/MM/yyyy')
                    .format(DateTime.parse(meeting['date']).toLocal()),
                style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18),
              )),
              DataCell(Text(
                meeting['time'] ?? '',
                style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18),
              )),
              DataCell(Text(
                meeting['type'] ?? '',
                style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18),
              )),
DataCell(
  meeting['type'] == 'presencial'
      ? Row(
          children: [
            Expanded(
              child: Text(
                meeting['location'] != null && meeting['location']!.length > 15
                    ? '${meeting['location']!.substring(0, 15)}...' // Mostrar solo los primeros 15 caracteres
                    : meeting['location'] ?? 'N/A',
                style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.blue),
              tooltip: 'Copiar ubicación',
              onPressed: () {
                if (meeting['location'] != null) {
                  Clipboard.setData(
                      ClipboardData(text: meeting['location']!));
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Ubicación copiada'),
                        content: const Text(
                            'La ubicación se ha copiado al portapapeles.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        )
      : Row(
          children: [
            Expanded(
              child: Text(
                meeting['url'] != null && meeting['url']!.length > 15
                    ? '${meeting['url']!.substring(0, 40)}...' // Mostrar solo los primeros 15 caracteres
                    : meeting['url'] ?? 'N/A',
                style: const TextStyle(color: Colors.blue, fontSize: 18),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.blue),
              tooltip: 'Copiar URL',
              onPressed: () {
                if (meeting['url'] != null) {
                  Clipboard.setData(
                      ClipboardData(text: meeting['url']!));
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('URL copiada'),
                        content: const Text(
                            'El URL se ha copiado al portapapeles.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
),

              DataCell(
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Editar reunión',
                  onPressed: () =>
                      _editMeeting(filteredMeetings.indexOf(meeting)),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Borrar reunión',
                  onPressed: () =>
                      _deleteMeeting(meetings.indexOf(meeting)),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ),
  ),
),


    ],
  ),
),
floatingActionButton: Align(
  alignment: Alignment.bottomCenter,
  child: FloatingActionButton.extended(
    onPressed: _showAddMeetingDialog,
    backgroundColor: const Color.fromARGB(255, 76, 78, 175),
    icon: const Icon(Icons.add, color: Colors.white),
    label: const Text('Añadir reunión', style: TextStyle(color: Colors.white)),
    tooltip: 'Añadir nueva reunión',
  ),
),


  );
}
}