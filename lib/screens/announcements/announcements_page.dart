import 'package:events_manager/data/clubs_data.dart';
import 'package:events_manager/providers/stream_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  String getClubImage(String clubId) {
    final club = sampleClubs.firstWhere(
      (club) => club.id == clubId,
      orElse: () => sampleClubs.first,
    );
    return club.logoUrl;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementsStreamProvider);

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
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  'Announcements',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAEE7FF),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: announcements.when(
                  data: (announcementsList) {
                    if (announcementsList.isEmpty) {
                      return const Center(
                        child: Text(
                          'No announcements yet',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 29),
                      itemCount: announcementsList.length,
                      itemBuilder: (context, index) {
                        final announcement = announcementsList[index];
                        return ExpandableAnnouncementCard(
                          announcement: announcement,
                          getClubImage: getClubImage,
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading announcements: $error',
                      style: const TextStyle(color: Colors.white),
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

class ExpandableAnnouncementCard extends StatefulWidget {
  final dynamic announcement;
  final Function(String) getClubImage;

  const ExpandableAnnouncementCard({
    super.key,
    required this.announcement,
    required this.getClubImage,
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF064756),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.28),
            blurRadius: 19.9,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.announcement.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFAEE7FF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.announcement.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      widget.announcement.description,
                      maxLines: isExpanded ? null : 3,
                      overflow: isExpanded ? null : TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  widget.announcement.image == null ? 51 : 10,
                ),
                child: Image.network(
                  widget.announcement.image ??
                      widget.getClubImage(widget.announcement.clubId),
                  width: widget.announcement.image == null ? 100 : 69,
                  height: widget.announcement.image == null ? 100 : 66,
                  fit: widget.announcement.image == null
                      ? BoxFit.contain
                      : BoxFit.cover,
                  semanticLabel: widget.announcement.image == null
                      ? 'Club Logo'
                      : 'Announcement Image',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF064756),
                  padding: EdgeInsets.all(5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      isExpanded ? 'See less' : 'See more',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF83ACBD),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: Color(0xFF83ACBD),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
