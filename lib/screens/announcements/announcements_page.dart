import 'package:events_manager/providers/stream_providers.dart';
import 'package:events_manager/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:events_manager/screens/dashboard/widgets/announcement_card.dart';
import 'package:intl/intl.dart';
import 'package:events_manager/models/announcement.dart';

class AnnouncementsPage extends ConsumerStatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  ConsumerState<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends ConsumerState<AnnouncementsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    // Reset filter state when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(announcementsSearchQueryProvider.notifier).state = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _submitSearch() {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAnnouncements = ref.watch(filteredAnnouncementsProvider);
    final clubs = ref.watch(clubsStreamProvider);

    return PopScope(
      canPop: !_isSearchExpanded,
      onPopInvokedWithResult: (didPop,result) {
        if (_isSearchExpanded) {
          setState(() {
            _isSearchExpanded = false;
            _searchController.clear();
            ref.read(announcementsSearchQueryProvider.notifier).state = '';
          });
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _isSearchExpanded
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFAEE7FF)),
                  onPressed: () {
                    setState(() {
                      _isSearchExpanded = false;
                      _searchController.clear();
                      ref.read(announcementsSearchQueryProvider.notifier).state = '';
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFAEE7FF)),
                  onPressed: () => Navigator.pop(context),
                ),
          title: _isSearchExpanded
              ? TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: false,
                  style: const TextStyle(color: Color(0xFFAEE7FF)),
                  decoration: const InputDecoration(
                    hintText: 'Search announcements...',
                    hintStyle: TextStyle(color: Color(0xFF83ACBD)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    ref.read(announcementsSearchQueryProvider.notifier).state = value;
                  },
                  onSubmitted: (_) => _submitSearch(),
                )
              : const Text(
                  'Announcements',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFAEE7FF),
                  ),
                ),
          actions: [
            if (!_isSearchExpanded)
              Padding(
                padding: const EdgeInsets.only(right:8.0),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFFAEE7FF)),
                  onPressed: () {
                    setState(() {
                      _isSearchExpanded = true;
                    });
                    // Focus the search field when expanding
                    _searchFocusNode.requestFocus();
                  },
                ),
              ),
          ],
        ),
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Club filter
                      clubs.when(
                        data: (clubsList) {
                          if (clubsList.isEmpty) {
                            return const SizedBox();
                          }

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip('All Clubs'),
                                  ...clubsList.map((club) => _buildFilterChip(club.id, clubName: club.name)),
                                ],
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                ),

                // Results list
                clubs.when(
                  data: (clubsList) {
                    if (filteredAnnouncements.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off,
                                color: Color(0xFF83ACBD),
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No announcements found',
                                style: TextStyle(
                                  color: Color(0xFFAEE7FF),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'Try selecting a different club'
                                    : 'Try a different search term',
                                style: const TextStyle(
                                  color: Color(0xFF83ACBD),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final announcement = filteredAnnouncements[index];
                            return MarkdownAnnouncementCard(
                              announcement: announcement,
                              onTap: _submitSearch,
                            );
                          },
                          childCount: filteredAnnouncements.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAEE7FF)),
                      ),
                    ),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Error loading announcements: $error',
                        style: const TextStyle(color: Colors.red),
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

  Widget _buildFilterChip(String clubId, {String? clubName}) {
    final selectedClub = ref.watch(announcementsFilterClubProvider);
    final isSelected = selectedClub == clubId;
    final displayName = clubName ?? clubId;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          displayName == clubId ? 'All Clubs' : displayName,
          style: TextStyle(
            color: isSelected ? const Color(0xFFAEE7FF) : const Color(0xFF83ACBD),
            fontSize: 12,
          ),
        ),
        backgroundColor: const Color(0xFF0F2026),
        selectedColor: const Color(0xFF17323D),
        checkmarkColor: const Color(0xFFAEE7FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? const Color(0xFF71C2E4) : const Color(0xFF17323D),
          ),
        ),
        onSelected: (selected) {
          ref.read(announcementsFilterClubProvider.notifier).state = selected ? clubId : 'All Clubs';
        },
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

            // Call the onTap callback if provided
            widget.onTap?.call();

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
                      radius: 16,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:NetworkImage(getClubLogo(ref, widget.announcement.clubId)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getClubName(ref, widget.announcement.clubId),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFAEE7FF),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
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
                const SizedBox(height: 10),
                Text(
                  widget.announcement.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAEE7FF),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
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
                    physics: const NeverScrollableScrollPhysics(),
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
                        horizontalRuleDecoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 1.0,
                              color: Color(0xFF2A3F4A),
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
