import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        color: const Color(0xFF04161D),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              icon: Icons.home,
              index: 0,
            ),
            _buildNavItem(
              icon: Icons.calendar_month_outlined,
              index: 1,
            ),
            _buildNavItem(
              icon: Icons.search,
              index: 2,
            ),
            _buildNavItem(
              icon: Icons.auto_stories,
              index: 3,
            ),
            _buildNavItem(
              icon: Icons.chat,
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    bool isSelected = _selectedIndex == index;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.all(0),
      ),
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xff71C2E4),
            size: 26,
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            width: isSelected ? 20 : 0,
            color: isSelected ? const Color(0xff71C2E4) : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
