# Revision Feature

## Purpose
Reinforce memory

## UI

- Flashcards
- Mixed content

## Logic

- Only learned items
- Prioritize:
  - Low revision count
  - Old lastReviewed

## Tracking

- Increment revisionCount
- Update lastReviewed

## BLoC

Events:
- LoadRevisionItems
- ReviseItem