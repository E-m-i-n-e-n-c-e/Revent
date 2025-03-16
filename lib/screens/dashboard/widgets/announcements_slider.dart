import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/screens/dashboard/widgets/announcement_card.dart';
import 'package:events_manager/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnnouncementsSlider extends ConsumerWidget {
  const AnnouncementsSlider({
    super.key,
    required PageController pageController,
    required this.announcements,
  }) : _pageController = pageController;

  final PageController _pageController;
  final List<Announcement> announcements;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 200,
      child: GestureDetector(
        onTap: () {
          if (announcements.isEmpty) return;
          final currentIndex = _pageController.page!.round() % announcements.length;
          var currentAnnouncement = announcements[currentIndex];
          final clubAnnouncementList = announcements.where((announcement) => announcement.clubId == currentAnnouncement.clubId).toList();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailView(
                title: currentAnnouncement.title,
                description: currentAnnouncement.description,
                clubId: currentAnnouncement.clubId,
                index: clubAnnouncementList.indexOf(currentAnnouncement),
                date: currentAnnouncement.date,
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
              image: getClubLogo(ref, announcement.clubId),
            );
          },
        ),
      ),
    );
  }
}
