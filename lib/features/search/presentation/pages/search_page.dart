import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../library/presentation/widgets/library_item_tile.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Search anything',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (String value) {
                  context.read<SearchBloc>().add(QueryChanged(value));
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (BuildContext context, SearchState state) {
                  return switch (state) {
                    SearchInitial() => const _SearchHint(),
                    SearchLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    SearchResults(:final query, :final items) =>
                      query.trim().isEmpty
                          ? const _SearchHint()
                          : items.isEmpty
                          ? const _NoSearchResults()
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: items.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const SizedBox(height: 10),
                              itemBuilder: (BuildContext context, int index) {
                                return LibraryItemTile(item: items[index]);
                              },
                            ),
                    SearchError(:final message) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(message, textAlign: TextAlign.center),
                      ),
                    ),
                    SearchState() => const _SearchHint(),
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

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Search Japanese, romaji, Hindi, English, tags, or status.',
        ),
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('No matching items found.'),
      ),
    );
  }
}
