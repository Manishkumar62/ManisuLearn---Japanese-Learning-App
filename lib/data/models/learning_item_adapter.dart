import 'package:hive/hive.dart';

import 'learning_item.dart';

class LearningItemAdapter extends TypeAdapter<LearningItem> {
  @override
  final int typeId = LearningItem.typeId;

  @override
  LearningItem read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return LearningItem(
      id: fields[0] as String,
      type: fields[1] as String,
      japanese: fields[2] as String,
      romaji: fields[3] as String,
      hindi: fields[4] as String,
      english: fields[5] as String,
      isLearned: fields[6] as bool? ?? false,
      revisionCount: fields[7] as int? ?? 0,
      lastReviewed: fields[8] as DateTime?,
      createdAt: fields[9] as DateTime?,
      difficulty: (fields[10] as num?)?.toDouble() ?? 0,
      tags: (fields[11] as List?)?.cast<String>() ?? <String>[],
    );
  }

  @override
  void write(BinaryWriter writer, LearningItem obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.japanese)
      ..writeByte(3)
      ..write(obj.romaji)
      ..writeByte(4)
      ..write(obj.hindi)
      ..writeByte(5)
      ..write(obj.english)
      ..writeByte(6)
      ..write(obj.isLearned)
      ..writeByte(7)
      ..write(obj.revisionCount)
      ..writeByte(8)
      ..write(obj.lastReviewed)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.difficulty)
      ..writeByte(11)
      ..write(obj.tags);
  }
}
