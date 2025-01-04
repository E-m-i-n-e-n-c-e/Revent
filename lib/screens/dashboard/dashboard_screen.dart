import 'package:events_manager/screens/dashboard/widgets/add_announcement_form.dart';
import 'package:events_manager/screens/dashboard/widgets/announcements_slider.dart';
import 'package:events_manager/screens/dashboard/widgets/bottom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'widgets/event_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/clubs_container.dart';
import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/data/announcements_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.user});

  final User user;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();
  List<Announcement> _announcements = [];
  bool _isLoading = true;
  int _announcementCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    setState(() {
      _isLoading = true;
    });

    // Load from local data
    _announcements = sampleAnnouncements;
    _announcementCount = _announcements.length;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _loadAnnouncements();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNavigationBar(),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF07181F),
                Color(0xFF000000),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          // constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.fromLTRB(15, 3, 15, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileHeader(
                userMail: widget.user.email ?? '',
                date: 'Today ${DateFormat('MMM d').format(DateTime.now())}',
                profileImage:
                    widget.user.photoURL ?? '', // Replace with your image asset
              ),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Row(
                  children: [
                    Text(
                      'Announcements',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                        //  Navigate to announcements page
                      },
                      child: Row(
                        children: [
                          Text(
                            'See more',
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
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF83ACBD),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        navigateToAddAnnouncement(context);
                      },
                      icon: Container(
                        margin: const EdgeInsets.only(right: 14),
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
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AnnouncementsSlider(
                      pageController: _pageController,
                      announcements: _announcements,
                    ),
              const SizedBox(height: 10),
              SmoothPageIndicator(
                controller: _pageController,
                count: _announcementCount,
                effect: WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  spacing: 6,
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
              const ClubsContainer(),
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
              const EventCard(),
              // const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> navigateToAddAnnouncement(BuildContext context) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AddAnnouncementForm(),
    ),
  );
}
