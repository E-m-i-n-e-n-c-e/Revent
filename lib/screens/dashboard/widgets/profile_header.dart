import 'package:events_manager/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileHeader extends StatefulWidget {
  final String userMail;
  final String date;
  final String profileImage;

  const ProfileHeader({
    super.key,
    required this.userMail,
    required this.date,
    required this.profileImage,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  Widget build(BuildContext context) {
    // Fetch the current user dynamically
    final User? user = FirebaseAuth.instance.currentUser;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            // Navigate to the profile screen and pass the user object
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(user: user),
              ),
            );
          },
          child: CircleAvatar(
            radius: 23,
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : const AssetImage('assets/default_avatar.png')
                    as ImageProvider,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              extractRollNumber(widget.userMail),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              widget.date,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(0),
          ),
          onPressed: () {
            // print("Notification pressed");
          },
          icon: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Color(0xFF06222F),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black),
            ),
            child: Center(
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 32,
                color: Color(0xffAEE7FF),
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }
}

String extractRollNumber(String email) {
  {
    final String userMail = email.split('@')[0];
    final RegExp regExp = RegExp(r'(\d+)([a-zA-Z]+)(\d+)');
    final match = regExp.firstMatch(userMail);

    if (match != null) {
      final String year = match.group(1)!;
      final String branch = match.group(2)!.toUpperCase();
      final String number = match.group(3)!.padLeft(4, '0');
      return '20$year$branch$number';
    }

    return "Unknown";
  }
}
