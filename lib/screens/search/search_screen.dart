import 'package:flutter/material.dart';
import 'package:events_manager/data/announcements_data.dart';
import 'package:events_manager/data/events_data.dart';
import 'package:events_manager/data/clubs_data.dart';
import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/screens/dashboard/widgets/announcement_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  String _selectedFilter = 'All';

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    List<dynamic> results = [];
    query = query.toLowerCase();

    // Filter based on selected category
    if (_selectedFilter == 'All' || _selectedFilter == 'Events') {
      results.addAll(sampleEvents.where((event) =>
          event.title.toLowerCase().contains(query) ||
          event.description.toLowerCase().contains(query) ||
          event.time.toLowerCase().contains(query) ||
          event.clubId.toLowerCase().contains(query)));
    }

    if (_selectedFilter == 'All' || _selectedFilter == 'Announcements') {
      results.addAll(sampleAnnouncements.where((announcement) =>
          announcement.title.toLowerCase().contains(query) ||
          announcement.subtitle.toLowerCase().contains(query) ||
          announcement.description.toLowerCase().contains(query) ||
          announcement.venue.toLowerCase().contains(query) ||
          announcement.time.toLowerCase().contains(query) ||
          announcement.clubId.toLowerCase().contains(query)));
    }

    if (_selectedFilter == 'All' || _selectedFilter == 'Clubs') {
      results.addAll(sampleClubs.where((club) =>
          club.name.toLowerCase().contains(query) ||
          club.id.toLowerCase().contains(query)));
    }

    setState(() => _searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: const Color(0xFF06222F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar with filter chips
            Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _performSearch,
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
            // Search results
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
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
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: _selectedFilter == label ? Colors.black : Colors.white,
          ),
        ),
        selected: _selectedFilter == label,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = label;
            _performSearch(_searchController.text);
          });
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
    return Card(
      color: const Color(0xFF06222F),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.event, color: Color(0xFF83ACBD)),
        title: Text(
          event.title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          event.description,
          style: const TextStyle(color: Color(0xFF83ACBD)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
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
