import 'dart:io';
import 'package:events_manager/models/user.dart';
import 'package:events_manager/utils/firedata.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileForm extends StatefulWidget {
  final AppUser user;

  const EditProfileForm({super.key, required this.user});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late TextEditingController _nameController;
  bool _isUploading = false;
  String? _profileImagePath;
  String? _backgroundImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isProfileImage) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        if (isProfileImage) {
          _profileImagePath = image.path;
        } else {
          _backgroundImagePath = image.path;
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isUploading = true);
    try {
      String? newPhotoURL;
      String? newBackgroundURL;

      // Upload profile image if changed
      if (_profileImagePath != null) {
        newPhotoURL = await uploadUserProfileImage(widget.user.uid, _profileImagePath!);
      }

      // Upload background image if changed
      if (_backgroundImagePath != null) {
        newBackgroundURL = await uploadUserBackgroundImage(widget.user.uid, _backgroundImagePath!);
      }

      // Update user profile
      await updateUserProfile(
        widget.user.uid,
        name: _nameController.text.trim(),
        photoURL: newPhotoURL,
        backgroundImageUrl: newBackgroundURL,
      );
      // Create updated user object
      final updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        photoURL: newPhotoURL,
        backgroundImageUrl: newBackgroundURL,
      );
      if (!mounted) return;
      Navigator.of(context).pop(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF0E668A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07181F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06222F),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFAEE7FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isUploading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAEE7FF)),
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveChanges,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFFAEE7FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
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
                    image: _backgroundImagePath != null
                        ? DecorationImage(
                            image: FileImage(File(_backgroundImagePath!)),
                            fit: BoxFit.cover,
                            opacity: 0.7,
                          )
                        : widget.user.backgroundImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(widget.user.backgroundImageUrl!),
                                fit: BoxFit.cover,
                                opacity: 0.7,
                              )
                            : null,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF07181F).withValues(alpha:0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: () => _pickImage(false),
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

            // Profile Image Section
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
                          image: _profileImagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(_profileImagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : widget.user.photoURL != null
                                  ? DecorationImage(
                                      image: NetworkImage(widget.user.photoURL!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: _profileImagePath == null && widget.user.photoURL == null
                            ? const Center(
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFFAEE7FF),
                                  size: 40,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () => _pickImage(true),
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
                        hintText: 'Enter your name',
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

            // Profile Details Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Details',
                    style: TextStyle(
                      color: Color(0xFFAEE7FF),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2026),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF71C2E4).withValues(alpha:0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: widget.user.email,
                          isEditable: false,
                        ),
                        const Divider(color: Color(0xFF17323D), height: 24),
                        _buildDetailRow(
                          icon: Icons.numbers,
                          label: 'Roll Number',
                          value: widget.user.rollNumber ?? 'Not set',
                          isEditable: false,
                        ),
                        const Divider(color: Color(0xFF17323D), height: 24),
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Member since',
                          value: widget.user.createdAt.toString().split(' ')[0],
                          isEditable: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isEditable,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF17323D),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFAEE7FF),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFFAEE7FF).withValues(alpha:0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFAEE7FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}