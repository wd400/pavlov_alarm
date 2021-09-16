// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmAdapter extends TypeAdapter<Alarm> {
  @override
  final int typeId = 1;

  @override
  Alarm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alarm(
      remarks: fields[0] as String?,
      date: fields[1] as DateTime,
      time: fields[2] as DateTime,
      password: fields[3] as String,
      notificationId: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Alarm obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.remarks)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.notificationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
