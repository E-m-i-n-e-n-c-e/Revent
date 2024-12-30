import 'package:events_manager/screens/dashboard/widgets/bottom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'widgets/announcement_card.dart';
import 'widgets/event_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/clubs_container.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.user});

  final User user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 15, 32, 39),
              Color.fromARGB(255, 32, 58, 67),
              Color.fromARGB(255, 44, 83, 100),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.fromLTRB(15, 12, 15, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ProfileHeader(
              userName: user.displayName ?? '',
              date: 'Today ${DateFormat('MMM d').format(DateTime.now())}',
              profileImage:
                  user.photoURL ?? '', // Replace with your image asset
              notificationImage:
                  "https://cdn.builder.io/api/v1/image/assets/TEMP/8c631dc645f470c140a9d1f5ef8fac2e9be09eb7f806a3637526fcf6b422e88b?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60",
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
            const AnnouncementCard(
              title: "CyberArc's",
              subtitle: "CTF Challenge",
              image:
                  "https://cdn.builder.io/api/v1/image/assets/TEMP/a9276fd5715a6133eea9ffdae9790377354c81105b89c22fe2bb57eb12856cca?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60",
            ),
            const SizedBox(height: 10),
            const ClubsContainer(
                image:
                    "https://cdn.builder.io/api/v1/image/assets/TEMP/71d91538e0c2b90a730df492efa0b352c0694ab4c6758e8bb710e0faf16c900b?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60"),
            const SizedBox(height: 25),
            Row(
              children: [
                const SizedBox(width: 14),
                Text(
                  "Today's Events",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            const EventCard(title: "XYZ"),
            const SizedBox(height: 19),
            CustomBottomNavigationBar(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
