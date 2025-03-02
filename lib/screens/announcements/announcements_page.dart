import 'package:events_manager/providers/stream_providers.dart';
import 'package:events_manager/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:events_manager/screens/dashboard/widgets/announcement_card.dart';
import 'package:intl/intl.dart';
import 'package:events_manager/models/announcement.dart';

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementsStreamProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF07181F),
              Color(0xFF000000),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFFAEE7FF),
                      ),
                    ),
                    const Text(
                      'Announcements',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFAEE7FF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: announcements.when(
                  data: (announcementsList) {
                    if (announcementsList.isEmpty) {
                      return const Center(
                        child: Text(
                          'No announcements yet',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: announcementsList.length,
                      itemBuilder: (context, index) {
                        final announcement = announcementsList[index];
                        return MarkdownAnnouncementCard(
                          announcement: announcement,
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading announcements: $error',
                      style: const TextStyle(color: Colors.white),
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

class MarkdownAnnouncementCard extends ConsumerStatefulWidget {
  final Announcement announcement;
  final VoidCallback? onTap;

  const MarkdownAnnouncementCard({
    super.key,
    required this.announcement,
    this.onTap,
  });

  @override
  ConsumerState<MarkdownAnnouncementCard> createState() => _MarkdownAnnouncementCardState();
}

class _MarkdownAnnouncementCardState extends ConsumerState<MarkdownAnnouncementCard> {
  bool isExpanded = false;
  String? clubLogo;
  String? clubName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClubData();
  }

  Future<void> _loadClubData() async {
    setState(() {
      isLoading = true;
    });

    // Now we can use ref directly since we're in a ConsumerState
    clubName = getClubName(ref, widget.announcement.clubId);
    clubLogo = getClubLogo(ref, widget.announcement.clubId);

    setState(() {
      isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(widget.announcement.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2027),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // Find the index of this announcement in its club's list
            final clubAnnouncementList = ref
                .read(announcementsStreamProvider)
                .value!
                .where((a) => a.clubId == widget.announcement.clubId)
                .toList();
            final index = clubAnnouncementList.indexOf(widget.announcement);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnnouncementDetailView(
                  title: widget.announcement.title,
                  description: widget.announcement.description,
                  clubId: widget.announcement.clubId,
                  index: index,
                  date: widget.announcement.date,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: isLoading || clubLogo == null
                          ? null
                          : NetworkImage(clubLogo!),
                      child: isLoading || clubLogo == null
                          ? Icon(Icons.group, color: Colors.grey[600])
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoading ? 'Loading...' : clubName ?? 'Unknown Club',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFAEE7FF),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF83ACBD),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(
                  color: Color(0xFF17323D),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: isExpanded ? double.infinity : 100,
                  ),
                  child: SingleChildScrollView(
                    physics: isExpanded
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: MarkdownBody(
                      data: widget.announcement.description,
                      styleSheet: MarkdownStyleSheet(
                        // Text styles
                        p: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 14,
                          height: 1.5,
                        ),
                        h1: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        h4: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        h5: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        h6: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 10,
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
                        horizontalRuleDecoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 1.0,
                              color: const Color(0xFF2A3F4A),
                            ),
                          ),
                        ),
                      ),
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
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 64, // Account for padding
                            ),
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
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (widget.announcement.description.length > 150 ||
                    widget.announcement.description.contains('\n'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isExpanded ? 'See less' : 'See more',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF83ACBD),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isExpanded ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 12,
                              color: const Color(0xFF83ACBD),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
