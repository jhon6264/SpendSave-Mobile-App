import 'package:hive/hive.dart';
import '../services/hive_service.dart';
part 'budget_period.g.dart';

@HiveType(typeId: 2)
class BudgetPeriod {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  double totalAmount;
  
  @HiveField(2)
  DateTime startDate;
  
  @HiveField(3)
  DateTime endDate;
  
  @HiveField(4)
  int durationDays;
  
  @HiveField(5)
  bool isActive;

  Future<void> save() async {
  final box = HiveService.budgetBox;
  final index = box.values.toList().indexWhere((b) => b.id == id);
  if (index != -1) {
    await box.putAt(index, this);
  }
}
  BudgetPeriod({
    String? id,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        durationDays = endDate.difference(startDate).inDays + 1;

  // Factory for creating with days
  factory BudgetPeriod.createWithDays({
    required double amount,
    required DateTime start,
    required int days,
  }) {
    final end = start.add(Duration(days: days - 1));
    return BudgetPeriod(
      totalAmount: amount,
      startDate: start,
      endDate: end,
    );
  }

  // Check if expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  // Days elapsed
  int get daysElapsed {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return durationDays;
    return now.difference(startDate).inDays + 1;
  }

  // Days left
  int get daysLeft {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays + 1;
  }
}