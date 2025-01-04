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
          var page = _pageController.page!.round();
          var currentAnnouncement = announcements[page % announcements.length];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailView(
                title: currentAnnouncement.title,
                subtitle: currentAnnouncement.subtitle,
                image: currentAnnouncement.image,
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
              image: announcement.image,
            );
          },
        ),
      ),
    );
  }
}
