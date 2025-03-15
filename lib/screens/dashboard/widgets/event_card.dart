import 'package:flutter/material.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/screens/events/event_utils.dart';
import 'package:events_manager/utils/common_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventCard extends StatefulWidget {
  const EventCard({super.key, required this.events});
  final List<Event> events;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: const Color(0xFF06151C),
          borderRadius: BorderRadius.circular(30),
        ),
        child: widget.events.isEmpty
            ? const Center(
                child: Text(
                  'No events today',
                  style: TextStyle(
                    color: Color(0xFFAEE7FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: SingleChildScrollView(
                  child: Column(
                    children: widget.events.map((event) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        child: EventItem(event: event),
                      );
                    }).toList(),
                  ),
                ),
            ),
      ),
    );
  }
}

class EventItem extends ConsumerWidget {
  final Event event;

  const EventItem({
    super.key,
    required this.event,
  });

  bool _isEventPast() {
    return DateTime.now().isAfter(event.endTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isPastEvent = _isEventPast();

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2027),
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, 2),
            blurRadius: 5,
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            event.description,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(51),
                        child: Image.network(
                          getClubLogo(ref, event.clubId),
                          width: 23,
                          height: 23,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17323D),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatTimeRange(context, event.startTime, event.endTime),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (event.venue != null && event.venue!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF17323D),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFFAEE7FF),
                                size: 9,
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
                                    fontSize: 9,
                                    fontWeight: FontWeight.w400,
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
                  onPressed: () => launchUrlExternal(event.feedbackLink!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E668A),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ).copyWith(
                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) => states.contains(WidgetState.pressed)
                          ? Colors.white.withValues(alpha:0.1)
                          : null,
                    ),
                  ),
                  child: const Text(
                    'FEEDBACK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else if (!isPastEvent && event.registrationLink != null) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => launchUrlExternal(event.registrationLink!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E668A),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ).copyWith(
                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) => states.contains(WidgetState.pressed)
                          ? Colors.white.withValues(alpha:0.1)
                          : null,
                    ),
                  ),
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
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
}
