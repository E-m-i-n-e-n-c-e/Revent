import 'package:events_manager/screens/dashboard/widgets/announcements_slider.dart';
import 'package:events_manager/screens/dashboard/widgets/bottom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'widgets/event_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/clubs_container.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.user});

  final User user;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
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
                  ],
                ),
              ),
              const SizedBox(height: 5),
              AnnouncementsSlider(pageController: _pageController),
              const SizedBox(height: 10),
              SmoothPageIndicator(
                controller: _pageController,
                count: 4, // Update based on the number of pages
                effect: WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  spacing: 6, // Default spacing between dots
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
