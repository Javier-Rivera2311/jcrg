import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:jcrg/screens/theme_switcher.dart';
import 'package:intl/intl.dart';

class CalendarMeetingsScreen extends StatefulWidget {
  final List<dynamic> meetings;

  const CalendarMeetingsScreen({Key? key, required this.meetings}) : super(key: key);

  @override
  _CalendarMeetingsScreenState createState() => _CalendarMeetingsScreenState();
}

class _CalendarMeetingsScreenState extends State<CalendarMeetingsScreen> {
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
      'presencial': Colors.green,
      'remoto': Colors.blue,
    };

    for (var meeting in widget.meetings) {
      final startDate = DateTime.parse(meeting['date']);
      appointments.add(
        Appointment(
          startTime: startDate,
          endTime: startDate.add(const Duration(hours: 1)),
          subject: meeting['title'],
          notes: meeting['location'] ?? meeting['url'],
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
    return Column(
      children: [
        // Barra de leyenda de colores
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Presencial', Colors.green),
              _buildLegendItem('Remoto', Colors.blue),
            ],
          ),
        ),
        Expanded(
          child: SfCalendar(
            view: CalendarView.month,
            dataSource: MeetingDataSource(_appointments),
            headerHeight: 50,
            headerStyle: const CalendarHeaderStyle(
              textAlign: TextAlign.center,
              textStyle: TextStyle(
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
                message: 'Reunión: ${appointment.subject}\nDetalles: ${appointment.notes}\nFecha: ${DateFormat.yMMMMd('es_ES').format(appointment.startTime)}',
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
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
