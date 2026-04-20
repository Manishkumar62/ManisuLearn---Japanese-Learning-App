import 'package:hive/hive.dart';

import '../models/learning_item.dart';

class HiveBoxes {
  static const String learningItems = 'learning_items';

  const HiveBoxes._();

  static Box<LearningItem> get learningItemsBox =>
      Hive.box<LearningItem>(learningItems);
}
