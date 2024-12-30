import 'package:events_manager/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  final User? user;

  const ProfileScreen({super.key, required this.user});
  String extractRollNumber(String email) {
    {
      final String username = email.split('@')[0];
      final RegExp regExp = RegExp(r'(\d+)([a-zA-Z]+)(\d+)');
      final match = regExp.firstMatch(username);

      if (match != null) {
        final String year = match.group(1)!;
        final String branch = match.group(2)!.toUpperCase();
        final String number = match.group(3)!.padLeft(3, '0');
        return '20$year$branch$number';
      }

      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final rollNumber =
        user?.email != null ? extractRollNumber(user!.email!) : "Unknown";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: user?.photoURL != null
                    ? CircleAvatar(
                        radius: 48,
                        backgroundImage: NetworkImage(user!.photoURL!),
                      )
                    : const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                'Name: ${user?.displayName ?? "Unknown"}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Roll Number: $rollNumber',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Email: ${user?.email ?? "Unknown"}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  // Perform logout
                  await AuthService().signOut();
                  if (!context.mounted) return;
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
