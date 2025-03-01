import 'package:flutter/material.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/data/clubs_data.dart';
import 'package:events_manager/screens/events/event_utils.dart';

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
        padding: EdgeInsets.symmetric(vertical: 1),
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
              padding: EdgeInsets.symmetric(vertical: 1),
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

class EventItem extends StatelessWidget {
  final Event event;

  const EventItem({
    super.key,
    required this.event,
  });

  String getClubLogo(String clubId) {
    final club = sampleClubs.firstWhere(
      (club) => club.id == clubId,
      orElse: () => sampleClubs.first,
    );
    return club.logoUrl;
  }

  @override
  Widget build(BuildContext context) {
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
              ClipRRect(
                borderRadius: BorderRadius.circular(51),
                child: Image.network(
                  getClubLogo(event.clubId),
                  width: 25,
                  height: 25,
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
                child: Text(
                  formatTimeRange(context, event.startTime, event.endTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E668A),
                  borderRadius: BorderRadius.circular(6),
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
          ),
        ],
      ),
    );
  }
}
