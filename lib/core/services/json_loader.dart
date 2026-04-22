import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/learning_item.dart';

class JsonLoader {
  static Future<List<LearningItem>> loadItems() async {
    final jsonString = await rootBundle.loadString('assets/data.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.map((item) {
      return LearningItem(
        id: DateTime.now().millisecondsSinceEpoch.toString() + item["japanese"],
        type: item["type"],
        japanese: item["japanese"],
        romaji: item["romaji"],
        hindi: item["hindi"],
        english: item["english"],
        isLearned: false,
        revisionCount: 0,
        lastReviewed: DateTime.now(),
        createdAt: DateTime.now(),
        difficulty: 0,
        tags: (item["tags"] as List?)?.cast<String>() ?? [],
      );
    }).toList();
  }
}