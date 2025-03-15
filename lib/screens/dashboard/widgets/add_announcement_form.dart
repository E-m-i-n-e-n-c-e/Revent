import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/utils/common_utils.dart';
import 'package:events_manager/utils/firedata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AddAnnouncementForm extends ConsumerStatefulWidget {
  final Future<void> Function(Announcement) addAnnouncement;
  const AddAnnouncementForm({
    super.key,
    required this.addAnnouncement,
  });

  @override
  ConsumerState<AddAnnouncementForm> createState() => _AddAnnouncementFormState();
}

class _AddAnnouncementFormState extends ConsumerState<AddAnnouncementForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isPreviewMode = false;
  bool _isSaving = false;
  String? _errorMessage;
  bool _isUploadingFile = false;

  // Insert text at current cursor position
  void _insertText(String text) {
    final currentText = _descriptionController.text;
    final selection = _descriptionController.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    _descriptionController.text = newText;
    _descriptionController.selection = TextSelection.collapsed(
      offset: selection.start + text.length,
    );
  }

  // Insert markdown formatting
  void _insertFormatting(String prefix, [String suffix = '']) {
    final currentText = _descriptionController.text;
    final selection = _descriptionController.selection;

    // If text is selected, wrap it with formatting
    if (selection.start != selection.end) {
      final selectedText = currentText.substring(selection.start, selection.end);
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        '$prefix$selectedText$suffix',
      );
      _descriptionController.text = newText;
      _descriptionController.selection = TextSelection.collapsed(
        offset: selection.start + prefix.length + selectedText.length + suffix.length,
      );
    } else {
      // If no text is selected, just insert the formatting
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        '$prefix$suffix',
      );
      _descriptionController.text = newText;
      _descriptionController.selection = TextSelection.collapsed(
        offset: selection.start + prefix.length,
      );
    }
  }

  // Upload image and insert markdown
  Future<void> _uploadImage() async {
    try {
      setState(() {
        _isUploadingFile = true;
      });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
        // Upload to Supabase
        final imageUrl = await uploadAnnouncementImage(pickedFile.path);

        // Insert markdown image syntax
        _insertText('![Image]($imageUrl)');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to upload image: $e';
      });
    } finally {
      setState(() {
        _isUploadingFile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06222F),
      appBar: AppBar(
        title: const Text('Add Announcement'),
        backgroundColor: const Color(0xFF06222F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff83ACBD)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isUploadingFile)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAEE7FF)),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              _isPreviewMode ? Icons.edit : Icons.visibility,
              color: const Color(0xff83ACBD),
            ),
            onPressed: () {
              setState(() {
                _isPreviewMode = !_isPreviewMode;
              });
            },
            tooltip: _isPreviewMode ? 'Edit' : 'Preview',
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xff83ACBD)),
            onPressed: _isSaving
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isSaving = true;
                        _errorMessage = null;
                      });

                      try {
                        // Get current user email directly from Firebase Auth
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null || user.email == null) {
                          setState(() {
                            _errorMessage = 'User not logged in';
                            _isSaving = false;
                          });
                          return;
                        }

                        final adminClubs = getAdminClubs(ref, user.email!);

                        if (!mounted) return;

                        if (adminClubs.isEmpty) {
                          _showNoAdminClubsDialog();
                          return;
                        }

                        final selectedClub = await showDialog<Club>(
                          context: context,
                          builder: (context) => ClubSelectionDialog(clubs: adminClubs),
                        );

                        if (selectedClub != null) {
                          final announcement = Announcement(
                            title: _titleController.text,
                            subtitle: '', // Not used anymore
                            description: _descriptionController.text,
                            venue: '', // Not used anymore
                            time: '', // Not used anymore
                            image: null, // Images are now in markdown
                            clubId: selectedClub.id,
                            date: DateTime.now(),
                          );

                          await widget.addAnnouncement(announcement);
                          if(context.mounted) {
                            Navigator.pop(context, announcement);
                          }
                        } else {
                          setState(() {
                            _isSaving = false;
                          });
                        }
                      } catch (e) {
                        setState(() {
                          _errorMessage = 'Failed to create announcement: $e';
                          _isSaving = false;
                        });
                      }
                    }
                  },
            tooltip: 'Save',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  color: Colors.red.withValues(alpha:0.2),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Markdown toolbar
              if (!_isPreviewMode)
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F2026),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF17323D),
                        width: 1.0,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.format_bold, color: Color(0xFFAEE7FF)),
                          onPressed: () => _insertFormatting('**', '**'),
                          tooltip: 'Bold',
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_italic, color: Color(0xFFAEE7FF)),
                          onPressed: () => _insertFormatting('*', '*'),
                          tooltip: 'Italic',
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_list_bulleted, color: Color(0xFFAEE7FF)),
                          onPressed: () => _insertText('\n- '),
                          tooltip: 'Bullet List',
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_list_numbered, color: Color(0xFFAEE7FF)),
                          onPressed: () => _insertText('\n1. '),
                          tooltip: 'Numbered List',
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                        IconButton(
                          icon: const Icon(Icons.title, color: Color(0xFFAEE7FF)),
                          onPressed: () => _insertText('\n## '),
                          tooltip: 'Heading',
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                        IconButton(
                          icon: const Icon(Icons.code, color: Color(0xFFAEE7FF)),
                          onPressed: () => _insertFormatting('`', '`'),
                          tooltip: 'Code',
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                        IconButton(
                          icon: const Icon(Icons.link, color: Color(0xFFAEE7FF)),
                          onPressed: () => _insertFormatting('[', '](url)'),
                          tooltip: 'Link',
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                        IconButton(
                          icon: const Icon(Icons.image, color: Color(0xFFAEE7FF)),
                          onPressed: _isUploadingFile ? null : _uploadImage,
                          tooltip: 'Upload Image',
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ],
                    ),
                  ),
                ),

              // Unified content area
              Expanded(
                child: Container(
                  color: const Color(0xFF0F2026),
                  child: _isPreviewMode
                      ? _buildPreviewMode()
                      : _buildEditMode(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoAdminClubsDialog() {
    showDialog(
      context: context,
      builder: (context) => const NoAdminClubsDialog(),
    );
    setState(() {
      _isSaving = false;
    });
  }

  Widget _buildEditMode() {
    return Column(
      children: [
        // Title field
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
              hintText: 'Title',
              hintStyle: TextStyle(
                color: Color(0xFFAEE7FF),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
        ),

        // Divider
        const Divider(
          color: Color(0xFF17323D),
          thickness: 1,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),

        // Description field
        Expanded(
          child: TextFormField(
            controller: _descriptionController,
                decoration: const InputDecoration(
              hintText: 'Write your announcement in markdown...',
              hintStyle: TextStyle(color: Color(0xFF83ACBD)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(color: Color(0xFFAEE7FF)),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewMode() {
    return SingleChildScrollView(
      child: Container(
        color: const Color(0xFF0F2026),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title preview
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                _titleController.text.isEmpty ? 'Title' : _titleController.text,
                style: const TextStyle(
                  color: Color(0xFFAEE7FF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Divider
            const Divider(
              color: Color(0xFF17323D),
              thickness: 1,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),

            // Description preview
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildMarkdownContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdownContent() {
    try {
      return MarkdownBody(
        data: _descriptionController.text.isEmpty
            ? '_No content yet_'
            : _descriptionController.text,
        styleSheet: MarkdownStyleSheet(
          // Text styles
          p: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 16,
            height: 1.5,
          ),
          h1: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          h2: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          h3: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          h4: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          h5: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          h6: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),

          // List styles
          listBullet: const TextStyle(
            color: Color(0xFFAEE7FF),
          ),
          listIndent: 20.0,

          // Code styles
          code: const TextStyle(
            color: Color(0xFFAEE7FF),
            backgroundColor: Color(0xFF17323D),
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: const Color(0xFF17323D),
            borderRadius: BorderRadius.circular(4),
          ),

          // Emphasis styles
          em: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontStyle: FontStyle.italic,
          ),
          strong: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontWeight: FontWeight.bold,
          ),

          // Quote styles
          blockquote: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontStyle: FontStyle.italic,
          ),
          blockquoteDecoration: BoxDecoration(
            color: const Color(0xFF17323D),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF2A3F4A)),
          ),

          // Link style - using the same color as in the preview
          a: const TextStyle(
            color: Color(0xFF71C2E4),
            decoration: TextDecoration.underline,
          ),

          // Table styles
          tableHead: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontWeight: FontWeight.bold,
          ),
          tableBody: const TextStyle(
            color: Color(0xFFAEE7FF),
          ),
          tableBorder: TableBorder.all(
            color: const Color(0xFF2A3F4A),
            width: 1,
          ),
          tableCellsPadding: const EdgeInsets.all(8.0),

          // Horizontal rule style
          horizontalRuleDecoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 1.0,
                color: Color(0xFF2A3F4A),
              ),
            ),
          ),
        ),
        selectable: true,
        onTapLink: (text, href, title) {
          if (href != null) {
            launchUrlExternal(href);
          }
        },
        imageBuilder: (uri, title, alt) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              uri.toString(),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17323D),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Unable to load image',
                    style: TextStyle(color: Color(0xFFAEE7FF)),
                  ),
                );
              },
            ),
          );
        },
      );
    } catch (e) {
      // Fallback to plain text if markdown parsing fails
      return Text(
        _descriptionController.text,
        style: const TextStyle(
          color: Color(0xFFAEE7FF),
          fontSize: 16,
          height: 1.5,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// Club Selection Dialog
class ClubSelectionDialog extends StatelessWidget {
  final List<Club> clubs;

  const ClubSelectionDialog({super.key, required this.clubs});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2026),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF17323D),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Club',
              style: TextStyle(
                color: Color(0xFFAEE7FF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose which club to post this announcement for:',
              style: TextStyle(
                color: Color(0xFF83ACBD),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Divider(
              color: Color(0xFF17323D),
              thickness: 1,
              height: 1,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: clubs.length,
                itemBuilder: (context, index) {
                  final club = clubs[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop(club);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF71C2E4),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                club.logoUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              club.name,
                              style: const TextStyle(
                                color: Color(0xFFAEE7FF),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF83ACBD),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF83ACBD),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

// No Admin Clubs Dialog
class NoAdminClubsDialog extends StatelessWidget {
  const NoAdminClubsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2026),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF17323D),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFAEE7FF),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Not a Club Admin',
              style: TextStyle(
                color: Color(0xFFAEE7FF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sorry, you\'re not the admin of any club.',
              style: TextStyle(
                color: Color(0xFF83ACBD),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Contact ',
                  style: TextStyle(
                    color: Color(0xFF83ACBD),
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    launchUrlExternal('https://wa.me/917036972415');
                  },
                  child: const Text(
                    'Akhil',
                    style: TextStyle(
                      color: Color(0xFF71C2E4),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Text(
                  ' if this is a mistake.',
                  style: TextStyle(
                    color: Color(0xFF83ACBD),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E668A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}