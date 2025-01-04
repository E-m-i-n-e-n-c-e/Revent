import 'package:events_manager/data/clubs_data.dart';
import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/screens/dashboard/widgets/announcement_card.dart';
import 'package:flutter/material.dart';

class AnnouncementsSlider extends StatelessWidget {
  const AnnouncementsSlider({
    super.key,
    required PageController pageController,
    required this.announcements,
  }) : _pageController = pageController;

  final PageController _pageController;
  final List<Announcement> announcements;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GestureDetector(
        onDoubleTap: () {
          if (announcements.isEmpty) return;
          var currentAnnouncement = announcements[
              _pageController.page!.round() % announcements.length];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailView(
                title: currentAnnouncement.title,
                subtitle: currentAnnouncement.subtitle,
                image: currentAnnouncement.image,
                description: currentAnnouncement.description,
                venue: currentAnnouncement.venue,
                time: currentAnnouncement.time,
                clubId: currentAnnouncement.clubId,
              ),
            ),
          );
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: null, // Infinite scrolling
          itemBuilder: (context, index) {
            final announcement = announcements[index % announcements.length];
            return AnnouncementCard(
              title: announcement.title,
              subtitle: announcement.subtitle,
              image: getClubImage(announcement.clubId),
            );
          },
        ),
      ),
    );
  }
}

String getClubImage(String clubId) {
  final club = sampleClubs.firstWhere(
    (club) => club.id == clubId,
    orElse: () => sampleClubs.first,
  );
  return club.logoUrl;
}
