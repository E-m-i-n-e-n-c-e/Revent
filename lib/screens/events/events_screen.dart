import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/utils/firedata.dart';
import 'event_utils.dart';
import 'event_dialogs.dart';
import 'events_calendar.dart';

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

      final eventList = await loadEvents();
      final events =
          eventList.map((eventData) => Event.fromJson(eventData)).toList();

      _appointments = events.map((event) {
        return Appointment(
          startTime: event.startTime,
          endTime: event.endTime,
          subject: event.title,
          notes: event.description,
          location: event.venue,
          resourceIds: [event.clubId],
          color: getColorForClub(event.clubId),
          id: event.id,
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
                  _loadEvents();
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
      builder: (context) => EditEventDialog(
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
            _loadEvents();
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
      _loadEvents();
    }
  }

  Future<void> _addEvent() async {
    final selectedDate = _selectedDate ?? DateTime.now();
    final today = DateTime.now();

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
      builder: (context) => AddEventDialog(
        initialDate: selectedDate.add(const Duration(hours: 12)),
        finalDate: _currentView == CalendarView.day
            ? selectedDate.add(const Duration(hours: 1))
            : selectedDate.add(const Duration(hours: 23, minutes: 59)),
        onEventAdded: (event) async {
          try {
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
              _loadEvents();
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
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Calendar'),
        backgroundColor: const Color(0xFF06222F),
        leading: _currentView == CalendarView.day
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF83ACBD)),
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
              child: EventsCalendar(
                currentView: _currentView,
                selectedDate: _selectedDate,
                appointments: _appointments,
                onTap: _onCalendarTapped,
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
