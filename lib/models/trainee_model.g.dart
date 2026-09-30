// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainee_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TraineeAdapter extends TypeAdapter<Trainee> {
  @override
  final int typeId = 0;

  @override
  Trainee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Trainee(
      id: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String?,
      subscriptionDate: fields[3] as DateTime,
      isPaid: fields[4] as bool,
      notes: fields[8] as String?,
      imagePath: fields[9] as String?,
    )
      .._subscriptionTypeId = fields[5] as String?
      .._subscriptionDurationMonths = fields[6] as int?
      .._joinDate = fields[7] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, Trainee obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.subscriptionDate)
      ..writeByte(4)
      ..write(obj.isPaid)
      ..writeByte(5)
      ..write(obj._subscriptionTypeId)
      ..writeByte(6)
      ..write(obj._subscriptionDurationMonths)
      ..writeByte(7)
      ..write(obj._joinDate)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TraineeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
