import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_save/utils/app_theme.dart';
import 'package:spend_save/widgets/glass_card.dart';
import 'package:spend_save/models/activity.dart';
import 'package:spend_save/services/hive_service.dart';
import 'package:spend_save/widgets/animated_background.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Activity> _activities = [];
  DateTimeFilter _selectedFilter = DateTimeFilter.all;
  bool _isLoading = true;
  
  // Expanded states
  final Map<String, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() {
      _activities = HiveService.getFilteredActivities(_selectedFilter);
      _isLoading = false;
    });
  }

  void _toggleExpand(String activityId) {
    setState(() {
      _expandedStates[activityId] = !(_expandedStates[activityId] ?? false);
    });
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  IconData _getIconFromCode(String code) {
    try {
      final codePoint = int.tryParse(code);
      return codePoint != null 
          ? IconData(
              codePoint, 
              fontFamily: 'FontAwesomeSolid',
              fontPackage: 'font_awesome_flutter',
            )
          : FontAwesomeIcons.moneyBill;
    } catch (e) {
      return FontAwesomeIcons.moneyBill;
    }
  }

  String _getFilterText(DateTimeFilter filter) {
    switch (filter) {
      case DateTimeFilter.today:
        return 'Today';
      case DateTimeFilter.last7Days:
        return 'Last 7 Days';
      case DateTimeFilter.thisMonth:
        return 'This Month';
      case DateTimeFilter.lastMonth:
        return 'Last Month';
      case DateTimeFilter.all:
        return 'All Time';
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: AnimatedBackground(
      child: SafeArea(
        child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'History',
                        style: AppTheme.headline3,
                      ),
                    ),
                    // Filter Dropdown
                    _buildFilterDropdown(),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _activities.isEmpty
                        ? _buildEmptyState()
                        : _buildActivitiesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 20),
          Text('Loading history...', style: AppTheme.bodyText1),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.history,
              size: 60,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 25),
            Text(
              'No Activity Yet',
              style: AppTheme.headline3,
            ),
            const SizedBox(height: 10),
            Text(
              'Create envelopes to see activity history',
              style: AppTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DateTimeFilter>(
          value: _selectedFilter,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          dropdownColor: const Color(0xFF203A43),
          style: AppTheme.bodyText1.copyWith(fontSize: 14),
          onChanged: (DateTimeFilter? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFilter = newValue;
                _isLoading = true;
              });
              _loadData();
            }
          },
          items: DateTimeFilter.values.map((DateTimeFilter filter) {
            return DropdownMenuItem<DateTimeFilter>(
              value: filter,
              child: Text(_getFilterText(filter)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivitiesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        final isExpanded = _expandedStates[activity.id] ?? false;
        final shouldShowExpand = activity.isCollapsible;
        
        return GestureDetector(
          onTap: shouldShowExpand ? () => _toggleExpand(activity.id) : null,
          child: GlassCard(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Colored Dot
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 4, right: 12),
                        decoration: BoxDecoration(
                          color: _getColorFromHex(activity.colorHex),
                          shape: BoxShape.circle,
                        ),
                      ),
                      
                      // Title and Time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    activity.title,
                                    style: AppTheme.bodyText1.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  activity.timeAgo,
                                  style: AppTheme.captionText.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Expand hint (only for collapsible)
                            if (shouldShowExpand && !isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Tap to expand...',
                                  style: AppTheme.captionText.copyWith(
                                    color: Colors.white60,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Expanded Content (for multiple envelopes)
                  if (isExpanded && activity.isCollapsible)
                    Padding(
                      padding: const EdgeInsets.only(top: 12, left: 24),
                      child: Column(
                        children: activity.envelopeNames.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final name = entry.value;
                          final iconCode = activity.envelopeIcons[idx];
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white70,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                FaIcon(
                                  _getIconFromCode(iconCode),
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: AppTheme.bodyText2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}