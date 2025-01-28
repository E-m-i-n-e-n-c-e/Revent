import 'package:flutter/material.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/utils/firedata.dart';

class ClubPage extends StatefulWidget {
  final Club club;

  const ClubPage({super.key, required this.club});

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  List<Event> _clubEvents = [];
  bool _isLoading = true;
  String _selectedTab = 'EVENTS';

  @override
  void initState() {
    super.initState();
    _loadClubEvents();
  }

  Future<void> _loadClubEvents() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final eventList = await loadEvents();
      final events = eventList
          .map((eventData) => Event.fromJson(eventData))
          .where((event) => event.clubId == widget.club.id)
          .toList();

      setState(() {
        _clubEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load events: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 169,
                    decoration: BoxDecoration(
                      color: const Color(0xFF06222F),
                      image: DecorationImage(
                        image: NetworkImage(widget.club.logoUrl),
                        fit: BoxFit.cover,
                        opacity: 0.6,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 121,
                    left: 27,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF71C2E4),
                          width: 1,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(widget.club.logoUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 54, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.club.name,
                      style: const TextStyle(
                        color: Color(0xFF61E7FF),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Welcome to the Cybersecurity Club! We\'re a group of students passionate about hands-on activities, workshops, and discussions. Whether you\'re a beginner or experienced, our club is a great place to grow your skills, stay updated, and connect with others. Join us and be part of the community!',
                      style: TextStyle(
                        color: Color(0xFFAEE7FF),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildSocialButton('DISCORD', 40),
                        const SizedBox(width: 5),
                        _buildSocialButton('WHATSAPP COMMUNITY', 88),
                        const SizedBox(width: 5),
                        _buildSocialButton('LINKTREE', 40),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recent Highlights',
                      style: TextStyle(
                        color: Color(0xFFAEE7FF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildHighlightCard(
                            'CyberWeek 2025',
                            widget.club.logoUrl,
                            'assets/cyberweek.jpg',
                          ),
                          const SizedBox(width: 16),
                          _buildHighlightCard(
                            'CTF Challenge',
                            widget.club.logoUrl,
                            'assets/ctf.jpg',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTabButton('EVENTS', true),
                          _buildTabButton('LEADERBOARD', false),
                          _buildTabButton('ANNOUNCEMENTS', false),
                          _buildTabButton('RESOURCES', false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ..._clubEvents.map((event) => _buildEventCard(event)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String text, double width) {
    return Container(
      width: width,
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFF17323D),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightCard(
      String title, String logoUrl, String backgroundImage) {
    return Container(
      width: 215,
      height: 121,
      decoration: BoxDecoration(
        color: const Color(0xFF06222F),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 19.9,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              backgroundImage,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.66),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 19,
                      backgroundImage: NetworkImage(logoUrl),
                    ),
                  ],
                ),
                const Spacer(),
                const Row(
                  children: [
                    Text(
                      'View more',
                      style: TextStyle(
                        color: Color(0xFF83ACBD),
                        fontSize: 10,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF83ACBD),
                      size: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF17323D) : const Color(0xFF010507),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: const Color(0xFF71C2E4),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2026),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 5.1,
            offset: const Offset(0, 2),
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
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundImage: NetworkImage(widget.club.logoUrl),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF17323D),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - ${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
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
