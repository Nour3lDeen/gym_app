// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_type_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionTypeAdapter extends TypeAdapter<SubscriptionType> {
  @override
  final int typeId = 1;

  @override
  SubscriptionType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscriptionType(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as double,
      durationMonths: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SubscriptionType obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.durationMonths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
