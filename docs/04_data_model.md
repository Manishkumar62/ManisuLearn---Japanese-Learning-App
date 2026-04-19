# Data Model

## LearningItem

Represents all types of content.

```dart
class LearningItem {
  String id;

  String type; // word | sentence | paragraph | story | song

  String japanese;
  String romaji;
  String hindi;
  String english;

  bool isLearned;

  int revisionCount;
  DateTime lastReviewed;
  DateTime createdAt;

  double difficulty;

  List<String> tags;
}