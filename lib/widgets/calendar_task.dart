import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:jcrg/screens/theme_switcher.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CalendarScreen extends StatefulWidget {
  final List<dynamic> tasks;

  const CalendarScreen({Key? key, required this.tasks}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late List<Appointment> _appointments = [];
  CalendarController _calendarController = CalendarController();
  final GlobalKey _calendarKey = GlobalKey();

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
      'Entregas': const Color.fromARGB(255, 240, 22, 7),
      'Revisión': Colors.purple,
      'Entrega perentoria': const Color.fromARGB(255, 22, 153, 125),
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

  Future<void> _printCalendar() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isDarkMode) {
      // Mostrar advertencia
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: isDarkMode
                ? const Color.fromARGB(255, 40, 40, 40) // Fondo oscuro para modo oscuro
                : Colors.white, // Fondo claro para modo claro
            title: Text(
              'Advertencia',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            content: Text(
              'Por favor, cambie al tema claro antes de imprimir.',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Aceptar',
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            ],
          );
        },
      );
    } else {
      try {
        RenderRepaintBoundary boundary = _calendarKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // Mostrar el cuadro de diálogo de impresión
        await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
          final doc = pw.Document();
          final image = pw.MemoryImage(pngBytes);
          final margin = 1 * PdfPageFormat.cm;
          final pageFormat = format.copyWith(
            marginLeft: margin,
            marginRight: margin,
            marginTop: margin,
            marginBottom: margin,
          );

          doc.addPage(pw.Page(
            pageFormat: pageFormat,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ));
          return doc.save();
        });

        print("Imagen capturada con éxito");
      } catch (e) {
        print("Error al capturar la imagen: $e");
      }
    }
  }

  void _moveToPreviousMonth() {
    _calendarController.backward!();
  }

  void _moveToNextMonth() {
    _calendarController.forward!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 107, 135, 182),
        actions: [
          ThemeSwitcher(),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printCalendar,
            color: Colors.white
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _calendarKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem('Dibujantes', Colors.blue),
                  _buildLegendItem('Ingeniería', Colors.green),
                  _buildLegendItem('Administrativo', Colors.orange),
                  _buildLegendItem('Entregas', const Color.fromARGB(255, 240, 22, 7)),
                  _buildLegendItem('Revisión', Colors.purple),
                  _buildLegendItem('Entrega perentoria', const Color.fromARGB(255, 22, 153, 125)),

                ],
              ),
            ),
            Expanded(
              child: SfCalendar(
                controller: _calendarController,
                view: CalendarView.month,
                dataSource: TaskDataSource(_appointments),
                headerHeight: 50,
                headerStyle: CalendarHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                showNavigationArrow: true, // Habilita flechas para navegar entre meses
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                ),
                appointmentBuilder: (context, details) {
                  final Appointment appointment = details.appointments.first;
                  return Tooltip(
                    message: 'Tarea: ${appointment.subject}\nEncargado: ${appointment.notes}\nFecha límite: ${DateFormat.yMMMMd('es_Es').format(appointment.startTime)}',
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

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Appointment> source) {
    appointments = source;
  }
}
