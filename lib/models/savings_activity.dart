import 'package:hive/hive.dart';

part 'savings_activity.g.dart';

@HiveType(typeId: 8)  // NEW typeId (different from Activity's typeId 7)
enum SavingsActivityType {
  @HiveField(0)
  goalAdded,
  
  @HiveField(1)
  goalEdited,
  
  @HiveField(2)
  goalDeleted,
  
  @HiveField(3)
  fundsAdded,
  
  @HiveField(4)
  fundsWithdrawn,
}

@HiveType(typeId: 9)  // NEW typeId (different from Activity's typeId 7)
class SavingsActivity {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final SavingsActivityType type;
  
  @HiveField(2)
  final String goalName;
  
  @HiveField(3)
  final String goalIcon;
  
  @HiveField(4)
  final DateTime timestamp;
  
  @HiveField(5)
  final String goalId;
  
  @HiveField(6)  // For tracking amounts in funds activities
  final double? amount;
  
  @HiveField(7)  // For tracking current amount after transaction
  final double? currentAmount;
  
  @HiveField(8)  // For tracking target amount
  final double? targetAmount;

  SavingsActivity({
    String? id,
    required this.type,
    required this.goalName,
    required this.goalIcon,
    required this.timestamp,
    required this.goalId,
    this.amount,
    this.currentAmount,
    this.targetAmount,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Get activity title
  String get title {
    switch (type) {
      case SavingsActivityType.goalAdded:
        return 'Added $goalName Savings Goal';
      case SavingsActivityType.goalEdited:
        return 'Edited $goalName Savings Goal';
      case SavingsActivityType.goalDeleted:
        return 'Deleted $goalName Savings Goal';
      case SavingsActivityType.fundsAdded:
        return 'Added ₱${amount!.toStringAsFixed(2)} to $goalName';
      case SavingsActivityType.fundsWithdrawn:
        return 'Withdrew ₱${amount!.toStringAsFixed(2)} from $goalName';
    }
  }

  // Get color for activity type
  String get colorHex {
    switch (type) {
      case SavingsActivityType.goalAdded:
        return 'FF6A11CB'; // Purple
      case SavingsActivityType.goalEdited:
        return 'FFFFC107'; // Amber
      case SavingsActivityType.goalDeleted:
        return 'FFFF5722'; // Deep Orange
      case SavingsActivityType.fundsAdded:
        return 'FF00B09B'; // Teal Green
      case SavingsActivityType.fundsWithdrawn:
        return 'FF1E90FF'; // Blue
    }
  }

  // Get time ago text
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}