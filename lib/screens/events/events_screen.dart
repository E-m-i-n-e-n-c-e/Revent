import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/data/clubs_data.dart';
import 'package:events_manager/utils/firedata.dart';
import 'event_utils.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Appointment> _appointments = [];
  CalendarView _currentView = CalendarView.month;
  DateTime? _selectedDate;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_selectedDate != null) {
      setState(() {
        _currentView = CalendarView.day;
      });
    }
  }

  void _loadEvents() async {
    _selectedDate = null;
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load events from Firebase
      final eventList = await loadEvents();
      final events =
          eventList.map((eventData) => Event.fromJson(eventData)).toList();

      // Convert events to appointments
      _appointments = events.map((event) {
        return Appointment(
          startTime: event.startTime,
          endTime: event.endTime,
          subject: event.title,
          notes: event.description,
          location: event.venue,
          resourceIds: [event.clubId],
          color: getColorForClub(event.clubId),
          id: event.id, // Store event ID in appointment
        );
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load events. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      setState(() {
        _selectedDate = details.date;
      });
    } else if (details.targetElement == CalendarElement.appointment) {
      final Appointment tappedAppointment = details.appointments![0];
      final Event selectedEvent = Event(
        id: tappedAppointment.id?.toString(),
        title: tappedAppointment.subject,
        description: tappedAppointment.notes ?? '',
        startTime: tappedAppointment.startTime,
        endTime: tappedAppointment.endTime,
        clubId: (tappedAppointment.resourceIds?.first as String?) ?? '',
        venue: tappedAppointment.location,
      );
      _showEventOptions(selectedEvent);
    }
  }

  void _showEventOptions(Event event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF06222F),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                color: Color(0xFFAEE7FF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFFAEE7FF)),
              title: const Text('Edit Event',
                  style: TextStyle(color: Color(0xFFAEE7FF))),
              onTap: () {
                Navigator.pop(context);
                _editEvent(event);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Event',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteEvent(event);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteEvent(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF06222F),
        title: const Text('Delete Event?',
            style: TextStyle(color: Color(0xFFAEE7FF))),
        content: const Text('This action cannot be undone.',
            style: TextStyle(color: Color(0xFFAEE7FF))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFFAEE7FF))),
          ),
          TextButton(
            onPressed: () async {
              try {
                await deleteEvent(event.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadEvents(); // Reload events after deletion
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete event: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _editEvent(Event event) async {
    final result = await showDialog<Event>(
      context: context,
      builder: (context) => _EditEventDialog(
        event: event,
        onEventEdited: (updatedEvent) async {
          try {
            if (updatedEvent.startTime.isAfter(updatedEvent.endTime)) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Start time cannot be after end time'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            await updateEvent(event.id!, updatedEvent.toJson());
            _loadEvents(); // Reload events after update
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update event: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );

    if (result != null) {
      _loadEvents(); // Reload events if dialog was closed with a result
    }
  }

  Future<void> _addEvent() async {
    final selectedDate = _selectedDate ?? DateTime.now();
    final today = DateTime.now();

    // Check if selected date is in the past
    if (selectedDate.year < today.year ||
        (selectedDate.year == today.year && selectedDate.month < today.month) ||
        (selectedDate.year == today.year &&
            selectedDate.month == today.month &&
            selectedDate.day < today.day)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot add events in the past'),
          backgroundColor: Color(0xFF06222F),
        ),
      );
      return;
    }

    final result = await showDialog<Event>(
      context: context,
      builder: (context) => _AddEventDialog(
        initialDate: selectedDate.add(const Duration(hours: 12)),
        finalDate: _currentView == CalendarView.day
            ? selectedDate.add(const Duration(hours: 1))
            : selectedDate.add(const Duration(hours: 23, minutes: 59)),
        onEventAdded: (event) async {
          try {
            // Validate event times
            if (event.startTime.isAfter(event.endTime)) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Start time cannot be after end time'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            await sendEvent(event.toJson());
            if (mounted) {
              _loadEvents(); // Reload events after adding
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to create event: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );

    if (result != null) {
      _loadEvents(); // Reload events if dialog was closed with a result
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
          child:
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Calendar'),
        backgroundColor: const Color(0xFF06222F),
        leading: _currentView == CalendarView.day
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentView = CalendarView.month;
                  });
                },
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onDoubleTapDown: _handleDoubleTap,
              child: SfCalendar(
                key: ValueKey(_currentView),
                view: _currentView,
                initialDisplayDate: _selectedDate,
                dataSource: AppointmentDataSource(_appointments),
                onTap: _onCalendarTapped,
                showDatePickerButton: true,
                showNavigationArrow: true,
                allowViewNavigation: true,
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
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
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedDate != null) {
            _addEvent();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a date first'),
                backgroundColor: Color(0xFF06222F),
              ),
            );
          }
        },
        backgroundColor: const Color(0xFF83ACBD),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddEventDialog extends StatefulWidget {
  final DateTime initialDate;
  final Function(Event) onEventAdded;
  final DateTime finalDate;

  const _AddEventDialog({
    required this.initialDate,
    required this.finalDate,
    required this.onEventAdded,
  });

  @override
  State<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<_AddEventDialog> {
  late DateTime _startTime;
  late DateTime _endTime;
  late String _selectedClubId;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set initial times
    _startTime = widget.initialDate;
    _endTime = widget.finalDate;
    _selectedClubId = sampleClubs.first.id;
  }

  Widget _buildTimePicker(
      String label, DateTime dateTime, Function(DateTime) onChanged) {
    return Row(
      children: [
        Text('$label:', style: const TextStyle(color: Color(0xFFAEE7FF))),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17323D),
            ),
            onPressed: () async {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(dateTime),
              );
              if (pickedTime != null) {
                final DateTime newDateTime = DateTime(
                  widget.initialDate.year,
                  widget.initialDate.month,
                  widget.initialDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );

                onChanged(newDateTime);
              }
            },
            child: Text(
              '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${TimeOfDay.fromDateTime(dateTime).format(context)}',
              style: const TextStyle(color: Color(0xFFAEE7FF)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF06222F),
      title:
          const Text('Add Event', style: TextStyle(color: Color(0xFFAEE7FF))),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
              ),
              style: const TextStyle(color: Color(0xFFAEE7FF)),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
              ),
              style: const TextStyle(color: Color(0xFFAEE7FF)),
              maxLines: 3,
            ),
            TextField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: 'Venue',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
              ),
              style: const TextStyle(color: Color(0xFFAEE7FF)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedClubId,
              dropdownColor: const Color(0xFF06222F),
              items: sampleClubs.map((club) {
                return DropdownMenuItem(
                  value: club.id,
                  child: Text(club.name,
                      style: const TextStyle(color: Color(0xFFAEE7FF))),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedClubId = value!),
              decoration: const InputDecoration(
                labelText: 'Club',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
              ),
            ),
            const SizedBox(height: 16),
            _buildTimePicker('Start Time', _startTime,
                (newDate) => setState(() => _startTime = newDate)),
            const SizedBox(height: 8),
            _buildTimePicker('End Time', _endTime,
                (newDate) => setState(() => _endTime = newDate)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text('Cancel', style: TextStyle(color: Color(0xFFAEE7FF))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF83ACBD),
          ),
          onPressed: () {
            final event = Event(
              title: _titleController.text,
              description: _descriptionController.text,
              startTime: _startTime,
              endTime: _endTime,
              clubId: _selectedClubId,
              venue: _venueController.text,
            );
            widget.onEventAdded(event);
            Navigator.pop(context, event);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    super.dispose();
  }
}

class _EditEventDialog extends StatefulWidget {
  final Event event;
  final Function(Event) onEventEdited;

  const _EditEventDialog({
    required this.event,
    required this.onEventEdited,
  });

  @override
  State<_EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<_EditEventDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _venueController;
  late DateTime _startTime;
  late DateTime _endTime;
  late String _selectedClubId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController =
        TextEditingController(text: widget.event.description);
    _venueController = TextEditingController(text: widget.event.venue ?? '');
    _startTime = widget.event.startTime;
    _endTime = widget.event.endTime;
    _selectedClubId = widget.event.clubId;
  }

  Widget _buildDateTimePicker(
      String label, DateTime dateTime, Function(DateTime) onChanged) {
    return Row(
      children: [
        Text('$label:', style: const TextStyle(color: Color(0xFFAEE7FF))),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17323D),
            ),
            onPressed: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: dateTime,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null && mounted) {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(dateTime),
                );
                if (pickedTime != null) {
                  final DateTime newDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );

                  // Validate start time is before end time

                  onChanged(newDateTime);
                }
              }
            },
            child: Text(
              '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${TimeOfDay.fromDateTime(dateTime).format(context)}',
              style: const TextStyle(color: Color(0xFFAEE7FF)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF06222F),
      title:
          const Text('Edit Event', style: TextStyle(color: Color(0xFFAEE7FF))),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
              ),
              style: const TextStyle(color: Color(0xFFAEE7FF)),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
              ),
              style: const TextStyle(color: Color(0xFFAEE7FF)),
              maxLines: 3,
            ),
            TextField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: 'Venue',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
              ),
              style: const TextStyle(color: Color(0xFFAEE7FF)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedClubId,
              dropdownColor: const Color(0xFF06222F),
              items: sampleClubs.map((club) {
                return DropdownMenuItem(
                  value: club.id,
                  child: Text(club.name,
                      style: const TextStyle(color: Color(0xFFAEE7FF))),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedClubId = value!),
              decoration: const InputDecoration(
                labelText: 'Club',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
              ),
            ),
            const SizedBox(height: 16),
            _buildDateTimePicker('Start Time', _startTime,
                (newDate) => setState(() => _startTime = newDate)),
            const SizedBox(height: 8),
            _buildDateTimePicker('End Time', _endTime,
                (newDate) => setState(() => _endTime = newDate)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text('Cancel', style: TextStyle(color: Color(0xFFAEE7FF))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF83ACBD),
          ),
          onPressed: () {
            final updatedEvent = Event(
              title: _titleController.text,
              description: _descriptionController.text,
              startTime: _startTime,
              endTime: _endTime,
              clubId: _selectedClubId,
              venue: _venueController.text,
            );
            widget.onEventEdited(updatedEvent);
            Navigator.pop(context, updatedEvent);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    super.dispose();
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
