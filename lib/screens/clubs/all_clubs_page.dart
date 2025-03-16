import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/providers/stream_providers.dart';
import 'package:events_manager/screens/clubs/club_page.dart';
import 'package:events_manager/utils/common_utils.dart';

class AllClubsPage extends ConsumerStatefulWidget {
  const AllClubsPage({super.key});

  @override
  ConsumerState<AllClubsPage> createState() => _AllClubsPageState();
}

class _AllClubsPageState extends ConsumerState<AllClubsPage> {
  final String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = 'Name A-Z';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Club> _sortClubs(List<Club> clubs) {
    switch (_sortOption) {
      case 'Name A-Z':
        return clubs..sort((a, b) => a.name.compareTo(b.name));
      case 'Name Z-A':
        return clubs..sort((a, b) => b.name.compareTo(a.name));
      default:
        return clubs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clubs = ref.watch(clubsStreamProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFAEE7FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Clubs',
          style: TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort, color: Color(0xFFAEE7FF)),
                const SizedBox(width: 4),
                Text(
                  _sortOption,
                  style: const TextStyle(
                    color: Color(0xFFAEE7FF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Name A-Z',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 18, color: Color(0xFFAEE7FF)),
                    SizedBox(width: 8),
                    Text('Name A-Z', style: TextStyle(color: Color(0xFFAEE7FF))),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Name Z-A',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 18, color: Color(0xFFAEE7FF)),
                    SizedBox(width: 8),
                    Text('Name Z-A', style: TextStyle(color: Color(0xFFAEE7FF))),
                  ],
                ),
              ),
            ],
            color: const Color(0xFF0F2026),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF17323D)),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF07181F), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height:15),
              Expanded(
                child: clubs.when(
                  data: (clubsList) {
                    // Filter clubs based on search query
                    final filteredClubs = _searchQuery.isEmpty
                        ? clubsList
                        : clubsList
                            .where((club) =>
                                club.name.toLowerCase().contains(_searchQuery))
                            .toList();

                    // Sort the filtered clubs
                    final sortedClubs = _sortClubs(filteredClubs);

                    if (sortedClubs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              color: Color(0xFF83ACBD),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No clubs found',
                              style: TextStyle(
                                color: Color(0xFFAEE7FF),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'There are no clubs available'
                                  : 'Try a different search term',
                              style: const TextStyle(
                                color: Color(0xFF83ACBD),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: sortedClubs.length,
                            itemBuilder: (context, index) {
                              final club = sortedClubs[index];
                              return ClubCard(club: club);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAEE7FF)),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading clubs: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClubCard extends StatelessWidget {
  final Club club;

  const ClubCard({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderScope(
                child: ClubPage(club: club),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF0F2026),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Club background image with gradient overlay
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: getCachedNetworkImageProvider(
                      imageUrl: club.backgroundImageUrl.isNotEmpty
                          ? club.backgroundImageUrl
                          : club.logoUrl,
                      imageType: ImageType.club,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF07181F).withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // Club logo
              Transform.translate(
                offset: const Offset(0, -30),
                child: Hero(
                  tag: 'club-logo-${club.id}',
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF71C2E4),
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: getCachedNetworkImageProvider(
                          imageUrl: club.logoUrl,
                          imageType: ImageType.club,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // Club name
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    club.name,
                    style: const TextStyle(
                      color: Color(0xFF61E7FF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // View button
              Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17323D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF71C2E4).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Club',
                        style: TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFAEE7FF),
                        size: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}