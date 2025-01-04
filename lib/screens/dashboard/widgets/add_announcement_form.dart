import 'package:events_manager/models/announcement.dart';
import 'package:flutter/material.dart';

class AddAnnouncementForm extends StatefulWidget {
  const AddAnnouncementForm({super.key});

  @override
  State<AddAnnouncementForm> createState() => _AddAnnouncementFormState();
}

class _AddAnnouncementFormState extends State<AddAnnouncementForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _timeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Announcement'),
        backgroundColor: const Color(0xFF06222F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff83ACBD)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
                ),
                style: const TextStyle(color: Color(0xFFAEE7FF)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle',
                  labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
                ),
                style: const TextStyle(color: Color(0xFFAEE7FF)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
                ),
                style: const TextStyle(color: Color(0xFFAEE7FF)),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(
                  labelText: 'Venue',
                  labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
                ),
                style: const TextStyle(color: Color(0xFFAEE7FF)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
                ),
                style: const TextStyle(color: Color(0xFFAEE7FF)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  labelStyle: TextStyle(color: Color(0xFFAEE7FF)),
                ),
                style: const TextStyle(color: Color(0xFFAEE7FF)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newAnnouncement = Announcement(
                      title: _titleController.text,
                      subtitle: _subtitleController.text,
                      description: _descriptionController.text,
                      venue: _venueController.text,
                      time: _timeController.text,
                      image: _imageUrlController.text.isEmpty
                          ? null
                          : Uri.parse(_imageUrlController.text.trim())
                              .toString(),
                      clubId: 'betalabs',
                      date: DateTime.now(),
                    );

                    Navigator.pop(context, newAnnouncement);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF83ACBD),
                ),
                child: const Text('Create Announcement'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _timeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
