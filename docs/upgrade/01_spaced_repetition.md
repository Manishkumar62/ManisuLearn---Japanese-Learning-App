# Spaced Repetition System (SM-2 Lite)

## Purpose
Improve long-term memory retention using scheduling.

## Model Updates

Add fields to LearningItem:

```dart
double easeFactor; // default: 2.5
int interval; // in days
int repetitions;
DateTime nextReview;