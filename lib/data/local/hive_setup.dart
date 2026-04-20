import 'package:hive_flutter/hive_flutter.dart';

import '../models/learning_item.dart';
import '../models/learning_item_adapter.dart';
import 'hive_boxes.dart';

class HiveSetup {
  const HiveSetup._();

  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(LearningItem.typeId)) {
      Hive.registerAdapter(LearningItemAdapter());
    }

    await Hive.openBox<LearningItem>(HiveBoxes.learningItems);
  }
}
