import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/hive_learning_item_repository.dart';
import '../../../add_data/presentation/bloc/add_data_bloc.dart';
import '../../../add_data/presentation/pages/add_data_page.dart';
import '../../../learn/presentation/bloc/learn_bloc.dart';
import '../../../learn/presentation/pages/learn_page.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../widgets/library_item_tile.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController _searchController = TextEditingController();

  LibraryTypeFilter _typeFilter = LibraryTypeFilter.all;
  LibraryProgressFilter _progressFilter = LibraryProgressFilter.all;

  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(const LoadLibrary());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<LibraryBloc>().add(
      FilterLibrary(
        searchQuery: _searchController.text,
        typeFilter: _typeFilter,
        progressFilter: _progressFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add data',
            onPressed: () => _openAddDataPage(context),
            icon: const Icon(Icons.add),
          ),
          TextButton(
            onPressed: () => _openLearnPage(context),
            child: const Text('Learn'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Search Japanese, romaji, Hindi, or English',
                  prefixIcon: Icon(Icons.search),
                ),
                textInputAction: TextInputAction.search,
                onChanged: (_) => _applyFilters(),
              ),
            ),
            _FilterSection(
              typeFilter: _typeFilter,
              progressFilter: _progressFilter,
              onTypeChanged: (LibraryTypeFilter filter) {
                setState(() => _typeFilter = filter);
                _applyFilters();
              },
              onProgressChanged: (LibraryProgressFilter filter) {
                setState(() => _progressFilter = filter);
                _applyFilters();
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<LibraryBloc, LibraryState>(
                builder: (BuildContext context, LibraryState state) {
                  return switch (state) {
                    LibraryInitial() || LibraryLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    LibraryLoaded(:final items) =>
                      items.isEmpty
                          ? const _EmptyLibraryMessage()
                          : RefreshIndicator(
                              onRefresh: () async {
                                context.read<LibraryBloc>().add(
                                  const LoadLibrary(),
                                );
                              },
                              child: ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: items.length,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(height: 10),
                                itemBuilder: (BuildContext context, int index) {
                                  return LibraryItemTile(
                                    item: items[index],
                                    onTap: () => _openLearnPage(context),
                                  );
                                },
                              ),
                            ),
                    LibraryError(:final message) => _LibraryErrorMessage(
                      message: message,
                    ),
                    LibraryState() => const _EmptyLibraryMessage(),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddDataPage(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (BuildContext routeContext) {
              return BlocProvider<AddDataBloc>(
                create: (_) => AddDataBloc(
                  repository: context.read<HiveLearningItemRepository>(),
                ),
                child: const AddDataPage(),
              );
            },
          ),
        )
        .then((_) {
          if (context.mounted) {
            context.read<LibraryBloc>().add(const LoadLibrary());
          }
        });
  }

  void _openLearnPage(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (BuildContext routeContext) {
              return BlocProvider<LearnBloc>(
                create: (_) => LearnBloc(
                  repository: context.read<HiveLearningItemRepository>(),
                ),
                child: const LearnPage(),
              );
            },
          ),
        )
        .then((_) {
          if (context.mounted) {
            context.read<LibraryBloc>().add(const LoadLibrary());
          }
        });
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.typeFilter,
    required this.progressFilter,
    required this.onTypeChanged,
    required this.onProgressChanged,
  });

  final LibraryTypeFilter typeFilter;
  final LibraryProgressFilter progressFilter;
  final ValueChanged<LibraryTypeFilter> onTypeChanged;
  final ValueChanged<LibraryProgressFilter> onProgressChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Content type', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilterChip(
                label: const Text('All'),
                selected: typeFilter == LibraryTypeFilter.all,
                onSelected: (_) => onTypeChanged(LibraryTypeFilter.all),
              ),
              FilterChip(
                label: const Text('Words'),
                selected: typeFilter == LibraryTypeFilter.words,
                onSelected: (_) => onTypeChanged(LibraryTypeFilter.words),
              ),
              FilterChip(
                label: const Text('Sentences'),
                selected: typeFilter == LibraryTypeFilter.sentences,
                onSelected: (_) => onTypeChanged(LibraryTypeFilter.sentences),
              ),
              FilterChip(
                label: const Text('Stories'),
                selected: typeFilter == LibraryTypeFilter.stories,
                onSelected: (_) => onTypeChanged(LibraryTypeFilter.stories),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Progress', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilterChip(
                label: const Text('All'),
                selected: progressFilter == LibraryProgressFilter.all,
                onSelected: (_) => onProgressChanged(LibraryProgressFilter.all),
              ),
              FilterChip(
                label: const Text('Learned'),
                selected: progressFilter == LibraryProgressFilter.learned,
                onSelected: (_) =>
                    onProgressChanged(LibraryProgressFilter.learned),
              ),
              FilterChip(
                label: const Text('Not learned'),
                selected: progressFilter == LibraryProgressFilter.notLearned,
                onSelected: (_) =>
                    onProgressChanged(LibraryProgressFilter.notLearned),
              ),
              FilterChip(
                label: const Text('Needs revision'),
                selected: progressFilter == LibraryProgressFilter.needsRevision,
                onSelected: (_) =>
                    onProgressChanged(LibraryProgressFilter.needsRevision),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyLibraryMessage extends StatelessWidget {
  const _EmptyLibraryMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('No learning items found.', textAlign: TextAlign.center),
      ),
    );
  }
}

class _LibraryErrorMessage extends StatelessWidget {
  const _LibraryErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.read<LibraryBloc>().add(const LoadLibrary());
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
