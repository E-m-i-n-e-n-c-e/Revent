import 'package:events_manager/providers/stream_providers.dart';
import 'package:events_manager/screens/announcements/announcements_page.dart';
import 'package:events_manager/screens/dashboard/widgets/add_announcement_form.dart';
import 'package:events_manager/screens/dashboard/widgets/announcement_card.dart';
import 'package:events_manager/screens/dashboard/widgets/announcements_slider.dart';
import 'package:events_manager/utils/firedata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'widgets/event_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/clubs_container.dart';
import 'package:events_manager/models/announcement.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    super.key,
    required this.user,
  });

  final User user;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final PageController _pageController = PageController();

  Future<void> _addAnnouncement(Announcement newAnnouncement) async {
    try {
      await addAnnouncement(newAnnouncement);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add announcement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(todaysEventsStreamProvider);
    final announcements = ref.watch(announcementsStreamProvider);
    final clubs = ref.watch(clubsStreamProvider);
    bool isLoading = announcements.isLoading || events.isLoading || clubs.isLoading;
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF07181F),
                      Color(0xFF000000),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(child: CircularProgressIndicator()))
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF07181F),
                      Color(0xFF000000),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(15, 3, 15, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileHeader(
                      userMail: widget.user.email ?? '',
                      date:
                          'Today ${DateFormat('MMM d').format(DateTime.now())}',
                      profileImage: widget.user.photoURL ?? '',
                    ),
                    const SizedBox(height: 26),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Row(
                        children: [
                          Text(
                            'Announcements',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                ),
                          ),
                          const SizedBox(width: 5),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProviderScope(
                                      child: const AnnouncementsPage()),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  'See all',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: const Color(0xFF83ACBD),
                                        fontSize: 10,
                                      ),
                                ),
                                const SizedBox(width: 0.5),
                                const Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Color(0xFF83ACBD),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.all(0),
                            ),
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddAnnouncementForm(
                                    addAnnouncement: _addAnnouncement,
                                  ),
                                ),
                              );
                            },
                            icon: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    announcements.when(
                      data: (announcementsList) {
                        if (announcementsList.isEmpty) {
                          return SizedBox(
                            height: 200,
                            child: AnnouncementCard(
                              title: 'You have no announcements',
                              subtitle: 'You have no announcements',
                              image:
                                  'https://i.pinimg.com/originals/c0/88/7d/c0887d39121ff3649f04e249942b8fec.jpg',
                            ),
                          );
                        }
                        return Column(
                          children: [
                            AnnouncementsSlider(
                              pageController: _pageController,
                              announcements: announcementsList,
                            ),
                            const SizedBox(height: 10),
                            SmoothPageIndicator(
                              controller: _pageController,
                              count: announcementsList.length,
                              effect: WormEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                activeDotColor:
                                    Theme.of(context).colorScheme.primary,
                                spacing: 6,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (error, stack) => Center(
                        child: Text('Error loading announcements: $error'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 14),
                        Text(
                          'Your Clubs',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    clubs.when(
                      data: (clubsList) => ClubsContainer(clubs: clubsList),
                      loading: () => const SizedBox(),
                      error: (error, stack) => Center(
                        child: Text('Error loading clubs: $error'),
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 14),
                        Text(
                          "Today's Events",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    events.when(
                      data: (eventsList) => EventCard(events: eventsList),
                      loading: () => const SizedBox(),
                      error: (error, stack) => Center(
                        child: Text('Error loading events: $error'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
