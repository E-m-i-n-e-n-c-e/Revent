import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/screens/clubs/club_page.dart';

class ClubsContainer extends StatefulWidget {
  const ClubsContainer({super.key, required this.clubs});

  final List<Club> clubs;

  @override
  State<ClubsContainer> createState() => _ClubsContainerState();
}

class _ClubsContainerState extends State<ClubsContainer> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  bool _firstTime = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollArrows);
  }

  void _updateScrollArrows() {
    setState(() {
      _canScrollLeft = _scrollController.offset > 0;
      _canScrollRight =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_firstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScrollArrows();
      });
      _firstTime = false;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF06222F),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.clubs
                  .map(
                    (club) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ClubIcon(club: club),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (_canScrollLeft)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildScrollButton(true),
            ),
          if (_canScrollRight)
            Positioned(
              right: -6,
              top: 0,
              bottom: 0,
              child: _buildScrollButton(false),
            ),
        ],
      ),
    );
  }

  Widget _buildScrollButton(bool isLeft) {
    return GestureDetector(
      onTap: () {
        _scrollController.animateTo(
          _scrollController.offset + (isLeft ? -100 : 100),
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      },
      child: Icon(
        isLeft ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
        color: const Color(0xffAEE7FF),
      ),
    );
  }
}

class ClubIcon extends StatelessWidget {
  final Club club;

  const ClubIcon({
    super.key,
    required this.club,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A2C34),
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProviderScope(
                  child: ClubPage(club: club),
                ),
              ),
            );
          },
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(500),
              child: Image.network(
                club.logoUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

