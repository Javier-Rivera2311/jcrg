import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:jcrg/screens/theme_switcher.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final List<dynamic> meetings;

  const CalendarScreen({Key? key, required this.meetings}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late List<Appointment> _appointments = [];
  CalendarController _calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    _generateAppointments();
  }

  void _generateAppointments() {
    List<Appointment> appointments = [];
    Map<String, Color> meetingColors = {
      'remoto': Colors.blue,
      'presencial': Colors.green,
    };

    for (var meeting in widget.meetings) {
      final startDate = DateTime.parse(meeting['date']);
      final timeParts = meeting['time'].split(':');
      final startTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      final startDateTime = DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);

      appointments.add(
        Appointment(
          startTime: startDateTime,
          endTime: startDateTime.add(const Duration(hours: 1)),
          subject: meeting['title'],
          notes: meeting['type'] == 'remoto' ? meeting['url'] : meeting['location'],
          color: meetingColors[meeting['type']] ?? Colors.grey,
        ),
      );
    }
    setState(() {
      _appointments = appointments;
    });
  }

  void _moveToPreviousMonth() {
    _calendarController.backward!();
  }

  void _moveToNextMonth() {
    _calendarController.forward!();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Reuniones', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 107, 135, 182),
        actions: [
          ThemeSwitcher(),
        ],
      ),
      body: Container(
        color: isDarkMode ? const Color(0xFF1C1C1C) : Colors.white, // Fondo según el tema
        margin: const EdgeInsets.all(16.0), // Margen para evitar que ocupe todo el espacio
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem('Remoto', Colors.blue),
                  _buildLegendItem('Presencial', Colors.green),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _moveToPreviousMonth,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_calendarController.displayDate?.month ?? DateTime.now().month} - ${_calendarController.displayDate?.year ?? DateTime.now().year}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _moveToNextMonth,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SfCalendar(
                controller: _calendarController,
                view: CalendarView.month,
                dataSource: MeetingDataSource(_appointments),
                headerHeight: 50,
                headerStyle: CalendarHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                showNavigationArrow: true,
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                ),
                appointmentBuilder: (context, details) {
                  final Appointment appointment = details.appointments.first;
                  return Tooltip(
                    message: 'Reunión: ${appointment.subject}\nDetalles: ${appointment.notes}',
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
                              fontSize: 16,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(title),
      ],
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
