import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:events_manager/utils/common_utils.dart';

class MarkdownRenderer extends StatelessWidget {
  final String data;
  final bool selectable;

  const MarkdownRenderer({
    super.key,
    required this.data,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return MarkdownBody(
        data: data.isEmpty ? '_No content yet_' : data,
        softLineBreak: true,
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

          // Link style
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
        selectable: selectable,
        onTapLink: (text, href, title) {
          if (href != null) {
            // Show a snackbar to indicate the link is being opened
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening link: $text'),
                duration: const Duration(seconds: 2),
                backgroundColor: const Color(0xFF0E668A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                // behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'DISMISS',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );

            // Launch the URL
            launchUrlExternal(href);
          }
        },
        imageBuilder: (uri, title, alt) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: getCachedNetworkImage(
              imageUrl: uri.toString(),
              imageType: ImageType.markdown,
              fit: BoxFit.contain,
              errorWidget:
                  Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFF17323D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Unable to load image',
                    style: TextStyle(color: Color(0xFFAEE7FF)),
                  ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Fallback to plain text if markdown parsing fails
      return Text(
        data,
        style: const TextStyle(
          color: Color(0xFFAEE7FF),
          fontSize: 16,
          height: 1.5,
        ),
      );
    }
  }
}