import '../../data/models/learning_item.dart';

abstract class LearningItemRepository {
  Future<void> addItem(LearningItem item);

  Future<void> updateItem(LearningItem item);

  Future<void> deleteItem(String id);

  Future<LearningItem?> getItem(String id);

  Future<List<LearningItem>> getAllItems();

  Future<List<LearningItem>> filterItems(bool Function(LearningItem item) test);
}
