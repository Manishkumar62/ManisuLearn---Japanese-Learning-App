import '../../data/models/learning_item.dart';

class SpacedRepetitionService {
  static const double defaultEaseFactor = 2.5;
  static const double minimumEaseFactor = 1.3;
  static const int defaultPassingQuality = 4;

  LearningItem review(
    LearningItem item, {
    int quality = defaultPassingQuality,
    DateTime? reviewedAt,
  }) {
    final normalizedQuality = quality.clamp(0, 5).toInt();
    final reviewDate = reviewedAt ?? DateTime.now();

    item
      ..lastReviewed = reviewDate
      ..revisionCount += 1;

    if (normalizedQuality < 3) {
      item
        ..repetitions = 0
        ..interval = 1
        ..nextReview = _nextReviewDate(reviewDate, 1);
      return item;
    }

    final nextRepetitions = item.repetitions + 1;
    final nextEaseFactor = _calculateEaseFactor(
      item.easeFactor,
      normalizedQuality,
    );
    final nextInterval = _calculateInterval(
      repetitions: nextRepetitions,
      previousInterval: item.interval,
      easeFactor: nextEaseFactor,
    );

    item
      ..isLearned = true
      ..easeFactor = nextEaseFactor
      ..interval = nextInterval
      ..repetitions = nextRepetitions
      ..nextReview = _nextReviewDate(reviewDate, nextInterval);

    return item;
  }

  List<LearningItem> dueItems(
    Iterable<LearningItem> items, {
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();
    final due = items
        .where((LearningItem item) => !item.nextReview.isAfter(currentDate))
        .toList(growable: false);

    return due..sort(compareReviewPriority);
  }

  int compareReviewPriority(LearningItem a, LearningItem b) {
    final nextReviewCompare = a.nextReview.compareTo(b.nextReview);
    if (nextReviewCompare != 0) {
      return nextReviewCompare;
    }

    final easeFactorCompare = a.easeFactor.compareTo(b.easeFactor);
    if (easeFactorCompare != 0) {
      return easeFactorCompare;
    }

    return a.revisionCount.compareTo(b.revisionCount);
  }

  double _calculateEaseFactor(double currentEaseFactor, int quality) {
    final qualityPenalty = 5 - quality;
    final nextEaseFactor =
        currentEaseFactor +
        0.1 -
        (qualityPenalty * (0.08 + qualityPenalty * 0.02));

    if (nextEaseFactor < minimumEaseFactor) {
      return minimumEaseFactor;
    }

    return nextEaseFactor;
  }

  int _calculateInterval({
    required int repetitions,
    required int previousInterval,
    required double easeFactor,
  }) {
    if (repetitions <= 1) {
      return 1;
    }

    if (repetitions == 2) {
      return 6;
    }

    final interval = previousInterval <= 0 ? 6 : previousInterval;
    return (interval * easeFactor).round();
  }

  DateTime _nextReviewDate(DateTime reviewedAt, int interval) {
    return reviewedAt.add(Duration(days: interval));
  }
}
