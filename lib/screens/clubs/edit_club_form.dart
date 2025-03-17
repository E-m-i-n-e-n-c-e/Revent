import 'package:flutter/material.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/utils/firedata.dart';
import 'package:events_manager/utils/common_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditClubForm extends StatefulWidget {
  final Club club;

  const EditClubForm({super.key, required this.club});

  @override
  State<EditClubForm> createState() => _EditClubFormState();
}

class _EditClubFormState extends State<EditClubForm> {
  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  late List<TextEditingController> _adminEmailControllers;
  bool _isLoading = false;
  String? _logoFile;
  String? _backgroundFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.club.name);
    _aboutController = TextEditingController(text: widget.club.about);
    _adminEmailControllers = widget.club.adminEmails
        .map((email) => TextEditingController(text: email))
        .toList();
    if (_adminEmailControllers.isEmpty) {
      _adminEmailControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    for (var controller in _adminEmailControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          if (type == 'logo') {
            _logoFile = pickedFile.path;
          } else {
            _backgroundFile = pickedFile.path;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _addAdminEmail() {
    setState(() {
      _adminEmailControllers.add(TextEditingController());
    });
  }

  void _removeAdminEmail(int index) {
    setState(() {
      _adminEmailControllers[index].dispose();
      _adminEmailControllers.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      // Upload new images if selected
      String? newLogoUrl;
      String? newBackgroundUrl;

      if (_logoFile != null) {
        newLogoUrl = await uploadClubImage(widget.club.id, _logoFile!, 'logo');
        await updateClubLogo(widget.club.id, newLogoUrl);
      }

      if (_backgroundFile != null) {
        newBackgroundUrl = await uploadClubImage(widget.club.id, _backgroundFile!, 'background');
        await updateClubBackground(widget.club.id, newBackgroundUrl);
      }

      // Update other club details
      await updateClubDetails(
        widget.club.id,
        name: _nameController.text,
        about: _aboutController.text,
        adminEmails: _adminEmailControllers
            .map((controller) => controller.text)
            .where((email) => email.isNotEmpty)
            .toList(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Club details updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('permission-denied')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sorry, you are not an admin of this club')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating club details: $e')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07181F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06222F),
        title: const Text(
          'Edit Club',
          style: TextStyle(color: Color(0xFFAEE7FF)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFAEE7FF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
            child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Background Image Section
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2026),
                            image: _backgroundFile != null
                                ? DecorationImage(
                                    image: FileImage(File(_backgroundFile!)),
                                    fit: BoxFit.cover,
                                    opacity: 0.7,
                                  )
                                : DecorationImage(
                                    image: getCachedNetworkImageProvider(
                                      imageUrl: widget.club.backgroundImageUrl.isNotEmpty
                                          ? widget.club.backgroundImageUrl
                                          : widget.club.logoUrl,
                                      imageType: ImageType.club,
                                    ),
                                    fit: BoxFit.cover,
                                    opacity: 0.7,
                                  ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF07181F).withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: IconButton(
                            onPressed: () => _pickImage('background'),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF17323D),
                              padding: const EdgeInsets.all(12),
                            ),
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFFAEE7FF),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Club Logo Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF71C2E4),
                                    width: 2,
                                  ),
                                  image: _logoFile != null
                                      ? DecorationImage(
                                          image: FileImage(File(_logoFile!)),
                                          fit: BoxFit.cover,
                                        )
                                      : DecorationImage(
                                          image: getCachedNetworkImageProvider(
                                            imageUrl: widget.club.logoUrl,
                                            imageType: ImageType.club,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  onPressed: () => _pickImage('logo'),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFF17323D),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Color(0xFFAEE7FF),
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(
                                color: Color(0xFFAEE7FF),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter club name',
                                hintStyle: TextStyle(
                                  color: Color(0xFF71C2E4),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // About Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About',
                            style: TextStyle(
                              color: Color(0xFFAEE7FF),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _aboutController,
                            maxLines: 5,
                            style: const TextStyle(color: Color(0xFFAEE7FF)),
                            decoration: InputDecoration(
                              hintText: 'Write about your club...',
                              hintStyle: const TextStyle(color: Color(0xFF71C2E4)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF17323D)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF71C2E4)),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF0F2027),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Admin Emails Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Emails',
                            style: TextStyle(
                              color: Color(0xFFAEE7FF),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._adminEmailControllers.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: entry.value,
                                      style: const TextStyle(color: Color(0xFFAEE7FF)),
                                      decoration: InputDecoration(
                                        hintText: 'Enter admin email',
                                        hintStyle: const TextStyle(color: Color(0xFF71C2E4)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFF17323D)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFF71C2E4)),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF0F2027),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () => _removeAdminEmail(entry.key),
                                  ),
                                ],
                              ),
                            );
                          }),
                          TextButton.icon(
                            icon: const Icon(Icons.add, color: Color(0xFF71C2E4)),
                            label: const Text(
                              'Add Admin Email',
                              style: TextStyle(color: Color(0xFF71C2E4)),
                            ),
                            onPressed: _addAdminEmail,
                          ),
                        ],
                      ),
                    ),

                    // Save Button
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF71C2E4),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _saveChanges,
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}