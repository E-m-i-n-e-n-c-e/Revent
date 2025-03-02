import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:events_manager/providers/stream_providers.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/utils/common_utils.dart';
import 'package:intl/intl.dart';

class EventsPage extends ConsumerWidget {
  const EventsPage({super.key});

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

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 11, bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 18,
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
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsStreamProvider);
    final clubs = ref.watch(clubsStreamProvider);

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
                      'Events',
                      style: TextStyle(
                        color: Color(0xFFAEE7FF),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: events.when(
                  data: (eventsList) {
                    if (eventsList.isEmpty) {
                      return const Center(
                        child: Text(
                          'No events available',
                          style: TextStyle(
                            color: Color(0xFFAEE7FF),
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    final upcomingEvents = _getUpcomingEvents(eventsList);
                    final pastEvents = _getPastEvents(eventsList);

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      children: [
                        if (upcomingEvents.isNotEmpty) ...[
                          _buildSectionHeader('Upcoming Events', upcomingEvents.length),
                          ...upcomingEvents.map((event) {
                            final club = clubs.value?.firstWhere(
                              (club) => club.id == event.clubId,
                              orElse: () => Club(id: '', name: '', logoUrl: '', backgroundImageUrl: ''),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ExpandableEventCard(
                                event: event,
                                club: club,
                                isPastEvent: false,
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                        ],
                        if (pastEvents.isNotEmpty) ...[
                          _buildSectionHeader('Past Events', pastEvents.length),
                          ...pastEvents.map((event) {
                            final club = clubs.value?.firstWhere(
                              (club) => club.id == event.clubId,
                              orElse: () => Club(id: '', name: '', logoUrl: '', backgroundImageUrl: ''),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ExpandableEventCard(
                                event: event,
                                club: club,
                                isPastEvent: true,
                              ),
                            );
                          }),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
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
    );
  }
}

class ExpandableEventCard extends StatefulWidget {
  final Event event;
  final Club? club;
  final bool isPastEvent;

  const ExpandableEventCard({
    super.key,
    required this.event,
    required this.club,
    required this.isPastEvent,
  });

  @override
  State<ExpandableEventCard> createState() => _ExpandableEventCardState();
}

class _ExpandableEventCardState extends State<ExpandableEventCard> {
  bool isExpanded = false;

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(widget.event.startTime);

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
                Container(
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(widget.club?.logoUrl ?? ''),
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
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFAEE7FF),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
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
                        Text(
                          widget.event.venue!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
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
                else if (!widget.isPastEvent && widget.event.registrationLink != null)
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
      ),
    );
  }
}