import 'package:events_manager/screens/dashboard/widgets/announcement_card.dart';
import 'package:flutter/material.dart';

class AnnouncementsSlider extends StatelessWidget {
  const AnnouncementsSlider({
    super.key,
    required PageController pageController,
  }) : _pageController = pageController;

  final PageController _pageController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Adjust height as needed
      child: GestureDetector(
        onDoubleTap: () {
          var details = getAnnouncementDetails(_pageController.page!.round());
          // Navigate to the detailed view on double-tap
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailView(
                title: details['title'],
                subtitle: details['subtitle'],
                image: details['image'],
              ),
            ),
          );
        },
        child: PageView.builder(
          controller: _pageController,
          itemBuilder: (context, index) {
            final actualIndex =
                index % 5; // Assuming there are 4 announcement cards
            final details = getAnnouncementDetails(actualIndex);
            return AnnouncementCard(
              title: details['title'],
              subtitle: details['subtitle'],
              image: details['image'],
            );
          },
        ),
      ),
    );
  }
}

Map<String, dynamic> getAnnouncementDetails(index) {
  final actualIndex = index % 5; // Assuming there are 4 announcement cards
  switch (actualIndex) {
    case 0:
      return {
        'title': "BetaLabs Mini Project🚀",
        'subtitle': "🤖 Dive into the Future with BETALABS Mini-Projects! 🔬  ",
        'image':
            'https://cdn.builder.io/api/v1/image/assets/TEMP/fed9b3a788b46dd354fea88c29041d4a84d5f62787d73436fe30f66d8d127d5f?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60'
      };
    case 1:
      return {
        'title': "CyberArc's CTF Challenge",
        'subtitle': "CTF Challenge",
        'image':
            'https://cdn.builder.io/api/v1/image/assets/TEMP/a70aa1deb5a0c0e7e806875063dfa1e13dc07225ea5d3942037ad18f7437f9a2?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60'
      };
    case 2:
      return {
        'title': "Coder's Club Coding Marathon",
        'subtitle': "Coding Marathon",
        'image':
            'https://cdn.builder.io/api/v1/image/assets/TEMP/5f950d41f1ad7f9496002217e671c81742ff4891e1aaa6eb1e4ac86095361a57?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60'
      };
    case 3:
      return {
        'title': "WildBeats Music Festival",
        'subtitle': "Music Festival",
        'image':
            'https://cdn.builder.io/api/v1/image/assets/TEMP/37e7989965e171596ee40b7d5d043213ad09494587b6af294656a47ca2eb0988?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60'
      };
    case 4:
      return {
        'title': "GDGC Flutter Workshop",
        'subtitle': "Flutter Workshop",
        'image':
            'https://cdn.builder.io/api/v1/image/assets/TEMP/613a1aa021408fa85d9954915baceba0821ac2eb6af01df00f9d61c7229444fb?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60'
      };
    default:
      return {};
  }
}
