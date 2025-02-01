import 'package:flutter/material.dart';
import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/screens/dashboard/widgets/announcement_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:events_manager/screens/events/event_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:events_manager/providers/stream_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: const Color(0xFF06222F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) =>
                      ref.read(searchQueryProvider.notifier).state = value,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Color(0xFF83ACBD)),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF83ACBD)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF06222F),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Events'),
                      _buildFilterChip('Announcements'),
                      _buildFilterChip('Clubs'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
                        return _buildSearchResultCard(result);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final selectedFilter = ref.watch(searchFilterProvider);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: selectedFilter == label ? Colors.black : Colors.white,
          ),
        ),
        selected: selectedFilter == label,
        onSelected: (bool selected) {
          ref.read(searchFilterProvider.notifier).state = label;
        },
        backgroundColor: const Color(0xFF06222F),
        selectedColor: const Color(0xFF83ACBD),
      ),
    );
  }

  Widget _buildSearchResultCard(dynamic result) {
    if (result is Event) {
      return _buildEventCard(result);
    } else if (result is Announcement) {
      return _buildAnnouncementCard(result);
    } else if (result is Club) {
      return _buildClubCard(result);
    }
    return const SizedBox.shrink();
  }

  Widget _buildEventCard(Event event) {
    final clubs = ref.watch(clubsStreamProvider).value ?? [];
    final clubLogo = clubs
        .firstWhere((club) => club.id == event.clubId,
            orElse: () => Club(id: '', name: '', logoUrl: '', points: 0))
        .logoUrl;

    return Card(
      color: const Color(0xFF06222F),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(clubLogo),
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          event.title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.description,
              style: const TextStyle(color: Color(0xFF83ACBD)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF17323D),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                formatTimeRange(context, event.startTime, event.endTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnnouncementDetailView(
              title: announcement.title,
              subtitle: announcement.subtitle,
              description: announcement.description,
              venue: announcement.venue,
              time: announcement.time,
              image: announcement.image,
              clubId: announcement.clubId,
            ),
          ),
        );
      },
      child: Card(
        color: const Color(0xFF06222F),
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const FaIcon(
            FontAwesomeIcons.bullhorn,
            color: Color(0xFF83ACBD),
          ),
          title: Text(
            announcement.title,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            announcement.subtitle,
            style: const TextStyle(color: Color(0xFF83ACBD)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildClubCard(Club club) {
    return Card(
      color: const Color(0xFF06222F),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(club.logoUrl),
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          club.name,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              club.points.toString(),
              style: const TextStyle(color: Colors.amber),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
