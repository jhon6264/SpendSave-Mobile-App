// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_period.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetPeriodAdapter extends TypeAdapter<BudgetPeriod> {
  @override
  final int typeId = 2;

  @override
  BudgetPeriod read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetPeriod(
      id: fields[0] as String?,
      totalAmount: fields[1] as double,
      startDate: fields[2] as DateTime,
      endDate: fields[3] as DateTime,
      isActive: fields[5] as bool,
    )..durationDays = fields[4] as int;
  }

  @override
  void write(BinaryWriter writer, BudgetPeriod obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.totalAmount)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.durationDays)
      ..writeByte(5)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
