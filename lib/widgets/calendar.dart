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
    for (var priority in widget.tasks) {
      for (var task in priority['tasks']) {
        final startDate = DateTime.parse(task['dueDate']);
        appointments.add(
          Appointment(
            startTime: startDate,
            endTime: startDate.add(const Duration(hours: 1)),
            subject: task['title'],
            notes: task['assignee'],
            color: Colors.blue,
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
      ),
    );
  }
}

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Appointment> source) {
    appointments = source;
  }
}
