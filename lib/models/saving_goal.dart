import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'saving_goal.g.dart';

@HiveType(typeId: 5)
class SavingGoal {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String iconCode; // FontAwesome icon code
  
  @HiveField(3)
  int colorIndex; // 0-15 from AppTheme colors
  
  @HiveField(4)
  double targetAmount; // Can be 0 for no target
  
  @HiveField(5)
  double currentAmount;
  
  @HiveField(6)
  String? description;
  
  @HiveField(7)
  DateTime? targetDate;
  
  @HiveField(8)
  DateTime createdAt;
  
  @HiveField(9)
  bool isActive;

  SavingGoal({
    String? id,
    required this.name,
    required this.iconCode,
    required this.colorIndex,
    this.targetAmount = 0,
    this.currentAmount = 0,
    this.description,
    this.targetDate,
    DateTime? createdAt,
    this.isActive = true,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  // Get color gradient - This needs access to AppTheme from utils
  List<Color> get colorGradient {
    // Import AppTheme from utils in your main app file
    // For now, return a default gradient
    if (colorIndex >= 0 && colorIndex < _defaultColorOptions.length) {
      return _defaultColorOptions[colorIndex];
    }
    return _defaultColorOptions[0]; // Default purple
  }

  // Get progress percentage (0.0 to 1.0)
  double get progress {
    if (targetAmount <= 0) return 0;
    return currentAmount / targetAmount;
  }

  // Get progress as percentage string
  String get progressPercentage {
    return '${(progress * 100).toStringAsFixed(1)}%';
  }

  // Add funds
  void addFunds(double amount) {
    currentAmount += amount;
  }

  // Withdraw funds
  bool withdrawFunds(double amount) {
    if (currentAmount >= amount) {
      currentAmount -= amount;
      return true;
    }
    return false;
  }

  // Check if goal is reached
  bool get isReached {
    if (targetAmount <= 0) return false;
    return currentAmount >= targetAmount;
  }

  // Get amount left
  double get amountLeft {
    if (targetAmount <= 0) return 0;
    return targetAmount - currentAmount;
  }

  // Default color options (temporary - should use AppTheme from utils)
  static List<List<Color>> _defaultColorOptions = [
    [const Color(0xFF8A2BE2), const Color(0xFF4B0082)], // Purple
    [const Color(0xFF1E90FF), const Color(0xFF00BFFF)], // Blue
    [const Color(0xFF00B09B), const Color(0xFF96C93D)], // Green
    [const Color(0xFFFFA500), const Color(0xFFFF6347)], // Orange
    [const Color(0xFFFF69B4), const Color(0xFFDB7093)], // Pink
    [const Color(0xFFFF416C), const Color(0xFFFF4B2B)], // Red
    [const Color(0xFF11998E), const Color(0xFF38EF7D)], // Teal
    [const Color(0xFF6A11CB), const Color(0xFF2575FC)], // Royal
    [const Color(0xFF9C27B0), const Color(0xFF673AB7)], // Deep Purple
    [const Color(0xFF2196F3), const Color(0xFF03A9F4)], // Light Blue
    [const Color(0xFF4CAF50), const Color(0xFF8BC34A)], // Light Green
    [const Color(0xFFFFC107), const Color(0xFFFF9800)], // Amber
    [const Color(0xFFFF5722), const Color(0xFFE64A19)], // Deep Orange
    [const Color(0xFF795548), const Color(0xFF5D4037)], // Brown
    [const Color(0xFF607D8B), const Color(0xFF455A64)], // Blue Grey
    [const Color(0xFFE91E63), const Color(0xFFC2185B)], // Pink Dark
  ];
}