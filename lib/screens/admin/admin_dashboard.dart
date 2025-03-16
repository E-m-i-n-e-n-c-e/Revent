import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_manager/models/admin_log.dart';
import 'package:events_manager/providers/stream_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;
  bool _isCreatingDummyData = false;

  @override
  void initState() {
    super.initState();
    // Reset filter state when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminLogsSearchQueryProvider.notifier).state = '';
      ref.read(adminLogsCollectionFilterProvider.notifier).state = 'All';
      ref.read(adminLogsOperationFilterProvider.notifier).state = 'All';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _submitSearch() {
    _searchFocusNode.unfocus();
  }

  Future<void> _createDummyLogData() async {
    if (_isCreatingDummyData) return;

    setState(() {
      _isCreatingDummyData = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      // Create dummy log entries for different operations and collections
      final dummyLogs = [
        {
          'collection': 'events',
          'documentId': 'dummy-event-1',
          'operation': 'create_events',
          'timestamp': Timestamp.now(),
          'userId': user?.uid ?? 'system',
          'userEmail': user?.email ?? 'system',
          'beforeData': null,
          'afterData': {
            'title': 'Sample Event',
            'description': 'This is a sample event created for testing',
            'startTime': Timestamp.now(),
            'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 2))),
            'clubId': 'test-club',
          }
        },
        {
          'collection': 'announcements',
          'documentId': 'test-club',
          'operation': 'update_announcements',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
          'userId': user?.uid ?? 'system',
          'userEmail': user?.email ?? 'system',
          'beforeData': {
            'announcementsList': [
              {'title': 'Old Announcement', 'description': 'Old description'}
            ]
          },
          'afterData': {
            'announcementsList': [
              {'title': 'New Announcement', 'description': 'Updated description'}
            ]
          }
        },
        {
          'collection': 'clubs',
          'documentId': 'test-club',
          'operation': 'update_clubs',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
          'userId': user?.uid ?? 'system',
          'userEmail': user?.email ?? 'system',
          'beforeData': {
            'name': 'Test Club',
            'adminEmails': ['admin@example.com']
          },
          'afterData': {
            'name': 'Test Club',
            'adminEmails': ['admin@example.com', 'newadmin@example.com']
          }
        },
        {
          'collection': 'mapMarkers',
          'documentId': 'marker-1',
          'operation': 'delete_mapMarkers',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
          'userId': user?.uid ?? 'system',
          'userEmail': user?.email ?? 'system',
          'beforeData': {
            'title': 'Old Marker',
            'description': 'This marker was deleted',
            'latitude': 12.345,
            'longitude': 67.890
          },
          'afterData': null
        },
        {
          'collection': 'users',
          'documentId': user?.uid ?? 'dummy-user',
          'operation': 'update_users',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
          'userId': user?.uid ?? 'system',
          'userEmail': user?.email ?? 'system',
          'beforeData': {
            'name': 'Old Name',
            'photoURL': 'https://example.com/old.jpg'
          },
          'afterData': {
            'name': 'New Name',
            'photoURL': 'https://example.com/new.jpg'
          }
        }
      ];

      // Add dummy logs to Firestore
      for (final log in dummyLogs) {
        await firestore.collection('admin_logs').add(log);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dummy log data created successfully'),
            backgroundColor: Color(0xFF0E668A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating dummy data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isCreatingDummyData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = ref.watch(filteredAdminLogsProvider);
    final isUserAdmin = ref.watch(isUserAdminProvider);

    return PopScope(
      canPop: !_isSearchExpanded,
      onPopInvokedWithResult: (didPop, result) {
        if (_isSearchExpanded) {
          setState(() {
            _isSearchExpanded = false;
            _searchController.clear();
            ref.read(adminLogsSearchQueryProvider.notifier).state = '';
          });
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _isSearchExpanded
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFAEE7FF)),
                  onPressed: () {
                    setState(() {
                      _isSearchExpanded = false;
                      _searchController.clear();
                      ref.read(adminLogsSearchQueryProvider.notifier).state = '';
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFAEE7FF)),
                  onPressed: () => Navigator.pop(context),
                ),
          title: _isSearchExpanded
              ? TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: false,
                  style: const TextStyle(color: Color(0xFFAEE7FF)),
                  decoration: const InputDecoration(
                    hintText: 'Search logs...',
                    hintStyle: TextStyle(color: Color(0xFF83ACBD)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    ref.read(adminLogsSearchQueryProvider.notifier).state = value;
                  },
                  onSubmitted: (_) => _submitSearch(),
                )
              : const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFAEE7FF),
                  ),
                ),
          actions: [
            if (!_isSearchExpanded)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFFAEE7FF)),
                  onPressed: () {
                    setState(() {
                      _isSearchExpanded = true;
                    });
                    // Focus the search field when expanding
                    _searchFocusNode.requestFocus();
                  },
                ),
              ),
          ],
        ),
        body: !isUserAdmin
            ? _buildNotAdminView()
            : Container(
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
                      // Filter options
                      _buildFilterOptions(),

                      // Stats summary
                      _buildStatsSummary(),

                      // Logs list
                      Expanded(
                        child: filteredLogs.isEmpty
                            ? _buildEmptyState()
                            : _buildLogsList(filteredLogs),
                      ),
                    ],
                  ),
                ),
              ),
        floatingActionButton: isUserAdmin
            ? FloatingActionButton(
                onPressed: _isCreatingDummyData ? null : _createDummyLogData,
                backgroundColor: const Color(0xFF0E668A),
                child: _isCreatingDummyData
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Icon(Icons.add, color: Color(0xFFAEE7FF)),
              )
            : null,
      ),
    );
  }

  Widget _buildNotAdminView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF07181F), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                color: Color(0xFF83ACBD),
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Admin Access Required',
                style: TextStyle(
                  color: Color(0xFFAEE7FF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'You need to be an admin of at least one club to access the admin dashboard.',
                style: TextStyle(
                  color: Color(0xFF83ACBD),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E668A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', adminLogsCollectionFilterProvider),
                _buildFilterChip('events', adminLogsCollectionFilterProvider),
                _buildFilterChip('announcements', adminLogsCollectionFilterProvider),
                _buildFilterChip('clubs', adminLogsCollectionFilterProvider),
                _buildFilterChip('users', adminLogsCollectionFilterProvider),
                _buildFilterChip('mapMarkers', adminLogsCollectionFilterProvider),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', adminLogsOperationFilterProvider),
                _buildFilterChip('Create', adminLogsOperationFilterProvider),
                _buildFilterChip('Update', adminLogsOperationFilterProvider),
                _buildFilterChip('Delete', adminLogsOperationFilterProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, StateProvider<String> provider) {
    final selectedValue = ref.watch(provider);
    final isSelected = selectedValue == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFAEE7FF) : const Color(0xFF83ACBD),
            fontSize: 12,
          ),
        ),
        backgroundColor: const Color(0xFF0F2026),
        selectedColor: const Color(0xFF17323D),
        checkmarkColor: const Color(0xFFAEE7FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? const Color(0xFF71C2E4) : const Color(0xFF17323D),
          ),
        ),
        onSelected: (selected) {
          ref.read(provider.notifier).state = selected ? label : 'All';
        },
      ),
    );
  }

  Widget _buildStatsSummary() {
    final logs = ref.watch(adminLogsStreamProvider).value ?? [];

    // Calculate stats
    final totalLogs = logs.length;
    final createCount = logs.where((log) => log.operation.startsWith('create_')).length;
    final updateCount = logs.where((log) => log.operation.startsWith('update_')).length;
    final deleteCount = logs.where((log) => log.operation.startsWith('delete_')).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2026),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF17323D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Summary',
            style: TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(totalLogs, 'Total Logs', FontAwesomeIcons.listUl),
              _buildStatItem(createCount, 'Created', FontAwesomeIcons.plus, color: Colors.green),
              _buildStatItem(updateCount, 'Updated', FontAwesomeIcons.pen, color: Colors.blue),
              _buildStatItem(deleteCount, 'Deleted', FontAwesomeIcons.trash, color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(int count, String label, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? const Color(0xFF83ACBD),
          size: 18,
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF83ACBD),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
            'No logs found',
            style: TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Try selecting a different filter'
                : 'Try a different search term',
            style: const TextStyle(
              color: Color(0xFF83ACBD),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isCreatingDummyData ? null : _createDummyLogData,
            icon: const Icon(Icons.add),
            label: const Text('Create Sample Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E668A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(List<AdminLog> logs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogCard(log);
      },
    );
  }

  Widget _buildLogCard(AdminLog log) {
    // Determine operation color
    Color operationColor;
    IconData operationIcon;

    if (log.operation.startsWith('create_')) {
      operationColor = Colors.green;
      operationIcon = FontAwesomeIcons.plus;
    } else if (log.operation.startsWith('update_')) {
      operationColor = Colors.blue;
      operationIcon = FontAwesomeIcons.pen;
    } else if (log.operation.startsWith('delete_')) {
      operationColor = Colors.red;
      operationIcon = FontAwesomeIcons.trash;
    } else {
      operationColor = Colors.grey;
      operationIcon = FontAwesomeIcons.question;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF0F2027),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF17323D), width: 1),
      ),
      elevation: 4,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          backgroundColor: operationColor.withValues(alpha:0.2),
          child: Icon(operationIcon, color: operationColor, size: 16),
        ),
        title: Text(
          log.changeDescription,
          style: const TextStyle(
            color: Color(0xFFAEE7FF),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.solidClock,
                  color: const Color(0xFF83ACBD),
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy • h:mm a').format(log.timestamp),
                  style: const TextStyle(
                    color: Color(0xFF83ACBD),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.solidUser,
                  color: const Color(0xFF83ACBD),
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  log.userEmail,
                  style: const TextStyle(
                    color: Color(0xFF83ACBD),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          const Divider(color: Color(0xFF17323D)),
          if (log.beforeData != null || log.afterData != null)
            _buildDataComparisonTable(log),
        ],
      ),
    );
  }

  Widget _buildDataComparisonTable(AdminLog log) {
    final changedFields = log.getChangedFields();

    if (log.operation.startsWith('create_')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Created Data:',
            style: TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildDataTable(log.afterData),
        ],
      );
    } else if (log.operation.startsWith('delete_')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deleted Data:',
            style: TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildDataTable(log.beforeData),
        ],
      );
    } else if (log.operation.startsWith('update_')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Changed Fields:',
            style: TextStyle(
              color: Color(0xFFAEE7FF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            border: TableBorder.all(
              color: const Color(0xFF17323D),
              width: 1,
            ),
            children: [
              const TableRow(
                decoration: BoxDecoration(
                  color: Color(0xFF17323D),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Field',
                      style: TextStyle(
                        color: Color(0xFFAEE7FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Before',
                      style: TextStyle(
                        color: Color(0xFFAEE7FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'After',
                      style: TextStyle(
                        color: Color(0xFFAEE7FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              ...changedFields.map((field) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        field,
                        style: const TextStyle(
                          color: Color(0xFFAEE7FF),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _formatFieldValue(log.beforeData?[field]),
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _formatFieldValue(log.afterData?[field]),
                        style: const TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDataTable(Map<String, dynamic>? data) {
    if (data == null) {
      return const Text(
        'No data available',
        style: TextStyle(
          color: Color(0xFF83ACBD),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
      },
      border: TableBorder.all(
        color: const Color(0xFF17323D),
        width: 1,
      ),
      children: [
        const TableRow(
          decoration: BoxDecoration(
            color: Color(0xFF17323D),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Field',
                style: TextStyle(
                  color: Color(0xFFAEE7FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Value',
                style: TextStyle(
                  color: Color(0xFFAEE7FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        ...data.entries.map((entry) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    color: Color(0xFFAEE7FF),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _formatFieldValue(entry.value),
                  style: const TextStyle(
                    color: Color(0xFFAEE7FF),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  String _formatFieldValue(dynamic value) {
    if (value == null) {
      return 'null';
    } else if (value is Timestamp) {
      return DateFormat('MMM d, yyyy • h:mm a').format(value.toDate());
    } else if (value is List) {
      if (value.isEmpty) {
        return '[]';
      }
      return '[${value.take(3).join(', ')}${value.length > 3 ? ', ...' : ''}]';
    } else if (value is Map) {
      if (value.isEmpty) {
        return '{}';
      }
      return '{${value.keys.take(3).join(', ')}${value.length > 3 ? ', ...' : ''}}';
    } else {
      return value.toString();
    }
  }
}