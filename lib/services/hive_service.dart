import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/custom_envelope.dart';
import '../models/budget_period.dart';
import '../models/transaction.dart';
import '../models/saving_goal.dart';
import '../models/activity.dart';
import '../models/savings_activity.dart';

class HiveService {
  static late Box settingsBox;
  static late Box<CustomEnvelope> envelopeBox;
  static late Box<BudgetPeriod> budgetBox;
  static late Box<Transaction> transactionBox;
  static late Box<SavingGoal> savingsBox;
  static late Box<Activity> activityBox;
  static late Box<SavingsActivity> savingsActivityBox;

  static SavingGoal? getSavingsGoal(String id) {
  try {
    return savingsBox.values.firstWhere((goal) => goal.id == id);
  } catch (e) {
    return null;
  }
}

// Update savings goal
static Future<void> updateSavingsGoal(SavingGoal goal) async {
  final index = savingsBox.values.toList().indexWhere((g) => g.id == goal.id);
  if (index != -1) {
    await savingsBox.putAt(index, goal);
  }
}

// Add funds to savings goal
static Future<bool> addFundsToGoal(String goalId, double amount) async {
  try {
    final goal = getSavingsGoal(goalId);
    if (goal != null) {
      goal.addFunds(amount);
      await updateSavingsGoal(goal);
      return true;
    }
    return false;
  } catch (e) {
    print('Error adding funds: $e');
    return false;
  }
}

  static Future<void> logSavingsActivity(SavingsActivity activity) async {
  await savingsActivityBox.add(activity);
  print('📝 Savings Activity logged: ${activity.title}');
}

static List<SavingsActivity> getSavingsActivities() {
  return savingsActivityBox.values.toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
}

static List<SavingsActivity> getFilteredSavingsActivities(DateTimeFilter filter) {
  final activities = getSavingsActivities();
  final now = DateTime.now();
  
  switch (filter) {
    case DateTimeFilter.today:
      final today = DateTime(now.year, now.month, now.day);
      return activities.where((a) => a.timestamp.isAfter(today)).toList();
    
    case DateTimeFilter.last7Days:
      final weekAgo = now.subtract(const Duration(days: 7));
      return activities.where((a) => a.timestamp.isAfter(weekAgo)).toList();
    
    case DateTimeFilter.thisMonth:
      final firstDay = DateTime(now.year, now.month, 1);
      return activities.where((a) => a.timestamp.isAfter(firstDay)).toList();
    
    case DateTimeFilter.lastMonth:
      final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
      final lastDayLastMonth = DateTime(now.year, now.month, 0);
      return activities.where((a) => 
        a.timestamp.isAfter(firstDayLastMonth) && 
        a.timestamp.isBefore(lastDayLastMonth)
      ).toList();
    
    case DateTimeFilter.all:
    default:
      return activities;
  }
}

// Withdraw funds from savings goal
static Future<bool> withdrawFundsFromGoal(String goalId, double amount) async {
  try {
    final goal = getSavingsGoal(goalId);
    if (goal != null && goal.currentAmount >= amount) {
      final success = goal.withdrawFunds(amount);
      if (success) {
        await updateSavingsGoal(goal);
        return true;
      }
    }
    return false;
  } catch (e) {
    print('Error withdrawing funds: $e');
    return false;
  }
}

  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // Register adapters
    Hive.registerAdapter(CustomEnvelopeAdapter());
    Hive.registerAdapter(BudgetPeriodAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(SavingGoalAdapter());
    Hive.registerAdapter(ActivityAdapter());
    Hive.registerAdapter(ActivityTypeAdapter());
    Hive.registerAdapter(SavingsActivityAdapter());
    Hive.registerAdapter(SavingsActivityTypeAdapter());
    savingsActivityBox = await Hive.openBox<SavingsActivity>('savings_activities');

    // Open boxes
    settingsBox = await Hive.openBox('settings');
    envelopeBox = await Hive.openBox<CustomEnvelope>('envelopes');
    budgetBox = await Hive.openBox<BudgetPeriod>('budgets');
    transactionBox = await Hive.openBox<Transaction>('transactions');
    savingsBox = await Hive.openBox<SavingGoal>('savings');
    activityBox = await Hive.openBox<Activity>('activities');

    print('✅ Hive initialized with all boxes');
  }

  // === BUDGET METHODS ===
  static BudgetPeriod? getActiveBudget() {
    try {
      return budgetBox.values.firstWhere(
        (budget) => budget.isActive && !budget.isExpired,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveBudget(BudgetPeriod budget) async {
    final index = budgetBox.values.toList().indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      await budgetBox.putAt(index, budget);
    } else {
      await budgetBox.add(budget);
    }
  }

  // === ENVELOPE METHODS ===
  static List<CustomEnvelope> getActiveEnvelopes() {
    try {
      return envelopeBox.values.where((env) => env.isActive).toList();
    } catch (e) {
      return [];
    }
  }

  static List<CustomEnvelope> getAllEnvelopes() {
    return envelopeBox.values.toList();
  }

  static Future<void> saveEnvelope(CustomEnvelope envelope) async {
    final index = envelopeBox.values.toList().indexWhere((e) => e.id == envelope.id);
    if (index != -1) {
      await envelopeBox.putAt(index, envelope);
    } else {
      await envelopeBox.add(envelope);
    }
  }

  static Future<void> deleteEnvelope(String envelopeId) async {
    final index = envelopeBox.values.toList().indexWhere((e) => e.id == envelopeId);
    if (index != -1) {
      await envelopeBox.deleteAt(index);
    }
  }

  // === ACTIVITY METHODS ===
  static Future<void> logActivity(Activity activity) async {
    await activityBox.add(activity);
    print('📝 Activity logged: ${activity.title}');
  }

  static List<Activity> getActivities() {
    return activityBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static List<Activity> getFilteredActivities(DateTimeFilter filter) {
    final activities = getActivities();
    final now = DateTime.now();
    
    switch (filter) {
      case DateTimeFilter.today:
        final today = DateTime(now.year, now.month, now.day);
        return activities.where((a) => a.timestamp.isAfter(today)).toList();
      
      case DateTimeFilter.last7Days:
        final weekAgo = now.subtract(const Duration(days: 7));
        return activities.where((a) => a.timestamp.isAfter(weekAgo)).toList();
      
      case DateTimeFilter.thisMonth:
        final firstDay = DateTime(now.year, now.month, 1);
        return activities.where((a) => a.timestamp.isAfter(firstDay)).toList();
      
      case DateTimeFilter.lastMonth:
        final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayLastMonth = DateTime(now.year, now.month, 0);
        return activities.where((a) => 
          a.timestamp.isAfter(firstDayLastMonth) && 
          a.timestamp.isBefore(lastDayLastMonth)
        ).toList();
      
      case DateTimeFilter.all:
      default:
        return activities;
    }
  }

  // === CLEAR DATA ===
  static Future<void> clearAll() async {
    await envelopeBox.clear();
    await budgetBox.clear();
    await transactionBox.clear();
    await savingsBox.clear();
    await activityBox.clear();
    await settingsBox.clear();
  }
}



// Filter enum
enum DateTimeFilter {
  today,
  last7Days,
  thisMonth,
  lastMonth,
  all,
}