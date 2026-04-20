import 'package:hive/hive.dart';

import '../models/learning_item.dart';
import 'hive_boxes.dart';

class LearningItemLocalDataSource {
  LearningItemLocalDataSource({Box<LearningItem>? box})
    : _box = box ?? HiveBoxes.learningItemsBox;

  final Box<LearningItem> _box;

  Future<void> addItem(LearningItem item) {
    return _box.put(item.id, item);
  }

  Future<void> updateItem(LearningItem item) {
    return _box.put(item.id, item);
  }

  Future<void> deleteItem(String id) {
    return _box.delete(id);
  }

  LearningItem? getItem(String id) {
    return _box.get(id);
  }

  List<LearningItem> getAllItems() {
    return _box.values.toList(growable: false);
  }

  List<LearningItem> filterItems(bool Function(LearningItem item) test) {
    return _box.values.where(test).toList(growable: false);
  }
}
