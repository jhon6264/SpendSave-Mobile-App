// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_envelope.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomEnvelopeAdapter extends TypeAdapter<CustomEnvelope> {
  @override
  final int typeId = 1;

  @override
  CustomEnvelope read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomEnvelope(
      id: fields[0] as String?,
      name: fields[1] as String,
      iconCode: fields[2] as String,
      colorIndex: fields[3] as int,
      percentage: fields[4] as double,
      allocatedAmount: fields[5] as double,
      remainingAmount: fields[6] as double,
      dailyBudget: fields[7] as double,
      startDate: fields[8] as DateTime?,
      endDate: fields[9] as DateTime?,
      isActive: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CustomEnvelope obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCode)
      ..writeByte(3)
      ..write(obj.colorIndex)
      ..writeByte(4)
      ..write(obj.percentage)
      ..writeByte(5)
      ..write(obj.allocatedAmount)
      ..writeByte(6)
      ..write(obj.remainingAmount)
      ..writeByte(7)
      ..write(obj.dailyBudget)
      ..writeByte(8)
      ..write(obj.startDate)
      ..writeByte(9)
      ..write(obj.endDate)
      ..writeByte(10)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomEnvelopeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
