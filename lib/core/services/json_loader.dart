import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/learning_item.dart';

class JsonLoader {
  static const List<String> _files = [
    'assets/data/hiragana.json',
    'assets/data/katakana.json',
    'assets/data/kanji.json',
    'assets/data/words.json',
    'assets/data/sentences.json',
    'assets/data/grammars.json',
    'assets/data/dialogues.json',
  ];

  static Future<List<LearningItem>> loadItems() async {
    final jsonStrings = await Future.wait(
      _files.map((file) => rootBundle.loadString(file)),
    );

    return jsonStrings.expand((jsonString) {
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.map((item) {
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
      });
    }).toList();
  }
}