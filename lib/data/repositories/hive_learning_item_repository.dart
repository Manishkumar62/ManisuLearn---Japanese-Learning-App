import '../../domain/repositories/learning_item_repository.dart';
import '../local/learning_item_local_data_source.dart';
import '../models/learning_item.dart';

class HiveLearningItemRepository implements LearningItemRepository {
  HiveLearningItemRepository({LearningItemLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? LearningItemLocalDataSource();

  final LearningItemLocalDataSource _localDataSource;

  @override
  Future<void> addItem(LearningItem item) {
    return _localDataSource.addItem(item);
  }

  @override
  Future<void> updateItem(LearningItem item) {
    return _localDataSource.updateItem(item);
  }

  @override
  Future<void> deleteItem(String id) {
    return _localDataSource.deleteItem(id);
  }

  @override
  Future<LearningItem?> getItem(String id) async {
    return _localDataSource.getItem(id);
  }

  @override
  Future<List<LearningItem>> getAllItems() async {
    return _localDataSource.getAllItems();
  }

  @override
  Future<List<LearningItem>> filterItems(
    bool Function(LearningItem item) test,
  ) async {
    return _localDataSource.filterItems(test);
  }
}
