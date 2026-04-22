import 'package:flutter/material.dart';

import '../../../../data/models/learning_item.dart';

class SearchResultTile extends StatelessWidget {
  final LearningItem item;
  final String query;

  const SearchResultTile({super.key, required this.item, required this.query});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _highlightText(context, item.japanese),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _highlightText(context, item.romaji),
          _highlightText(context, item.english),
          _highlightText(context, item.hindi),
        ],
      ),
    );
  }

  Widget _highlightText(BuildContext context, String text) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (query.isEmpty || !lowerText.contains(lowerQuery)) {
      return Text(text);
    }

    final start = lowerText.indexOf(lowerQuery);
    final end = start + query.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(
              backgroundColor: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
        style: DefaultTextStyle.of(context).style,
      ),
    );
  }
}
