import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../widgets/library_item_tile.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, this.onLearnItem, this.onReviseItem});

  final void Function(String itemId)? onLearnItem;
  final void Function(String itemId)? onReviseItem;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _filterIconKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  LibraryTypeFilter _typeFilter = LibraryTypeFilter.all;
  LibraryProgressFilter _progressFilter = LibraryProgressFilter.all;
  int? _minDaysAgo;
  int? _maxRevisions;

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<LibraryBloc>().add(const LoadLibrary());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<LibraryBloc>().state;
      if (state is LibraryLoaded && state.hasMore) {
        context.read<LibraryBloc>().add(const LoadMoreLibrary());
      }
    }
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

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _applyFilters);
  }

  void _openAdvancedFilters(BuildContext context) async {
    final renderBox =
        _filterIconKey.currentContext?.findRenderObject() as RenderBox?;
    final screenSize = MediaQuery.sizeOf(context);

    final position = renderBox != null
        ? RelativeRect.fromSize(
            renderBox.localToGlobal(Offset.zero) & renderBox.size,
            screenSize,
          )
        : RelativeRect.fromLTRB(screenSize.width - 200, 80, 16, 0);

    await showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: StatefulBuilder(
            builder: (context, setStateSheet) {
              final theme = Theme.of(context);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Days learned",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _minDaysAgo == null ? "Any" : "$_minDaysAgo+",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: (_minDaysAgo ?? 0).toDouble(),
                    min: 0,
                    max: 7,
                    divisions: 3,
                    label: _minDaysAgo == null || _minDaysAgo == 0
                        ? "Any"
                        : "$_minDaysAgo+",
                    onChanged: (val) {
                      setState(() {
                        _minDaysAgo = val == 0 ? null : val.toInt();
                      });
                      setStateSheet(() {});
                    },
                  ),

                  Row(
                    children: [
                      Text(
                        "Max revisions",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _maxRevisions == null ? "Any" : "≤$_maxRevisions",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: (_maxRevisions ?? 0).toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 3,
                    label: _maxRevisions == null || _maxRevisions == 0
                        ? "Any"
                        : "≤$_maxRevisions",
                    onChanged: (val) {
                      setState(() {
                        _maxRevisions = val == 0 ? null : val.toInt();
                      });
                      setStateSheet(() {});
                    },
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _minDaysAgo = null;
                                _maxRevisions = null;
                              });
                              Navigator.pop(context);
                              _applyFilters();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text("Reset"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _applyFilters();
                            },
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.zero,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text("Apply"),
                          ),
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
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _FilterSection(
              controller: _searchController,
              typeFilter: _typeFilter,
              progressFilter: _progressFilter,
              filterIconKey: _filterIconKey,
              onTypeChanged: (filter) {
                setState(() => _typeFilter = filter);
                _applyFilters();
              },
              onProgressChanged: (filter) {
                setState(() => _progressFilter = filter);
                _applyFilters();
              },
              onSearchChanged: _onSearchChanged,
              onOpenAdvanced: () => _openAdvancedFilters(context),
            ),

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
                    LibraryLoaded(:final items, :final hasMore) =>
                      items.isEmpty
                          ? const _EmptyLibraryMessage()
                          : RefreshIndicator(
                              onRefresh: () async {
                                context.read<LibraryBloc>().add(
                                  const LoadLibrary(),
                                );
                              },
                              child: ListView.separated(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: items.length + (hasMore ? 1 : 0),
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(height: 10),
                                itemBuilder: (BuildContext context, int index) {
                                  if (index >= items.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return LibraryItemTile(
                                    item: items[index],
                                    onTap: () {
                                      final item = items[index];

                                      if (item.isLearned) {
                                        widget.onReviseItem?.call(item.id);
                                      } else {
                                        widget.onLearnItem?.call(item.id);
                                      }

                                      _applyFilters();
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
    this.filterIconKey,
  });

  final TextEditingController controller;
  final LibraryTypeFilter typeFilter;
  final LibraryProgressFilter progressFilter;
  final GlobalKey? filterIconKey;

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
                    key: filterIconKey,
                    icon: const Icon(Icons.tune),
                    onPressed: onOpenAdvanced,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
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
                "Dialogues",
                typeFilter == LibraryTypeFilter.dialogue,
                () => onTypeChanged(LibraryTypeFilter.dialogue),
              ),

              _chip(
                context,
                "Grammar",
                typeFilter == LibraryTypeFilter.grammar,
                () => onTypeChanged(LibraryTypeFilter.grammar),
              ),

              _chip(
                context,
                "Stories",
                typeFilter == LibraryTypeFilter.stories,
                () => onTypeChanged(LibraryTypeFilter.stories),
              ),

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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
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
