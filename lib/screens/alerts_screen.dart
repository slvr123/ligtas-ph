import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/services/alert_service.dart';
import 'package:disaster_awareness_app/widgets/disaster_alert_card.dart';
import 'package:disaster_awareness_app/widgets/screen_header.dart';

class AlertsScreen extends StatefulWidget {
  final String location;
  const AlertsScreen({super.key, required this.location});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertService _alertService = AlertService();
  late Stream<List<Alert>> _alertStream;
  bool _isLoading = true;
  String _filterLevel = 'ALL'; // ALL, SEVERE, MODERATE, WARNING
  DateTime _lastUpdated = DateTime.now();

  @override
  void initState() {
    super.initState();
    _alertStream = _alertService.streamAlertsForLocation(widget.location);
  }

  void _refreshAlerts() {
    setState(() {
      _alertStream = _alertService.streamAlertsForLocation(widget.location);
      _lastUpdated = DateTime.now();
    });
  }

  Color _getAlertColor(String level) {
    switch (level.toUpperCase()) {
      case 'SEVERE':
        return Colors.red.shade700;
      case 'MODERATE':
        return Colors.orange.shade700;
      case 'WARNING':
        return Colors.amber.shade700;
      case 'INFO':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'typhoon':
        return '🌪️';
      case 'earthquake':
        return '🏚️';
      case 'flood':
        return '🌊';
      case 'fire':
        return '🔥';
      case 'rainfall':
        return '🌧️';
      case 'landslide':
        return '⛰️';
      case 'air quality':
        return '💨';
      case 'thunderstorm':
        return '⛈️';
      case 'strong winds':
        return '💨';
      default:
        return '⚠️';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated);

    if (difference.inSeconds < 60) {
      return 'Updated just now';
    } else if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes}m ago';
    } else {
      final hour = _lastUpdated.hour.toString().padLeft(2, '0');
      final minute = _lastUpdated.minute.toString().padLeft(2, '0');
      return 'Updated at $hour:$minute';
    }
  }

  Map<String, List<Alert>> _groupAlertsByType(List<Alert> alerts) {
    final grouped = <String, List<Alert>>{};
    for (var alert in alerts) {
      grouped.putIfAbsent(alert.type, () => []).add(alert);
    }
    return grouped;
  }

  List<Alert> _filterAlerts(List<Alert> alerts) {
    if (_filterLevel == 'ALL') return alerts;
    return alerts.where((a) => a.level == _filterLevel).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(title: 'Disaster Alerts', subtitle: widget.location),
          
          // Filter buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('ALL', 'All Alerts'),
                  const SizedBox(width: 8),
                  _buildFilterButton('SEVERE', 'Severe', Colors.red.shade700),
                  const SizedBox(width: 8),
                  _buildFilterButton('MODERATE', 'Moderate', Colors.orange.shade700),
                  const SizedBox(width: 8),
                  _buildFilterButton('WARNING', 'Warning', Colors.amber.shade700),
                ],
              ),
            ),
          ),

          // Last Updated Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatLastUpdated(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Alert>>(
              stream: _alertStream,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting && _isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading alerts...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            'Error loading alerts',
                            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _refreshAlerts,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFb91c1c),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                _isLoading = false;
                final allAlerts = snapshot.data ?? [];
                final filteredAlerts = _filterAlerts(allAlerts);
                final groupedAlerts = _groupAlertsByType(filteredAlerts);

                // No data - IMPROVED EMPTY STATE
                if (filteredAlerts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated checkmark
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green.withOpacity(0.2),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.5),
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.check_circle,
                              size: 60,
                              color: Colors.green.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'All Clear!',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _filterLevel != 'ALL'
                                ? 'No ${_filterLevel.toLowerCase()} alerts in your area'
                                : 'No active disaster alerts affecting ${widget.location} at the moment.',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Stay vigilant and check back regularly',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // Improved button
                          ElevatedButton.icon(
                            onPressed: _refreshAlerts,
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text(
                              'Refresh Alerts',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFea580c),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Last checked time
                          Text(
                            _formatLastUpdated(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshAlerts();
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      // Category summary
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Text(
                              'Total Alerts: ${filteredAlerts.length}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (filteredAlerts.isNotEmpty)
                              Expanded(
                                child: Text(
                                  'Categories: ${groupedAlerts.keys.length}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Group by disaster type
                      ...groupedAlerts.entries.map((entry) {
                        final disasterType = entry.key;
                        final typeAlerts = entry.value;
                        final icon = _getAlertIcon(disasterType);
                        final severeCount = typeAlerts.where((a) => a.level == 'SEVERE').length;
                        final moderateCount = typeAlerts.where((a) => a.level == 'MODERATE').length;
                        final warningCount = typeAlerts.where((a) => a.level == 'WARNING').length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category header
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF374151),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      icon,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            disasterType,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${typeAlerts.length} alert${typeAlerts.length != 1 ? 's' : ''}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Severity badges
                                    if (severeCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade700,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'S:$severeCount',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    if (moderateCount > 0) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade700,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'M:$moderateCount',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            // Individual alerts in category
                            ...typeAlerts.map((alert) {
                              final alertColor = _getAlertColor(alert.level);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  color: const Color(0xFF1f2937),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: alertColor, width: 2),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    alert.title,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _formatTime(alert.issuedTime),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white.withOpacity(0.6),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: alertColor,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                alert.level,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          alert.description,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (alert.affectedAreas.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 4,
                                            children: alert.affectedAreas
                                                .map(
                                                  (area) => Chip(
                                                    label: Text(
                                                      area,
                                                      style: const TextStyle(fontSize: 10),
                                                    ),
                                                    backgroundColor: Colors.grey.shade800,
                                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),

                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String level, String label, [Color? color]) {
    final isActive = _filterLevel == level;
    return FilterChip(
      label: Text(label),
      selected: isActive,
      backgroundColor: const Color(0xFF374151),
      selectedColor: color ?? Colors.blue.shade700,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : Colors.white70,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        setState(() {
          _filterLevel = level;
        });
      },
    );
  }
}