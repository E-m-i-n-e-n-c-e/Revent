import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return GestureDetector(
      onDoubleTap: () {
        // Navigate to the detailed view on double-tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnnouncementDetailView(
              title: title,
              subtitle: subtitle,
              image: image,
            ),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }
}

class AnnouncementDetailView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const AnnouncementDetailView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
        backgroundColor: const Color(0xFF06222F),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0Rl83Th9FU_rZnf4eeMP%2F6a4d38414580959635e787efd8249e496022d3c0image.png?alt=media&token=f435da32-88e8-419f-8d9a-ccfebabcefa8',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xCC051116)],
                    stops: [0, 0.68],
                  ),
                ),
                child: Center(
                  child: Text(
                    'BetaLabs Mini Project🚀',
                    style: GoogleFonts.getFont(
                      'DM Sans',
                      color: const Color(0xFFAEE7FF),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
