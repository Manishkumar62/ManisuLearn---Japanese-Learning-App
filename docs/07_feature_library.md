# Library Feature

## Purpose
Display all learning content

## UI

- List view
- Filter chips:
  - Words
  - Sentences
  - Stories

## Features

- Search within library
- Filter by:
  - Learned
  - Not learned
  - Needs revision

## BLoC

Events:
- LoadLibrary
- FilterLibrary

State:
- List<LearningItem>

## Interaction

- Tap item → open detail / learn