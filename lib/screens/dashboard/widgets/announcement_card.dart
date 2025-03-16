import 'package:flutter/material.dart';
import 'package:events_manager/screens/dashboard/widgets/edit_announcement_form.dart';
import 'package:events_manager/utils/markdown_renderer.dart';
import 'package:events_manager/utils/common_utils.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String image;

  const AnnouncementCard({
    super.key,
    required this.title,
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
                child: getCachedNetworkImage(
                  imageUrl: image,
                  imageType: ImageType.club,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'View more',
                style: TextStyle(
                  color: Color(0xFF83ACBD),
                  fontSize: 11.5,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(width: 4),
              Icon(
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
  final String description;
  final String clubId;
  final int? index; // Add index parameter to identify which announcement to update
  final DateTime date;

  const AnnouncementDetailView({
    super.key,
    required this.title,
    required this.description,
    required this.clubId,
    this.index, // Optional parameter for the index
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06222F),
      appBar: AppBar(
        title: const Text('Announcement'),
        backgroundColor: const Color(0xFF06222F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff83ACBD)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Only show edit button if we have an index (meaning we can edit this announcement)
          if (index != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xff83ACBD)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAnnouncementForm(
                      title: title,
                      description: description,
                      clubId: clubId,
                      index: index!,
                      date: date,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: const Color(0xFF0F2026),
                child: _buildDetailView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        color: const Color(0xFF0F2026),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFAEE7FF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Divider
            const Divider(
              color: Color(0xFF17323D),
              thickness: 1,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),

            // Markdown content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MarkdownRenderer(data: description),
            ),
          ],
        ),
      ),
    );
  }
}


