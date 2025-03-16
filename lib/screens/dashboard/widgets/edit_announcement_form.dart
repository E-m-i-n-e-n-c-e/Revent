import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/utils/firedata.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:events_manager/utils/markdown_renderer.dart';

class EditAnnouncementForm extends StatefulWidget {
  final String title;
  final String description;
  final String clubId;
  final int index;
  final DateTime date;

  const EditAnnouncementForm({
    super.key,
    required this.title,
    required this.description,
    required this.clubId,
    required this.index,
    required this.date,
  });

  @override
  State<EditAnnouncementForm> createState() => _EditAnnouncementFormState();
}

class _EditAnnouncementFormState extends State<EditAnnouncementForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool _isPreviewMode = false;
  bool _isSaving = false;
  String? _errorMessage;
  bool _isUploadingFile = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
  }

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

  Future<void> _updateAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
      });

      try {
        // Create updated announcement with the same fields except title and description
        final updatedAnnouncement = Announcement(
          title: _titleController.text,
          description: _descriptionController.text,
          clubId: widget.clubId,
          date: widget.date, // Do not change date upon updating
        );

        // Update the announcement
        await updateAnnouncement(widget.clubId, widget.index, updatedAnnouncement);

        if (mounted) {
          // Show success message and navigate back twice (to detail view and list)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Announcement updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Go back to detail view
          Navigator.pop(context); // Go back to list
        }
      } catch (e) {
        setState(() {
          _isSaving = false;
          if (e.toString().contains('permission') || e.toString().contains('denied')) {
            _errorMessage = "Sorry, you're not an admin of this club";
          } else {
            _errorMessage = 'Failed to update announcement: $e';
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06222F),
      appBar: AppBar(
        title: const Text('Edit Announcement'),
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
            onPressed: _isSaving ? null : _updateAnnouncement,
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
      physics: const AlwaysScrollableScrollPhysics(),
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
              child: MarkdownRenderer(data: _descriptionController.text),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}