import 'package:flutter/material.dart';

class ClubsContainer extends StatelessWidget {
  final String image;

  const ClubsContainer({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFC5C5C5),
          borderRadius: BorderRadius.circular(35),
        ),
        child: ClubIconsRow());
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC5C5C5),
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
            ),
            onPressed: () {
              // print("Button pressed");
            },
            child: Container(
              width: 58,
              height: 58,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.black),
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
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC5C5C5),
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
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
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC5C5C5),
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
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
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC5C5C5),
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
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
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC5C5C5),
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
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
        ],
      ),
    );
  }
}
