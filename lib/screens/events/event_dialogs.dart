import 'package:flutter/material.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/utils/common_utils.dart';
import 'package:events_manager/utils/common_dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEventDialog extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final Function(Event) onEventAdded;
  final DateTime finalDate;

  const AddEventDialog({
    super.key,
    required this.initialDate,
    required this.finalDate,
    required this.onEventAdded,
  });

  @override
  ConsumerState<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends ConsumerState<AddEventDialog> {
  late DateTime _startTime;
  late DateTime _endTime;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _registrationLinkController = TextEditingController();
  final TextEditingController _feedbackLinkController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialDate;
    _endTime = widget.finalDate;
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

  // Show visual feedback when a link is entered
  void _showLinkFeedback(String linkType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$linkType link added'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF0E668A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
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
            TextField(
              controller: _registrationLinkController,
              decoration: const InputDecoration(
                labelText: 'Registration Link (Optional)',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
                suffixIcon: Icon(Icons.link, color: Color(0xFF71C2E4)),
              ),
              style: const TextStyle(color: Color(0xFFAEE7FF)),
              onChanged: (value) {
                if (value.isNotEmpty && value.startsWith('http')) {
                  _showLinkFeedback('Registration');
                }
              },
            ),
            TextField(
              controller: _feedbackLinkController,
              decoration: const InputDecoration(
                labelText: 'Feedback Link (Optional)',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
                suffixIcon: Icon(Icons.link, color: Color(0xFF71C2E4)),
              ),
              style: const TextStyle(color: Color(0xFFAEE7FF)),
              onChanged: (value) {
                if (value.isNotEmpty && value.startsWith('http')) {
                  _showLinkFeedback('Feedback');
                }
              },
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
          onPressed: _isSaving ? null : () async {
            setState(() {
              _isSaving = true;
            });

            try {
              // Get current user email directly from Firebase Auth
              final user = FirebaseAuth.instance.currentUser;
              if (user == null || user.email == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User not logged in'),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() {
                  _isSaving = false;
                });
                return;
              }

              final adminClubs = getAdminClubs(ref, user.email!);

              if (!mounted) return;

              if (adminClubs.isEmpty) {
                await showDialog(
                  context: context,
                  builder: (context) => const NoAdminClubsDialog(),
                );
                setState(() {
                  _isSaving = false;
                });
                return;
              }

              final selectedClub = await showDialog<Club>(
                context: context,
                builder: (context) => ClubSelectionDialog(clubs: adminClubs),
              );

              if (selectedClub != null) {
                final event = Event(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  startTime: _startTime,
                  endTime: _endTime,
                  clubId: selectedClub.id,
                  venue: _venueController.text,
                  registrationLink: _registrationLinkController.text.isNotEmpty
                      ? _registrationLinkController.text
                      : null,
                  feedbackLink: _feedbackLinkController.text.isNotEmpty
                      ? _feedbackLinkController.text
                      : null,
                );
                widget.onEventAdded(event);
                if(context.mounted){
                  Navigator.pop(context, event);
                }

              } else {
                setState(() {
                  _isSaving = false;
                });
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              setState(() {
                _isSaving = false;
              });
            }
          },
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _registrationLinkController.dispose();
    _feedbackLinkController.dispose();
    super.dispose();
  }
}

class EditEventDialog extends ConsumerStatefulWidget {
  final Event event;
  final Function(Event) onEventEdited;

  const EditEventDialog({
    super.key,
    required this.event,
    required this.onEventEdited,
  });

  @override
  ConsumerState<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends ConsumerState<EditEventDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _venueController;
  late TextEditingController _registrationLinkController;
  late TextEditingController _feedbackLinkController;
  late DateTime _startTime;
  late DateTime _endTime;
  late String _clubId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController =
        TextEditingController(text: widget.event.description);
    _venueController = TextEditingController(text: widget.event.venue ?? '');
    _registrationLinkController = TextEditingController(text: widget.event.registrationLink ?? '');
    _feedbackLinkController = TextEditingController(text: widget.event.feedbackLink ?? '');
    _startTime = widget.event.startTime;
    _endTime = widget.event.endTime;
    _clubId = widget.event.clubId;
  }

  // Show visual feedback when a link is entered
  void _showLinkFeedback(String linkType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$linkType link updated'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF0E668A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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
            TextField(
              controller: _registrationLinkController,
              decoration: const InputDecoration(
                labelText: 'Registration Link (Optional)',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
                suffixIcon: Icon(Icons.link, color: Color(0xFF71C2E4)),
              ),
              style: const TextStyle(color: Color(0xFFAEE7FF)),
              onChanged: (value) {
                if (value.isNotEmpty && value.startsWith('http')) {
                  _showLinkFeedback('Registration');
                }
              },
            ),
            TextField(
              controller: _feedbackLinkController,
              decoration: const InputDecoration(
                labelText: 'Feedback Link (Optional)',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
                suffixIcon: Icon(Icons.link, color: Color(0xFF71C2E4)),
              ),
              style: const TextStyle(color: Color(0xFFAEE7FF)),
              onChanged: (value) {
                if (value.isNotEmpty && value.startsWith('http')) {
                  _showLinkFeedback('Feedback');
                }
              },
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
          onPressed: _isSaving ? null : () {
            setState(() {
              _isSaving = true;
            });

            final updatedEvent = Event(
              title: _titleController.text,
              description: _descriptionController.text,
              startTime: _startTime,
              endTime: _endTime,
              clubId: _clubId, // Keep the original club ID
              venue: _venueController.text,
              registrationLink: _registrationLinkController.text.isNotEmpty
                  ? _registrationLinkController.text
                  : null,
              feedbackLink: _feedbackLinkController.text.isNotEmpty
                  ? _feedbackLinkController.text
                  : null,
            );
            widget.onEventEdited(updatedEvent);
            Navigator.pop(context, updatedEvent);
          },
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _registrationLinkController.dispose();
    _feedbackLinkController.dispose();
    super.dispose();
  }
}
