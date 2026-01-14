// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingGoalAdapter extends TypeAdapter<SavingGoal> {
  @override
  final int typeId = 5;

  @override
  SavingGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingGoal(
      id: fields[0] as String?,
      name: fields[1] as String,
      iconCode: fields[2] as String,
      colorIndex: fields[3] as int,
      targetAmount: fields[4] as double,
      currentAmount: fields[5] as double,
      description: fields[6] as String?,
      targetDate: fields[7] as DateTime?,
      createdAt: fields[8] as DateTime?,
      isActive: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SavingGoal obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCode)
      ..writeByte(3)
      ..write(obj.colorIndex)
      ..writeByte(4)
      ..write(obj.targetAmount)
      ..writeByte(5)
      ..write(obj.currentAmount)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.targetDate)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
