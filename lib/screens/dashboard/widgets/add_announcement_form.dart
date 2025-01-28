import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/utils/firedata.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddAnnouncementForm extends StatefulWidget {
  final Future<void> Function(Announcement) addAnnouncement;
  const AddAnnouncementForm({super.key, required this.addAnnouncement});

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

  File? _selectedImage;
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _errorMessage = null;
      });
    }
  }

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
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _pickImage,
                      icon: const Icon(Icons.image),
                      label: Text(_selectedImage == null
                          ? 'Select Image'
                          : 'Change Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF83ACBD),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isSaving = true;
                              _errorMessage = null;
                            });

                            try {
                              String? imageUrl;
                              if (_selectedImage != null) {
                                imageUrl = await uploadAnnouncementImage(
                                    _selectedImage!.path);
                              }

                              final newAnnouncement = Announcement(
                                title: _titleController.text,
                                subtitle: _subtitleController.text,
                                description: _descriptionController.text,
                                venue: _venueController.text,
                                time: _timeController.text,
                                image: imageUrl,
                                clubId: 'betalabs',
                                date: DateTime.now(),
                              );

                              await widget.addAnnouncement(newAnnouncement);

                              if (!context.mounted) return;
                              Navigator.pop(context, newAnnouncement);
                            } catch (e) {
                              setState(() {
                                _errorMessage =
                                    'Failed to create announcement: $e';
                                _isSaving = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF83ACBD),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Announcement',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
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
    super.dispose();
  }
}
