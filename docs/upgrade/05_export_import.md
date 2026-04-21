# Export & Import System

## Purpose
Data backup and portability

## Export

- Convert Hive data → JSON
- Save to file

## Import

- Load JSON
- Convert → LearningItem
- Insert into Hive

## JSON Format

```json
[
  {
    "type": "word",
    "japanese": "...",
    "romaji": "...",
    "hindi": "...",
    "english": "..."
  }
]