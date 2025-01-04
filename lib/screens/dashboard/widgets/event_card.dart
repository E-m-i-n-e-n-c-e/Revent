import 'package:flutter/material.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/data/events_data.dart';

class EventCard extends StatefulWidget {
  const EventCard({super.key});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _isLoading = true;
    });

    // Load from local data
    _events = sampleEvents;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          decoration: BoxDecoration(
            color: const Color(0xFF06151C),
            borderRadius: BorderRadius.circular(30),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: _events.map((event) {
                      return Column(
                        children: [
                          EventItem(event: event),
                          const SizedBox(height: 12),
                        ],
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 26, 9),
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
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 12,
              fontWeight: FontWeight.w200,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(51),
                child: Image.network(
                  event.imageUrl,
                  width: 35,
                  height: 35,
                  fit: BoxFit.contain,
                  semanticLabel: 'Club Logo',
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF17323D),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  event.time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'DM Sans',
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
