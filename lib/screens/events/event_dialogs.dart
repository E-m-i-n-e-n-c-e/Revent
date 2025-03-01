import 'package:flutter/material.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/data/clubs_data.dart';

class AddEventDialog extends StatefulWidget {
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
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  late DateTime _startTime;
  late DateTime _endTime;
  late String _selectedClubId;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _registrationLinkController = TextEditingController();
  final TextEditingController _feedbackLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
            TextField(
              controller: _registrationLinkController,
              decoration: const InputDecoration(
                labelText: 'Registration Link (Optional)',
                labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
              ),
              style: const TextStyle(color: Color(0xFFAEE7FF)),
            ),
            TextField(
              controller: _feedbackLinkController,
              decoration: const InputDecoration(
                labelText: 'Feedback Link (Optional)',
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
              registrationLink: _registrationLinkController.text.isNotEmpty
                  ? _registrationLinkController.text
                  : null,
              feedbackLink: _feedbackLinkController.text.isNotEmpty
                  ? _feedbackLinkController.text
                  : null,
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
    _registrationLinkController.dispose();
    _feedbackLinkController.dispose();
    super.dispose();
  }
}

class EditEventDialog extends StatefulWidget {
  final Event event;
  final Function(Event) onEventEdited;

  const EditEventDialog({
    super.key,
    required this.event,
    required this.onEventEdited,
  });

  @override
  State<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _venueController;
  late TextEditingController _registrationLinkController;
  late TextEditingController _feedbackLinkController;
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
    _registrationLinkController = TextEditingController(text: widget.event.registrationLink ?? '');
    _feedbackLinkController = TextEditingController(text: widget.event.feedbackLink ?? '');
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
              ),
              style: const TextStyle(color: Color(0xFFAEE7FF)),
            ),
            TextField(
              controller: _feedbackLinkController,
              decoration: const InputDecoration(
                labelText: 'Feedback Link (Optional)',
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
    _registrationLinkController.dispose();
    _feedbackLinkController.dispose();
    super.dispose();
  }
}
