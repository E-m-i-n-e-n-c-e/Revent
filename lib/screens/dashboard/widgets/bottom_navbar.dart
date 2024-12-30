import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 357),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B1919),
          borderRadius: BorderRadius.circular(35),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 31, vertical: 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              color: Colors.white,
              iconSize: 43,
              onPressed: () {
                // Handle navigation to home
              },
            ),
            IconButton(
              icon: const Icon(Icons.home),
              color: Colors.white,
              iconSize: 43,
              onPressed: () {
                // Handle navigation to search
              },
            ),
            IconButton(
              icon: const Icon(Icons.auto_stories),
              color: Colors.white,
              iconSize: 43,
              onPressed: () {
                // Handle navigation to notifications
              },
            ),
            IconButton(
              icon: const Icon(Icons.chat),
              color: Colors.white,
              iconSize: 43,
              onPressed: () {
                // Handle navigation to profile
              },
            ),
          ],
        ),
      ),
    );
  }
}
