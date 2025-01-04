// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/data/clubs_data.dart';

class ClubsContainer extends StatefulWidget {
  const ClubsContainer({super.key});

  @override
  State<ClubsContainer> createState() => _ClubsContainerState();
}

class _ClubsContainerState extends State<ClubsContainer> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  bool _firstTime = true;
  List<Club> _clubs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollArrows);
    _loadClubs();
  }

  void _loadClubs() {
    setState(() {
      _isLoading = true;
    });

    // Load from local data
    _clubs = sampleClubs;

    setState(() {
      _isLoading = false;
    });
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
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _clubs
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
            // Handle club selection
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
        Points(points: club.points),
      ],
    );
  }
}

class Points extends StatelessWidget {
  const Points({
    super.key,
    required this.points,
  });

  final int points;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      color: Color(0xff06151C),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.crown,
            color: Color(0xffFFD700),
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(points.toString(),
              style: const TextStyle(
                color: Color(0xffFFD700),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
