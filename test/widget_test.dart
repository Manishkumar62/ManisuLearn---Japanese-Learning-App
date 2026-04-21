import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:manisulearn/data/local/hive_boxes.dart';
import 'package:manisulearn/data/models/learning_item.dart';
import 'package:manisulearn/data/models/learning_item_adapter.dart';
import 'package:manisulearn/main.dart';

void main() {
  late Directory hiveDirectory;

  setUp(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('manisulearn_test_');
    Hive.init(hiveDirectory.path);

    if (!Hive.isAdapterRegistered(LearningItem.typeId)) {
      Hive.registerAdapter(LearningItemAdapter());
    }

    await Hive.openBox<LearningItem>(HiveBoxes.learningItems);
  });

  tearDown(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  testWidgets('Navigation shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Manisu Learn'), findsOneWidget);
    expect(find.text('Library'), findsWidgets);
    expect(find.text('Learn'), findsWidgets);
    expect(find.text('Revision'), findsWidgets);
    expect(find.text('Search'), findsOneWidget);
    expect(find.byTooltip('Add data'), findsOneWidget);
  });
}
