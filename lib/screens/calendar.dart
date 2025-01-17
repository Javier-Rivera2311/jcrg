import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';

class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EventList<Event> markedDates = EventList<Event>(
      events: {
        DateTime(2025, 1, 17): [Event(date: DateTime(2025, 1, 17), title: "Evento 1")],
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: Colors.blue,
      ),
      body: CalendarCarousel<Event>(
        onDayPressed: (date, events) {
          for (var event in events) {
            print(event.title);
          }
        },
        markedDatesMap: markedDates,
        markedDateShowIcon: true,
        markedDateIconBuilder: (event) {
          return const Icon(Icons.circle, color: Colors.red, size: 10);
        },
      ),
    );
  }
}
