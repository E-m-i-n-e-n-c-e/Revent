import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:events_manager/utils/common_utils.dart';
import 'package:events_manager/screens/dashboard/widgets/edit_announcement_form.dart';
import 'package:markdown/markdown.dart' as markdown;

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF06222F),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.28),
            blurRadius: 20,
            offset: Offset(0, 0),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate a dynamic font size based on the available width
                    double fontSize = constraints.maxWidth * 3 / title.length;
                    // Adjust the factor as needed
                    fontSize = fontSize.clamp(18, 28);
                    // Ensure the font size is not too small or too large
                    // Minimum font size 18, maximum 30

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(51),
                child: Image.network(
                  image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  semanticLabel: 'Club Logo',
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'View more',
                style: TextStyle(
                  color: Color(0xFF83ACBD),
                  fontSize: 11.5,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF83ACBD),
                size: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnnouncementDetailView extends StatelessWidget {
  final String title;
  final String description;
  final String clubId;
  final int? index; // Add index parameter to identify which announcement to update
  final DateTime date;

  const AnnouncementDetailView({
    super.key,
    required this.title,
    required this.description,
    required this.clubId,
    this.index, // Optional parameter for the index
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06222F),
      appBar: AppBar(
        title: const Text('Announcement'),
        backgroundColor: const Color(0xFF06222F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff83ACBD)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Only show edit button if we have an index (meaning we can edit this announcement)
          if (index != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xff83ACBD)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAnnouncementForm(
                      title: title,
                      description: description,
                      clubId: clubId,
                      index: index!,
                      date: date,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFF0F2026),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      title,
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

                  // Markdown content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildMarkdownContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownContent() {
    try {
      return MarkdownBody(
        data: description,
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
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 1.0,
                color: const Color(0xFF2A3F4A),
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
        builders: {
          'a': CustomLinkBuilder(),
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
        description,
        style: const TextStyle(
          color: Color(0xFFAEE7FF),
          fontSize: 16,
          height: 1.5,
        ),
      );
    }
  }
}

class CustomLinkBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(markdown.Element element, TextStyle? preferredStyle) {
    var text = element.textContent;
    var href = element.attributes['href'];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (href != null) {
            launchUrlExternal(href);
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            text,
            style: TextStyle(
              color: Color(0xFF71C2E4),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
