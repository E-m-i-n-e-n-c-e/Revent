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
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          final actualIndex =
              index % 4; // Assuming there are 4 announcement cards
          switch (actualIndex) {
            case 0:
              return const AnnouncementCard(
                title: "CyberArc's",
                subtitle: "CTF Challenge",
                image:
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/a70aa1deb5a0c0e7e806875063dfa1e13dc07225ea5d3942037ad18f7437f9a2?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60',
              );
            case 1:
              return const AnnouncementCard(
                title: "TechFest",
                subtitle: "Coding Marathon",
                image:
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/5f950d41f1ad7f9496002217e671c81742ff4891e1aaa6eb1e4ac86095361a57?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60',
              );
            case 2:
              return const AnnouncementCard(
                title: "WildBeats",
                subtitle: "Music Festival",
                image:
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/37e7989965e171596ee40b7d5d043213ad09494587b6af294656a47ca2eb0988?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60',
              );
            case 3:
              return const AnnouncementCard(
                title: "GDGC",
                subtitle: "Flutter Workshop",
                image:
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/613a1aa021408fa85d9954915baceba0821ac2eb6af01df00f9d61c7229444fb?placeholderIfAbsent=true&apiKey=e0155e6c2dfe4f2bb7942c2b033a9a60',
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
