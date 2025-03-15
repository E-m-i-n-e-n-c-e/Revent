import 'package:flutter/material.dart';
import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/screens/dashboard/widgets/announcement_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:events_manager/providers/stream_providers.dart';
import 'package:events_manager/screens/clubs/club_page.dart';
import 'package:events_manager/utils/common_utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isInitialized = false;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Clear search state when screen is initialized
    _searchController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchQueryProvider.notifier).state = '';
      ref.read(searchFilterProvider.notifier).state = 'All';
      setState(() {
        _isInitialized = true;
      });
    });
  }

  void _submitSearch() {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return PopScope(
      canPop: !_searchFocusNode.hasFocus,
      onPopInvokedWithResult: (didPop,result) {
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Search',
              style: TextStyle(
                color: Color(0xFFAEE7FF),
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF07181F), Color(0xFF000000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
        child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2026),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF17323D),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                  controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: const TextStyle(color: Color(0xFFAEE7FF)),
                      decoration: const InputDecoration(
                        hintText: 'Search Revent',
                        hintStyle: TextStyle(color: Color(0xFF83ACBD)),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF83ACBD)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                  onChanged: (value) =>
                      ref.read(searchQueryProvider.notifier).state = value,
                      onSubmitted: (_) => _submitSearch(),
                      autofocus: false,
                    ),
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Filter chips
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Center(
                            child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Events'),
                      _buildFilterChip('Announcements'),
                      _buildFilterChip('Clubs'),
                    ],
                  ),
                ),
                          ),
                        ),
                      ),

                      // Results count
                      if (_isInitialized && searchResults.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Row(
                              children: [
                                Text(
                                  'Found ${searchResults.length} result${searchResults.length != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    color: Color(0xFF83ACBD),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Results list
                      !_isInitialized || searchResults.isEmpty
                          ? SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _searchController.text.isEmpty
                                          ? Icons.search
                                          : Icons.search_off,
                                      color: const Color(0xFF83ACBD),
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchController.text.isEmpty
                                          ? 'Search for events, announcements, or clubs'
                                          : 'No results found',
                                      style: const TextStyle(
                                        color: Color(0xFFAEE7FF),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (_searchController.text.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Try a different search term or filter',
                                        style: TextStyle(
                                          color: Color(0xFF83ACBD),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                        final result = searchResults[index];
                        return _buildSearchResultCard(result);
                      },
                                  childCount: searchResults.length,
                                ),
                              ),
                            ),
                    ],
                    ),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final selectedFilter = ref.watch(searchFilterProvider);
    final isSelected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFFAEE7FF) : const Color(0xFF83ACBD),
            fontSize: 12,
          ),
        ),
        backgroundColor: const Color(0xFF0F2026),
        selectedColor: const Color(0xFF17323D),
        checkmarkColor: const Color(0xFFAEE7FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color:
                isSelected ? const Color(0xFF71C2E4) : const Color(0xFF17323D),
          ),
        ),
        onSelected: (bool selected) {
          ref.read(searchFilterProvider.notifier).state = label;
        },
      ),
    );
  }

  Widget _buildSearchResultCard(dynamic result) {
    if (result is Event) {
      return _buildEventCard(result);
    } else if (result is Announcement) {
      return _buildAnnouncementCard(result);
    } else if (result is Club) {
      return _buildClubCard(result);
    }
    return const SizedBox.shrink();
  }

  Widget _buildEventCard(Event event) {
    final clubs = ref.watch(clubsStreamProvider).value ?? [];
    final club = clubs.firstWhere(
      (club) => club.id == event.clubId,
      orElse: () => Club(id: '', name: '', logoUrl: '', backgroundImageUrl: ''),
    );

    final isPastEvent = DateTime.now().isAfter(event.endTime);
    final timeRange =
        '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}';
    final dateFormatted = DateFormat('EEE, MMM d').format(event.startTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF0F2027),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF17323D), width: 1),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          _submitSearch();
          showModalBottomSheet(
            context: context,
            backgroundColor: const Color(0xFF0F2027),
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(club.logoUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                color: Color(0xFFAEE7FF),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              club.name,
                              style: const TextStyle(
                                color: Color(0xFF83ACBD),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
            Text(
              event.description,
                    style: const TextStyle(
                      color: Color(0xFFAEE7FF),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF83ACBD),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormatted,
                        style: const TextStyle(
                          color: Color(0xFF83ACBD),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFF83ACBD),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeRange,
                        style: const TextStyle(
                          color: Color(0xFF83ACBD),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (event.venue != null && event.venue!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF83ACBD),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.venue!,
                            style: const TextStyle(
                              color: Color(0xFF83ACBD),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (isPastEvent && event.feedbackLink != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E668A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => launchUrlExternal(event.feedbackLink!),
                        child: const Text('GIVE FEEDBACK'),
                      ),
                    ),
                  ] else if (!isPastEvent &&
                      event.registrationLink != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E668A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () =>
                            launchUrlExternal(event.registrationLink!),
                        child: const Text('REGISTER'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(club.logoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: Color(0xFFAEE7FF),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          club.name,
                          style: const TextStyle(
                            color: Color(0xFF83ACBD),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
            Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                      color: isPastEvent
                          ? const Color(0xFF173240)
                          : const Color(0xFF0E668A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPastEvent ? 'Past' : 'Upcoming',
                      style: const TextStyle(
                        color: Color(0xFFAEE7FF),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: const TextStyle(color: Color(0xFFAEE7FF)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF83ACBD),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormatted,
                    style: const TextStyle(
                      color: Color(0xFF83ACBD),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF83ACBD),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeRange,
                style: const TextStyle(
                      color: Color(0xFF83ACBD),
                  fontSize: 12,
                ),
                  ),
                  if (event.venue != null && event.venue!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF83ACBD),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.venue!,
                        style: const TextStyle(
                          color: Color(0xFF83ACBD),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
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
            _submitSearch();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnnouncementDetailView(
              title: announcement.title,
              description: announcement.description,
              clubId: announcement.clubId,
              date: announcement.date,
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
                      backgroundImage:
                          NetworkImage(getClubLogo(ref, announcement.clubId)),
                      child: null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getClubName(ref, announcement.clubId),
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
                            _formatDate(announcement.date),
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
            announcement.title,
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
                      data: announcement.description,
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
                              maxWidth: MediaQuery.of(context).size.width -
                                  64, // Account for padding
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
                if (announcement.description.length > 150 ||
                    announcement.description.contains('\n'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
                              isExpanded
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
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

  Widget _buildClubCard(Club club) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF0F2027),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF17323D), width: 1),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          _submitSearch();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClubPage(club: club),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'club-logo-${club.id}',
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF71C2E4),
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(club.logoUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
          club.name,
                      style: const TextStyle(
                        color: Color(0xFF61E7FF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF173240),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Club',
                        style: TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFAEE7FF),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
