import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_save/utils/app_theme.dart';
import 'package:spend_save/widgets/glass_card.dart';
import 'package:spend_save/models/savings_activity.dart';
import 'package:spend_save/services/hive_service.dart';
import 'package:spend_save/widgets/animated_background.dart';

class SavingsHistoryScreen extends StatefulWidget {
  const SavingsHistoryScreen({super.key});

  @override
  State<SavingsHistoryScreen> createState() => _SavingsHistoryScreenState();
}

class _SavingsHistoryScreenState extends State<SavingsHistoryScreen> {
  List<SavingsActivity> _activities = [];
  DateTimeFilter _selectedFilter = DateTimeFilter.all;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() {
      _activities = HiveService.getFilteredSavingsActivities(_selectedFilter);
      _isLoading = false;
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
          : FontAwesomeIcons.piggyBank;
    } catch (e) {
      return FontAwesomeIcons.piggyBank;
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

  String _getActivitySubtitle(SavingsActivity activity) {
    switch (activity.type) {
      case SavingsActivityType.goalAdded:
        if (activity.targetAmount != null) {
          return 'Target: ₱${activity.targetAmount!.toStringAsFixed(2)}';
        }
        return 'Savings goal created';
      case SavingsActivityType.goalEdited:
        return 'Goal details updated';
      case SavingsActivityType.goalDeleted:
        return 'Goal removed';
      case SavingsActivityType.fundsAdded:
        return 'New balance: ₱${activity.currentAmount!.toStringAsFixed(2)}';
      case SavingsActivityType.fundsWithdrawn:
        return 'Remaining: ₱${activity.currentAmount!.toStringAsFixed(2)}';
    }
  }

  IconData _getActivityIcon(SavingsActivity activity) {
    switch (activity.type) {
      case SavingsActivityType.goalAdded:
        return Icons.add_circle_outline;
      case SavingsActivityType.goalEdited:
        return Icons.edit_outlined;
      case SavingsActivityType.goalDeleted:
        return Icons.delete_outline;
      case SavingsActivityType.fundsAdded:
        return Icons.arrow_circle_up;
      case SavingsActivityType.fundsWithdrawn:
        return Icons.arrow_circle_down;
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
                        'Savings History',
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
              'No Savings Activity',
              style: AppTheme.headline3,
            ),
            const SizedBox(height: 10),
            Text(
              'Add funds or create savings goals to see history',
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
        
        return GlassCard(
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
                    // Colored Dot with Icon
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: _getColorFromHex(activity.colorHex),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          _getActivityIcon(activity),
                          color: Colors.white,
                          size: 18,
                        ),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity.title,
                                      style: AppTheme.bodyText1.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getActivitySubtitle(activity),
                                      style: AppTheme.captionText.copyWith(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
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
                          
                          // Goal Icon and Name
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              FaIcon(
                                _getIconFromCode(activity.goalIcon),
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  activity.goalName,
                                  style: AppTheme.bodyText2.copyWith(
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          // Amount for funds transactions
                          if (activity.amount != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: activity.type == SavingsActivityType.fundsAdded
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    activity.type == SavingsActivityType.fundsAdded
                                        ? Icons.add
                                        : Icons.remove,
                                    size: 12,
                                    color: activity.type == SavingsActivityType.fundsAdded
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '₱${activity.amount!.toStringAsFixed(2)}',
                                    style: AppTheme.captionText.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: activity.type == SavingsActivityType.fundsAdded
                                          ? Colors.green
                                          : Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}