import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manisulearn/features/learn/presentation/bloc/learn_bloc.dart';
import 'package:manisulearn/features/learn/presentation/bloc/learn_event.dart';
import 'package:manisulearn/features/revision/presentation/bloc/revision_bloc.dart';
import 'package:manisulearn/features/revision/presentation/bloc/revision_event.dart';

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
  int? _minDaysAgo;
  int? _maxRevisions;

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
        minDaysAgo: _minDaysAgo,
        maxRevisions: _maxRevisions,
      ),
    );
  }

  void _openAdvancedFilters(BuildContext context) async {
    final result = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 16, 0),
      items: [
        PopupMenuItem(
          enabled: false,
          child: StatefulBuilder(
            builder: (context, setStateSheet) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Advanced Filters"),

                  const SizedBox(height: 10),

                  DropdownButton<int?>(
                    value: _minDaysAgo,
                    hint: const Text("Days ago"),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: null, child: Text("Any")),
                      DropdownMenuItem(value: 1, child: Text("1+ days")),
                      DropdownMenuItem(value: 3, child: Text("3+ days")),
                      DropdownMenuItem(value: 7, child: Text("7+ days")),
                    ],
                    onChanged: (val) {
                      setState(() => _minDaysAgo = val);
                      setStateSheet(() {});
                    },
                  ),

                  const SizedBox(height: 8),

                  DropdownButton<int?>(
                    value: _maxRevisions,
                    hint: const Text("Max revisions"),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: null, child: Text("Any")),
                      DropdownMenuItem(value: 1, child: Text("≤ 1")),
                      DropdownMenuItem(value: 3, child: Text("≤ 3")),
                      DropdownMenuItem(value: 5, child: Text("≤ 5")),
                    ],
                    onChanged: (val) {
                      setState(() => _maxRevisions = val);
                      setStateSheet(() {});
                    },
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _minDaysAgo = null;
                              _maxRevisions = null;
                            });
                            Navigator.pop(context);
                            _applyFilters();
                          },
                          child: const Text("Reset"),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _applyFilters();
                          },
                          child: const Text("Apply"),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _FilterSection(
              controller: _searchController,
              typeFilter: _typeFilter,
              progressFilter: _progressFilter,
              onTypeChanged: (filter) {
                setState(() => _typeFilter = filter);
                _applyFilters();
              },
              onProgressChanged: (filter) {
                setState(() => _progressFilter = filter);
                _applyFilters();
              },
              onSearchChanged: (_) => _applyFilters(),
              onOpenAdvanced: () => _openAdvancedFilters(context),
            ),

            /// ✅ ADD HERE (NOT inside _FilterSection)
            if (_minDaysAgo != null ||
                _maxRevisions != null ||
                _typeFilter != LibraryTypeFilter.all ||
                _progressFilter != LibraryProgressFilter.all ||
                _searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Text("Filters applied"),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _minDaysAgo = null;
                          _maxRevisions = null;
                          _typeFilter = LibraryTypeFilter.all;
                          _progressFilter = LibraryProgressFilter.all;
                          _searchController.clear();
                        });
                        _applyFilters();
                      },
                      child: const Text("Reset all"),
                    ),
                  ],
                ),
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
                                    onTap: () async {
                                      final item = items[index];

                                      if (item.isLearned) {
                                        context.read<RevisionBloc>().add(
                                          MarkItemReviewed(item.id),
                                        );
                                      } else {
                                        context.read<LearnBloc>().add(
                                          MarkLearnedFromLibrary(item.id),
                                        );
                                      }

                                      /// 🔥 trigger re-filter (NOT LoadLibrary)
                                      context.read<LibraryBloc>().add(
                                        FilterLibrary(
                                          searchQuery: _searchController.text,
                                          typeFilter: _typeFilter,
                                          progressFilter: _progressFilter,
                                          minDaysAgo: _minDaysAgo,
                                          maxRevisions: _maxRevisions,
                                        ),
                                      );
                                    },
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
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.controller,
    required this.typeFilter,
    required this.progressFilter,
    required this.onTypeChanged,
    required this.onProgressChanged,
    required this.onSearchChanged,
    required this.onOpenAdvanced,
  });

  final TextEditingController controller;
  final LibraryTypeFilter typeFilter;
  final LibraryProgressFilter progressFilter;

  final ValueChanged<LibraryTypeFilter> onTypeChanged;
  final ValueChanged<LibraryProgressFilter> onProgressChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenAdvanced;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          /// 🔍 SEARCH
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: onOpenAdvanced,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// 🎛 FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip(
                  context,
                  "All",
                  typeFilter == LibraryTypeFilter.all,
                  () => onTypeChanged(LibraryTypeFilter.all),
                ),

                _chip(
                  context,
                  "Words",
                  typeFilter == LibraryTypeFilter.words,
                  () => onTypeChanged(LibraryTypeFilter.words),
                ),

                _chip(
                  context,
                  "Sentences",
                  typeFilter == LibraryTypeFilter.sentences,
                  () => onTypeChanged(LibraryTypeFilter.sentences),
                ),

                _chip(
                  context,
                  "Stories",
                  typeFilter == LibraryTypeFilter.stories,
                  () => onTypeChanged(LibraryTypeFilter.stories),
                ),

                const SizedBox(width: 16),

                _chip(
                  context,
                  "Learned",
                  progressFilter == LibraryProgressFilter.learned,
                  () => onProgressChanged(LibraryProgressFilter.learned),
                ),

                _chip(
                  context,
                  "New",
                  progressFilter == LibraryProgressFilter.notLearned,
                  () => onProgressChanged(LibraryProgressFilter.notLearned),
                ),

                _chip(
                  context,
                  "Revise",
                  progressFilter == LibraryProgressFilter.needsRevision,
                  () => onProgressChanged(LibraryProgressFilter.needsRevision),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary : Colors.white10,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(color: selected ? Colors.black : Colors.white70),
          ),
        ),
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
