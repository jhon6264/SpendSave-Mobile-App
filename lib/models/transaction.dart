import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 3)
class Transaction {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String envelopeId; // Reference to envelope
  
  @HiveField(2)
  final String? savingGoalId; // Null if not a saving transaction
  
  @HiveField(3)
  final double amount;
  
  @HiveField(4)
  final String note;
  
  @HiveField(5)
  final DateTime date;
  
  @HiveField(6)
  final TransactionType type;

  Transaction({
    required this.amount,
    required this.note,
    required this.date,
    required this.type,
    this.envelopeId = '',
    this.savingGoalId,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Factory for spending transaction
  factory Transaction.spending({
    required double amount,
    required String envelopeId,
    required String note,
    DateTime? date,
  }) {
    return Transaction(
      amount: amount,
      note: note,
      date: date ?? DateTime.now(),
      type: TransactionType.spending,
      envelopeId: envelopeId,
    );
  }

  // Factory for saving transaction
  factory Transaction.saving({
    required double amount,
    required String savingGoalId,
    required String note,
    DateTime? date,
  }) {
    return Transaction(
      amount: amount,
      note: note,
      date: date ?? DateTime.now(),
      type: TransactionType.saving,
      savingGoalId: savingGoalId,
    );
  }
}

@HiveType(typeId: 4)
enum TransactionType {
  @HiveField(0)
  spending,
  
  @HiveField(1)
  saving,
  
  @HiveField(2)
  withdrawal, // From savings
}