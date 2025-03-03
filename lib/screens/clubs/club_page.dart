import 'package:events_manager/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/providers/stream_providers.dart' as providers;
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:events_manager/screens/dashboard/widgets/announcement_card.dart';
import 'package:events_manager/screens/clubs/edit_club_form.dart';

class ClubPage extends ConsumerStatefulWidget {
  final Club club;

  const ClubPage({super.key, required this.club});

  @override
  ConsumerState<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends ConsumerState<ClubPage> {
  String _selectedTab = 'EVENTS';
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;
  final bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 140 && !_isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = true);
    } else if (_scrollController.offset <= 140 && _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = false);
    }
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

  List<Announcement> _getRecentAnnouncements(List<Announcement> announcements) {
    return announcements..sort((a, b) => b.date.compareTo(a.date));
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

  @override
  Widget build(BuildContext context) {
    // Get the live club data from the provider
    final clubs = ref.watch(providers.clubsStreamProvider);

    return clubs.when(
      data: (clubsList) {
        // Find the current club from the live data
        final currentClub = clubsList.firstWhere((club) => club.id == widget.club.id);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: _isHeaderCollapsed ? const Color(0xFF06222F) : Colors.transparent,
            elevation: _isHeaderCollapsed ? 4 : 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFAEE7FF)),
              onPressed: () => Navigator.pop(context),
            ),
            title: _isHeaderCollapsed
                ? Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(currentClub.logoUrl),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        currentClub.name,
                        style: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFFAEE7FF)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditClubForm(club: currentClub),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF07181F), Color(0xFF000000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: const Color(0xFF06222F),
                          image: DecorationImage(
                            image: NetworkImage(
                              currentClub.backgroundImageUrl.isNotEmpty
                                  ? currentClub.backgroundImageUrl
                                  : currentClub.logoUrl,
                            ),
                            fit: BoxFit.cover,
                            opacity: 0.3,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
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
                            if (_isUploading)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Color(0xFFAEE7FF)),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Uploading image...',
                                        style: TextStyle(
                                          color: Color(0xFFAEE7FF),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 27,
                        right: 27,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF71C2E4),
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(currentClub.logoUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentClub.name,
                                        style: const TextStyle(
                                          color: Color(0xFF61E7FF),
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _buildMetricItem(
                                            FontAwesomeIcons.users,
                                            '1.2K',
                                            'Members',
                                          ),
                                          const SizedBox(width: 16),
                                          _buildMetricItem(
                                            FontAwesomeIcons.calendar,
                                            '24',
                                            'Events',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSocialButton(
                              FontAwesomeIcons.discord,
                              'DISCORD',
                              onTap: () {},
                            ),
                            _buildSocialButton(
                              FontAwesomeIcons.whatsapp,
                              'WHATSAPP',
                              onTap: () {},
                            ),
                            _buildSocialButton(
                              FontAwesomeIcons.link,
                              'LINKTREE',
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildTabButton('EVENTS'),
                              _buildTabButton('ANNOUNCEMENTS'),
                              _buildTabButton('ABOUT'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedTab == 'EVENTS') ...[
                          ref.watch(providers.eventsStreamProvider).when(
                            data: (eventsList) {
                              final clubEvents = eventsList
                                  .where((event) => event.clubId == currentClub.id)
                                  .toList();
                              final upcomingEvents = _getUpcomingEvents(clubEvents);
                              final pastEvents = _getPastEvents(clubEvents);

                              final upcomingGrouped = _groupEventsByDate(upcomingEvents);
                              final pastGrouped = _groupEventsByDate(pastEvents);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (upcomingEvents.isNotEmpty) ...[
                                    _buildSectionHeader(
                                        'Upcoming Events', upcomingEvents.length),
                                    const SizedBox(height: 10),
                                    ...upcomingGrouped.entries.expand((entry) => [
                                          buildDateSeparator(entry.key),
                                          ...entry.value.map((event) => Padding(
                                                padding: const EdgeInsets.only(bottom: 12),
                                                child: _buildEventCard(event),
                                              )),
                                        ]),
                                    const SizedBox(height: 20),
                                  ],
                                  if (pastEvents.isNotEmpty) ...[
                                    _buildSectionHeader(
                                        'Past Events', pastEvents.length),
                                    const SizedBox(height: 10),
                                    ...pastGrouped.entries.expand((entry) => [
                                          buildDateSeparator(entry.key),
                                          ...entry.value.map((event) => Padding(
                                                padding: const EdgeInsets.only(bottom: 12),
                                                child: _buildEventCard(event),
                                              )),
                                        ]),
                                  ],
                                ],
                              );
                            },
                            loading: () =>
                                const Center(child: CircularProgressIndicator()),
                            error: (error, stack) => Center(
                              child: Text('Error loading events: $error',
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          ),
                        ] else if (_selectedTab == 'ANNOUNCEMENTS') ...[
                          ref.watch(providers.announcementsStreamProvider).when(
                            data: (announcementsList) {
                              final clubAnnouncements = announcementsList
                                  .where((announcement) =>
                                      announcement.clubId == currentClub.id)
                                  .toList();
                              final recentAnnouncements =
                                  _getRecentAnnouncements(clubAnnouncements);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader(
                                      'Announcements', recentAnnouncements.length),
                                  const SizedBox(height: 10),
                                  ...recentAnnouncements.map((announcement) =>
                                      _buildAnnouncementCard(announcement)),
                                ],
                              );
                            },
                            loading: () =>
                                const Center(child: CircularProgressIndicator()),
                            error: (error, stack) => Center(
                              child: Text('Error loading announcements: $error',
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          ),
                        ] else if (_selectedTab == 'ABOUT') ...[
                          _buildSectionHeader('About Us', null),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F2026),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome to ${currentClub.name}!',
                                  style: const TextStyle(
                                    color: Color(0xFFAEE7FF),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentClub.about.isNotEmpty
                                      ? currentClub.about
                                      : 'We\'re a group of students passionate about organizing events, workshops, and discussions. Join us to grow your skills and connect with others in the community.',
                                  style: const TextStyle(
                                    color: Color(0xFFAEE7FF),
                                    fontSize: 14,
                                    height: 1.5,
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
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading club: $error', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFFAEE7FF),
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFAEE7FF).withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int? count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF17323D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Color(0xFFAEE7FF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String text,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF17323D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF71C2E4).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFFAEE7FF),
              size: 14,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFFAEE7FF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text) {
    final isSelected = _selectedTab == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF17323D) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF71C2E4)
                : const Color(0xFF71C2E4).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFAEE7FF)
                : const Color(0xFFAEE7FF).withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final bool isPastEvent = DateTime.now().isAfter(event.endTime);
    final timeRange = _formatTimeRange(event.startTime, event.endTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2026),
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
          const SizedBox(height: 8),
          Text(
            event.description,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 14,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
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
                              Icons.access_time,
                              color: Color(0xFFAEE7FF),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
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
                      if (event.venue != null && event.venue!.isNotEmpty) ...[
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
                                  event.venue!,
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
              if (isPastEvent && event.feedbackLink != null) ...[
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
                  onPressed: () => launchUrlExternal(event.feedbackLink!),
                  child: const Text(
                    'FEEDBACK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else if (!isPastEvent && event.registrationLink != null) ...[
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
                  onPressed: () => launchUrlExternal(event.registrationLink!),
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
    );
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    final startTime = DateFormat('h:mm a').format(start);
    final endTime = DateFormat('h:mm a').format(end);
    return '$startTime - $endTime';
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    final formattedDate = DateFormat('MMM d, y').format(announcement.date);

    return ExpandableAnnouncementCard(
      announcement: announcement,
      formattedDate: formattedDate,
    );
  }
}

class ExpandableEventCard extends StatefulWidget {
  final Event event;
  final String formattedDate;
  final String formattedTime;
  final bool isPastEvent;
  final Function(String) onLaunchUrl;

  const ExpandableEventCard({
    super.key,
    required this.event,
    required this.formattedDate,
    required this.formattedTime,
    required this.isPastEvent,
    required this.onLaunchUrl,
  });

  @override
  State<ExpandableEventCard> createState() => _ExpandableEventCardState();
}

class _ExpandableEventCardState extends State<ExpandableEventCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2026),
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
          const SizedBox(height: 8),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF17323D),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFAEE7FF),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.formattedDate,
                      style: const TextStyle(
                        color: Color(0xFFAEE7FF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF17323D),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Color(0xFFAEE7FF),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.formattedTime,
                      style: const TextStyle(
                        color: Color(0xFFAEE7FF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (widget.isPastEvent && widget.event.feedbackLink != null)
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
                  )
              else if (!widget.isPastEvent &&
                  widget.event.registrationLink != null)
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
          ),
        ],
      ),
    );
  }
}

class ExpandableAnnouncementCard extends StatefulWidget {
  final Announcement announcement;
  final String formattedDate;

  const ExpandableAnnouncementCard({
    super.key,
    required this.announcement,
    required this.formattedDate,
  });

  @override
  State<ExpandableAnnouncementCard> createState() =>
      _ExpandableAnnouncementCardState();
}

class _ExpandableAnnouncementCardState
    extends State<ExpandableAnnouncementCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2026),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnnouncementDetailView(
                  title: widget.announcement.title,
                  description: widget.announcement.description,
                  clubId: widget.announcement.clubId,
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
                Text(
                  widget.announcement.title,
                  style: const TextStyle(
                    color: Color(0xFFAEE7FF),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.announcement.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.announcement.subtitle,
                    style: const TextStyle(
                      color: Color(0xFFAEE7FF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                const Divider(
                  color: Color(0xFF17323D),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: 8),
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
                          height: 1.3,
                        ),
                        h2: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        h3: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        h4: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        h5: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        h6: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        // Adjust paragraph spacing
                        pPadding: const EdgeInsets.only(bottom: 8),
                        h1Padding: const EdgeInsets.only(bottom: 8, top: 8),
                        h2Padding: const EdgeInsets.only(bottom: 8, top: 8),
                        h3Padding: const EdgeInsets.only(bottom: 8, top: 8),
                        h4Padding: const EdgeInsets.only(bottom: 8, top: 8),
                        h5Padding: const EdgeInsets.only(bottom: 8, top: 8),
                        h6Padding: const EdgeInsets.only(bottom: 8, top: 8),

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
                if (widget.announcement.description.length > 150 ||
                    widget.announcement.description.contains('\n'))
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF17323D),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFAEE7FF),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.formattedDate,
                            style: const TextStyle(
                              color: Color(0xFFAEE7FF),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.announcement.venue.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17323D),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFFAEE7FF),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.announcement.venue,
                              style: const TextStyle(
                                color: Color(0xFFAEE7FF),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
