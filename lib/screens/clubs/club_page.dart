import 'package:events_manager/utils/firedata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:events_manager/models/club.dart';
import 'package:events_manager/models/event.dart';
import 'package:events_manager/models/announcement.dart';
import 'package:events_manager/providers/stream_providers.dart' as providers;
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class ClubPage extends ConsumerStatefulWidget {
  final Club club;

  const ClubPage({super.key, required this.club});

  @override
  ConsumerState<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends ConsumerState<ClubPage> {
  String _selectedTab = 'EVENTS';
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 140 && !_isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = true);
    } else if (_scrollController.offset <= 140 && _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    // Ensure URL has a scheme
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() => _isUploading = true);

        final file = File(pickedFile.path);
        final fileExt = pickedFile.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        // Upload to Supabase
        final supabase = Supabase.instance.client;
        await supabase.storage
            .from('assets')
            .upload('clubs/${widget.club.id}/$fileName', file);

        final imageUrl = supabase.storage
            .from('assets')
            .getPublicUrl('clubs/${widget.club.id}/$fileName');

        // Update club in Firestore
        await updateClubBackground(widget.club.id, imageUrl);

        setState(() => _isUploading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Background image updated successfully')),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }

  List<Event> _getUpcomingEvents(List<Event> events) {
    final now = DateTime.now();
    return events.where((event) => event.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Event> _getPastEvents(List<Event> events) {
    final now = DateTime.now();
    return events.where((event) => event.startTime.isBefore(now)).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  List<Announcement> _getRecentAnnouncements(List<Announcement> announcements) {
    return announcements
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(providers.eventsStreamProvider);
    final announcements = ref.watch(providers.announcementsStreamProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _isHeaderCollapsed ? const Color(0xFF06222F) : Colors.transparent,
        elevation: _isHeaderCollapsed ? 4 : 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFAEE7FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isHeaderCollapsed
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(widget.club.logoUrl),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.club.name,
                    style: const TextStyle(
                      color: Color(0xFFAEE7FF),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFAEE7FF)),
            onPressed: _isUploading ? null : _pickAndUploadImage,
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
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xFF06222F),
                      image: DecorationImage(
                        image: NetworkImage(
                          widget.club.backgroundImageUrl.isNotEmpty
                              ? widget.club.backgroundImageUrl
                              : widget.club.logoUrl,
                        ),
                        fit: BoxFit.cover,
                        opacity: 0.3,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF07181F).withValues(alpha:0.8),
                              ],
                            ),
                          ),
                        ),
                        if (_isUploading)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAEE7FF)),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Uploading image...',
                                    style: TextStyle(
                                      color: Color(0xFFAEE7FF),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 27,
                    right: 27,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF71C2E4),
                                  width: 2,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(widget.club.logoUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.club.name,
                                    style: const TextStyle(
                                      color: Color(0xFF61E7FF),
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildMetricItem(
                                        FontAwesomeIcons.users,
                                        '1.2K',
                                        'Members',
                                      ),
                                      const SizedBox(width: 16),
                                      _buildMetricItem(
                                        FontAwesomeIcons.calendar,
                                        '24',
                                        'Events',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialButton(
                          FontAwesomeIcons.discord,
                          'DISCORD',
                          onTap: () {},
                        ),
                        _buildSocialButton(
                          FontAwesomeIcons.whatsapp,
                          'WHATSAPP',
                          onTap: () {},
                        ),
                        _buildSocialButton(
                          FontAwesomeIcons.link,
                          'LINKTREE',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTabButton('EVENTS'),
                          _buildTabButton('ANNOUNCEMENTS'),
                          _buildTabButton('ABOUT'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedTab == 'EVENTS') ...[
                      events.when(
                        data: (eventsList) {
                          final clubEvents = eventsList
                              .where((event) => event.clubId == widget.club.id)
                              .toList();
                          final upcomingEvents = _getUpcomingEvents(clubEvents);
                          final pastEvents = _getPastEvents(clubEvents);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (upcomingEvents.isNotEmpty) ...[
                                _buildSectionHeader('Upcoming Events', upcomingEvents.length),
                                const SizedBox(height: 10),
                                ...upcomingEvents.map((event) => _buildEventCard(event)),
                                const SizedBox(height: 20),
                              ],
                              if (pastEvents.isNotEmpty) ...[
                                _buildSectionHeader('Past Events', pastEvents.length),
                                const SizedBox(height: 10),
                                ...pastEvents.map((event) => _buildEventCard(event)),
                              ],
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Text('Error loading events: $error',
                              style: const TextStyle(color: Colors.red)),
                        ),
                      ),
                    ] else if (_selectedTab == 'ANNOUNCEMENTS') ...[
                      announcements.when(
                        data: (announcementsList) {
                          final clubAnnouncements = announcementsList
                              .where((announcement) => announcement.clubId == widget.club.id)
                              .toList();
                          final recentAnnouncements = _getRecentAnnouncements(clubAnnouncements);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Announcements', recentAnnouncements.length),
                              const SizedBox(height: 10),
                              ...recentAnnouncements.map((announcement) => _buildAnnouncementCard(announcement)),
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Text('Error loading announcements: $error',
                              style: const TextStyle(color: Colors.red)),
                        ),
                      ),
                    ] else if (_selectedTab == 'ABOUT') ...[
                      _buildSectionHeader('About Us', null),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2026),
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 5.1,
                              offset: Offset(0, 2),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to our club!',
                              style: TextStyle(
                                color: Color(0xFFAEE7FF),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'We\'re a group of students passionate about organizing events, workshops, and discussions. Join us to grow your skills and connect with others in the community.',
                              style: TextStyle(
                                color: Color(0xFFAEE7FF),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFFAEE7FF),
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFAEE7FF).withValues(alpha:0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int? count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF17323D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Color(0xFFAEE7FF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF17323D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF71C2E4).withValues(alpha:0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFFAEE7FF),
              size: 14,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFFAEE7FF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text) {
    final isSelected = _selectedTab == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF17323D) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF71C2E4) : const Color(0xFF71C2E4).withValues(alpha:0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? const Color(0xFFAEE7FF) : const Color(0xFFAEE7FF).withValues(alpha:0.7),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final formattedDate = DateFormat('MMM d, y').format(event.startTime);
    final formattedTime = DateFormat('h:mm a').format(event.startTime);
    final bool isPastEvent = DateTime.now().isAfter(event.endTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2026),
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 5.1,
            offset: Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF17323D),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFAEE7FF),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Color(0xFFAEE7FF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF17323D),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Color(0xFFAEE7FF),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        color: Color(0xFFAEE7FF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isPastEvent && event.feedbackLink != null)
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF0E668A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () => _launchUrl(event.feedbackLink!),
                  child: const Text(
                    'FEEDBACK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else if (!isPastEvent && event.registrationLink != null)
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF0E668A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () => _launchUrl(event.registrationLink!),
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    final formattedDate = DateFormat('MMM d, y').format(announcement.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2026),
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 5.1,
            offset: Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            announcement.title,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            announcement.subtitle,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            announcement.description,
            style: const TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF17323D),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFAEE7FF),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Color(0xFFAEE7FF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (announcement.venue.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17323D),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFAEE7FF),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        announcement.venue,
                        style: const TextStyle(
                          color: Color(0xFFAEE7FF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
