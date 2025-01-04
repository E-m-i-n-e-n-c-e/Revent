import 'package:events_manager/data/clubs_data.dart';
import 'package:flutter/material.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF06222F),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.28),
            blurRadius: 20,
            offset: Offset(0, 0),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate a dynamic font size based on the available width
                    double fontSize = constraints.maxWidth * 3 / title.length;
                    // Adjust the factor as needed
                    fontSize = fontSize.clamp(18, 28);
                    // Ensure the font size is not too small or too large
                    // Minimum font size 18, maximum 30

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(51),
                child: Image.network(
                  image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  semanticLabel: 'Club Logo',
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'View more',
                style: TextStyle(
                  color: Color(0xFF83ACBD),
                  fontSize: 11.5,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF83ACBD),
                size: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnnouncementDetailView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String venue;
  final String time;
  final String? image;
  final String clubId;

  const AnnouncementDetailView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.venue,
    required this.time,
    required this.image,
    required this.clubId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
        backgroundColor: const Color(0xFF06222F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff83ACBD)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null && Uri.parse(image!).isAbsolute)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Image.network(
                  image!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(getClubImage(clubId)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFAEE7FF),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFAEE7FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(Icons.access_time, time),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on, venue),
                  const SizedBox(height: 24),
                  const Text(
                    'About',
                    style: TextStyle(
                      color: Color(0xFFAEE7FF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFFAEE7FF),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF83ACBD),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

String getClubImage(String clubId) {
  final club = sampleClubs.firstWhere(
    (club) => club.id == clubId,
    orElse: () => sampleClubs.first,
  );
  return club.logoUrl;
}
