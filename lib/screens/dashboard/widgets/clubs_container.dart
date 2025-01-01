// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClubsContainer extends StatefulWidget {
  const ClubsContainer({super.key});

  @override
  State<ClubsContainer> createState() => _ClubsContainerState();
}

class _ClubsContainerState extends State<ClubsContainer> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  final bool _firstTime = true;

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
            child: ClubIconsRow(),
          ),
          if (_canScrollLeft)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  _scrollController.animateTo(
                    _scrollController.offset - 100,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xffAEE7FF),
                ),
              ),
            ),
          if (_canScrollRight)
            Positioned(
              right: -6,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  _scrollController.animateTo(
                    _scrollController.offset + 100,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xffAEE7FF),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ClubIconsRow extends StatelessWidget {
  const ClubIconsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2C34),
                  padding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                onPressed: () {
                  // print("Button pressed");
                },
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.black),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(500),
                    child: Image.network(
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/37e7989965e171596ee40b7d5d043213ad09494587b6af294656a47ca2eb0988?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              const Points(points: 1000),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0x001a2c34),
                  padding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                onPressed: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(51),
                  child: Image.network(
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/603ab57aebffa443d017c5d9aa169930ecd8da6f3709d3596061a3968d42d2d6?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60',
                    width: 57,
                    height: 57,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Points(points: 2000),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2C34),
                  padding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                onPressed: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(51),
                  child: Image.network(
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/613a1aa021408fa85d9954915baceba0821ac2eb6af01df00f9d61c7229444fb?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60',
                    width: 58,
                    height: 58,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Points(points: 3000),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2C34),
                  padding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                onPressed: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(51),
                  child: Image.network(
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/5f950d41f1ad7f9496002217e671c81742ff4891e1aaa6eb1e4ac86095361a57?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60',
                    width: 57,
                    height: 57,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Points(points: 4000),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2C34),
                  padding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                ),
                onPressed: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(51),
                  child: Image.network(
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/945592a2b1f8c4ef834c67e9dfb9cf376d9a3e44b6528a40407ee509fc839ee2?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60',
                    width: 57,
                    height: 57,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Points(points: 5000),
            ],
          ),
        ],
      ),
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
