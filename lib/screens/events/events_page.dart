import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:events_manager/providers/stream_providers.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/utils/common_utils.dart';

class EventsPage extends ConsumerWidget {
  const EventsPage({super.key});

  bool _isEventPast(DateTime endTime) {
    return DateTime.now().isAfter(endTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsStreamProvider);
    final clubs = ref.watch(clubsStreamProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF071820),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 7, 20, 20),
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
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
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
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      itemCount: eventsList.length,
                      itemBuilder: (context, index) {
                        final event = eventsList[index];
                        final club = clubs.value?.firstWhere(
                          (club) => club.id == event.clubId,
                          orElse: () => Club(id: '', name: '', logoUrl: '', backgroundImageUrl: ''),
                        );
                        final bool isPastEvent = _isEventPast(event.endTime);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExpandableEventCard(
                            event: event,
                            club: club,
                            isPastEvent: isPastEvent,
                          ),
                        );
                      },
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

  @override
  Widget build(BuildContext context) {
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
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF71C2E4),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(widget.club?.logoUrl ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF173240),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.startTime.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (widget.isPastEvent && widget.event.feedbackLink != null)
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF0E668A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
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
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF0E668A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
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