import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          decoration: BoxDecoration(
            color: const Color(0xFF06151C),
            borderRadius: BorderRadius.circular(30),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: const [
                EventItem(
                  title: 'Hack the Box: Cyber Challenge',
                  description:
                      'Join us for an action-packed Hack the Box Challenge! Solve puzzles, crack codes, and compete to top the leaderboard. Open to all skill...',
                  time: '4:30 PM - 5:30 PM',
                  imageUrl:
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/a70aa1deb5a0c0e7e806875063dfa1e13dc07225ea5d3942037ad18f7437f9a2?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60',
                ),
                SizedBox(height: 12),
                EventItem(
                  title: 'Code Smart: Problem-Solving 101',
                  description:
                      'Level up your coding game and dive into the fundamentals of algorithms, data structures, and problem-solving techniques.',
                  time: '5:30 PM - 6:30 PM',
                  imageUrl:
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/5f950d41f1ad7f9496002217e671c81742ff4891e1aaa6eb1e4ac86095361a57?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EventItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final String imageUrl;

  const EventItem({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 26, 9),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2027),
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, 2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 12,
              fontWeight: FontWeight.w200,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(51),
                child: Image.network(
                  imageUrl,
                  width: 35,
                  height: 35,
                  fit: BoxFit.contain,
                  semanticLabel: 'Club Logo',
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF17323D),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
