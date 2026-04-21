import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'core/navigation/app_shell.dart';
import 'core/services/json_loader.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_boxes.dart';
import 'data/local/hive_setup.dart';
import 'data/models/learning_item.dart';
import 'data/repositories/hive_learning_item_repository.dart';
import 'features/learn/presentation/bloc/learn_bloc.dart';
import 'features/library/presentation/bloc/library_bloc.dart';
import 'features/revision/presentation/bloc/review_queue_bloc.dart';
import 'features/revision/presentation/bloc/revision_bloc.dart';
import 'features/search/presentation/bloc/search_bloc.dart';

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
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<LibraryBloc>(
            create: (BuildContext context) => LibraryBloc(
              repository: context.read<HiveLearningItemRepository>(),
            ),
          ),
          BlocProvider<LearnBloc>(
            create: (BuildContext context) => LearnBloc(
              repository: context.read<HiveLearningItemRepository>(),
            ),
          ),
          BlocProvider<RevisionBloc>(
            create: (BuildContext context) => RevisionBloc(
              repository: context.read<HiveLearningItemRepository>(),
            ),
          ),
          BlocProvider<ReviewQueueBloc>(
            create: (BuildContext context) => ReviewQueueBloc(
              repository: context.read<HiveLearningItemRepository>(),
            ),
          ),
          BlocProvider<SearchBloc>(
            create: (BuildContext context) => SearchBloc(
              repository: context.read<HiveLearningItemRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Manisu Learn',
          debugShowCheckedModeBanner : false,
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: const AppShell(),
        ),
      ),
    );
  }
}
