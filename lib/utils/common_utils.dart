import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/providers/stream_providers.dart';

/// Launches a URL in the external browser
/// Handles URLs without schemes by adding https:// prefix
Future<void> launchUrlExternal(String url) async {
  // Ensure URL has a scheme
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }

  final Uri uri = Uri.parse(url);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('Could not launch $url: $e');
  }
}

// Cache for club logos to avoid repeated lookups
final Map<String, String> _clubLogoCache = {};
// Cache for club names to avoid repeated lookups
final Map<String, String> _clubNameCache = {};
// Reverse lookup cache for user's admin clubs (user email -> list of clubs)
final Map<String, List<Club>> _userAdminClubsCache = {};

/// Gets a club's logo URL from the clubs provider
/// Uses the WidgetRef to access the clubs provider
String getClubLogo(WidgetRef ref, String clubId) {
  // Check if we already have this club logo in cache
  if (_clubLogoCache.containsKey(clubId)) {
    return _clubLogoCache[clubId]!;
  }

  // Use a placeholder while loading
  const placeholderImage = 'https://via.placeholder.com/100';

  final clubs = ref.read(clubsStreamProvider).value;
  if (clubs == null || clubs.isEmpty) {
    return placeholderImage;
  }

  try {
    final club = clubs.firstWhere(
      (club) => club.id == clubId,
      orElse: () => Club(
        id: '',
        name: '',
        logoUrl: placeholderImage,
        backgroundImageUrl: '',
      ),
    );

    // Cache the result for future use
    _clubLogoCache[clubId] = club.logoUrl;
    return club.logoUrl;
  } catch (e) {
    debugPrint('Error getting club logo: $e');
    return placeholderImage;
  }
}

/// Gets a club's name from the clubs provider
String getClubName(WidgetRef ref, String clubId) {
  // Check if we already have this club name in cache
  if (_clubNameCache.containsKey(clubId)) {
    return _clubNameCache[clubId]!;
  }

  final clubs = ref.read(clubsStreamProvider).value;
  if (clubs == null || clubs.isEmpty) {
    return "Loading...";
  }

  try {
    final club = clubs.firstWhere(
      (club) => club.id == clubId,
      orElse: () => Club(id: '', name: 'Unknown Club', logoUrl: '', backgroundImageUrl: ''),
    );

    // Cache the result for future use
    _clubNameCache[clubId] = club.name;
    return club.name;
  } catch (e) {
    debugPrint('Error getting club name: $e');
    return "Unknown Club";
  }
}


/// Gets a list of clubs where the user is an admin
/// Uses the WidgetRef to access the clubs provider
List<Club> getAdminClubs(WidgetRef ref, String userEmail) {
  // Check if we already have this user's admin clubs in cache
  if (_userAdminClubsCache.containsKey(userEmail)) {
    return _userAdminClubsCache[userEmail]!;
  }

  final clubs = ref.read(clubsStreamProvider).value;
  if (clubs == null || clubs.isEmpty) {
    return [];
  }

  try {
    final adminClubs = clubs.where(
      (club) => club.adminEmails.contains(userEmail)
    ).toList();

    // Cache the results in both directions for future use
    _userAdminClubsCache[userEmail] = adminClubs;


    return adminClubs;
  } catch (e) {
    debugPrint('Error getting admin clubs: $e');
    return [];
  }
}

Widget buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    String dateText;
    if (date == today) {
      dateText = 'Today';
    } else if (date == tomorrow) {
      dateText = 'Tomorrow';
    } else {
      dateText = DateFormat('EEEE, MMMM d').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          Text(
            dateText,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Divider(
              color: Colors.white.withValues(alpha: 0.1),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }