import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'appointment_data_source.dart';

class EventsCalendar extends StatelessWidget {
  final CalendarView currentView;
  final DateTime? selectedDate;
  final List<Appointment> appointments;
  final Function(CalendarTapDetails) onTap;

  const EventsCalendar({
    super.key,
    required this.currentView,
    required this.selectedDate,
    required this.appointments,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      key: ValueKey(currentView),
      view: currentView,
      initialDisplayDate: selectedDate,
      dataSource: AppointmentDataSource(appointments),
      onTap: onTap,
      showDatePickerButton: true,
      showNavigationArrow: true,
      allowViewNavigation: true,
      monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        showAgenda: true,
        agendaViewHeight: 200,
        numberOfWeeksInView: 6,
        appointmentDisplayCount: 3,
        showTrailingAndLeadingDates: true,
        dayFormat: 'EEE',
        agendaStyle: AgendaStyle(
          backgroundColor: Color(0xFF06222F),
          dayTextStyle: TextStyle(
            color: Color(0xFF83ACBD),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          dateTextStyle: TextStyle(
            color: Color(0xFF83ACBD),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          appointmentTextStyle: TextStyle(
            color: Color(0xFF06222F),
            fontSize: 12,
          ),
        ),
      ),
      timeSlotViewSettings: const TimeSlotViewSettings(
        timeFormat: 'h:mm a',
        dayFormat: 'EEE',
        timeRulerSize: 70,
        timeTextStyle: TextStyle(
          color: Color(0xFF83ACBD),
          fontSize: 12,
        ),
      ),
      headerStyle: const CalendarHeaderStyle(
        textStyle: TextStyle(
          color: Color(0xFF06222F),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      viewHeaderStyle: const ViewHeaderStyle(
        dayTextStyle: TextStyle(
          color: Color(0xFF06222F),
          fontSize: 12,
        ),
        dateTextStyle: TextStyle(
          color: Color(0xFF06222F),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      cellBorderColor: Color(0xFF83ACBD),
      backgroundColor: Colors.white,
      todayHighlightColor: Color(0xFF83ACBD),
      selectionDecoration: BoxDecoration(
        border: Border.all(
          color: Color(0xFF83ACBD),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
