// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingsActivityAdapter extends TypeAdapter<SavingsActivity> {
  @override
  final int typeId = 9;

  @override
  SavingsActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingsActivity(
      id: fields[0] as String?,
      type: fields[1] as SavingsActivityType,
      goalName: fields[2] as String,
      goalIcon: fields[3] as String,
      timestamp: fields[4] as DateTime,
      goalId: fields[5] as String,
      amount: fields[6] as double?,
      currentAmount: fields[7] as double?,
      targetAmount: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, SavingsActivity obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.goalName)
      ..writeByte(3)
      ..write(obj.goalIcon)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.goalId)
      ..writeByte(6)
      ..write(obj.amount)
      ..writeByte(7)
      ..write(obj.currentAmount)
      ..writeByte(8)
      ..write(obj.targetAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SavingsActivityTypeAdapter extends TypeAdapter<SavingsActivityType> {
  @override
  final int typeId = 8;

  @override
  SavingsActivityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SavingsActivityType.goalAdded;
      case 1:
        return SavingsActivityType.goalEdited;
      case 2:
        return SavingsActivityType.goalDeleted;
      case 3:
        return SavingsActivityType.fundsAdded;
      case 4:
        return SavingsActivityType.fundsWithdrawn;
      default:
        return SavingsActivityType.goalAdded;
    }
  }

  @override
  void write(BinaryWriter writer, SavingsActivityType obj) {
    switch (obj) {
      case SavingsActivityType.goalAdded:
        writer.writeByte(0);
        break;
      case SavingsActivityType.goalEdited:
        writer.writeByte(1);
        break;
      case SavingsActivityType.goalDeleted:
        writer.writeByte(2);
        break;
      case SavingsActivityType.fundsAdded:
        writer.writeByte(3);
        break;
      case SavingsActivityType.fundsWithdrawn:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsActivityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
