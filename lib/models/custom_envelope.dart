import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart'; // Add this at top

part 'custom_envelope.g.dart';

@HiveType(typeId: 1)
class CustomEnvelope {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String iconCode; // FontAwesome icon code
  
  @HiveField(3)
  int colorIndex; // 0=Purple, 1=Blue, 2=Green, etc.
  
  @HiveField(4)
  double percentage; // 0.0 to 100.0
  
  @HiveField(5)
  double allocatedAmount;
  
  @HiveField(6)
  double remainingAmount;
  
  @HiveField(7)
  double dailyBudget;
  
  @HiveField(8)
  DateTime? startDate;
  
  @HiveField(9)
  DateTime? endDate;
  
  @HiveField(10)
  bool isActive;

  CustomEnvelope({
    String? id,
    required this.name,
    required this.iconCode,
    required this.colorIndex,
    this.percentage = 0.0,
    this.allocatedAmount = 0.0,
    this.remainingAmount = 0.0,
    this.dailyBudget = 0.0,
    this.startDate,
    this.endDate,
    this.isActive = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Get color gradient based on index
  List<Color> get colorGradient {
  if (colorIndex >= 0 && colorIndex < AppTheme.envelopeColorOptions.length) {
    return AppTheme.envelopeColorOptions[colorIndex];
  }
  return AppTheme.envelopeColorOptions[0]; // Default to first color
}

  // Get linear gradient
  LinearGradient get gradient {
    return LinearGradient(
      colors: colorGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Calculate daily budget
  void calculateDailyBudget() {
    if (startDate != null && endDate != null && remainingAmount > 0) {
      final days = endDate!.difference(startDate!).inDays + 1;
      dailyBudget = remainingAmount / days;
    } else {
      dailyBudget = 0.0;
    }
  }

  // Update with budget info
  void updateWithBudget({
    required double totalBudget,
    required DateTime start,
    required DateTime end,
  }) {
    allocatedAmount = totalBudget * (percentage / 100);
    remainingAmount = allocatedAmount;
    startDate = start;
    endDate = end;
    calculateDailyBudget();
    isActive = true;
  }

  // Get days left
  int get daysLeft {
    if (endDate == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inDays + 1;
  }

  // Spend from envelope
  bool spend(double amount) {
    if (remainingAmount >= amount) {
      remainingAmount -= amount;
      calculateDailyBudget();
      return true;
    }
    return false;
  }
}