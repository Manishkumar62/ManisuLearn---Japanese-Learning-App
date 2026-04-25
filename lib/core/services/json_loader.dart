import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/learning_item.dart';

class JsonLoader {
  static const List<String> _files = [
    'assets/data/words.json',
    'assets/data/sentences.json',
    'assets/data/grammers.json',
    'assets/data/dialogues.json',
  ];

  static Future<List<LearningItem>> loadItems() async {
    List<LearningItem> allItems = [];

    for (final file in _files) {
      final jsonString = await rootBundle.loadString(file);
      final List<dynamic> jsonData = json.decode(jsonString);

      final items = jsonData.map((item) {
        return LearningItem(
          id: item["id"],
          type: item["type"],
          japanese: item["japanese"],
          romaji: item["romaji"],
          hindi: item["hindi"],
          english: item["english"],
          isLearned: false,
          revisionCount: 0,
          lastReviewed: null,
          createdAt: DateTime.now(),
          difficulty: 0,
          tags: (item["tags"] as List?)?.cast<String>() ?? [],
        );
      }).toList();

      allItems.addAll(items);
    }

    return allItems;
  }
}