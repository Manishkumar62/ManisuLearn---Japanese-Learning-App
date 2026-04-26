# Library Feature

## Purpose
Browse and filter all learning content by type and tags.

## Content Types
- Hiragana
- Katakana
- Kanji
- Words
- Sentences
- Dialogues
- Grammar

## UI

- List/grid view of items
- Filter chips by type
- Tag-based filtering
- Learned / not learned toggle

## Features

- Filter by type (word, sentence, etc.)
- Filter by tags (greeting, anime, routine, etc.)
- Filter by learning status
- Search within library

## BLoC

Events:
- LoadLibrary
- FilterLibrary(type, tags, learnedStatus)

State:
- List<LearningItem> with active filters

## Interaction

- Tap item → open detail / learn view