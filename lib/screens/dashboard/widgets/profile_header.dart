import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 23,
          backgroundImage: NetworkImage(profileImage),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello $userName',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              date,
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
              notificationImage,
              width: 32,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
