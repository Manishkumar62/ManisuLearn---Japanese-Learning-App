import 'package:hive/hive.dart';

@HiveType(typeId: LearningItem.typeId)
class LearningItem extends HiveObject {
  static const int typeId = 0;

  LearningItem({
    required this.id,
    required this.type,
    required this.japanese,
    required this.romaji,
    required this.hindi,
    required this.english,
    this.isLearned = false,
    this.revisionCount = 0,
    DateTime? lastReviewed,
    DateTime? createdAt,
    this.difficulty = 0,
    List<String>? tags,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    DateTime? nextReview,
  }) : lastReviewed = lastReviewed ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       tags = tags ?? <String>[],
       nextReview = nextReview ?? DateTime.now();

  @HiveField(0)
  String id;

  @HiveField(1)
  String type;

  @HiveField(2)
  String japanese;

  @HiveField(3)
  String romaji;

  @HiveField(4)
  String hindi;

  @HiveField(5)
  String english;

  @HiveField(6)
  bool isLearned;

  @HiveField(7)
  int revisionCount;

  @HiveField(8)
  DateTime lastReviewed;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  double difficulty;

  @HiveField(11)
  List<String> tags;

  @HiveField(12)
  double easeFactor;

  @HiveField(13)
  int interval;

  @HiveField(14)
  int repetitions;

  @HiveField(15)
  DateTime nextReview;
}
