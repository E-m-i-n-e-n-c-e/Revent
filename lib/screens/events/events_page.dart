import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:events_manager/providers/stream_providers.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/utils/common_utils.dart';
import 'package:intl/intl.dart';

class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({super.key});

  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    // Reset filter state when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventsSearchQueryProvider.notifier).state = '';
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

  List<Event> _getUpcomingEvents(List<Event> events) {
    final now = DateTime.now();
    return events.where((event) => event.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Event> _getPastEvents(List<Event> events) {
    final now = DateTime.now();
    return events.where((event) => event.startTime.isBefore(now)).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Map<DateTime, List<Event>> _groupEventsByDate(List<Event> events) {
    final Map<DateTime, List<Event>> groupedEvents = {};
    for (var event in events) {
      final date = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      if (!groupedEvents.containsKey(date)) {
        groupedEvents[date] = [];
      }
      groupedEvents[date]!.add(event);
    }
    return groupedEvents;
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 11, bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF173240),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Color(0xFFAEE7FF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = ref.watch(filteredEventsProvider);
    final clubs = ref.watch(clubsStreamProvider);

    return PopScope(
      canPop: !_isSearchExpanded,
      onPopInvokedWithResult: (didPop,result) {
        if (_isSearchExpanded) {
          setState(() {
            _isSearchExpanded = false;
            _searchController.clear();
            ref.read(eventsSearchQueryProvider.notifier).state = '';
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
                      ref.read(eventsSearchQueryProvider.notifier).state = '';
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
                    hintText: 'Search events...',
                    hintStyle: TextStyle(color: Color(0xFF83ACBD)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    ref.read(eventsSearchQueryProvider.notifier).state = value;
                  },
                  onSubmitted: (_) => _submitSearch(),
                )
              : const Text(
                  'Events',
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
                                  _buildClubFilterChip('All Clubs'),
                                  ...clubsList.map((club) => _buildClubFilterChip(club.id, clubName: club.name)),
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
                    if (filteredEvents.isEmpty) {
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
                                'No events found',
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

                    final upcomingEvents = _getUpcomingEvents(filteredEvents);
                    final pastEvents = _getPastEvents(filteredEvents);

                    final upcomingGrouped = _groupEventsByDate(upcomingEvents);
                    final pastGrouped = _groupEventsByDate(pastEvents);

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          if (upcomingEvents.isNotEmpty) ...[
                            _buildSectionHeader('Upcoming Events', upcomingEvents.length),
                            ...upcomingGrouped.entries.expand((entry) => [
                              buildDateSeparator(entry.key),
                              ...entry.value.map((event) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ExpandableEventCard(
                                    event: event,
                                    isPastEvent: false,
                                  ),
                                );
                              }),
                            ]),
                          ],
                          if (pastEvents.isNotEmpty) ...[
                             const SizedBox(height: 10),
                            _buildSectionHeader('Past Events', pastEvents.length),
                            ...pastGrouped.entries.expand((entry) => [
                              buildDateSeparator(entry.key),
                              ...entry.value.map((event) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ExpandableEventCard(
                                    event: event,
                                    isPastEvent: true,
                                  ),
                                );
                              }),
                            ]),
                          ],
                        ]),
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
                        'Error loading events: $error',
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

  Widget _buildClubFilterChip(String clubId, {String? clubName}) {
    final selectedClub = ref.watch(eventsFilterClubProvider);
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
          ref.read(eventsFilterClubProvider.notifier).state = selected ? clubId : 'All Clubs';
        },
      ),
    );
  }
}

class ExpandableEventCard extends ConsumerStatefulWidget {
  final Event event;
  final bool isPastEvent;

  const ExpandableEventCard({
    super.key,
    required this.event,
    required this.isPastEvent,
  });

  @override
  ConsumerState<ExpandableEventCard> createState() => _ExpandableEventCardState();
}

class _ExpandableEventCardState extends ConsumerState<ExpandableEventCard> {
  bool isExpanded = false;

  String _formatTimeRange(DateTime start, DateTime end) {
    final startTime = DateFormat('h:mm a').format(start);
    final endTime = DateFormat('h:mm a').format(end);
    return '$startTime - $endTime';
  }

  @override
  Widget build(BuildContext context) {
    final timeRange = _formatTimeRange(widget.event.startTime, widget.event.endTime);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F2027),
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 5.1,
            offset: Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.title,
              style: const TextStyle(
                color: Color(0xFFAEE7FF),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.event.description,
              style: const TextStyle(
                color: Color(0xFFAEE7FF),
                fontSize: 14,
              ),
              maxLines: isExpanded ? null : 3,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            ),
            if (widget.event.description.split('\n').length > 3 ||
                widget.event.description.length > 150)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
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
                ],
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: getCachedNetworkImageProvider(
                                imageUrl: getClubLogo(ref, widget.event.clubId),
                                imageType: ImageType.club,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF173240),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                timeRange,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.event.venue != null && widget.event.venue!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF173240),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xFFAEE7FF),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.3,
                                  ),
                                  child: Text(
                                    widget.event.venue!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (widget.isPastEvent && widget.event.feedbackLink != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E668A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ).copyWith(
                      overlayColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.white.withValues(alpha:0.1);
                          }
                          return null;
                        },
                      ),
                    ),
                    onPressed: () => launchUrlExternal(widget.event.feedbackLink!),
                    child: const Text(
                      'FEEDBACK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ] else if (!widget.isPastEvent && widget.event.registrationLink != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E668A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ).copyWith(
                      overlayColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.white.withValues(alpha:0.1);
                          }
                          return null;
                        },
                      ),
                    ),
                    onPressed: () => launchUrlExternal(widget.event.registrationLink!),
                    child: const Text(
                      'REGISTER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}