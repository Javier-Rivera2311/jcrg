import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:jcrg/screens/theme_switcher.dart';

class CalendarScreen extends StatefulWidget {
  final List<dynamic> tasks;

  const CalendarScreen({Key? key, required this.tasks}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _generateAppointments();
  }

  void _generateAppointments() {
    List<Appointment> appointments = [];
    Map<String, Color> sectionColors = {
      'Dibujantes': Colors.blue,
      'Ingeniería': Colors.green,
      'Administrativo': Colors.orange,
      'Entregas': Colors.red,
      'Revisión': Colors.purple,
    };

    for (var priority in widget.tasks) {
      for (var task in priority['tasks']) {
        final startDate = DateTime.parse(task['dueDate']);
        appointments.add(
          Appointment(
            startTime: startDate,
            endTime: startDate.add(const Duration(hours: 1)),
            subject: task['title'],
            notes: task['assignee'],
            color: sectionColors[priority['title']] ?? Colors.grey,
          ),
        );
      }
    }
    setState(() {
      _appointments = appointments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 107, 135, 182),
        actions: [
          ThemeSwitcher(),
        ],
      ),
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: TaskDataSource(_appointments),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        appointmentBuilder: (context, details) {
          final Appointment appointment = details.appointments.first;
          return Tooltip(
            message: 'Tarea: ${appointment.subject}\nEncargado: ${appointment.notes}',
            child: Container(
              width: details.bounds.width,
              height: details.bounds.height,
              decoration: BoxDecoration(
                color: appointment.color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    appointment.subject,
                    style: const TextStyle(
                      fontSize: 16, // Base font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Appointment> source) {
    appointments = source;
  }
}
