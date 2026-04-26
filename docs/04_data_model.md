# Data Model

## LearningItem

Single model for all content types. Stored in Hive with type ID 0.

### Types (`ItemType` enum)
- `hiragana`
- `katakana`
- `kanji`
- `word`
- `sentence`
- `dialogue`
- `grammar`
- `story`

### Fields

```dart
@HiveField(0)  String id;            // e.g. "word_1", "sentence_15"
@HiveField(1)  String type;          // matches ItemType values
@HiveField(2)  String japanese;
@HiveField(3)  String romaji;
@HiveField(4)  String hindi;
@HiveField(5)  String english;
@HiveField(6)  bool isLearned;       // default: false
@HiveField(7)  int revisionCount;    // default: 0
@HiveField(8)  DateTime? lastReviewed;
@HiveField(9)  DateTime createdAt;   // default: DateTime.now()
@HiveField(10) double difficulty;    // default: 0
@HiveField(11) List<String> tags;    // e.g. ["greeting", "anime"]
@HiveField(12) double easeFactor;    // SM-2, default: 2.5
@HiveField(13) int interval;         // SM-2, in days, default: 0
@HiveField(14) int repetitions;      // SM-2, default: 0
@HiveField(15) DateTime nextReview;  // default: 1 year from now
@HiveField(16) DateTime? firstLearnedAt;
```

## JSON Format (input files)

```json
{
  "type": "word",
  "japanese": "こんにちは",
  "romaji": "konnichiwa",
  "hindi": "नमस्ते",
  "english": "hello",
  "tags": ["greeting"],
  "id": "word_2"
}
```

## ID Convention
- Format: `{type}_{number}` (e.g. `word_1`, `sentence_42`, `hiragana_あ`)
- IDs must be sequential with no gaps within each JSON file
