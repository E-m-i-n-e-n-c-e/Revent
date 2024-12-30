import 'package:events_manager/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileHeader extends StatefulWidget {
  final String userName;
  final String date;
  final String profileImage;
  final String notificationImage;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.date,
    required this.profileImage,
    required this.notificationImage,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                : const AssetImage('assets/default_avatar.png') as ImageProvider,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello ${widget.userName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              widget.date,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Image.network(
              widget.notificationImage,
              width: 32,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
