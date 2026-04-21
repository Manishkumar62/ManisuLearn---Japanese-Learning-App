
# Daily Review Queue

## Purpose
Show only items that need revision today

## Logic

Filter:

nextReview <= now

## Output

List<LearningItem> dueItems

## BLoC

Events:
- LoadDueItems

States:
- DueItemsLoaded

## UI

- Show count: "You have X items to review"
- Button: Start Review

## Priority Sorting

Sort by:
1. Oldest nextReview
2. Lowest easeFactor
3. Lowest revisionCount

## Notes

- This is the main entry point for daily usage