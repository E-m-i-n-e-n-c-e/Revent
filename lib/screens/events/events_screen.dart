import 'package:events_manager/providers/stream_providers.dart';
import 'package:events_manager/utils/common_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/utils/firedata.dart';
import 'event_dialogs.dart';
import 'events_calendar.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  void _onCalendarTapped(BuildContext context, CalendarTapDetails details, List<Event> events, WidgetRef ref) {
    final currentView = ref.read(calendarViewProvider);
    final selectedDate = ref.read(selectedDayProvider);

    if (details.targetElement == CalendarElement.calendarCell) {
      if (currentView != 'day' &&
          details.date!.year == selectedDate.year &&
          details.date!.month == selectedDate.month &&
          details.date!.day == selectedDate.day) {
        // If tapping already selected date, go to day view
        ref.read(calendarViewProvider.notifier).state = 'day';
      } else {
        // Otherwise just select the new date
        ref.read(selectedDayProvider.notifier).state = details.date!;
      }
    } else if (details.targetElement == CalendarElement.appointment) {
      final Appointment tappedAppointment = details.appointments![0];
      final Event selectedEvent = events.firstWhere((event) => event.id == tappedAppointment.id);
      _showEventOptions(context, selectedEvent, ref);
    }
  }

  void _showEventOptions(BuildContext context, Event event, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF06222F),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(width: 10),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipOval(
                    child: getCachedNetworkImage(
                      imageUrl: getClubLogo(ref, event.clubId),
                      imageType: ImageType.club,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      color: Color(0xFFAEE7FF),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFFAEE7FF)),
              title: const Text('Edit Event',
                  style: TextStyle(color: Color(0xFFAEE7FF))),
              onTap: () {
                Navigator.pop(context);
                _editEvent(context, event, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Event',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteEvent(context, event);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteEvent(BuildContext context, Event event) {
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
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().contains('permission') || e.toString().contains('denied')
                            ? "Sorry, you're not an admin of this club"
                            : 'Failed to delete event: $e'
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _editEvent(BuildContext context, Event event, WidgetRef ref) async {
    await showDialog<Event>(
      context: context,
      builder: (context) => EditEventDialog(
        event: event,
        onEventEdited: (updatedEvent) async {
          try {
            if (updatedEvent.startTime.isAfter(updatedEvent.endTime)) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Start time cannot be after end time'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            final user = FirebaseAuth.instance.currentUser;
            if (user == null || user.email == null) {
              throw Exception("User not logged in");
            }

            final adminClubs = getAdminClubs(ref, user.email!);
            if (!adminClubs.any((club) => club.id == updatedEvent.clubId)) {
              throw Exception("permission-denied");
            }

            await updateEvent(event.id!, updatedEvent.toJson());
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    e.toString().contains('permission') || e.toString().contains('denied')
                        ? "Sorry, you're not an admin of this club"
                        : 'Failed to update event: $e'
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _addEvent(BuildContext context, WidgetRef ref) async {
    final selectedDate = ref.read(selectedDayProvider);
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

    final currentView = ref.read(calendarViewProvider);
    await showDialog<Event>(
      context: context,
      builder: (context) => AddEventDialog(
        initialDate: currentView == 'day'
            ? selectedDate
            : selectedDate.add(const Duration(hours: 12)),
        finalDate: currentView == 'day'
            ? selectedDate.add(const Duration(hours: 1))
            : selectedDate.add(const Duration(hours: 23, minutes: 59)),
        onEventAdded: (event) async {
          try {
            if (event.startTime.isAfter(event.endTime)) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Start time cannot be after end time'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            await sendEvent(event.toJson());
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create event: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsStreamProvider);
    final currentView = ref.watch(calendarViewProvider);
    final selectedDate = ref.watch(selectedDayProvider);

    return PopScope(
      canPop: currentView != 'day',
      onPopInvokedWithResult: (didPop, result) async {
        if (currentView == 'day') {
          ref.read(calendarViewProvider.notifier).state = 'month';
          ref.read(selectedDayProvider.notifier).state = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Events Calendar',
            style: TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF06222F),
          leading: currentView == 'day'
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF83ACBD)),
                  onPressed: () {
                    ref.read(calendarViewProvider.notifier).state = 'month';
                    ref.read(selectedDayProvider.notifier).state = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                  },
                )
              : null,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF07181F),
                Color(0xFF000000),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: events.when(
            data: (eventsList) {
              final appointments = eventsList.map((event) {
                final notesWithLogo = '${event.description}|${getClubLogo(ref, event.clubId)}';
                return Appointment(
                  startTime: event.startTime,
                  endTime: event.endTime,
                  subject: event.title,
                  notes: notesWithLogo,
                  location: event.venue,
                  resourceIds: [event.clubId],
                  color: const Color(0xFF0F2027),
                  id: event.id,
                );
              }).toList();

              return EventsCalendar(
                currentView: currentView == 'day' ? CalendarView.day : CalendarView.month,
                selectedDate: selectedDate,
                appointments: appointments,
                onTap: (details) => _onCalendarTapped(context, details, eventsList, ref),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading events: $error',
                style: const TextStyle(color: Colors.red)),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addEvent(context, ref),
          backgroundColor: const Color(0xFF0E668A),
          child: const Icon(Icons.add, color: Color(0xFFAEE7FF)),
        ),
      ),
    );
  }
}
