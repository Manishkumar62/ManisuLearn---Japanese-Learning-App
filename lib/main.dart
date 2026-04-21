import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'core/services/json_loader.dart';
import 'data/local/hive_boxes.dart';
import 'data/local/hive_setup.dart';
import 'data/models/learning_item.dart';
import 'data/repositories/hive_learning_item_repository.dart';
import 'features/library/presentation/bloc/library_bloc.dart';
import 'features/library/presentation/pages/library_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveSetup.initialize();
  final box = Hive.box<LearningItem>(HiveBoxes.learningItems);

  if (box.isEmpty) {
    final items = await JsonLoader.loadItems();

    for (var item in items) {
      box.put(item.id, item);
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<HiveLearningItemRepository>(
      create: (BuildContext context) => HiveLearningItemRepository(),
      child: BlocProvider<LibraryBloc>(
        create: (BuildContext context) =>
            LibraryBloc(repository: context.read<HiveLearningItemRepository>()),
        child: MaterialApp(
          title: 'Manisu Learn',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
          ),
          home: const LibraryPage(),
        ),
      ),
    );
  }
}
